<figure>
<img src="architecture.svg" alt="FHIR2 layers: servlet, resource providers, services, translators and DAOs over the OpenMRS database, with Lab on FHIR calling the services in-process" style="max-width:100%"/>
<figcaption>FHIR2 layers and where Lab on FHIR plugs in.</figcaption>
</figure>


### How the three modules fit together

```
                  ┌─ OpenMRS / Bahmni (Tomcat) ────────────────────────────────────────────────────────────────┐
                  │                                                                                            │
                  │                                                                                            │
FHIR clients   ───┼────> /openmrs/ws/fhir2/R4 -> FhirRestServlet   (HAPI RestfulServer)                        │
(Bahmni apps,  ───┼────> /openmrs/ws/fhir2/R3 -> FhirR3RestServlet (STU3 <-> R4 conversion)                    │
 curl, OpenHIM,   │           │                                                                                │
 LIS, ...)        │           v                                                                                │
                  │      @R4Provider ResourceProviders  <-- Bahmni FHIR2 Addl Extension adds/overrides         │
                  │           │                                                                                │
                  │           v                                                                                │
                  │      Fhir*Service (interfaces)      <-- LabOnFHIR calls these in-process                   │
                  │           │                          (FhirTaskService, FhirObservationService,             │
                  │           v                           FhirDiagnosticReportService, ...)                    │
                  │      Translators   +   DAOs (Hibernate Criteria / SearchQuery)                             │
                  │           │                                                                                │
                  │           v                                                                                │
                  │      OpenMRS DB (patient, encounter, obs, orders, test_order, fhir_task, ...)              │
                  │                                                                                            │
                  │      LabOnFHIR: event listeners -> LabOrderHandler -> FHIR2 TaskService                    │
                  │                 scheduler tasks (FetchTaskUpdates / RetryFailedTasks)                      │
                  │                 HAPI IGenericClient ────────────┐                                          │
                  │                                                 │                                          │
                  │                                                 │                                          │
                  └─────────────────────────────────────────────────┼──────────────────────────────────────────┘
                                                                    │
                                                                    │ FHIR R4 (JSON)
                                                                    v
                                              ┌────────────────────────────────────────────┐
                                              │ LIS HAPI FHIR server (labonfhir.lisUrl)    │
                                              │ e.g. OpenELIS / DISA hapi-fhir-jpaserver   │
                                              └────────────────────────────────────────────┘
```

### FHIR2 module (1.9.0)

#### Packaging
```
fhir2-1.9.0-SNAPSHOT.omod
├── config.xml, liquibase.xml, moduleApplicationContext.xml, webModuleApplicationContext.xml
├── org/openmrs/module/fhir2/          (omod/web layer)
│   ├── web/servlet/FhirRestServlet          → R4 HAPI RestfulServer
│   ├── web/servlet/FhirR3RestServlet        → STU3 HAPI RestfulServer
│   ├── web/filter/ForwardingFilter          → maps /ws/fhir2/R4/* and /ws/fhir2/R3/* onto the servlets (/ms/fhir2Servlet…)
│   ├── web/filter/AuthenticationFilter      → HTTP Basic / OpenMRS session auth
│   ├── web/authentication/RequireAuthenticationInterceptor
│   ├── web/util/SummaryInterceptor, DisableCacheInterceptor, OpenmrsFhirAddressStrategy
│   └── narrative/OpenmrsThymeleafNarrativeGenerator (+ templates)
└── lib/
    ├── fhir2-api-1.9.0-SNAPSHOT.jar         → providers, services, translators, DAOs, search
    ├── fhir2-api-2.1 / 2.2 / 2.5 / 2.6      → version-conditional beans (@OpenmrsProfile)
    └── hapi-fhir-* 5.4.0, org.hl7.fhir.* 5.4.0, thymeleaf, jackson, guava, caffeine …
```

#### Layering (from the module README, confirmed against the jar's package layout)

