### Resource ids

Every FHIR id served by FHIR2 is the **OpenMRS UUID** of the underlying row (patient, encounter, obs, order, provider, location…).
Lab on FHIR relies on this: its transaction uses `PUT <type>/<uuid>`, so the LIS stores the same ids.

### Identifier systems

| System | Used on | Meaning |
|---|---|---|
| `http://fhir.openmrs.org/ext/task/identifier` | `Task.identifier` | The Task's OpenMRS UUID. Lab on FHIR searches the LIS with `identifier=<system>|` to find Tasks that came from OpenMRS. See [NamingSystem](NamingSystem-openmrs-task-identifier.html) |
| `http://openelis-global.org/pat_nationalId` (default of `labonfhir.lisIdentifierSystem.url`) | `Patient.identifier` | Registered by Lab on FHIR at startup as the FHIR system for patient identifier type `labonfhir.openmrsPatientIdentifier.uuid`. See [NamingSystem](NamingSystem-openlis-patient-identifier.html) |
| Rows of the FHIR2 table `fhir_patient_identifier_system` | `Patient.identifier` | Any other identifier type mapped to a FHIR system by the implementation. Unmapped types are sent without a system |
| `http://fhir.openmrs.org/ext/provider/identifier` | `Practitioner.identifier` | OpenMRS provider identifier |
| `http://fhir.openmrs.org/ext/user/identifier` | `Practitioner.identifier` | OpenMRS username, for practitioners backed by a user |

### Code systems

The rows marked with a FHIR2 URL come from constants in the FHIR2 1.9.0 module and will be checked against live resources once authenticated access is available.

| System | Where it appears | Notes |
|---|---|---|
| *(no system)*, code = concept UUID | Every `CodeableConcept` built from an OpenMRS concept | FHIR2 always includes the concept UUID as a coding without a system |
| Concept-source URLs in the FHIR2 table `fhir_concept_source`, e.g. `http://loinc.org`, `http://snomed.info/sct`, CIEL | Additional codings, one per concept mapping | A mapping only appears when its concept source has a row in `fhir_concept_source` |
| `http://fhir.openmrs.org/ext/encounter-tag` | `Encounter.meta.tag` | `encounter` or `visit`. See [CodeSystem](CodeSystem-openmrs-encounter-tag.html) |
| `http://fhir.openmrs.org/ext/location-tag` | `Location.meta.tag` | OpenMRS location tags (e.g. *Login Location*) |
| `http://fhir.openmrs.org/code-system/visit-type` | `Encounter.type` for visits | Visit type UUIDs |
| `http://terminology.hl7.org/CodeSystem/observation-category` | `Observation.category` | Derived from the concept class (table `fhir_observation_category_map`) |
| `http://health.gov.ls/laboratory-services` | Supporting observations sent to the LIS; derived viral-load observations | Lesotho DISA codes. See [CodeSystem](CodeSystem-lsmoh-disa-lab-services.html) and the slash issue on [Findings](findings.html) |

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

* [Supporting-information codes](ValueSet-labonfhir-supporting-info-codes.html): DISA codes added to clinical-context observations sent with an order (`CTREA`, `PTREA`, `PVLD`, `FCD4`, `LCD4`).
* [Viral-load trigger codes](ValueSet-labonfhir-viral-load-trigger-codes.html): result codes that make Lab on FHIR derive the Lesotho viral-load observations.
