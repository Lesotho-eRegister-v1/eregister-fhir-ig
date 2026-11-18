These artifacts formalise this workflow: the [Lab Order Task](StructureDefinition-lab-order-task.html), [Lab Order ServiceRequest](StructureDefinition-lab-order-service-request.html), [Lab Order Transaction Bundle](StructureDefinition-lab-order-transaction-bundle.html), [Lab Result DiagnosticReport](StructureDefinition-lab-result-diagnostic-report.html) and [Lab Result Observation](StructureDefinition-lab-result-observation.html) profiles; the [Lab on FHIR client](CapabilityStatement-labonfhir-client.html) and [LIS server requirements](CapabilityStatement-lis-server-requirements.html) capability statements; and the worked example [transaction Bundle](Bundle-example-lab-order-bundle.html).

<figure>
<img src="lab-workflow.svg" alt="Lab on FHIR order and result flow between OpenMRS and the LIS" style="max-width:100%"/>
<figcaption>Orders go out as one transaction per Task; results come back through a 30-second poll.</figcaption>
</figure>


Everything here was read from the bytecode of `labonfhir-api-1.3.1-SNAPSHOT.jar`
(`LabOrderHandler`, `LabCreationListener`, `FetchTaskUpdates`, `RetryFailedTasks`, `FhirConfig`).

### Connection

| Item | Value |
|---|---|
| Target | `labonfhir.lisUrl` (default `http://<lis-host>:<port>/fhir`; class constant fallback `https://testapi.openelisci.org:8444/hapi-fhir-jpaserver/fhir`) |
| Client | HAPI `IGenericClient` (FHIR R4, JSON) built in `FhirConfig.getFhirClient()` |
| Auth | `labonfhir.authType=Basic` → `BasicAuthInterceptor(userName, password)`; `SSL` → Apache HttpClient with keystore/truststore (mutual TLS) |
| Switches | `labonfhir.activateFhirPush` (must be `true` to send); connector is active only when `labonfhir.lisUrl` is non-blank |

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

#### The Task that is sent (built by `LabOrderHandler.createTask`)

