These artifacts formalise this workflow: the [Lab Order Task](StructureDefinition-lab-order-task.html), [Lab Order ServiceRequest](StructureDefinition-lab-order-service-request.html), [Lab Order Transaction Bundle](StructureDefinition-lab-order-transaction-bundle.html), [Lab Result DiagnosticReport](StructureDefinition-lab-result-diagnostic-report.html) and [Lab Result Observation](StructureDefinition-lab-result-observation.html) profiles; the [Lab on FHIR client](CapabilityStatement-labonfhir-client.html) and [LIS server requirements](CapabilityStatement-lis-server-requirements.html) capability statements; and the worked example [transaction Bundle](Bundle-example-lab-order-bundle.html).

<figure>
<img src="lab-workflow.svg" alt="Lab on FHIR order and result flow between OpenMRS and the LIS" style="max-width:100%"/>
<figcaption>Orders go out as one transaction per Task; results come back through a 30-second poll.</figcaption>
</figure>


Everything here was read from the bytecode of `labonfhir-api-1.3.1-SNAPSHOT.jar`
(`LabOrderHandler`, `LabCreationListener`, `FetchTaskUpdates`, `RetryFailedTasks`, `FhirConfig`), then **checked against
the live instance on 2026-11-18** (84 Tasks, 85 ServiceRequests, 50 DiagnosticReports, their observations and the
`labonfhir.*` global properties). Where the live data differs from the code, the live behaviour is stated and marked
**Live:**. The instance runs a **customised FHIR2**, which changes what the ServiceRequest looks like.

### Connection

| Item | Value |
|---|---|
| Target | `labonfhir.lisUrl` (default `http://<lis-host>:<port>/fhir`; class constant fallback `https://testapi.openelisci.org:8444/hapi-fhir-jpaserver/fhir`) |
| Client | HAPI `IGenericClient` (FHIR R4, JSON) built in `FhirConfig.getFhirClient()` |
| Auth | `labonfhir.authType=Basic` → `BasicAuthInterceptor(userName, password)`; `SSL` → Apache HttpClient with keystore/truststore (mutual TLS) |
| Switches | `labonfhir.activateFhirPush` (must be `true` to send); connector is active only when `labonfhir.lisUrl` is non-blank |

#### Settings on this instance (2026-11-18)

| Global property | Value |
|---|---|
| `labonfhir.activateFhirPush` | `true` |
| `labonfhir.authType` | `Basic` (over plain `http://`; see [Findings](findings.html) S4) |
| `labonfhir.labUpdateTriggerObject` | `Order` |
| `labonfhir.addObsAsTaskInput` | `false` (so `Task.input` is never set) |
| `labonfhir.filterOrderBytestUuids` | `true` |
| `labonfhir.orderTestUuids` | `160046AAAA…` (CIEL), `165254AAAA…` (CIEL), `92d73e24-122e-4f3e-8447-fb972f01b617` (*HIVTC, Lab Test, Viral Load*) |
| `labonfhir.lisUserUuid` | `c1c26908-3f10-11e4-adec-0800271c1b75` (the `superman` provider; Findings S5) |
| `labonfhir.lisIdentifierSystem.url` | `http://openelis-global.org/pat_nationalId` |
| `labonfhir.openmrsPatientIdentifier.uuid` | `05a29f94-c0ed-11e2-94be-8c13b969e334` (no patient has this type; Findings L7) |

### What gets sent: one FHIR **transaction Bundle** per Task

**HTTP call:** `POST {lisUrl}` with `Bundle.type = transaction`.
**Each entry:** `request.method = PUT`, `request.url = <ResourceType>/<id>`. Resources are upserted on the LIS
**with the same ids (OpenMRS UUIDs)** they have in OpenMRS.

#### Resources in the bundle

