// ---------------------------------------------------------------------------
// Bonolo prescription workflow: OpenMRS -> HAPI FHIR -> dispensing system.
// STATUS: DRAFT. These profiles describe an AGREED DESIGN (2026-11-23), not
// current behaviour. Nothing sends prescriptions yet: the push is to be added
// to the eRegister Lab on FHIR fork as a separate prescription handler.
// See the Prescription Workflow page.
// ---------------------------------------------------------------------------

RuleSet: DraftProfile
* ^status = #draft
* ^publisher = "Lesotho eRegister Team"
* ^experimental = false

Extension: OriginatingFacility
Id: originating-facility
Title: "Originating facility"
Description: "The facility where the prescription was written: the parent of the OpenMRS encounter location. MedicationRequest has no element for the ordering facility, so the push adds this extension."
Context: MedicationRequest
* insert DraftProfile
* value[x] only Reference(BonoloFacilityLocation)
* valueReference 1..1

Profile: BonoloPrescriptionPatient
Parent: Patient
Id: bonolo-prescription-patient
Title: "Bonolo Prescription Patient"
Description: """
The Patient as the prescription push sends it. It starts from FHIR2's Patient and then:
keeps only four identifier types, each with a system; keeps only the *Primary Contact* phone (`telephoneNumber`
attribute) with system `phone` and use `mobile`; and removes all OpenMRS person-attribute extensions.
"""
* insert DraftProfile
* extension 0..0
* extension ^comment = "The push removes every http://fhir.openmrs.org/ext/person-attribute extension (they include free-text next-of-kin and treatment-supporter details)."
* identifier 1..* MS
* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #closed
* identifier ^comment = "FHIR2 sends every active identifier. The push drops all except these four types (no Biometric Fingerprint ID, TB/ANC/PNC Program ID, ECID, File Number, OpenMRS ID or Old ID)."
* identifier contains patientIdentifier 1..1 MS and nationalId 0..1 MS and hivProgramId 0..1 MS and newHivProgramId 0..1 MS
* identifier[patientIdentifier].system = $id-patient (exactly)
* identifier[patientIdentifier].value 1..1
* identifier[patientIdentifier] ^short = "Bahmni Patient Identifier (required in Bahmni)"
* identifier[nationalId].system = $id-national (exactly)
* identifier[nationalId].value 1..1
* identifier[hivProgramId].system = $id-hiv (exactly)
* identifier[hivProgramId].value 1..1
* identifier[newHivProgramId].system = $id-new-hiv (exactly)
* identifier[newHivProgramId].value 1..1
* identifier[newHivProgramId] ^comment = "Receivers prefer this over hivProgramId when both are present."
* name 1..* MS
* name.family MS
* name.given MS
* gender 1..1 MS
* birthDate MS
* birthDate ^comment = "If OpenMRS marks the birth date as estimated, FHIR2 reduces its precision to the year (over 5 years old) or year and month."
* telecom 0..1 MS
* telecom ^short = "Primary Contact (person attribute telephoneNumber)"
* telecom.system 1..1
* telecom.system = #phone (exactly)
* telecom.use 1..1
* telecom.use = #mobile (exactly)
* telecom.value 1..1
* telecom obeys bonolo-phone-1
* address MS
* address ^comment = "Sent as FHIR2 produces it. Street lines (address1..15) appear only in the http://fhir.openmrs.org/ext/address extension; Address.line is empty."

Invariant: bonolo-phone-1
Description: "The Primary Contact is an 8-digit Lesotho number."
Expression: "value.matches('^[0-9]{8}$')"
Severity: #error

Profile: BonoloFacilityLocation
Parent: Location
Id: bonolo-facility-location
Title: "Bonolo Facility Location"
Description: "The originating facility: the parent of the encounter location, identified by its *IdentifierSourceName* location attribute. Facilities without that attribute must be fixed in OpenMRS; the `WXYZ` fallback used by the lab ServiceRequest is not used here."
* insert DraftProfile
* identifier 1..* MS
* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier contains facilityCode 1..1 MS
* identifier[facilityCode].system = $id-facility (exactly)
* identifier[facilityCode].value 1..1
* name 1..1 MS

Profile: BonoloPrescriptionMedication
Parent: Medication
Id: bonolo-prescription-medication
Title: "Bonolo Prescription Medication"
Description: "One OpenMRS drug, as FHIR2 serves it. Until concept mappings to a national or standard drug code exist, receivers match on the concept code plus drug name and strength."
* insert DraftProfile
* code 1..1 MS
* code.coding 1..* MS
* code.coding ^comment = "The drug's concept UUID. FHIR2 emits it without a system; the push adds system http://health.gov.ls/fhir/CodeSystem/eregister-concept."
* extension MS
* extension ^comment = "FHIR2's http://fhir.openmrs.org/ext/medicine extension carries the drug name (#drugName) and strength (#strength). Both are required by this design."
* form MS
* status MS