| Layer | Package | Responsibility |
|---|---|---|
| **ResourceProvider** | `org.openmrs.module.fhir2.providers.r4` / `.r3` | HAPI `IResourceProvider`s annotated `@R4Provider` / `@R3Provider`. They parse HTTP and search params and delegate to Services. R3 providers convert R4↔STU3. |
| **Service** | `org.openmrs.module.fhir2.api` (+ `.impl`) | `FhirPatientService`, `FhirObservationService`, `FhirTaskService`… Business logic, coordinating Translator + DAO. Also usable from other modules. |
| **Translator** | `org.openmrs.module.fhir2.api.translators` (+ `.impl`) | OpenMRS object ⇄ FHIR resource mapping (`OpenmrsFhirUpdatableTranslator`). |
| **DAO** | `org.openmrs.module.fhir2.api.dao` (+ `.impl`) | Hibernate Criteria queries that implement FHIR search directly in SQL. This is the only layer that touches OpenMRS core services. |
| **Search** | `org.openmrs.module.fhir2.api.search` | `SearchParameterMap`, `SearchQuery`, `SearchQueryInclude` (for `_include`/`_revinclude`), paging bundle providers. |

#### Version-conditional jars
| Jar | Loaded when core ≥ | Adds |
|---|---|---|
| `fhir2-api-2.1` | 2.1 | Group via Cohort membership (`FhirCohortMembershipDao`, `GroupMemberTranslator`), Observation status/interpretation |
| `fhir2-api-2.2` | 2.2 | Condition backed by core `conditions` table (+ clinical/verification status), MedicationRequest status, 2.2-specific Encounter DAO, `_include` support (`SearchQueryInclude_2_2`) |
| `fhir2-api-2.5` | 2.5 | `Location.type` via location attribute |
| `fhir2-api-2.6` | 2.6 | **MedicationDispense** backed by core `medication_dispense` |

#### OpenMRS → FHIR resource mapping
| FHIR resource | OpenMRS source |
|---|---|
| Patient | `patient` + `person` + identifiers/names/addresses |
| Person | `person` |
| RelatedPerson | `relationship` |
| Practitioner | `provider` (and `users`) |
| Encounter | **both** `encounter` and `visit` (distinguished by `_tag`) |
| Observation | `obs` |
| Location | `location` (+ tags, hierarchy) |
| Condition | `conditions` (≥2.2) / `obs` |
| AllergyIntolerance | `allergy` |
| Medication | `drug` |
| MedicationRequest | `drug_order` |
| MedicationDispense | `medication_dispense` (≥2.6) |
| ServiceRequest | `test_order` (FHIR2). The Bahmni ext switches this to all non-drug `orders` |
| DiagnosticReport | `fhir_diagnostic_report` (FHIR2 table) |
| Task | `fhir_task` (FHIR2 table) |
| Group | `cohort` |
| ValueSet | `concept` sets |
| Immunization | `obs` groups in an immunization encounter |

### LabOnFHIR module (1.3.1)

#### Packaging (from the jar)
```
labonfhir-1.3.1-SNAPSHOT.omod
├── config.xml, liquibase.xml, moduleApplicationContext.xml
├── org/openmrs/module/labonfhir/web/resources/FailedTaskResource   → REST: /ws/rest/v1/failedtask
└── lib/labonfhir-api-1.3.1-SNAPSHOT.jar
    org/openmrs/module/labonfhir/
    ├── LabOnFhirActivator          started(): enable connector, register patient-identifier FHIR system
    ├── LabOnFhirConfig             reads global properties, builds SSL context (AuthType BASIC|SSL)
    ├── FhirConfig                  Spring @Bean IGenericClient → labonfhir.lisUrl (Basic auth interceptor or mTLS HttpClient)
    ├── api/
    │   ├── LabOrderManager         GlobalPropertyListener; subscribes/unsubscribes event listeners
    │   ├── LabOrderHandler         Order/Encounter → FHIR Task (stored via FhirTaskService)
    │   ├── event/
    │   │   ├── LabCreationListener      abstract JMS listener: createLabBundle(), sendTask()
    │   │   ├── OrderCreationListener    on Order CREATED
    │   │   └── EncounterCreationListener on Encounter CREATED
    │   ├── scheduler/
    │   │   ├── FetchTaskUpdates    pulls completed Tasks + results from LIS (“OpenELIS Pull Task”, 30 s)
    │   │   └── RetryFailedTasks    re-sends failed_task rows (3600 s)
    │   ├── service/LabOnFhirService(+Impl), dao/LabOnFhirDao
    │   ├── model/FailedTask (failed_task), TaskRequest (task_request)
    │   └── fhir/OrderCreationException
    └── sql/create_trigger.sql      orders (type 3) → test_order
```

