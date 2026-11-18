// ---------------------------------------------------------------------------
// Examples modelled on the live instance (customised FHIR2 1.9.0-SNAPSHOT,
// checked 2026-11-18). Structure, code systems, codes and OpenMRS concept /
// metadata UUIDs are copied from real resources. People, facility, identifier
// values and dates are SYNTHETIC. Readable ids are used instead of UUIDs.
// Deviations from what the server emits are called out in each Description.
// ---------------------------------------------------------------------------

Instance: example-patient
InstanceOf: Patient
Title: "Example patient"
Description: "Synthetic patient shaped like FHIR2's output on the live instance: four OpenMRS identifier types, none with a `system` (no identifier type is mapped in `fhir_patient_identifier_system`). The type coding is the identifier-type UUID without a system."
* identifier[0].use = #official
* identifier[0].type.coding[0].code = #81433852-3f10-11e4-adec-0800271c1b75
* identifier[0].type.text = "Patient Identifier"
* identifier[0].value = "X0000000001/26"
* identifier[1].use = #usual
* identifier[1].type.coding[0].code = #5c1e8ae2-33c6-11e8-8236-0242ac110002
* identifier[1].type.text = "HIV Program ID"
* identifier[1].value = "A0000001/26"
* identifier[2].use = #usual
* identifier[2].type.coding[0].code = #d2084c23-edae-4b0f-98a2-cbcdb6708294
* identifier[2].type.text = "File Number"
* identifier[2].value = "0001"
* identifier[3].use = #usual
* identifier[3].type.coding[0].code = #0d2ac572-8de3-46c8-9976-1f78899c599f
* identifier[3].type.text = "National ID"
* identifier[3].value = "000000000001"
* active = true
* name[0].family = "EXAMPLE"
* name[0].given[0] = "PALESA"
* telecom[0].value = "50000000"
* gender = #female
* birthDate = "1990-04-12"
* deceasedBoolean = false
* address[0].use = #home
* address[0].extension[0].url = "http://fhir.openmrs.org/ext/address"
* address[0].extension[0].extension[0].url = "http://fhir.openmrs.org/ext/address#address2"
* address[0].extension[0].extension[0].valueString = "MASERU"
* address[0].city = "EXAMPLE VILLAGE"
* address[0].state = "MASERU"

Instance: example-lis-user
InstanceOf: Practitioner
Title: "Task owner (labonfhir.lisUserUuid)"
Description: "The Practitioner that owns every lab-order Task. On the live instance `labonfhir.lisUserUuid` points at the provider of the built-in `superman` account (id `c1c26908-3f10-11e4-adec-0800271c1b75`), shown here as-is. See Findings."
* identifier[0].system = $provider-identifier
* identifier[0].value = "superman"
* active = true
* name[0].family = "Man"
* name[0].given[0] = "Super"
* gender = #male

Instance: example-clinician
InstanceOf: Practitioner
Title: "Ordering clinician"
* identifier[0].system = $provider-identifier
* identifier[0].value = "000-1"
* active = true
* name[0].family = "Clinician"
* name[0].given[0] = "Example"

Instance: example-location
InstanceOf: Location
Title: "ART Clinic"
Description: "Clinic location as served on the live instance, with OpenMRS location tags."
* meta.tag[0] = $location-tag#"Visit Location" "Visit Location"
* meta.tag[1] = $location-tag#"Login Location" "When a user logs in and chooses a session location, they may only choose one with this tag"
* status = #active
* name = "ART Clinic"
* description = "ART Clinic"

Instance: example-visit
InstanceOf: Encounter
Title: "Visit (parent Encounter)"
Description: "OpenMRS visit served as an Encounter tagged `visit`. Lab-order encounters point to it through partOf."
* meta.tag[0] = $encounter-tag#visit "Visit"
* status = #unknown
* class = http://terminology.hl7.org/CodeSystem/v3-ActCode#AMB
* subject = Reference(example-patient)
* period.start = "2026-11-18T09:00:00+02:00"

Instance: example-encounter
InstanceOf: Encounter
Title: "Lab-order encounter"
Description: "Encounter in which the order was placed, as served on the live instance: type Consultation, one participant (with identifier and display), location ART Clinic, partOf the visit."
* meta.tag[0] = $encounter-tag#encounter "Encounter"
* status = #unknown
* class = http://terminology.hl7.org/CodeSystem/v3-ActCode#AMB
* type[0] = $encounter-type#81852aee-3f10-11e4-adec-0800271c1b75 "Consultation"
* subject = Reference(example-patient)
* subject.display = "PALESA EXAMPLE (Patient Identifier: X0000000001/26)"
* participant[0].individual = Reference(example-clinician)
* participant[0].individual.identifier.value = "000-1"
* participant[0].individual.display = "Example Clinician (Identifier: 000-1)"
* period.start = "2026-11-18T09:15:00+02:00"
* location[0].location = Reference(example-location)
* location[0].location.display = "ART Clinic"
* partOf = Reference(example-visit)