Profile: BonoloPrescriptionMedicationRequest
Parent: MedicationRequest
Id: bonolo-prescription-medication-request
Title: "Bonolo Prescription MedicationRequest"
Description: """
One drug line of a Bonolo prescription. A prescription is all drug orders written in one OpenMRS encounter; its lines
share `groupIdentifier`. OpenMRS is the **only** writer of MedicationRequests on HAPI: the dispensing system never changes
them and records dispensing as a [MedicationDispense](StructureDefinition-bonolo-medication-dispense.html).
"""
* insert DraftProfile
* extension contains OriginatingFacility named originatingFacility 1..1 MS
* identifier 1..* MS
* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier contains orderNumber 1..1 MS
* identifier[orderNumber].system = $id-order-number (exactly)
* identifier[orderNumber].value 1..1
* identifier[orderNumber] ^short = "OpenMRS order number, e.g. ORD-1234 (not sent by FHIR2; added by the push)"
* groupIdentifier 1..1 MS
* groupIdentifier.system 1..1
* groupIdentifier.system = $id-prescription (exactly)
* groupIdentifier.value 1..1
* groupIdentifier ^short = "Prescription number: the OpenMRS encounter UUID"
* status MS
* status ^comment = "As FHIR2 maps it: active; cancelled (discontinued or voided); stopped (expired); completed (fulfiller status COMPLETED, set after dispensing); unknown. Only `active` may be dispensed."
* intent = #order (exactly)
* medication[x] only Reference(BonoloPrescriptionMedication)
* medication[x] MS
* subject only Reference(BonoloPrescriptionPatient)
* subject MS
* encounter 0..0
* encounter ^comment = "Removed by the push. Sending the Encounter would also need the Visit encounter it points to (partOf), and the dispensing system needs neither."
* authoredOn 1..1 MS
* authoredOn ^short = "Prescription date and time"
* requester 1..1 MS
* requester only Reference(Practitioner)
* supportingInformation 3..* MS
* supportingInformation only Reference(BonoloRegimenObservation or BonoloPickupPointObservation or BonoloNextPickupDateObservation)
* supportingInformation ^short = "Regimen, pickup point and next pickup date (one of each)"
* dosageInstruction 1..* MS
* dosageInstruction.text 1..1 MS
* dosageInstruction.text ^comment = "Human-readable text. Bahmni stores dosing instructions as JSON ({\"instructions\":…,\"additionalInstructions\":…}); FHIR2 copies the raw JSON, so the push rewrites it."
* dosageInstruction.additionalInstruction MS
* dosageInstruction.additionalInstruction ^comment = "From the additionalInstructions part of Bahmni's JSON, as text."
* dosageInstruction.timing MS
* dosageInstruction.route MS
* dosageInstruction.doseAndRate MS
* dispenseRequest MS
* dispenseRequest.quantity MS
* priorPrescription MS
* priorPrescription ^comment = "The previous order when this line revises or discontinues one."

Profile: BonoloRegimenObservation
Parent: Observation
Id: bonolo-regimen-observation
Title: "Bonolo Regimen Observation"
Description: "The *HIVTC, ART Regimen* answer recorded in the same encounter as the drug orders."
* insert DraftProfile
* status = #final (exactly)
* code 1..1 MS
* code = $eregister-concept#13382e01-9f18-488b-b2d2-58ab54c82d82
* subject 1..1 MS
* subject only Reference(BonoloPrescriptionPatient)
* encounter 0..0
* effective[x] 1..1 MS
* effective[x] only dateTime
* value[x] 1..1 MS
* value[x] only CodeableConcept
* value[x] ^comment = "The regimen concept (system eregister-concept). A DISA coding (http://health.gov.ls/laboratory-services/) may also be present where the concept is mapped."

Profile: BonoloPickupPointObservation
Parent: Observation
Id: bonolo-pickup-point-observation
Title: "Bonolo Pickup Point Observation"
Description: """
Where the patient will collect the medication. `code` is the pickup-point **question** that was answered, which gives the
type and district; `value` is the **site**. The components repeat the type and district explicitly.
"""
* insert DraftProfile
* status = #final (exactly)
* code 1..1 MS
* code from BonoloPickupQuestions (required)
* subject 1..1 MS
* subject only Reference(BonoloPrescriptionPatient)
* encounter 0..0
* effective[x] 1..1 MS
* effective[x] only dateTime
* value[x] 1..1 MS
* value[x] only CodeableConcept
* value[x] from BonoloPickupSites (required)
* component ^slicing.discriminator.type = #pattern
* component ^slicing.discriminator.path = "code"
* component ^slicing.rules = #open
* component contains pickupType 1..1 MS and pickupDistrict 1..1 MS
* component[pickupType].code = $eregister-concept#c128a7a7-45e9-4313-a49a-75b67b060456
* component[pickupType].value[x] only CodeableConcept
* component[pickupType].value[x] from BonoloPickupTypes (required)
* component[pickupDistrict].code = $eregister-concept#79186178-1fed-4645-9d12-bfac0956ac56
* component[pickupDistrict].value[x] only CodeableConcept
* component[pickupDistrict].value[x] from BonoloPickupDistricts (required)

