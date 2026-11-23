### Resource ids

Every FHIR id served by FHIR2 is the **OpenMRS UUID** of the underlying row (patient, encounter, obs, order, provider, location…).
Lab on FHIR relies on this: its transaction uses `PUT <type>/<uuid>`, so the LIS stores the same ids.

### Identifier systems

| System | Used on | Meaning |
|---|---|---|
| `http://fhir.openmrs.org/ext/task/identifier` | `Task.identifier` | The Task's OpenMRS UUID. Lab on FHIR searches the LIS with `identifier=<system>|` to find Tasks that came from OpenMRS. See [NamingSystem](NamingSystem-openmrs-task-identifier.html) |
| `http://openelis-global.org/pat_nationalId` (default of `labonfhir.lisIdentifierSystem.url`) | `Patient.identifier` | Registered by Lab on FHIR at startup as the FHIR system for patient identifier type `labonfhir.openmrsPatientIdentifier.uuid`. See [NamingSystem](NamingSystem-openlis-patient-identifier.html) |
| Rows of the FHIR2 table `fhir_patient_identifier_system` | `Patient.identifier` | Any other identifier type mapped to a FHIR system by the implementation. Unmapped types are sent without a system |
| `http://health.gov.ls/fhir/identifier/patient-identifier`, `…/national-id`, `…/hiv-program-id`, `…/new-hiv-program-id` | `Patient.identifier` | **Draft** ([Prescription Workflow](prescription-workflow.html)): proposed systems for the four identifier types the prescription push sends. To be added to `fhir_patient_identifier_system` |
| `http://health.gov.ls/fhir/identifier/prescription` | `MedicationRequest.groupIdentifier` | **Draft**: prescription number (the OpenMRS encounter UUID shared by all drug lines) |
| `http://health.gov.ls/fhir/identifier/order-number` | `MedicationRequest.identifier` | **Draft**: OpenMRS order number of one drug line |
| `http://health.gov.ls/fhir/identifier/facility-code` | `Location.identifier` | **Draft**: facility code (location attribute *IdentifierSourceName* of the parent location) |
| *(no system)* | `Patient.identifier` | **Live:** every patient identifier is served without a `system`. The type is identified by `type.coding.code` (identifier-type UUID) and `type.text`: *Patient Identifier* (`81433852-3f10-11e4-adec-0800271c1b75`, use `official`), *HIV Program ID* (`5c1e8ae2-33c6-11e8-8236-0242ac110002`), *File Number* (`d2084c23-edae-4b0f-98a2-cbcdb6708294`), *National ID* (`0d2ac572-8de3-46c8-9976-1f78899c599f`). The OpenLIS system above is never applied ([Findings](findings.html) L7). Search with `identifier=<value>` |
| `ServiceReq_id`, `Facility_name`, `Facility_code` | `ServiceRequest.identifier` | Customised FHIR2. Label systems, not URIs ([Findings](findings.html) F2) |
| `eRegister Lab order number` | `ServiceRequest.requisition` | Customised FHIR2. eRegister lab order number. Not a valid uri ([Findings](findings.html) F1) |
| `http://fhir.openmrs.org/ext/provider/identifier` | `Practitioner.identifier` | OpenMRS provider identifier |
| `http://fhir.openmrs.org/ext/user/identifier` | `Practitioner.identifier` | OpenMRS username, for practitioners backed by a user |

### Code systems

Checked against live resources on 2026-11-18 unless marked *not observed*.

