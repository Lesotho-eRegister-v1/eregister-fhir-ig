// ---------------------------------------------------------------------------
// Profiles describing what OpenMRS (FHIR2 1.9.0 + Lab on FHIR 1.3.1) actually
// produces for the laboratory workflow. Constraints reflect observed behaviour
// in the module code, not aspirations.
// ---------------------------------------------------------------------------

Profile: LabOrderTask
Parent: Task
Id: lab-order-task
Title: "Lab Order Task"
Description: """
The Task that Lab on FHIR creates in OpenMRS (through FHIR2's Task service) for every lab order that passes the
concept filter, and sends to the LIS in a transaction Bundle. The LIS updates the same Task (same id) to `completed` and
adds an output that points at the DiagnosticReport holding the results.
"""
* ^status = #active
* ^publisher = "Lesotho eRegister Team"
* ^experimental = false
* identifier 1..* MS
* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier contains openmrsTaskId 1..1 MS
* identifier[openmrsTaskId].system 1..1
* identifier[openmrsTaskId].system = $task-identifier (exactly)
* identifier[openmrsTaskId].value 1..1
* identifier[openmrsTaskId] ^short = "The Task's OpenMRS UUID; used to match LIS updates back to OpenMRS"
* status MS
* status ^short = "requested when created by OpenMRS; completed (or another state) when set by the LIS"
* intent = #order (exactly)
* basedOn 1..* MS
* basedOn only Reference(LabOrderServiceRequest)
* basedOn ^short = "The lab order(s): one per order (Order trigger) or all orders of the encounter (Encounter trigger)"
* for 1..1 MS
* for only Reference(Patient)
* encounter 1..1 MS
* encounter only Reference(Encounter)
* owner 1..1 MS
* owner only Reference(Practitioner)
* owner ^short = "The LIS service user (global property labonfhir.lisUserUuid)"
* requester 0..1 MS
* requester only Reference(Practitioner)
* requester ^comment = "Lab on FHIR 1.3.1 fills this with the uuid of the first active encounter_provider row, not the provider's uuid, and does not send that Practitioner. See Findings."
* location 0..1
* location only Reference(Location)
* location ^short = "Set only when labonfhir.labUpdateTriggerObject = Encounter"
* input 0..*
* input ^short = "Encounter observations, only when labonfhir.addObsAsTaskInput = true (type = Observation.code, value = Observation.value)"
* output 0..* MS
* output ^short = "Set by the LIS when results are ready"
* output.value[x] only Reference(LabResultDiagnosticReport)

Profile: LabOrderServiceRequest
Parent: ServiceRequest
Id: lab-order-service-request
Title: "Lab Order ServiceRequest"
Description: "A lab test order as FHIR2 1.9.0 serves it from the OpenMRS `test_order` table. The ServiceRequest id is the OpenMRS order UUID."
* ^status = #active
* ^publisher = "Lesotho eRegister Team"
* ^experimental = false
* status MS
* intent = #order (exactly)
* code 1..1 MS
* code ^short = "Test concept: coding with the concept UUID, plus a coding per concept mapping (e.g. LOINC)"
* subject 1..1 MS
* subject only Reference(Patient)
* encounter 1..1 MS
* encounter only Reference(Encounter)
* requester MS
* requester only Reference(Practitioner)
* occurrence[x] MS
* requisition MS
* requisition ^comment = "When present, Lab on FHIR copies it onto the Task as an identifier. The module also contains code to set it from an 'eRegister Lab Order Number' identifier, but that code is never called."
* supportingInfo MS
* supportingInfo only Reference(Observation or DiagnosticReport)
* supportingInfo ^comment = "Clinical-context observations are sent to the LIS; Lab on FHIR adds DISA codings to them (see ValueSet LabOnFHIRSupportingInfoCodes)."

Profile: LabResultDiagnosticReport
Parent: DiagnosticReport
Id: lab-result-diagnostic-report
Title: "Lab Result DiagnosticReport"
Description: "The DiagnosticReport that the LIS returns and that Lab on FHIR saves in OpenMRS (FHIR2 `fhir_diagnostic_report` table). Its results are re-created as OpenMRS observations."
* ^status = #active
* ^publisher = "Lesotho eRegister Team"
* ^experimental = false
* status MS
* code MS
* code ^comment = "LOINC 20447-9 triggers the Lesotho HIV viral-load handling."
* subject 1..1 MS
* subject only Reference(Patient)
* encounter 1..1 MS
* encounter only Reference(Encounter)
* encounter ^comment = "Set by Lab on FHIR to the Task's encounter when the report is saved in OpenMRS."
* result 1..* MS
* result only Reference(LabResultObservation)

Profile: LabResultObservation
Parent: Observation
Id: lab-result-observation
Title: "Lab Result Observation"
Description: "A lab result observation imported from the LIS and saved as an OpenMRS obs, linked to the order's encounter."
* ^status = #active
* ^publisher = "Lesotho eRegister Team"
* ^experimental = false
* status MS
* code MS
* subject 1..1 MS
* subject only Reference(Patient)
* encounter 1..1 MS
* encounter only Reference(Encounter)
* basedOn MS
* value[x] MS

Profile: LabOrderTransactionBundle
Parent: Bundle
Id: lab-order-transaction-bundle
Title: "Lab Order Transaction Bundle"
Description: """
What Lab on FHIR POSTs to the LIS base URL (`labonfhir.lisUrl`) for each new Task.
Every entry is an upsert (`PUT <type>/<id>`) so resources keep their OpenMRS UUIDs on the LIS.
It contains the Task and everything the Task references through `_include` (Patient, owner Practitioner, Encounter,
ServiceRequest), the encounter's Location, and any supporting Observations / DiagnosticReports of the ServiceRequest.
"""
* ^status = #active
* ^publisher = "Lesotho eRegister Team"
* ^experimental = false
* type = #transaction (exactly)
* entry 1..* MS
* entry.fullUrl MS
* entry.resource 1..1 MS
* entry.resource only LabOrderTask or Patient or Practitioner or Encounter or LabOrderServiceRequest or Location or Observation or DiagnosticReport
* entry.request 1..1 MS
* entry.request.method = #PUT (exactly)
* entry.request.url 1..1 MS
* entry.request.url ^short = "<ResourceType>/<OpenMRS uuid>"
* obeys lab-bundle-1

Invariant: lab-bundle-1
Description: "The bundle contains exactly one Task."
Expression: "entry.resource.ofType(Task).count() = 1"
Severity: #error