Profile: BonoloNextPickupDateObservation
Parent: Observation
Id: bonolo-next-pickup-date-observation
Title: "Bonolo Next Pickup Date Observation"
Description: "The *HIVTC, Bonolo Health next collection date* answer: the next drug pickup date."
* insert DraftProfile
* status = #final (exactly)
* code 1..1 MS
* code = $eregister-concept#9f2696bd-9c81-4ee8-9844-e6c77cd19e03
* subject 1..1 MS
* subject only Reference(BonoloPrescriptionPatient)
* encounter 0..0
* effective[x] 1..1 MS
* effective[x] only dateTime
* value[x] 1..1 MS
* value[x] only dateTime
* value[x] ^short = "Next drug pickup date"

Profile: BonoloPrescriptionBundle
Parent: Bundle
Id: bonolo-prescription-bundle
Title: "Bonolo Prescription Transaction Bundle"
Description: """
What the prescription push POSTs to the HAPI base URL for one prescription, each time it is created or changed
(new, cancelled, revised, Bonolo answers edited, dispensed). Every entry is an upsert (`PUT <type>/<id>`) so resources keep
their OpenMRS UUIDs. Every reference resolves inside the bundle.
"""
* insert DraftProfile
* type = #transaction (exactly)
* entry 1..* MS
* entry.fullUrl MS
* entry.resource 1..1 MS
* entry.resource only BonoloPrescriptionPatient or Practitioner or BonoloPrescriptionMedication or BonoloPrescriptionMedicationRequest or BonoloRegimenObservation or BonoloPickupPointObservation or BonoloNextPickupDateObservation or BonoloFacilityLocation
* entry.request 1..1 MS
* entry.request.method = #PUT (exactly)
* entry.request.url 1..1 MS
* entry.request.url ^short = "<ResourceType>/<OpenMRS uuid>"
* obeys bonolo-bundle-1 and bonolo-bundle-2 and bonolo-bundle-3

Invariant: bonolo-bundle-1
Description: "The bundle contains exactly one Patient and at least one MedicationRequest."
Expression: "entry.resource.ofType(Patient).count() = 1 and entry.resource.ofType(MedicationRequest).exists()"
Severity: #error

Invariant: bonolo-bundle-2
Description: "All MedicationRequests belong to one prescription (same groupIdentifier value)."
Expression: "entry.resource.ofType(MedicationRequest).groupIdentifier.value.distinct().count() = 1"
Severity: #error

Invariant: bonolo-bundle-3
Description: "The bundle contains no Encounter."
Expression: "entry.resource.ofType(Encounter).empty()"
Severity: #error

Profile: BonoloMedicationDispense
Parent: MedicationDispense
Id: bonolo-medication-dispense
Title: "Bonolo MedicationDispense"
Description: """
Written to HAPI by the **dispensing system** (e-locker, retail pharmacy or outreach) when medication is handed over.
OpenMRS polls HAPI for changed MedicationDispense resources and maps them back onto the drug order:

| `status` | Effect in OpenMRS |
|---|---|
| `completed` | Order fulfiller status COMPLETED, *Dispensed* order attribute = true; the MedicationRequest is then re-sent as `completed` |
| `in-progress` | Order fulfiller status IN_PROGRESS (partly collected); *Dispensed* not set |
| `declined`, `entered-in-error` | Logged only |

A missed pickup (no dispense by the next pickup date plus a grace period) is detected by the dispensing system, not by OpenMRS.
"""
* insert DraftProfile
* status MS
* status ^short = "completed | in-progress | declined | entered-in-error are acted on"
* medication[x] MS
* medication[x] only Reference(BonoloPrescriptionMedication)
* subject 1..1 MS
* subject only Reference(BonoloPrescriptionPatient)
* authorizingPrescription 1..1 MS
* authorizingPrescription only Reference(BonoloPrescriptionMedicationRequest)
* authorizingPrescription ^short = "MedicationRequest/<OpenMRS order uuid>: how OpenMRS finds the drug order"
* quantity MS
* whenHandedOver MS
* whenHandedOver ^comment = "Required when status = completed."
* location MS
* location ^short = "The pickup site where it was handed over"
* obeys bonolo-dispense-1

Invariant: bonolo-dispense-1
Description: "A completed dispense says when it was handed over."
Expression: "status = 'completed' implies whenHandedOver.exists()"
Severity: #error