#### Components and responsibilities

| Component | Key behaviour (from bytecode) |
|---|---|
| `LabOnFhirActivator.started()` | Autowires itself, gives the daemon token to `LabOrderManager`, calls `enableLisConnector()` if `isLisEnabled()` (i.e. `labonfhir.lisUrl` non-blank). Creates or updates a `FhirPatientIdentifierSystem` named **"OpenLIS ID System"** that maps identifier type `labonfhir.openmrsPatientIdentifier.uuid` → `labonfhir.lisIdentifierSystem.url`. |
| `LabOrderManager` | A `GlobalPropertyListener` for `labonfhir.lisUrl`: if the value is set it enables the connector, if blank it disables it. `enableLisConnector()` subscribes `OrderCreationListener` to `Event.subscribe(Order.class, CREATED)` **or** `EncounterCreationListener` to `(Encounter.class, CREATED)` depending on `labonfhir.labUpdateTriggerObject`. |
| `OrderCreationListener` | Reads `uuid` from the JMS `MapMessage`, loads the `Order`, calls `LabOrderHandler.createOrder(order)`, then `sendTask(task)`. Runs in a daemon thread. |
| `EncounterCreationListener` | Same, but for an `Encounter`, so one Task covers all orders in the encounter. |
| `LabOrderHandler.createOrder(Order)` | Applies the concept filter `labonfhir.orderTestUuids`, optionally adds encounter Obs as `Task.input` (type=obs.code, value=obs.value), builds a Task and **persists it locally through `FhirTaskService.create()`**. |
| `LabCreationListener.createLabBundle(Task)` | Uses FHIR2 `FhirTaskService.searchForTasks(_id=task, _include=Task:patient, Task:owner, Task:encounter, Task:based-on)` to gather resources, then adds Location, ServiceRequest supportingInfo Observations (with DISA codes) and DiagnosticReports, and wraps everything in a **transaction Bundle with PUT entries**. |
| `LabCreationListener.sendTask(Task)` | If `activateFhirPush` is on, sends `client.transaction().withBundle(bundle).execute()`. On exception it writes a `FailedTask(taskUuid, error, isSent=false)`. |
| `FetchTaskUpdates` | Polls the LIS and imports results (see [Lab Workflow](lab-workflow.html)). Stores the poll time in `task_request`. |
| `RetryFailedTasks` | For every `failed_task` row it re-reads the Task from FHIR2, rebuilds the bundle and re-POSTs the transaction. On success it sets `is_sent=true`. |
| `FailedTaskResource` | REST resource `v1/failedtask` (OpenMRS 2.*/3.*). Read-only: `GET` list/search (`?sent=true|false`), `GET /{uuid}`. Properties: `uuid`, `taskUuid`, `error`, `isSent`, `display`. Create, update and delete throw "Unimplemented". |

#### Outbound sequence (Order trigger)