Instance: example-earlier-encounter
InstanceOf: Encounter
Title: "Earlier encounter (source of supporting observations)"
Description: "The supporting observations of a lab order are taken from earlier encounters, not the order's encounter."
* meta.tag[0] = $encounter-tag#encounter "Encounter"
* status = #unknown
* class = http://terminology.hl7.org/CodeSystem/v3-ActCode#AMB
* type[0] = $encounter-type#81852aee-3f10-11e4-adec-0800271c1b75 "Consultation"
* subject = Reference(example-patient)
* period.start = "2026-05-02T10:00:00+02:00"
* location[0].location = Reference(example-location)

Instance: example-supporting-regimen
InstanceOf: Observation
Title: "Supporting observation: Current Regimen"
Description: "'HIVTC, ART Regimen' observation referenced from ServiceRequest.supportingInfo (display 'Current Regimen'). Codings as served by FHIR2: concept UUID, CIEL, LOINC; the value carries CIEL, DISA and SNOMED CT codings."
* status = #final
* code.coding[0].code = #13382e01-9f18-488b-b2d2-58ab54c82d82
* code.coding[0].display = "HIVTC, ART Regimen"
* code.coding[1] = $ciel#162240 "HIVTC, ART Regimen"
* code.coding[2] = $loinc#45260-7 "HIVTC, ART Regimen"
* code.text = "HIVTC, ART Regimen"
* subject = Reference(example-patient)
* encounter = Reference(example-earlier-encounter)
* effectiveDateTime = "2026-05-02T10:00:00+02:00"
* valueCodeableConcept.coding[0].code = #225b0d93-d4b9-46b0-bbb2-1bce82c9107c
* valueCodeableConcept.coding[0].display = "1j=TDF-3TC-DTG"
* valueCodeableConcept.coding[1] = $ciel#163565 "1j=TDF-3TC-DTG"
* valueCodeableConcept.coding[2] = $disa#TDF5 "1j=TDF-3TC-DTG"
* valueCodeableConcept.coding[3] = $sct#228468006 "1j=TDF-3TC-DTG"
* valueCodeableConcept.text = "1j=TDF-3TC-DTG"

Instance: example-supporting-vl-reason
InstanceOf: Observation
Title: "Supporting observation: VL Reason"
Description: "'HIVTC, Viral Load Monitoring Type' observation referenced from ServiceRequest.supportingInfo (display 'VL Reason')."
* status = #final
* code.coding[0].code = #2fd65680-9341-433a-b618-87216cec96f5
* code.coding[0].display = "HIVTC, Viral Load Monitoring Type"
* code.coding[1] = $disa#RFVL "HIVTC, Viral Load Monitoring Type"
* code.text = "HIVTC, Viral Load Monitoring Type"
* subject = Reference(example-patient)
* encounter = Reference(example-earlier-encounter)
* effectiveDateTime = "2026-05-02T10:00:00+02:00"
* valueCodeableConcept.coding[0].code = #9211c58c-37ed-4f06-b094-6640598f71e1
* valueCodeableConcept.coding[0].display = "Routine"
* valueCodeableConcept.coding[1] = $disa#ROUT "Routine"
* valueCodeableConcept.text = "Routine"

