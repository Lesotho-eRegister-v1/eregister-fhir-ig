// ---------------------------------------------------------------------------
// Profiles describing what OpenMRS (customised FHIR2 1.9.0-SNAPSHOT + Lab on FHIR
// 1.3.1-SNAPSHOT) actually serves for the laboratory workflow. Constraints were
// checked against every Task (84), ServiceRequest (85) and DiagnosticReport (50)
// on the live instance on 2026-11-18. They describe behaviour, not aspirations.
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
* identifier ^comment = "On the live instance every Task has exactly this one identifier. The ServiceRequest requisition (lab order number) is not copied onto the stored Task."
* status MS
* status ^short = "requested when created by OpenMRS; completed when set by the LIS (only these two observed)"
* intent = #order (exactly)
* basedOn 1..* MS
* basedOn only Reference(LabOrderServiceRequest)
* basedOn ^short = "The lab order(s): one per order (Order trigger) or all orders of the encounter (Encounter trigger)"
* for 1..1 MS
* for only Reference(Patient)
* encounter 1..1 MS
* encounter only Reference(Encounter)
* authoredOn 1..1 MS
* lastModified 1..1 MS
* owner 1..1 MS
* owner only Reference(Practitioner)
* owner ^short = "The LIS service user (global property labonfhir.lisUserUuid)"
* owner ^comment = "On the live instance this is the provider of the built-in 'superman' account (c1c26908-3f10-11e4-adec-0800271c1b75). See Findings."
* requester 0..1
* requester only Reference(Practitioner)
* requester ^comment = "Never populated on the stored Tasks served by FHIR2 (0 of 84). Lab on FHIR code sets it to the encounter_provider uuid; it is not persisted. See Findings L2."
* location 0..1
* location only Reference(Location)
* location ^short = "Set only when labonfhir.labUpdateTriggerObject = Encounter (not observed)"
* input 0..*
* input ^short = "Encounter observations, only when labonfhir.addObsAsTaskInput = true (not observed)"
* output 0..* MS
* output ^short = "Set by the LIS when results are ready: one per DiagnosticReport"
* output.type MS
* output.type ^comment = "Same codings as the order/report code: OpenMRS concept UUID (no system), LOINC and DISA."
* output.value[x] only Reference(LabResultDiagnosticReport)
* output.value[x] ^comment = "On the live instance valueReference.reference is the bare DiagnosticReport id (e.g. \"76fc…\") with valueReference.type = DiagnosticReport, not \"DiagnosticReport/<id>\". Generic clients cannot resolve it. See Findings."