```
Clinician saves lab order (Bahmni)
   │  orders row INSERT  ──(MySQL trigger, order_type_id=3)──► test_order row
   ▼
OpenMRS Event module (JMS topic "org.openmrs.Order" CREATED)
   ▼
OrderCreationListener.processMessage(uuid) [daemon thread]
   ▼
LabOrderHandler.createOrder(order)
   ├─ concept ∈ labonfhir.orderTestUuids ?  (else skip)
   ├─ Task{ status=requested, intent=order,
   │        basedOn=[ServiceRequest/<order.uuid>], for=Patient/<patient.uuid>,
   │        owner=Practitioner/<lisUserUuid>, encounter=Encounter/<enc.uuid>,
   │        requester=Practitioner/<first encounter provider>, input=[obs…]? }
   └─ FhirTaskService.create(task)  → fhir_task row
   ▼
LabCreationListener.sendTask(task)
   ├─ createLabBundle(task)  → Bundle(type=transaction, entry.request = PUT <Type>/<id>)
   └─ IGenericClient.transaction().withBundle(bundle).execute()  ──► POST {lisUrl}  (FHIR transaction)
         └─ on error → failed_task(task_uuid, error, is_sent=false) → RetryFailedTasks (hourly)
```

#### Inbound sequence (results)

```
Scheduler "OpenELIS Pull Task" (FetchTaskUpdates, every 30 s)
   ▼
GET {lisUrl}/Task?identifier=http://fhir.openmrs.org/ext/task/identifier|
                 &status=completed&_lastUpdated=ge<last poll>&_lastUpdated=le<now>   (+ follow "next" links)
   ▼  for each Task in the bundles
FhirTaskService.get(task.identifier[0].value)   → local OpenMRS Task
   ├─ copy status
   └─ for each output (DiagnosticReport reference):
        GET {lisUrl}/DiagnosticReport?_id=<id>&_include=DiagnosticReport:result&_include=DiagnosticReport:subject
        ├─ for each Observation: set encounter + basedOn → FhirObservationService.create()  → obs
        │     └─ if HIV VL (LOINC 20447-9 / DISA HIVVL-*), derive Lesotho VL obs
        │        (HIVTCVLReturnDate, HIVTCVLResult, HIVTCVLDATAAbnormal, HIVTCVL "<20" / ">=20" / "Undetectable")
        ├─ DiagnosticReport.result = new obs refs, encounter = task.encounter → FhirDiagnosticReportService.create()
        └─ task.addOutput(DiagnosticReport/<id>)
   ▼
FhirTaskService.update(task)  ;  task_request(request_date = now)
```

### Bahmni FHIR2 Additional Extension

```
api/src/main/java/org/bahmni/module/fhir2addlextension/
├── api/providers/      @R4Provider HAPI providers (new + subclasses of FHIR2 providers)
├── api/service(/impl)  Bahmni services (Appointment, EpisodeOfCare, DocumentReference, ImagingStudy,
│                       DiagnosticReport(+Bundle), ConsultationBundle, ServiceRequest, Condition, ValueSet …)
├── api/translator(/impl) OpenMRS ⇄ FHIR translators incl. extensions under http://fhir.bahmni.org/ext/…
├── api/dao(/impl)      Hibernate DAOs (ServiceRequest on `orders`, DocumentReference, ImagingStudy, …)
├── api/validators      Bundle/Encounter/ServiceRequest/DiagnosticReport validators
├── api/domain          ConsultationBundle, DiagnosticReportBundle (custom @ResourceDef Bundles)
├── advice/FhirEncounterSaveAdvice   AOP after-returning on FHIR encounter save → atom-feed "Encounter" event
├── interceptor/        FhirAuthExceptionHandlingInterceptor (registered on the FHIR server)
└── spring/             AOP + module configuration
```

The pattern is the same as FHIR2 (Provider → Service → Translator/DAO). New providers are registered in the
same HAPI server because they carry `@R4Provider`. Where a Bahmni provider **extends** a FHIR2 provider
(e.g. `BahmniServiceRequestFhirR4ResourceProvider extends ServiceRequestFhirResourceProvider`), its methods are added to or override
the FHIR2 handlers for that resource type (e.g. extra `@Search` signatures, `@Create` on MedicationRequest/ServiceRequest).
