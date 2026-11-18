// ---------------------------------------------------------------------------
// Synthetic examples. No real patient data. In OpenMRS every id is a UUID;
// readable ids are used here for clarity.
// ---------------------------------------------------------------------------

Instance: example-patient
InstanceOf: Patient
Title: "Example patient"
Description: "Synthetic patient as FHIR2 would serve it, with the identifier system registered by Lab on FHIR."
* identifier[0].use = #official
* identifier[0].system = $openlis-id
* identifier[0].value = "LS-0000123"
* name[0].family = "Example"
* name[0].given[0] = "Palesa"
* gender = #female
* birthDate = "1990-04-12"
* address[0].city = "Maseru"
* address[0].country = "Lesotho"

Instance: example-lis-user
InstanceOf: Practitioner
Title: "LIS service user"
Description: "The Practitioner that represents the LIS (global property labonfhir.lisUserUuid). It is the owner of every lab-order Task."
* identifier[0].system = "http://fhir.openmrs.org/ext/provider/identifier"
* identifier[0].value = "LIS"
* name[0].text = "LIS service user"

Instance: example-clinician
InstanceOf: Practitioner
Title: "Ordering clinician"
* identifier[0].system = "http://fhir.openmrs.org/ext/provider/identifier"
* identifier[0].value = "PRV-001"
* name[0].family = "Clinician"
* name[0].given[0] = "Example"

Instance: example-location
InstanceOf: Location
Title: "Example clinic"
* status = #active
* name = "Example Health Centre"
* address.city = "Maseru"
* address.country = "Lesotho"

Instance: example-encounter
InstanceOf: Encounter
Title: "Lab encounter"
Description: "Encounter in which the order was placed. FHIR2 tags OpenMRS encounters with the encounter-tag code system."
* meta.tag[0] = $encounter-tag#encounter "Encounter"
* status = #unknown
* class = http://terminology.hl7.org/CodeSystem/v3-ActCode#AMB "ambulatory"
* subject = Reference(example-patient)
* participant[0].individual = Reference(example-clinician)
* period.start = "2026-11-18T09:15:00+02:00"
* location[0].location = Reference(example-location)

Instance: example-supporting-cd4
InstanceOf: Observation
Title: "Supporting observation: Last CD4 (with DISA coding)"
Description: "Clinical-context observation sent with the order. Lab on FHIR adds the DISA coding LCD4 before sending."
* status = #final
* code.coding[0].code = #5497AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
* code.coding[0].display = "Last CD4"
* code.coding[1] = $disa#LCD4 "Last CD4"
* subject = Reference(example-patient)
* encounter = Reference(example-encounter)
* effectiveDateTime = "2026-05-02"
* valueQuantity = 412 'cells/uL' "cells/µL"

Instance: example-vl-order
InstanceOf: LabOrderServiceRequest
Title: "Viral-load test order"
Description: "HIV viral-load order as FHIR2 serves it from test_order. The first coding is the OpenMRS concept UUID (CIEL 856 shown as an example)."
* status = #active
* intent = #order
* code.coding[0].code = #856AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
* code.coding[0].display = "HIV viral load"
* code.coding[1] = $loinc#20447-9 "HIV 1 RNA [#/volume] (viral load) in Serum or Plasma by Probe and target amplification method"
* subject = Reference(example-patient)
* encounter = Reference(example-encounter)
* requester = Reference(example-clinician)
* occurrenceDateTime = "2026-11-18T09:20:00+02:00"
* supportingInfo[0] = Reference(example-supporting-cd4)

Instance: example-task-requested
InstanceOf: LabOrderTask
Title: "Lab order Task (requested)"
Description: "Task created by Lab on FHIR in OpenMRS and sent to the LIS."
* identifier[openmrsTaskId].system = $task-identifier
* identifier[openmrsTaskId].value = "example-task-requested"
* status = #requested
* intent = #order
* basedOn[0] = Reference(example-vl-order)
* for = Reference(example-patient)
* encounter = Reference(example-encounter)
* owner = Reference(example-lis-user)
* requester = Reference(example-clinician)
* authoredOn = "2026-11-18T09:20:05+02:00"

