// ---------------------------------------------------------------------------
// Examples for the DRAFT Bonolo prescription workflow (design of 2026-11-23).
// Concept, drug and identifier-type UUIDs are real (concept dictionary
// 2026-11-06). People, facility, identifier values, order numbers and dates
// are SYNTHETIC. Readable ids are used instead of UUIDs.
// ---------------------------------------------------------------------------

Instance: example-bonolo-patient
InstanceOf: BonoloPrescriptionPatient
Title: "Bonolo patient"
Description: "Synthetic patient after the push has filtered identifiers, typed the Primary Contact and removed person-attribute extensions."
* identifier[patientIdentifier].system = $id-patient
* identifier[patientIdentifier].value = "B10110000001"
* identifier[patientIdentifier].use = #official
* identifier[nationalId].system = $id-national
* identifier[nationalId].value = "000000000001"
* identifier[hivProgramId].system = $id-hiv
* identifier[hivProgramId].value = "0000001/01-26"
* identifier[newHivProgramId].system = $id-new-hiv
* identifier[newHivProgramId].value = "00000001"
* active = true
* name[0].family = "EXAMPLE"
* name[0].given[0] = "LINEO"
* telecom[0].system = #phone
* telecom[0].use = #mobile
* telecom[0].value = "50000000"
* gender = #female
* birthDate = "1988-07-03"

Instance: example-bonolo-prescriber
InstanceOf: Practitioner
Title: "Prescriber"
* identifier[0].system = $provider-identifier
* identifier[0].value = "000-2"
* active = true
* name[0].family = "Prescriber"
* name[0].given[0] = "Example"

Instance: example-bonolo-facility
InstanceOf: BonoloFacilityLocation
Title: "Originating facility"
Description: "Parent location of the encounter location, with its IdentifierSourceName code. Synthetic name and code."
* identifier[facilityCode].system = $id-facility
* identifier[facilityCode].value = "X000"
* name = "Example Health Centre"
* status = #active

Instance: example-bonolo-tld
InstanceOf: BonoloPrescriptionMedication
Title: "TDF-3TC-DTG 300/300/50mg"
Description: "Drug 189a5fc2-d29b-4ce5-b3ca-dc5405228bfc (concept 9d155660-c16e-42d8-bff1-76cebe867e56) from the eRegister dictionary."
* code.coding[0].system = $eregister-concept
* code.coding[0].code = #9d155660-c16e-42d8-bff1-76cebe867e56
* code.text = "1j=TDF-3TC-DTG"
* status = #active
* extension[0].url = $openmrs-medicine
* extension[0].extension[0].url = "http://fhir.openmrs.org/ext/medicine#drugName"
* extension[0].extension[0].valueString = "1j=TDF-3TC-DTG 300/300/50mg"
* extension[0].extension[1].url = "http://fhir.openmrs.org/ext/medicine#strength"
* extension[0].extension[1].valueString = "300/300/50mg"

Instance: example-bonolo-regimen
InstanceOf: BonoloRegimenObservation
Title: "Regimen: 1j=TDF-3TC-DTG"
* status = #final
* code = $eregister-concept#13382e01-9f18-488b-b2d2-58ab54c82d82 "HIVTC, ART Regimen"
* subject = Reference(example-bonolo-patient)
* effectiveDateTime = "2026-11-20T09:15:00+02:00"
* valueCodeableConcept.coding[0] = $eregister-concept#225b0d93-d4b9-46b0-bbb2-1bce82c9107c "1j=TDF-3TC-DTG"
* valueCodeableConcept.coding[1] = $disa#TDF5 "1j=TDF-3TC-DTG"

Instance: example-bonolo-pickup-point
InstanceOf: BonoloPickupPointObservation
Title: "Pickup point: e-locker, Maseru, Pioneer Mall"
* status = #final
* code = $eregister-concept#cfee8964-e9b0-4a09-8ad7-fb48bd643a46 "E-locker Pickup Location Maseru"
* subject = Reference(example-bonolo-patient)
* effectiveDateTime = "2026-11-20T09:15:00+02:00"
* valueCodeableConcept = $eregister-concept#bb21afd5-ebba-4efb-b3e1-bd61e8c90c6f "Pioneer Mall"
* component[pickupType].code = $eregister-concept#c128a7a7-45e9-4313-a49a-75b67b060456 "Pick-up Locker Type"
* component[pickupType].valueCodeableConcept = $eregister-concept#59b6f57b-770c-4168-9a79-f910dd6cb19f "E-locker"
* component[pickupDistrict].code = $eregister-concept#79186178-1fed-4645-9d12-bfac0956ac56 "Pick-up District"
* component[pickupDistrict].valueCodeableConcept = $eregister-concept#bd84b856-7699-49d9-a8cf-baad451d54d1 "Pick-up District Maseru"