Profile: LabOrderServiceRequest
Parent: ServiceRequest
Id: lab-order-service-request
Title: "Lab Order ServiceRequest"
Description: """
A lab test order as the **customised** FHIR2 1.9.0 serves it from the OpenMRS `test_order` table. The ServiceRequest id
is the OpenMRS order UUID. Compared with stock FHIR2, this build adds facility identifiers, the eRegister lab order number
in `requisition`, a contained Specimen, requester identifier/display and display labels on `supportingInfo`.
"""
* ^status = #active
* ^publisher = "Lesotho eRegister Team"
* ^experimental = false
* contained 1..* MS
* contained only Specimen
* contained ^short = "One Specimen: type (concept UUID + DISA code, e.g. B = Blood) and collection.collectedDateTime"
* contained ^comment = "The contained Specimen is NOT referenced from ServiceRequest.specimen on the live server, which breaks invariant dom-3. The example in this guide adds the reference so that it validates. See Findings."
* identifier 3..* MS
* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier contains serviceReqId 1..1 MS and facilityName 1..1 MS and facilityCode 1..1 MS
* identifier[serviceReqId].system = "ServiceReq_id" (exactly)
* identifier[serviceReqId].value 1..1
* identifier[serviceReqId] ^short = "The order UUID (same as id)"
* identifier[facilityName].system = "Facility_name" (exactly)
* identifier[facilityName].value 1..1
* identifier[facilityName] ^short = "Name of the ordering facility"
* identifier[facilityCode].system = "Facility_code" (exactly)
* identifier[facilityCode].value 1..1
* identifier[facilityCode] ^short = "MoH code of the ordering facility"
* identifier ^comment = "The systems are plain labels, not URIs. See Findings."
* requisition 1..1 MS
* requisition.system MS
* requisition.system ^comment = "The live server sends the label \"eRegister Lab order number\" here. It contains spaces, so it is not a valid FHIR uri and cannot be fixed in this profile; strict validators reject it. See Findings."
* requisition.value 1..1
* requisition ^short = "eRegister lab order number (e.g. <facility prefix>000575)"
* status MS
* status ^comment = "All 85 orders on the live instance are 'completed', including orders whose Task is still 'requested'. The status does not track the lab workflow."
* intent = #order (exactly)
* code 1..1 MS
* code ^short = "Test concept: coding with the concept UUID (no system), plus LOINC and DISA codings from concept mappings"
* code from LabOrderTestCodes (extensible)
* subject 1..1 MS
* subject only Reference(Patient)
* subject.display MS
* encounter 1..1 MS
* encounter only Reference(Encounter)
* occurrence[x] 1..1 MS
* occurrence[x] only Period
* occurrence[x] ^short = "start = order date; end = start + 1 hour"
* requester 1..1 MS
* requester only Reference(Practitioner)
* requester.identifier MS
* requester.identifier ^short = "Provider identifier (value only, no system)"
* requester.display MS
* supportingInfo MS
* supportingInfo only Reference(Observation)
* supportingInfo.display MS
* supportingInfo.display ^short = "Short label: Current Regimen, Current Regimen startdate, Previous Regimen 1/2, Prev VL Results, VL Reason, Pregnancy status, Breastfeeding status"
* supportingInfo ^comment = "The referenced observations come from earlier encounters, not from the order's encounter. Their codes come from concept mappings (see ValueSet LabOrderSupportingInfoCodes). Lab on FHIR may add more DISA codings while sending (ValueSet LabOnFHIRSupportingInfoCodes)."

Profile: LabResultDiagnosticReport
Parent: DiagnosticReport
Id: lab-result-diagnostic-report
Title: "Lab Result DiagnosticReport"
Description: "The DiagnosticReport that the LIS returns and that Lab on FHIR saves in OpenMRS (FHIR2 `fhir_diagnostic_report` table). Its results are re-created as OpenMRS observations."
* ^status = #active
* ^publisher = "Lesotho eRegister Team"
* ^experimental = false
* status MS
* status ^short = "final (all 50 observed)"
* category 1..* MS
* category ^short = "v2-0074 LAB"
* code MS
* code from LabOrderTestCodes (extensible)
* code ^comment = "Same codings as the order: concept UUID, LOINC 20447-9 and DISA HIVVL. LOINC 20447-9 triggers the Lesotho HIV viral-load handling."
* subject 1..1 MS
* subject only Reference(Patient)
* encounter 1..1 MS
* encounter only Reference(Encounter)
* encounter ^comment = "Set by Lab on FHIR to the Task's encounter when the report is saved in OpenMRS."
* issued 1..1 MS
* basedOn 0..0
* basedOn ^comment = "Not served by FHIR2. Link a report to its order through Task.output (Task.basedOn → ServiceRequest)."
* result 1..* MS
* result only Reference(LabResultObservation)
* result ^comment = "Viral-load reports observed with 1 result (HIVVL-HIVVH low value) or 2 results (HIVVL-HIVVM copies/ml + HIVVL-HIVML log)."

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
* code ^comment = "Observed: DISA HIVVL-HIVVM + LOINC 70241-5 (copies/ml), DISA HIVVL-HIVML + LOINC 51780-5 (log10), DISA HIVVL-HIVVH (low value, coded LDL). Always with the concept-UUID coding."
* subject 1..1 MS
* subject only Reference(Patient)
* encounter 1..1 MS
* encounter only Reference(Encounter)
* effective[x] MS
* issued MS
* basedOn 0..0
* basedOn ^comment = "Lab on FHIR sets basedOn before saving, but FHIR2 does not persist or serve it (0 of 78 results)."
* category 0..0
* category ^comment = "Not populated on imported results (0 of 78)."
* value[x] MS
* value[x] only Quantity or CodeableConcept

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