| Field | Value |
|---|---|
| `id` | new UUID (OpenMRS `fhir_task.uuid`) |
| `identifier` | `system = http://fhir.openmrs.org/ext/task/identifier`, `value = <task uuid>` (added by FHIR2's Task translator; this is how results are matched back). If the ServiceRequest has a `requisition`, it is also copied in as an identifier (`insertLabOrderIdentifierToTask`) |
| `status` | `requested` |
| `intent` | `order` |
| `basedOn` | `ServiceRequest/<order uuid>`. Trigger `Order`: just that order (only if its concept ∈ `labonfhir.orderTestUuids`). Trigger `Encounter`: every order in the encounter |
| `for` | `Patient/<patient uuid>` |
| `owner` | `Practitioner/<labonfhir.lisUserUuid>` (default `<lis-user-uuid>`) |
| `encounter` | `Encounter/<encounter uuid>` |
| `requester` | `Practitioner/<uuid of first active EncounterProvider>`. Note: this is the **encounter_provider** row's UUID, not the provider's UUID |
| `location` | `Location/<encounter location uuid>` (Encounter trigger only) |
| `input[]` | Only when `labonfhir.addObsAsTaskInput=true`: one per encounter Obs, `type = Observation.code`, `value = Observation.value` |

#### DISA re-coding of supporting Observations (`http://health.gov.ls/laboratory-services`)

When an Observation in `ServiceRequest.supportingInfo` matches one of these concepts by display name, an extra coding is added
before sending, so the LIS (DISA) can recognise it:

| Obs display contains | Added coding (code, display) |
|---|---|
| "Current Regimen" | `CTREA`, "Current Treatment" (also uses the obs effective date as "Current Regimen startdate") |
| "Previous Regimen" | `PTREA`, "Previous Treatment" |
| "Prev VL Results" | `PVLD`, "Previous VL Results" |
| "First CD4" | `FCD4`, "First CD4" |
| "Last CD4" | `LCD4`, "Last CD4" |

#### Example of the transaction bundle (shape)

```json
{
  "resourceType": "Bundle",
  "type": "transaction",
  "entry": [
    { "resource": { "resourceType": "Task", "id": "8b6f…",
        "identifier": [{ "system": "http://fhir.openmrs.org/ext/task/identifier", "value": "8b6f…" }],
        "status": "requested", "intent": "order",
        "basedOn":   [{ "reference": "ServiceRequest/1d2c…", "type": "ServiceRequest" }],
        "for":        { "reference": "Patient/5a1e…",        "type": "Patient" },
        "encounter":  { "reference": "Encounter/77aa…",      "type": "Encounter" },
        "owner":      { "reference": "Practitioner/<lis-user-uuid>", "type": "Practitioner" },
        "requester":  { "reference": "Practitioner/e3f0…",   "type": "Practitioner" } },
      "request": { "method": "PUT", "url": "Task/8b6f…" } },
    { "resource": { "resourceType": "Patient", "id": "5a1e…",
        "identifier": [{ "system": "http://openelis-global.org/pat_nationalId", "value": "…" }], "…": "…" },
      "request": { "method": "PUT", "url": "Patient/5a1e…" } },
    { "resource": { "resourceType": "Practitioner", "id": "<lis-user-uuid>" },  "request": { "method": "PUT", "url": "Practitioner/<lis-user-uuid>" } },
    { "resource": { "resourceType": "Encounter",    "id": "77aa…" },        "request": { "method": "PUT", "url": "Encounter/77aa…" } },
    { "resource": { "resourceType": "ServiceRequest","id": "1d2c…",
        "status": "active", "intent": "order",
        "code": { "coding": [{ "code": "<test concept uuid>" }, { "system": "http://loinc.org", "code": "…" }] },
        "subject": { "reference": "Patient/5a1e…" }, "encounter": { "reference": "Encounter/77aa…" } },
      "request": { "method": "PUT", "url": "ServiceRequest/1d2c…" } },
    { "resource": { "resourceType": "Location",     "id": "…" },             "request": { "method": "PUT", "url": "Location/…" } },
    { "resource": { "resourceType": "Observation",  "id": "…",
        "code": { "coding": [ { "…": "original" },
                              { "system": "http://health.gov.ls/laboratory-services", "code": "LCD4", "display": "Last CD4" } ] } },
      "request": { "method": "PUT", "url": "Observation/…" } }
  ]
}
```

#### Which orders trigger a send

- `labonfhir.labUpdateTriggerObject = Order` (default): every **Order CREATED** event whose concept UUID is in
  `labonfhir.orderTestUuids` (default: `160046AAAA…` (CIEL HIV viral load), `165254AAAA…`, and 4 local UUIDs:
  `92d73e24-…`, `fd9bb3b0-…`, `7124560e-…`, `c363d667-…`).
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
| **Observation** (each result) | `encounter` and `basedOn` set from the local Task, then `FhirObservationService.create()` → `obs` |
| **Observation** (derived HIV VL, Lesotho) | If the report code is LOINC `20447-9` or the obs codes include `HIVVL-HIVVM`, `HIVVL-HIVVT`, `70241-5`: creates `HIVTCVLReturnDate` ("Viral load blood results return date"), `HIVTCVLResult` ("Viral Load Result"), `HIVTCVLDATAAbnormal` ("Viral Load Abnormal") and `HIVTCVL` ("HIVTC, Viral Load") with value **"<20" (Less than 20 copies/ml)** or **">=20" (Greater or Equal to 20 copies/ml)**. For low-value codes `HIVVL-HIVVC` / `HIVVL-HIVVH`, `HIVTCVLResult = "Undetectable"`. All codes use system `http://health.gov.ls/laboratory-services/` |
| **DiagnosticReport** | `result` replaced with references to the newly created local Obs, `encounter` = Task.encounter → `FhirDiagnosticReportService.create()` |
| **Task** (update) | `status` copied from the LIS (completed). `output` gets `DiagnosticReport/<id>` with `type` = report code. `FhirTaskService.update()` |
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