Instance: example-bonolo-next-pickup
InstanceOf: BonoloNextPickupDateObservation
Title: "Next pickup date"
* status = #final
* code = $eregister-concept#9f2696bd-9c81-4ee8-9844-e6c77cd19e03 "HIVTC, Bonolo Health next collection date"
* subject = Reference(example-bonolo-patient)
* effectiveDateTime = "2026-11-20T09:15:00+02:00"
* valueDateTime = "2027-02-18"

Instance: example-bonolo-medication-request
InstanceOf: BonoloPrescriptionMedicationRequest
Title: "Drug line: TDF-3TC-DTG, 90 days"
Description: "One drug line. Dosage text is the readable form of Bahmni's JSON {\"instructions\":\"Once a day\",\"additionalInstructions\":\"Take in the morning\"}."
* extension[originatingFacility].valueReference = Reference(example-bonolo-facility)
* identifier[orderNumber].system = $id-order-number
* identifier[orderNumber].value = "ORD-0001"
* groupIdentifier.system = $id-prescription
* groupIdentifier.value = "00000000-0000-4000-8000-000000000001"
* status = #active
* intent = #order
* medicationReference = Reference(example-bonolo-tld)
* subject = Reference(example-bonolo-patient)
* authoredOn = "2026-11-20T09:15:00+02:00"
* requester = Reference(example-bonolo-prescriber)
* supportingInformation[0] = Reference(example-bonolo-regimen)
* supportingInformation[1] = Reference(example-bonolo-pickup-point)
* supportingInformation[2] = Reference(example-bonolo-next-pickup)
* dosageInstruction[0].text = "1 tablet, orally, once a day, for 90 days. Once a day."
* dosageInstruction[0].additionalInstruction[0].text = "Take in the morning"
* dosageInstruction[0].timing.repeat.duration = 90
* dosageInstruction[0].timing.repeat.durationUnit = #d
* dosageInstruction[0].doseAndRate[0].doseQuantity = 1 'tablet' "Tablet"
* dispenseRequest.quantity = 90 'tablet' "Tablet"

Instance: example-bonolo-prescription-bundle
InstanceOf: BonoloPrescriptionBundle
Title: "Bonolo prescription transaction"
Description: "One prescription (one drug line) as the push would send it to HAPI."
* type = #transaction
* entry[0].fullUrl = "http://hapi.example.org/fhir/Patient/example-bonolo-patient"
* entry[0].resource = example-bonolo-patient
* entry[0].request.method = #PUT
* entry[0].request.url = "Patient/example-bonolo-patient"
* entry[1].fullUrl = "http://hapi.example.org/fhir/Practitioner/example-bonolo-prescriber"
* entry[1].resource = example-bonolo-prescriber
* entry[1].request.method = #PUT
* entry[1].request.url = "Practitioner/example-bonolo-prescriber"
* entry[2].fullUrl = "http://hapi.example.org/fhir/Location/example-bonolo-facility"
* entry[2].resource = example-bonolo-facility
* entry[2].request.method = #PUT
* entry[2].request.url = "Location/example-bonolo-facility"
* entry[3].fullUrl = "http://hapi.example.org/fhir/Medication/example-bonolo-tld"
* entry[3].resource = example-bonolo-tld
* entry[3].request.method = #PUT
* entry[3].request.url = "Medication/example-bonolo-tld"
* entry[4].fullUrl = "http://hapi.example.org/fhir/Observation/example-bonolo-regimen"
* entry[4].resource = example-bonolo-regimen
* entry[4].request.method = #PUT
* entry[4].request.url = "Observation/example-bonolo-regimen"
* entry[5].fullUrl = "http://hapi.example.org/fhir/Observation/example-bonolo-pickup-point"
* entry[5].resource = example-bonolo-pickup-point
* entry[5].request.method = #PUT
* entry[5].request.url = "Observation/example-bonolo-pickup-point"
* entry[6].fullUrl = "http://hapi.example.org/fhir/Observation/example-bonolo-next-pickup"
* entry[6].resource = example-bonolo-next-pickup
* entry[6].request.method = #PUT
* entry[6].request.url = "Observation/example-bonolo-next-pickup"
* entry[7].fullUrl = "http://hapi.example.org/fhir/MedicationRequest/example-bonolo-medication-request"
* entry[7].resource = example-bonolo-medication-request
* entry[7].request.method = #PUT
* entry[7].request.url = "MedicationRequest/example-bonolo-medication-request"

Instance: example-bonolo-dispense
InstanceOf: BonoloMedicationDispense
Title: "Dispensed at the e-locker"
Description: "Written by the dispensing system. OpenMRS maps `completed` to fulfiller status COMPLETED and Dispensed = true."
* status = #completed
* medicationReference = Reference(example-bonolo-tld)
* subject = Reference(example-bonolo-patient)
* authorizingPrescription = Reference(example-bonolo-medication-request)
* quantity = 90 'tablet' "Tablet"
* whenHandedOver = "2026-11-21T14:02:00+02:00"