| System | Where it appears | Notes |
|---|---|---|
| *(no system)*, code = concept UUID | Every `CodeableConcept` built from an OpenMRS concept | FHIR2 always includes the concept UUID as a coding without a system |
| Concept-source URLs in the FHIR2 table `fhir_concept_source`, e.g. `http://loinc.org`, `http://snomed.info/sct`, CIEL | Additional codings, one per concept mapping | A mapping only appears when its concept source has a row in `fhir_concept_source` |
| `http://fhir.openmrs.org/ext/encounter-tag` | `Encounter.meta.tag` | `encounter` or `visit`. See [CodeSystem](CodeSystem-openmrs-encounter-tag.html) |
| `http://fhir.openmrs.org/ext/location-tag` | `Location.meta.tag` | OpenMRS location tags (e.g. *Login Location*) |
| `http://fhir.openmrs.org/code-system/encounter-type` | `Encounter.type` for encounters | Encounter type UUIDs (lab orders: *Consultation* `81852aee-3f10-11e4-adec-0800271c1b75`) |
| `http://fhir.openmrs.org/code-system/visit-type` | `Encounter.type` for visits | Visit type UUIDs (*not observed*) |
| `https://openconceptlab.org/orgs/CIEL/sources/CIEL` | Concept mappings | CIEL codes (e.g. `162240` ART regimen, `856` viral load) |
| `http://terminology.hl7.org/CodeSystem/v2-0074` | `DiagnosticReport.category` | `LAB` on every lab report |
| `http://terminology.hl7.org/CodeSystem/observation-category` | `Observation.category` | Derived from the concept class (table `fhir_observation_category_map`). **Live:** many observations have no category (e.g. all imported lab results) |
| `http://health.gov.ls/laboratory-services/` (trailing slash) | Order, specimen, result and supporting-observation codings served by FHIR2 | Lesotho DISA codes from the `LSMOH DISA` concept source. This is the form on the wire for every DISA coding FHIR2 serves. See [CodeSystem](CodeSystem-lsmoh-disa-lab-services.html) |
| `http://health.gov.ls/laboratory-services` (no slash) | Lab on FHIR's send-time codings (`CTREA`, `PTREA`, `PVLD`, `FCD4`, `LCD4`) | Exists only in the outgoing transaction. See the slash issue on [Findings](findings.html) L1 |

### Extension URLs emitted by FHIR2 1.9.0

These URLs are defined as constants in the FHIR2 module. This guide lists them so receivers know what to expect. They are not profiled here because their exact structure was not verified against live resources.

| URL | Purpose |
|---|---|
| `http://fhir.openmrs.org/ext/address` | Extra OpenMRS address fields on Patient/Person/Location addresses |
| `http://fhir.openmrs.org/ext/name` | Extra OpenMRS name fields |
| `http://fhir.openmrs.org/ext/patient/identifier#location` | The location where a patient identifier was issued |
| `http://fhir.openmrs.org/ext/obs-location-value` | Location-valued observations |
| `http://fhir.openmrs.org/ext/obs/interpretations` | Observation interpretation |
| `http://fhir.openmrs.org/ext/obs/reference-range` | Observation reference ranges |
| `http://fhir.openmrs.org/ext/non-coded-condition` | Free-text (non-coded) conditions |
| `http://fhir.openmrs.org/ext/medicine` | Medicine details on Medication |
| `http://fhir.openmrs.org/ext/group/description` | Cohort description on Group |

### Lab on FHIR value sets

* [Lab order test codes](ValueSet-lab-order-test-codes.html): codes on `ServiceRequest.code`, `DiagnosticReport.code` and `Task.output.type` (observed).
* [Lab order supporting-information codes](ValueSet-lab-order-supporting-info-codes.html): codes on the observations referenced from `ServiceRequest.supportingInfo` (observed).
* [Send-time supporting-information codes](ValueSet-labonfhir-supporting-info-codes.html): DISA codes Lab on FHIR adds while sending (`CTREA`, `PTREA`, `PVLD`, `FCD4`, `LCD4`; from code analysis).
* [Viral-load trigger codes](ValueSet-labonfhir-viral-load-trigger-codes.html): result codes that make Lab on FHIR derive the Lesotho viral-load observations.

### Bonolo prescription terminology (draft)

The [Prescription Workflow](prescription-workflow.html) codes OpenMRS concepts by UUID under the proposed system
`http://health.gov.ls/fhir/CodeSystem/eregister-concept` ([CodeSystem fragment](CodeSystem-eregister-concept.html)).
Value sets: [pickup questions](ValueSet-bonolo-pickup-questions.html), [pickup sites](ValueSet-bonolo-pickup-sites.html),
[pickup types](ValueSet-bonolo-pickup-types.html), [pickup districts](ValueSet-bonolo-pickup-districts.html).
