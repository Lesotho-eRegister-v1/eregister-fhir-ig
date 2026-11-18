<div class="note-to-balloters" markdown="1">
**Not deployed.** The live instance's capability statement (2026-11-18) contains none of these resources or operations. The extension is built for FHIR2 **2.5.0**; the instance runs FHIR2 **1.9.0**. This page records what the extension would add once FHIR2 is upgraded.
</div>

### What the extension adds

If `fhir2addlextension` is installed (designed for FHIR2 2.5.0), the R4 server also exposes:

#### New resource types
| Resource | Interactions | Search params / operations |
|---|---|---|
| **Appointment** (Bahmni appointments) | R, S | `patient` [`identifier`, `name`, …], `status`, `date`, `_id`, `_lastUpdated`, `_sort` |
| **EpisodeOfCare** (episodes module) | R, C, U, S | `patient` [`identifier`], `_id`, `_lastUpdated`, `_sort`, `_revinclude=Encounter:episode-of-care` |
| **DocumentReference** (patient documents) | R, C, U, D, S | `subject`/`patient` [chains], `encounter`, `_id`, `_lastUpdated`, `_sort` |
| **ImagingStudy** (radiology) | R, C, U, PATCH, S | `patient` [chains], `basedon` (→ ServiceRequest), `_id`, `_lastUpdated`, `_sort`; op `ImagingStudy/{id}/$fetch-quality-assessment` |
| **ConsultationBundle** (custom Bundle profile `http://fhir.bahmni.org/R4/StructureDefinition/BahmniConsultationBundle`) | C, R | Create a whole consultation (encounter + obs + conditions + orders …) in one call |

#### Overridden / extended FHIR2 resources
| Resource | Change |
|---|---|
| **ServiceRequest** | Mapped to **all non-drug `orders`** (not just `test_order`). Adds `@Create`. Extra search params `category` (order type: `http://fhir.bahmni.org/code-system/order-type|<order-type-uuid>`), `based-on`, `_revinclude=ImagingStudy:basedon`. Second search: `patient` + **`numberOfVisits`** (+ `category`). Adds priority, location and order-attribute extensions. |
| **DiagnosticReport** | Bahmni service. Adds `based-on` (→ ServiceRequest) search and `PATCH`. Operations `DiagnosticReport/{id}/$fetch-bundle`, `DiagnosticReport/$submit-bundle`, `DiagnosticReport/{id}/$update-bundle` (input: Bundle with report + observations). |
| **Condition** | Search **requires** `category` (`problem-list-item` or `encounter-diagnosis`). Adds `verification-status`. |
| **Observation** | Operation `Observation/$fetch-all?encounter=Encounter/<uuid>` returns all obs of an encounter with no paging limit. Adds form-namespace-path and attachment-value extensions. |
| **Medication** | Extra search `Medication?name=<text>` (required `name`). |
| **MedicationRequest** | Adds `@Create` (FHIR2 is read-only). |
| **ValueSet** | Operations `ValueSet/{id}/$expand` (hierarchical expansion) and `ValueSet/$expand?filter=<text>`. |
| **Encounter** | Saving through FHIR publishes a Bahmni atom-feed `Encounter` event (`encounter.feed.publish.url`). |

Extension URLs live under `http://fhir.bahmni.org/ext/...` and code systems under `http://fhir.bahmni.org/code-system/...`.