Instance: example-lab-order-bundle
InstanceOf: LabOrderTransactionBundle
Title: "Transaction sent to the LIS"
Description: "The Bundle that Lab on FHIR POSTs to labonfhir.lisUrl for the Task above. Every entry is a PUT so ids are preserved."
* type = #transaction
* entry[0].fullUrl = "http://example.org/fhir/Task/example-task-requested"
* entry[0].resource = example-task-requested
* entry[0].request.method = #PUT
* entry[0].request.url = "Task/example-task-requested"
* entry[1].fullUrl = "http://example.org/fhir/Patient/example-patient"
* entry[1].resource = example-patient
* entry[1].request.method = #PUT
* entry[1].request.url = "Patient/example-patient"
* entry[2].fullUrl = "http://example.org/fhir/Practitioner/example-lis-user"
* entry[2].resource = example-lis-user
* entry[2].request.method = #PUT
* entry[2].request.url = "Practitioner/example-lis-user"
* entry[3].fullUrl = "http://example.org/fhir/Encounter/example-encounter"
* entry[3].resource = example-encounter
* entry[3].request.method = #PUT
* entry[3].request.url = "Encounter/example-encounter"
* entry[4].fullUrl = "http://example.org/fhir/ServiceRequest/example-vl-order"
* entry[4].resource = example-vl-order
* entry[4].request.method = #PUT
* entry[4].request.url = "ServiceRequest/example-vl-order"
* entry[5].fullUrl = "http://example.org/fhir/Location/example-location"
* entry[5].resource = example-location
* entry[5].request.method = #PUT
* entry[5].request.url = "Location/example-location"
* entry[6].fullUrl = "http://example.org/fhir/Observation/example-supporting-cd4"
* entry[6].resource = example-supporting-cd4
* entry[6].request.method = #PUT
* entry[6].request.url = "Observation/example-supporting-cd4"

Instance: example-vl-result
InstanceOf: LabResultObservation
Title: "Viral-load result from the LIS"
* status = #final
* category[0] = $obs-category#laboratory
* code = $loinc#20447-9 "HIV 1 RNA [#/volume] (viral load) in Serum or Plasma by Probe and target amplification method"
* subject = Reference(example-patient)
* encounter = Reference(example-encounter)
* basedOn[0] = Reference(example-vl-order)
* effectiveDateTime = "2026-11-20T14:02:00+02:00"
* valueQuantity = 40 '{copies}/mL' "copies/mL"

Instance: example-vl-category
InstanceOf: Observation
Title: "Derived HIVTCVL observation"
Description: "Observation that Lab on FHIR derives from the viral-load result: 40 copies/ml becomes '>=20'."
* status = #final
* code = $disa#HIVTCVL "HIVTC, Viral Load"
* subject = Reference(example-patient)
* encounter = Reference(example-encounter)
* basedOn[0] = Reference(example-vl-order)
* effectiveDateTime = "2026-11-20T14:02:00+02:00"
* valueCodeableConcept = $disa#">=20" "Greater or Equal to 20 copies/ml"

Instance: example-vl-report
InstanceOf: LabResultDiagnosticReport
Title: "Viral-load DiagnosticReport"
* status = #final
* category[0] = $diag-service#LAB "Laboratory"
* code = $loinc#20447-9 "HIV 1 RNA [#/volume] (viral load) in Serum or Plasma by Probe and target amplification method"
* subject = Reference(example-patient)
* encounter = Reference(example-encounter)
* basedOn[0] = Reference(example-vl-order)
* issued = "2026-11-20T14:05:00+02:00"
* result[0] = Reference(example-vl-result)

Instance: example-task-completed
InstanceOf: LabOrderTask
Title: "Lab order Task (completed by the LIS)"
Description: "The same Task after the LIS completed it. Lab on FHIR finds it with its 30-second poll and imports the DiagnosticReport in output."
* identifier[openmrsTaskId].system = $task-identifier
* identifier[openmrsTaskId].value = "example-task-requested"
* status = #completed
* intent = #order
* basedOn[0] = Reference(example-vl-order)
* for = Reference(example-patient)
* encounter = Reference(example-encounter)
* owner = Reference(example-lis-user)
* authoredOn = "2026-11-18T09:20:05+02:00"
* lastModified = "2026-11-20T14:05:30+02:00"
* output[0].type = $loinc#20447-9
* output[0].valueReference = Reference(example-vl-report)