| # | Resource | How it gets into the bundle | Always? |
|---|---|---|---|
| 1 | **Task** | The Task just created by `LabOrderHandler` (fetched back with `FhirTaskService.searchForTasks(_id=…)`) | ✔ |
| 2 | **Patient** | `_include=Task:patient` (Task.for) | ✔ |
| 3 | **Practitioner** | `_include=Task:owner`: the LIS service user `labonfhir.lisUserUuid` | ✔ |
| 4 | **Encounter** | `_include=Task:encounter` | ✔ |
| 5 | **ServiceRequest** | `_include=Task:based-on`: the lab order(s) (`test_order`) | ✔ (one per order) |
| 6 | **Location** | Trigger `Encounter`: `Task.location`. Trigger `Order`: `Encounter.location[0]`. Loaded via `FhirLocationService` | if a location is set |
| 7 | **Observation** | Each `ServiceRequest.supportingInfo` reference of type Observation (clinical context), loaded via `FhirObservationService` and **re-coded with Lesotho DISA codes** (table below) | only if the order has supportingInfo |
| 8 | **DiagnosticReport** | Each `ServiceRequest.supportingInfo` reference of type DiagnosticReport, searched with `_include=DiagnosticReport:result` | only if present |
| 9 | **Observation** (results) | The `DiagnosticReport.result` observations pulled in by the include above | with #8 |

Not sent: the **requester** Practitioner (`Task.requester`). It is referenced but not included, so the LIS
sees a dangling reference unless that Practitioner already exists there.
**Live:** the stored Tasks have no `requester` at all, and the bundle is built from the stored Task, so in practice no
requester is sent on the Task. The ordering clinician travels on `ServiceRequest.requester` (with identifier and display),
but that Practitioner is not included in the bundle either.

#### The Task that is sent (built by `LabOrderHandler.createTask`)