Instance: example-vl-order
InstanceOf: LabOrderServiceRequest
Title: "Viral-load test order"
Description: """
HIV viral-load order as the customised FHIR2 serves it. Facility name/code and the order number are synthetic.
**Deviations:** (1) the live server does not set `specimen`; it is added here so that the contained Specimen is referenced
(invariant dom-3). (2) The live server sends `requisition.system = "eRegister Lab order number"`, which is not a valid
uri; it is left out here.
"""
* contained[0] = example-specimen
* identifier[serviceReqId].system = "ServiceReq_id"
* identifier[serviceReqId].value = "example-vl-order"
* identifier[facilityName].system = "Facility_name"
* identifier[facilityName].value = "Example Health Centre"
* identifier[facilityCode].system = "Facility_code"
* identifier[facilityCode].value = "X0000"
* requisition.value = "XDEP000001"
* status = #completed
* intent = #order
* code.coding[0].code = #92d73e24-122e-4f3e-8447-fb972f01b617
* code.coding[0].display = "HIVTC, Lab Test, Viral Load"
* code.coding[1] = $loinc#20447-9 "HIVTC, Lab Test, Viral Load"
* code.coding[2] = $disa#HIVVL "HIVTC, Lab Test, Viral Load"
* code.text = "HIVTC, Lab Test, Viral Load"
* subject = Reference(example-patient)
* subject.display = "PALESA EXAMPLE (Patient Identifier: X0000000001/26)"
* encounter = Reference(example-encounter)
* occurrencePeriod.start = "2026-11-18T09:20:00+02:00"
* occurrencePeriod.end = "2026-11-18T10:20:00+02:00"
* requester = Reference(example-clinician)
* requester.identifier.value = "000-1"
* requester.display = "Example Clinician (Identifier: 000-1)"
* specimen[0] = Reference(example-specimen)
* supportingInfo[0] = Reference(example-supporting-regimen)
* supportingInfo[0].display = "Current Regimen"
* supportingInfo[1] = Reference(example-supporting-vl-reason)
* supportingInfo[1].display = "VL Reason"

Instance: example-specimen
InstanceOf: Specimen
Usage: #inline
* type.coding[0].code = #23c1ac3f-9aa9-4261-b434-622dab8fe2bd
* type.coding[0].display = "Blood"
* type.coding[1] = $disa#B "Blood"
* type.text = "Blood"
* collection.collectedDateTime = "2026-11-18T09:10:00+02:00"

Instance: example-task-requested
InstanceOf: LabOrderTask
Title: "Lab order Task (requested)"
Description: "Task created by Lab on FHIR in OpenMRS and sent to the LIS, as served by FHIR2 (no requester, one identifier)."
* identifier[openmrsTaskId].system = $task-identifier
* identifier[openmrsTaskId].value = "example-task-requested"
* status = #requested
* intent = #order
* basedOn[0] = Reference(example-vl-order)
* for = Reference(example-patient)
* encounter = Reference(example-encounter)
* authoredOn = "2026-11-18T09:20:00+02:00"
* lastModified = "2026-11-18T09:20:00+02:00"
* owner = Reference(example-lis-user)

Instance: example-lab-order-bundle
InstanceOf: LabOrderTransactionBundle
Title: "Transaction sent to the LIS"
Description: "The Bundle that Lab on FHIR POSTs to labonfhir.lisUrl for the Task above. Every entry is a PUT so ids are preserved. Built from the resources above; the outbound transaction itself was not captured on the live instance."
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
* entry[6].fullUrl = "http://example.org/fhir/Observation/example-supporting-regimen"
* entry[6].resource = example-supporting-regimen
* entry[6].request.method = #PUT
* entry[6].request.url = "Observation/example-supporting-regimen"
* entry[7].fullUrl = "http://example.org/fhir/Observation/example-supporting-vl-reason"
* entry[7].resource = example-supporting-vl-reason
* entry[7].request.method = #PUT
* entry[7].request.url = "Observation/example-supporting-vl-reason"

Instance: example-vl-result
InstanceOf: LabResultObservation
Title: "Viral-load result (copies/ml)"
Description: "Imported viral-load result as served by FHIR2: DISA HIVVL-HIVVM + LOINC 70241-5, valueQuantity in copies/ml without a UCUM system, no category, no basedOn."
* status = #final
* code.coding[0].code = #9b3aaaa6-bd62-4d85-8f2a-acf3be85f8b0
* code.coding[0].display = "DISA, VL Result [#/vol]"
* code.coding[1] = $disa#HIVVL-HIVVM "DISA, VL Result [#/vol]"
* code.coding[2] = $loinc#70241-5 "DISA, VL Result [#/vol]"
* code.text = "DISA, VL Result [#/vol]"
* subject = Reference(example-patient)
* encounter = Reference(example-encounter)
* effectiveDateTime = "2026-11-20T14:02:00+02:00"
* issued = "2026-11-20T14:05:30.000+02:00"
* valueQuantity.value = 59
* valueQuantity.unit = "copies/ml"

Instance: example-vl-result-log
InstanceOf: LabResultObservation
Title: "Viral-load result (log10)"
Description: "Companion log10 result: DISA HIVVL-HIVML + LOINC 51780-5, valueQuantity without a unit."
* status = #final
* code.coding[0].code = #204a3e0d-9a3c-4d0a-8e0c-457875a9e363
* code.coding[0].display = "DISA, VL Result [log#/vol]"
* code.coding[1] = $loinc#51780-5 "DISA, VL Result [log#/vol]"
* code.coding[2] = $disa#HIVVL-HIVML "DISA, VL Result [log#/vol]"
* code.text = "DISA, VL Result [log#/vol]"
* subject = Reference(example-patient)
* encounter = Reference(example-encounter)
* effectiveDateTime = "2026-11-20T14:02:00+02:00"
* issued = "2026-11-20T14:05:30.000+02:00"
* valueQuantity.value = 1.77

