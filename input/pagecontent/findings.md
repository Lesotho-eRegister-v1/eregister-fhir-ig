The issues below come from analysing the module builds and from checking the live instance on 2026-11-18, first without logging in and then with an authenticated user (all 84 Tasks, 85 ServiceRequests, 50 DiagnosticReports and their observations were inspected). Each one says how it was found.

### Security

| # | Finding | Evidence | Suggested action |
|---|---|---|---|
| S1 | **`GET /openmrs/ws/rest/v1/failedtask` answers without authentication** (HTTP 200). It lists Lab on FHIR's failed sends: Task UUIDs and error messages. Error text can contain LIS URLs or responses. | Live instance: unauthenticated request returned 7 rows. `/ws/rest/v1/module` and `/ws/fhir2/R4/Task` correctly return 401. | Block the path at the reverse proxy now. Add a privilege check to `FailedTaskResource`. |
| S2 | **Module defaults contain credentials**: `labonfhir.userName` / `labonfhir.password` and keystore / truststore passwords. | Lab on FHIR `config.xml` | Confirm that every `labonfhir.*` credential property has been changed on the instance. |
| S3 | **Public base URL**: the server CapabilityStatement reports `implementation.url` as `http://` on an internal IP address, although the instance is reached over HTTPS. Resource narratives link to `http://localhost:8080/...`. | Live `/metadata`; `Task.text` | Set `fhir2.uriPrefix` so that links and `fullUrl` values use the public HTTPS address. |
| S4 | **Lab orders go to the LIS over plain HTTP.** `labonfhir.lisUrl` is an `http://` URL on a public IP address, with `labonfhir.authType = Basic`. Patient data and the LIS password cross the network unencrypted. | Live global properties | Put the LIS behind HTTPS (or switch to `authType = SSL` with the configured keystore/truststore). |
| S5 | **The Task owner is the `superman` superuser.** `labonfhir.lisUserUuid` points at the built-in admin provider (`c1c26908-…`), so every Task is owned by the admin account and the LIS receives it as a Practitioner. | Live global property; `Task.owner` on all 84 Tasks | Create a dedicated LIS service provider/user with minimum privileges. |
| S6 | **`/metadata` does not advertise authentication.** It has no `rest.security`, so clients cannot discover the Basic-auth requirement. | Live `/metadata` | Document it (done in this guide's CapabilityStatement). |

### Operations

| # | Finding | Evidence | Suggested action |
|---|---|---|---|
| O1 | **7 lab orders failed the first send** (rows in `failed_task`), all with `HTTP 401 Unauthorized` from the LIS. All 7 are now `is_sent = true`: the *Retry Failed Tasks* job re-sent them. | Live `failed_task` rows, authenticated | Monitor for new 401s; they indicate the LIS credentials changed. |
| O4 | **`GET /ws/fhir2/R4/MedicationRequest` without filters fails with HTTP 500** (an HTML error page from the proxy, not an OperationOutcome). With a filter (e.g. `?patient=…`) it returns 200. | Live instance, authenticated | Check the OpenMRS log for the exception; always filter MedicationRequest searches until fixed. |
| O5 | **34 of 84 Tasks are still `requested`** (no result imported). | Live Task search | Check them against the LIS and the *OpenELIS Pull Task* scheduler. |
| O6 | **Operation definition links depend on the caller's host.** `/metadata` builds `operation.definition` URLs from the host of the request that generated it, and HAPI caches the statement, so clients can see another caller's (internal) address. | Live `/metadata` fetched at different times | Resolve them against your own base URL. |
| O2 | The **"OpenELIS Pull Task"** scheduler task is installed with `start_on_startup = 0`, so results are only imported if someone starts it. | Lab on FHIR `liquibase.xml` | Confirm in *Admin → Manage Scheduler* that it is running. |
| O3 | The Bahmni FHIR2 extension is built for **FHIR2 2.5.0**; the instance runs **1.9.0**, and the extension's resources are absent. | Extension `pom.xml`; live `/metadata` | Upgrade FHIR2 before deploying the extension. See [Bahmni Extension](bahmni-extension.html). |

### Lab on FHIR behaviour

| # | Finding | Evidence | Impact |
|---|---|---|---|
| L1 | **DISA system URL is written two ways.** Lab on FHIR's send-time codings use `http://health.gov.ls/laboratory-services`; imported viral-load observations and the `fhir_concept_source` row use `http://health.gov.ls/laboratory-services/` (trailing slash). Every DISA coding served by FHIR2 on the live instance (over 1,000) uses the trailing slash. | `LabCreationListener` vs `FetchTaskUpdates` constants; `liquibase.xml`; live resources | The LIS and OpenMRS may not recognise each other's codes. Agree one URL. |
| L2 | **`Task.requester` points to the wrong UUID**: it uses the `encounter_provider` row's UUID, not the provider's. The requester Practitioner is not included in the transaction. On the live instance no stored Task has a requester at all (0 of 84), so it is not persisted. The ordering clinician is available on `ServiceRequest.requester`. | `LabOrderHandler` bytecode; live Tasks | The LIS may see a dangling or wrong requester reference in the transaction. |
| L3 | The **DISA concept-source changeset looks inverted**: its precondition expects `0` from `select 1 … where name = 'LSMOH DISA'`, so it is marked as run without inserting when the source exists. | `liquibase.xml` | Check that `fhir_concept_source` has the DISA row. |
| L4 | The **orders → test_order trigger** hard-codes `order_type_id = 3` and the schema name `openmrs`. | `sql/create_trigger.sql` | Orders of other types that exist only in `orders` get no `test_order` row, so FHIR2 cannot serve them as ServiceRequest and they are not sent. On another schema name the trigger fails. |
| L5 | **Dead code in Lab on FHIR, but no impact here**: `insertRequisitionIdOnServReq()` is never called. The customised FHIR2 fills `ServiceRequest.requisition` itself (all 85 orders), so the lab order number does reach the LIS. It is not copied onto `Task.identifier` (0 of 84). | `LabCreationListener` bytecode; live ServiceRequests and Tasks | None for the ServiceRequest. The Task carries only its UUID. |
| L6 | With the **Encounter trigger**, every order in the encounter appears to be attached to the Task: the `labonfhir.orderTestUuids` filter is only applied on the Order path. | `LabOrderHandler.createOrder(Encounter)` | Non-lab orders may be sent to the LIS. |
| L7 | **Patients never get the LIS identifier system.** `labonfhir.openmrsPatientIdentifier.uuid` is `05a29f94-…`, but no patient on the instance has an identifier of that type (they have *Patient Identifier*, *HIV Program ID*, *File Number*, *National ID*). So no `Patient.identifier` carries `http://openelis-global.org/pat_nationalId`; all identifiers are sent without a `system`. | Live global properties; 100 patients sampled | The LIS cannot match patients by a known identifier system. Point the property at the identifier type the LIS should use, or map types in `fhir_patient_identifier_system`. |
| L8 | **Derived viral-load observations not found.** A code search for `HIVTCVL`, `HIVTCVLResult`, `HIVTCVLDATAAbnormal` and `HIVTCVLReturnDate` (with and without trailing slash) returns nothing, even though 50 viral-load reports were imported. | Live Observation search | Either the derivation does not run or its concepts have no DISA mapping. Check the obs table for those concepts. |

### Customised FHIR2 output (non-conformant details)

The FHIR2 build on this instance is customised. These details differ from stock FHIR2 and some are not valid FHIR.

| # | Finding | Evidence | Impact |
|---|---|---|---|
| F1 | **`ServiceRequest.requisition.system` is `"eRegister Lab order number"`**, a label with spaces. `system` is a `uri`, so the resource fails validation. | All 85 ServiceRequests | Strict validators reject it. Use a URI, e.g. a NamingSystem under this guide's canonical. |
| F2 | **`ServiceRequest.identifier.system` values are labels**: `ServiceReq_id`, `Facility_name`, `Facility_code`. They are not absolute URIs, and facility name/code are not really identifiers of the order. | All 85 ServiceRequests | Receivers must match on these exact strings. Consider absolute URIs, and `performer`/`locationReference` or an extension for the facility. |
| F3 | **The contained Specimen is not referenced** (`ServiceRequest.specimen` is absent). This breaks invariant dom-3 (every contained resource must be referenced). | All 85 ServiceRequests | Validation error. Add `specimen = #<id>`. |
| F4 | **`Task.output.valueReference.reference` is the bare DiagnosticReport id** (e.g. `"76fc…"`), not `"DiagnosticReport/76fc…"`. | All 50 completed Tasks | Generic clients and `_include` cannot resolve it. They must combine it with `valueReference.type`. |
| F5 | **`ServiceRequest.status` is always `completed`**, even when the Task is still `requested`. | 85 ServiceRequests vs 34 requested Tasks | Use `Task.status`, not `ServiceRequest.status`, to track an order. |
| F6 | **`basedOn` is not served on lab results**: neither DiagnosticReport nor the result Observations have it, although Lab on FHIR sets it before saving. | 50 reports, 78 result observations | Link results to orders through `Task.basedOn` + `Task.output`. |
| F7 | **Supporting observations come from earlier encounters.** `ServiceRequest.supportingInfo` points to observations from previous visits, not from the order's encounter. | Live ServiceRequests | Receivers must not assume `Observation.encounter` = order encounter. |