| Field | Value |
|---|---|
| `id` | new UUID (OpenMRS `fhir_task.uuid`) |
| `identifier` | `system = http://fhir.openmrs.org/ext/task/identifier`, `value = <task uuid>` (added by FHIR2's Task translator; this is how results are matched back). The code would also copy the ServiceRequest `requisition` in as an identifier (`insertLabOrderIdentifierToTask`). **Live:** every stored Task has only the task-identifier, although every ServiceRequest has a requisition |
| `status` | `requested` (**Live:** 34 Tasks `requested`, 50 `completed`) |
| `intent` | `order` |
| `basedOn` | `ServiceRequest/<order uuid>`. Trigger `Order`: just that order (only if its concept ∈ `labonfhir.orderTestUuids`). Trigger `Encounter`: every order in the encounter |
| `for` | `Patient/<patient uuid>` |
| `owner` | `Practitioner/<labonfhir.lisUserUuid>` (default `<lis-user-uuid>`) |
| `encounter` | `Encounter/<encounter uuid>` |
| `requester` | `Practitioner/<uuid of first active EncounterProvider>`. Note: this is the **encounter_provider** row's UUID, not the provider's UUID. **Live:** absent on all stored Tasks |
| `location` | `Location/<encounter location uuid>` (Encounter trigger only; not used on this instance) |
| `authoredOn`, `lastModified` | Set by FHIR2 (**Live:** always present) |
| `input[]` | Only when `labonfhir.addObsAsTaskInput=true`: one per encounter Obs, `type = Observation.code`, `value = Observation.value` |

#### The ServiceRequest that is sent (customised FHIR2, live)

The customised FHIR2 adds fields that stock FHIR2 1.9.0 does not produce. See the
[Lab Order ServiceRequest](StructureDefinition-lab-order-service-request.html) profile and [example](ServiceRequest-example-vl-order.html).

| Field | Live value |
|---|---|
| `contained` | One **Specimen**: `type` = concept UUID + DISA `B` "Blood"; `collection.collectedDateTime`. Not referenced from `specimen` (Findings F3) |
| `identifier` | `ServiceReq_id` = order UUID; `Facility_name`; `Facility_code` (label systems; Findings F2) |
| `requisition` | `system = "eRegister Lab order number"` (not a valid uri; Findings F1), `value` = eRegister lab order number |
| `status` / `intent` | always `completed` / `order` (Findings F5) |
| `code` | concept UUID (no system) + LOINC `20447-9` + DISA `HIVVL` for viral load |
| `subject.display` | `"<NAME> (Patient Identifier: <id>)"` |
| `occurrencePeriod` | `start` = order date, `end` = start + 1 h |
| `requester` | reference + `identifier.value` (provider identifier) + `display` |
| `supportingInfo` | Observation references with a `display` label: *Current Regimen*, *Current Regimen startdate*, *Previous Regimen 1/2*, *Prev VL Results*, *VL Reason*, *Pregnancy status*, *Breastfeeding status*. The observations come from earlier encounters (Findings F7) |

The supporting observations already carry DISA codings from their concept mappings (system **with** trailing slash), for
example `DAIN` (ART start date), `RFVL`/`ROUT` (VL reason), `CPREG` and `CLACT` (pregnancy, breastfeeding), and regimen codes
such as `TDF5`. See [ValueSet LabOrderSupportingInfoCodes](ValueSet-lab-order-supporting-info-codes.html).

#### DISA re-coding of supporting Observations at send time (`http://health.gov.ls/laboratory-services`)

When an Observation in `ServiceRequest.supportingInfo` matches one of these concepts by display name, an extra coding is added
before sending, so the LIS (DISA) can recognise it. These codings exist only in the outgoing transaction; they are not stored
in OpenMRS, so they could not be checked on the live instance:

| Obs display contains | Added coding (code, display) |
|---|---|
| "Current Regimen" | `CTREA`, "Current Treatment" (also uses the obs effective date as "Current Regimen startdate") |
| "Previous Regimen" | `PTREA`, "Previous Treatment" |
| "Prev VL Results" | `PVLD`, "Previous VL Results" |
| "First CD4" | `FCD4`, "First CD4" |
| "Last CD4" | `LCD4`, "Last CD4" |

#### Example of the transaction bundle (shape)

Shape based on live resources (ids shortened, people synthetic). See also the full
[example Bundle](Bundle-example-lab-order-bundle.html).

```json
{
  "resourceType": "Bundle",
  "type": "transaction",
  "entry": [
    { "resource": { "resourceType": "Task", "id": "a1b2…",
        "identifier": [{ "system": "http://fhir.openmrs.org/ext/task/identifier", "value": "a1b2…" }],
        "basedOn":   [{ "reference": "ServiceRequest/e5f6…", "type": "ServiceRequest" }],
        "status": "requested", "intent": "order",
        "for":        { "reference": "Patient/c3d4…",   "type": "Patient" },
        "encounter":  { "reference": "Encounter/a7b8…", "type": "Encounter" },
        "authoredOn": "2026-11-18T09:20:00+02:00", "lastModified": "2026-11-18T09:20:00+02:00",
        "owner":      { "reference": "Practitioner/c1c26908-3f10-11e4-adec-0800271c1b75", "type": "Practitioner" } },
      "request": { "method": "PUT", "url": "Task/a1b2…" } },
    { "resource": { "resourceType": "Patient", "id": "c3d4…",
        "identifier": [{ "use": "official", "type": { "coding": [{ "code": "81433852-3f10-11e4-adec-0800271c1b75" }], "text": "Patient Identifier" }, "value": "X0000000001/26" },
                       { "use": "usual", "type": { "coding": [{ "code": "5c1e8ae2-33c6-11e8-8236-0242ac110002" }], "text": "HIV Program ID" }, "value": "…" }],
        "…": "…" },
      "request": { "method": "PUT", "url": "Patient/c3d4…" } },
    { "resource": { "resourceType": "Practitioner", "id": "c1c26908-3f10-11e4-adec-0800271c1b75",
        "identifier": [{ "system": "http://fhir.openmrs.org/ext/provider/identifier", "value": "superman" }] },
      "request": { "method": "PUT", "url": "Practitioner/c1c26908-3f10-11e4-adec-0800271c1b75" } },
    { "resource": { "resourceType": "Encounter", "id": "a7b8…" },  "request": { "method": "PUT", "url": "Encounter/a7b8…" } },
    { "resource": { "resourceType": "ServiceRequest", "id": "e5f6…",
        "contained": [{ "resourceType": "Specimen", "id": "a3b4…",
            "type": { "coding": [{ "code": "23c1ac3f-9aa9-4261-b434-622dab8fe2bd", "display": "Blood" },
                                 { "system": "http://health.gov.ls/laboratory-services/", "code": "B", "display": "Blood" }] },
            "collection": { "collectedDateTime": "…" } }],
        "identifier": [{ "system": "ServiceReq_id", "value": "e5f6…" },
                       { "system": "Facility_name", "value": "Example Health Centre" },
                       { "system": "Facility_code", "value": "X0000" }],
        "requisition": { "system": "eRegister Lab order number", "value": "XDEP000001" },
        "status": "completed", "intent": "order",
        "code": { "coding": [{ "code": "92d73e24-122e-4f3e-8447-fb972f01b617", "display": "HIVTC, Lab Test, Viral Load" },
                             { "system": "http://loinc.org", "code": "20447-9" },
                             { "system": "http://health.gov.ls/laboratory-services/", "code": "HIVVL" }] },
        "subject": { "reference": "Patient/c3d4…" }, "encounter": { "reference": "Encounter/a7b8…" },
        "occurrencePeriod": { "start": "…", "end": "…" },
        "requester": { "reference": "Practitioner/e1f2…", "identifier": { "value": "000-1" }, "display": "…" },
        "supportingInfo": [{ "reference": "Observation/c9d0…", "type": "Observation", "display": "Current Regimen" }] },
      "request": { "method": "PUT", "url": "ServiceRequest/e5f6…" } },
    { "resource": { "resourceType": "Location", "id": "6e38…", "name": "ART Clinic" }, "request": { "method": "PUT", "url": "Location/6e38…" } },
    { "resource": { "resourceType": "Observation", "id": "c9d0…",
        "code": { "coding": [ { "code": "13382e01-9f18-488b-b2d2-58ab54c82d82", "display": "HIVTC, ART Regimen" },
                              { "system": "https://openconceptlab.org/orgs/CIEL/sources/CIEL", "code": "162240" },
                              { "system": "http://loinc.org", "code": "45260-7" },
                              { "system": "http://health.gov.ls/laboratory-services", "code": "CTREA", "display": "Current Treatment" } ] } },
      "request": { "method": "PUT", "url": "Observation/c9d0…" } }
  ]
}
```

#### Which orders trigger a send

- `labonfhir.labUpdateTriggerObject = Order` (default): every **Order CREATED** event whose concept UUID is in
  `labonfhir.orderTestUuids` (default: `160046AAAA…` (CIEL HIV viral load), `165254AAAA…`, and 4 local UUIDs:
  `92d73e24-…`, `fd9bb3b0-…`, `7124560e-…`, `c363d667-…`). **Live:** set to `160046AAAA…`, `165254AAAA…` and
  `92d73e24-…` only. 84 of the 85 ServiceRequests are viral-load orders (`92d73e24-…`); one is a CD4 test.
- `= Encounter`: every **Encounter CREATED** event that has orders produces one Task covering all its orders.
- The MySQL trigger `openmrs_orders_AFTER_INSERT` makes sure that `orders` rows of `order_type_id = 3` also get a
  `test_order` row, because FHIR2 1.9 only exposes `test_order` as ServiceRequest. Bahmni writes plain `orders`.

#### Failure handling
On any exception during the transaction, a row is written to `failed_task` (`task_uuid`, `error` = exception message,
`is_sent = false`). The **Retry Failed Tasks** scheduler task (every 3600 s) rebuilds the same bundle and re-sends it.
On success it sets `is_sent = true`. Inspect it with `GET /ws/rest/v1/failedtask?sent=false`.

### What gets pulled back from the HAPI server (results)

Scheduler task **"OpenELIS Pull Task"** (`FetchTaskUpdates`, every 30 s; `start_on_startup=0`, so it must be started in
*Admin → Manage Scheduler*):

| Step | Request to LIS | Purpose |
|---|---|---|
| 1 | `GET {lisUrl}/Task?identifier=http://fhir.openmrs.org/ext/task/identifier\|&status=completed&_lastUpdated=ge{last poll (UTC)}&_lastUpdated=le{now (UTC)}` and every `next` page | Completed tasks that came from OpenMRS. The window starts at the last `task_request.request_date`. |
| 2 | `GET {lisUrl}/DiagnosticReport?_id={id from Task.output.valueReference}&_include=DiagnosticReport:result&_include=DiagnosticReport:subject` | Get the report, its result Observations and the patient |

Writes to OpenMRS (through FHIR2 services, not over HTTP):

| Resource written in OpenMRS | Details |
|---|---|
| **Observation** (each result) | `encounter` and `basedOn` set from the local Task, then `FhirObservationService.create()` → `obs`. **Live:** `basedOn` is not served (Findings F6). Codes seen: DISA `HIVVL-HIVVM` + LOINC `70241-5` (copies/ml), DISA `HIVVL-HIVML` + LOINC `51780-5` (log10), DISA `HIVVL-HIVVH` with value `LDL` |
| **Observation** (derived HIV VL, Lesotho) | If the report code is LOINC `20447-9` or the obs codes include `HIVVL-HIVVM`, `HIVVL-HIVVT`, `70241-5`: creates `HIVTCVLReturnDate` ("Viral load blood results return date"), `HIVTCVLResult` ("Viral Load Result"), `HIVTCVLDATAAbnormal` ("Viral Load Abnormal") and `HIVTCVL` ("HIVTC, Viral Load") with value **"<20" (Less than 20 copies/ml)** or **">=20" (Greater or Equal to 20 copies/ml)**. For low-value codes `HIVVL-HIVVC` / `HIVVL-HIVVH`, `HIVTCVLResult = "Undetectable"`. All codes use system `http://health.gov.ls/laboratory-services/`. **Live:** none of these derived observations were found (Findings L8) |
| **DiagnosticReport** | `result` replaced with references to the newly created local Obs, `encounter` = Task.encounter → `FhirDiagnosticReportService.create()` |
| **Task** (update) | `status` copied from the LIS (completed). `output` gets `DiagnosticReport/<id>` with `type` = report code. `FhirTaskService.update()`. **Live:** FHIR2 serves `output.valueReference.reference` as the bare id, without `DiagnosticReport/` (Findings F4) |
| `task_request` | new row with `request_date = now` (next poll window start) |

### Summary: resource flow

```
            OpenMRS (FHIR2 store)                                   LIS HAPI FHIR server
 ┌───────────────────────────────────┐   PUT (transaction)   ┌──────────────────────────────┐
 │ Task (requested)                  │ ────────────────────► │ Task                         │
 │ Patient, Practitioner(owner)      │ ────────────────────► │ Patient, Practitioner        │
 │ Encounter, Location               │ ────────────────────► │ Encounter, Location          │
 │ ServiceRequest (lab order)        │ ────────────────────► │ ServiceRequest               │
 │ Observation (supportingInfo, DISA)│ ────────────────────► │ Observation                  │
 │ DiagnosticReport (+ result Obs)   │ ────────────────────► │ DiagnosticReport             │
 │                                   │                       │                              │
 │                                   │  GET Task?status=completed                          │
 │ Task (completed, output=DR)  ◄────│ ◄──────────────────── │ Task (completed)             │
 │ DiagnosticReport             ◄────│  GET DiagnosticReport?_include=result,subject       │
 │ Observation (results + VL)   ◄────│ ◄──────────────────── │ DiagnosticReport+Observation │
 └───────────────────────────────────┘                       └──────────────────────────────┘
```

**Resource types sent to the HAPI server:** `Task`, `Patient`, `Practitioner`, `Encounter`, `ServiceRequest`,
`Location`, `Observation`, `DiagnosticReport`, all inside a `Bundle` (type `transaction`).
**Resource types read from it:** `Task`, `DiagnosticReport`, `Observation`, `Patient`.