Instance: example-vl-result-ldl
InstanceOf: LabResultObservation
Title: "Viral-load result (lower than detectable limit)"
Description: "Low-value viral-load result: DISA HIVVL-HIVVH with coded value LDL."
* status = #final
* code.coding[0].code = #ea8abb19-180f-48cf-8500-2c0aa6b7b77d
* code.coding[0].display = "DISA, VL Result (low value)"
* code.coding[1] = $disa#HIVVL-HIVVH "DISA, VL Result (low value)"
* code.text = "DISA, VL Result (low value)"
* subject = Reference(example-patient)
* encounter = Reference(example-encounter)
* effectiveDateTime = "2026-11-20T14:02:00+02:00"
* issued = "2026-11-20T14:05:30.000+02:00"
* valueCodeableConcept.coding[0].code = #f03f0d4a-7daf-4979-ab94-a04eea3419f7
* valueCodeableConcept.coding[0].display = "DISA, VL Lower Than Detectable Limit"
* valueCodeableConcept.coding[1] = $disa#LDL "DISA, VL Lower Than Detectable Limit"
* valueCodeableConcept.text = "DISA, VL Lower Than Detectable Limit"

Instance: example-vl-category
InstanceOf: Observation
Title: "Derived HIVTCVL observation (from code analysis)"
Description: "Observation that Lab on FHIR 1.3.1 code derives from a viral-load result (59 copies/ml becomes '>=20'). **Not observed on the live instance**: a code search for HIVTCVL returned no observations. Kept to document the code path."
* status = #final
* code = $disa#HIVTCVL "HIVTC, Viral Load"
* subject = Reference(example-patient)
* encounter = Reference(example-encounter)
* effectiveDateTime = "2026-11-20T14:02:00+02:00"
* valueCodeableConcept = $disa#">=20" "Greater or Equal to 20 copies/ml"

Instance: example-vl-report
InstanceOf: LabResultDiagnosticReport
Title: "Viral-load DiagnosticReport"
Description: "Report as served by FHIR2: category LAB, the order's three codings, issued, two results, no basedOn."
* status = #final
* category[0] = $diag-service#LAB
* code.coding[0].code = #92d73e24-122e-4f3e-8447-fb972f01b617
* code.coding[0].display = "HIVTC, Lab Test, Viral Load"
* code.coding[1] = $loinc#20447-9 "HIVTC, Lab Test, Viral Load"
* code.coding[2] = $disa#HIVVL "HIVTC, Lab Test, Viral Load"
* code.text = "HIVTC, Lab Test, Viral Load"
* subject = Reference(example-patient)
* subject.display = "PALESA EXAMPLE (Patient Identifier: X0000000001/26)"
* encounter = Reference(example-encounter)
* issued = "2026-11-20T14:02:00.000+02:00"
* result[0] = Reference(example-vl-result)
* result[1] = Reference(example-vl-result-log)

Instance: example-task-completed
InstanceOf: LabOrderTask
Title: "Lab order Task (completed by the LIS)"
Description: """
The same Task after the LIS completed it and Lab on FHIR imported the results.
**Deviation:** the live server serves `output.valueReference.reference` as the bare report id (`"example-vl-report"`);
here it is written as `DiagnosticReport/example-vl-report` so that it resolves. See Findings.
"""
* identifier[openmrsTaskId].system = $task-identifier
* identifier[openmrsTaskId].value = "example-task-requested"
* status = #completed
* intent = #order
* basedOn[0] = Reference(example-vl-order)
* for = Reference(example-patient)
* encounter = Reference(example-encounter)
* authoredOn = "2026-11-18T09:20:00+02:00"
* lastModified = "2026-11-20T14:05:30+02:00"
* owner = Reference(example-lis-user)
* output[0].type.coding[0].code = #92d73e24-122e-4f3e-8447-fb972f01b617
* output[0].type.coding[0].display = "HIVTC, Lab Test, Viral Load"
* output[0].type.coding[1] = $loinc#20447-9 "HIVTC, Lab Test, Viral Load"
* output[0].type.coding[2] = $disa#HIVVL "HIVTC, Lab Test, Viral Load"
* output[0].type.text = "HIVTC, Lab Test, Viral Load"
* output[0].valueReference = Reference(example-vl-report)
