The issues below come from analysing the module builds and checking the live instance without logging in, on 2026-11-18. Each one says how it was found.

### Security

| # | Finding | Evidence | Suggested action |
|---|---|---|---|
| S1 | **`GET /openmrs/ws/rest/v1/failedtask` answers without authentication** (HTTP 200). It lists Lab on FHIR's failed sends: Task UUIDs and error messages. Error text can contain LIS URLs or responses. | Live instance: unauthenticated request returned 7 rows. `/ws/rest/v1/module` and `/ws/fhir2/R4/Task` correctly return 401. | Block the path at the reverse proxy now. Add a privilege check to `FailedTaskResource`. |
| S2 | **Module defaults contain credentials**: `labonfhir.userName` / `labonfhir.password` and keystore / truststore passwords. | Lab on FHIR `config.xml` | Confirm that every `labonfhir.*` credential property has been changed on the instance. |
| S3 | **Public base URL**: the server CapabilityStatement reports `implementation.url` with `http://`, although the instance is reached over HTTPS. | Live `/metadata` | Set `fhir2.uriPrefix` so that links and `fullUrl` values use the public HTTPS address. |

### Operations

| # | Finding | Evidence | Suggested action |
|---|---|---|---|
| O1 | **7 lab orders never reached the LIS** (rows in `failed_task`). | Live instance, S1 endpoint (count only) | Review with an authenticated user. Check that the *Retry Failed Tasks* scheduler task is running. |
| O2 | The **"OpenELIS Pull Task"** scheduler task is installed with `start_on_startup = 0`, so results are only imported if someone starts it. | Lab on FHIR `liquibase.xml` | Confirm in *Admin → Manage Scheduler* that it is running. |
| O3 | The Bahmni FHIR2 extension is built for **FHIR2 2.5.0**; the instance runs **1.9.0**, and the extension's resources are absent. | Extension `pom.xml`; live `/metadata` | Upgrade FHIR2 before deploying the extension. See [Bahmni Extension](bahmni-extension.html). |

### Lab on FHIR behaviour

| # | Finding | Evidence | Impact |
|---|---|---|---|
| L1 | **DISA system URL is written two ways.** Outbound codings use `http://health.gov.ls/laboratory-services`; imported viral-load observations and the `fhir_concept_source` row use `http://health.gov.ls/laboratory-services/` (trailing slash). | `LabCreationListener` vs `FetchTaskUpdates` constants; `liquibase.xml` | The LIS and OpenMRS may not recognise each other's codes. Agree one URL. |
| L2 | **`Task.requester` points to the wrong UUID**: it uses the `encounter_provider` row's UUID, not the provider's. The requester Practitioner is not included in the transaction. | `LabOrderHandler` bytecode | The LIS sees a dangling or wrong requester reference. |
| L3 | The **DISA concept-source changeset looks inverted**: its precondition expects `0` from `select 1 … where name = 'LSMOH DISA'`, so it is marked as run without inserting when the source exists. | `liquibase.xml` | Check that `fhir_concept_source` has the DISA row. |
| L4 | The **orders → test_order trigger** hard-codes `order_type_id = 3` and the schema name `openmrs`. | `sql/create_trigger.sql` | Orders of other types that exist only in `orders` get no `test_order` row, so FHIR2 cannot serve them as ServiceRequest and they are not sent. On another schema name the trigger fails. |
| L5 | **Dead code**: `insertRequisitionIdOnServReq()` (copy the "eRegister Lab Order Number" to `ServiceRequest.requisition`) is never called. | `LabCreationListener` bytecode | The lab order number never reaches the LIS on the ServiceRequest. |
| L6 | With the **Encounter trigger**, every order in the encounter appears to be attached to the Task: the `labonfhir.orderTestUuids` filter is only applied on the Order path. | `LabOrderHandler.createOrder(Encounter)` | Non-lab orders may be sent to the LIS. |
