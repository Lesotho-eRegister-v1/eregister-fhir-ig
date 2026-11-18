
This list was extracted by loading every `providers/r4/*Provider` class from
`fhir2-api-1.9.0-SNAPSHOT.jar` and dumping its HAPI annotations, so it reflects this exact build.

**Base URLs**

| FHIR version | Base URL |
|---|---|
| R4 | `http(s)://<host>/openmrs/ws/fhir2/R4` |
| STU3 | `http(s)://<host>/openmrs/ws/fhir2/R3` |
| Capability statement | `GET <base>/metadata` |

Every endpoint except `GET <base>/metadata` needs authentication: HTTP Basic with an OpenMRS user, or an OpenMRS `JSESSIONID` cookie.
Unauthenticated calls get `401`.

> **The live `/metadata` does not say this.** The server's CapabilityStatement has no `rest.security` element, so a client
> cannot discover from it that authentication is required. The [copy in this guide](CapabilityStatement-openmrs-fhir2-r4-server.html)
> adds `rest.security` (service `Basic`) by hand.

> **Operation links in `/metadata` follow the caller's host.** `rest.resource.operation.definition` URLs (for example
> `http://<host>/openmrs/ws/fhir2/R4/OperationDefinition/Observation-t-lastn`) are built from the host of the request that
> generated the statement, and HAPI caches the statement for a while. A client can therefore see another caller's host
> (for example an internal IP) in those links. Resolve them against your own base URL instead.

### Summary matrix (R4)

The formal statement is the [OpenMRS FHIR2 R4 Server CapabilityStatement](CapabilityStatement-openmrs-fhir2-r4-server.html), generated from the live server's `/metadata` on 2026-11-18.

Legend: R = read (`GET /Type/{id}`), S = search, C = create (`POST`), U = update (`PUT`), D = delete.

| # | Resource | R | S | C | U | D | Extended operations |
|---|---|:-:|:-:|:-:|:-:|:-:|---|
| 1 | **Patient** | ✔ | ✔ | ✔ | ✔ | ✔ | `Patient/$everything`, `Patient/{id}/$everything` |
| 2 | **Person** | ✔ | ✔ | ✔ | ✔ | ✔ | |
| 3 | **RelatedPerson** | ✔ | ✔ | | | | |
| 4 | **Practitioner** | ✔ | ✔ | ✔ | ✔ | ✔ | |
| 5 | **Encounter** | ✔ | ✔ | ✔ | ✔ | ✔ | `Encounter/$everything`, `Encounter/{id}/$everything`; named search `_query=encountersWithMedicationRequests` |
| 6 | **Observation** | ✔ | ✔ | ✔ | | ✔ | `Observation/$lastn`, `Observation/$lastn-encounters` |
| 7 | **Location** | ✔ | ✔ | ✔ | ✔ | ✔ | |
| 8 | **Condition** | ✔ | ✔ | ✔ | ✔ | ✔ | |
| 9 | **AllergyIntolerance** | ✔ | ✔ | ✔ | ✔ | ✔ | |
| 10 | **DiagnosticReport** | ✔ | ✔ | ✔ | ✔ | ✔ | |
| 11 | **ServiceRequest** | ✔ | ✔ | | | | |
| 12 | **Task** | ✔ | ✔ | ✔ | ✔ | ✔ | |
| 13 | **Medication** | ✔ | ✔ | ✔ | ✔ | ✔ | |
| 14 | **MedicationRequest** | ✔ | ✔ | | | | Unfiltered search fails with HTTP 500 on the live instance; see [Findings](findings.html) |
| 15 | **MedicationDispense** | ✔ | ✔ | ✔ | ✔ | ✔ | (needs OpenMRS ≥ 2.6) |
| 16 | **Immunization** | ✔ | ✔ | ✔ | ✔ | ✔ | |
| 17 | **Group** | ✔ | ✔ | ✔ | ✔ | ✔ | `Group/{id}/$members` |
| 18 | **ValueSet** | ✔ | ✔ | | | | |
| 19 | **OperationDefinition** | ✔ | | | | | Read only. Serves the server's definitions of the operations above (ids below) |

STU3 (`/R3`) exposes the same set **except Immunization and ServiceRequest**. It adds **ProcedureRequest** (R/S),
the STU3 equivalent of ServiceRequest. The R3 Group provider has no search.
**None of the extended operations exist on `/R3`**: no `$everything`, `$lastn`, `$lastn-encounters`, `$members` or
`_query=encountersWithMedicationRequests`. Use `/R4` for them.

#### Server OperationDefinition ids (live)

| Operation | `GET <base>/OperationDefinition/…` | Guide definition |
|---|---|---|
| Patient / Encounter `$everything` | `EncounterPatient-it-everything` (one definition for both; type and instance level; no input parameters) | [EncounterPatient-everything](OperationDefinition-EncounterPatient-everything.html) |
| Observation `$lastn` | `Observation-t-lastn` | Standard FHIR [Observation-lastn](http://hl7.org/fhir/R4/operation-observation-lastn.html) |
| Observation `$lastn-encounters` | `Observation-t-lastn-encounters` | [Observation-lastn-encounters](OperationDefinition-Observation-lastn-encounters.html) |
| Group `$members` | `Group-i-members` | [Group-members](OperationDefinition-Group-members.html) |
| `_query=encountersWithMedicationRequests` | `Encounter-query-encountersWithMedicationRequests` (params `date`, `status`, `patientSearchTerm`) | [Encounter-encountersWithMedicationRequests](OperationDefinition-Encounter-encountersWithMedicationRequests.html) |

The server declares every operation parameter with type `string`, whatever its search type.

### Search parameters per resource (R4)

Notation: *string* = `StringAndListParam` (supports `:exact`, `:contains`), *token* = `system|code`,
*date* = `DateRangeParam` (`eq|ne|gt|lt|ge|le` prefixes), *reference* = `ReferenceAndListParam` (allowed chains in brackets),
*quantity* = `QuantityAndListParam`. Every resource supports `_id` and `_lastUpdated` unless noted.
`_sort` is supported where marked. Paging uses `_count` (default 10, max 100) and the `next`/`prev` links.

#### Patient
| Param | Type | Notes |
|---|---|---|
| `name`, `given`, `family` | string | |
| `identifier` | token | `identifier=10001V` or `identifier=<system>|<value>` |
| `gender` | token | `male`, `female`, `other`, `unknown` |
| `birthdate`, `death-date` | date | |
| `deceased` | token | `true`/`false` |
| `address-city`, `address-state`, `address-postalcode`, `address-country` | string | |
| `_id`, `_lastUpdated`, `_sort` | | |
| `_revinclude` | | `Observation:patient`, `AllergyIntolerance:patient`, `DiagnosticReport:patient`, `Encounter:patient`, `MedicationRequest:patient`, `ServiceRequest:patient`, `MedicationDispense:prescription` |
| **Operation** | | `$everything` (type-level and instance-level) |

#### Person
`name`, `gender`, `birthdate`, `address-city|state|postalcode|country`, `_id`, `_lastUpdated`, `_sort`;
`_include=Person:link:Patient`, `Person:patient`.

#### RelatedPerson
`name`, `gender`, `birthdate`, `address-city|state|postalcode|country`, `_id`, `_lastUpdated`, `_sort`;
`_include=RelatedPerson:patient`.

#### Practitioner
`name`, `given`, `family`, `identifier`, `address-city|state|postalcode|country`, `_id`, `_lastUpdated`;
`_revinclude=Encounter:participant`, `MedicationRequest:requester`, `ServiceRequest:requester`, `MedicationDispense:prescription`.

#### Encounter
| Param | Type | Notes |
|---|---|---|
| `date` | date | |
| `location` | reference [`address-city`, `address-state`, `address-country`, `address-postalcode`] | → Location |
| `participant` | reference [`identifier`, `given`, `family`, `name`] | → Practitioner |
| `subject`, `patient` | reference [`identifier`, `given`, `family`, `name`] | → Patient |
| `type` | token | encounter type UUID (or visit type for visits) |
| `_tag` | token | distinguishes OpenMRS encounters from visits (`http://fhir.openmrs.org/ext/encounter-tag|encounter` or `|visit`) |
| `_has` | has | e.g. `_has:MedicationRequest:encounter:intent=order` |
| `_id`, `_lastUpdated`, `_sort` | | |
| `_include` | | `Encounter:location`, `Encounter:patient`, `Encounter:participant` |
| `_revinclude` | | `Observation:encounter`, `DiagnosticReport:encounter`, `MedicationRequest:encounter`, `ServiceRequest:encounter`, `MedicationDispense:prescription` |
| Named query `_query=encountersWithMedicationRequests` | | params `date`, `status`, `patientSearchTerm` |
| **Operation** | | `Encounter/{id}/$everything` |

#### Observation
| Param | Type | Notes |
|---|---|---|
| `subject`, `patient` | reference [`identifier`, `given`, `family`, `name`] | → Patient |
| `encounter` | reference [`type`] | → Encounter |
| `has-member` | reference [`code`] | → Observation (obs groups) |
| `code` | token | concept UUID, or `<concept-source-url>|<code>` (e.g. `http://loinc.org|20447-9`) |
| `category` | token | `laboratory`, `vital-signs`, `exam`, `social-history`, … (`fhir_observation_category_map`) |
| `value-concept` | token | coded answers |
| `value-date` | date | |
| `value-quantity` | quantity | `value-quantity=gt100` |
| `value-string` | string | |
| `date` | date | obs datetime |
| `_id`, `_lastUpdated`, `_sort` | | |
| `_include` | | `Observation:encounter`, `Observation:patient`, `Observation:has-member` |
| `_revinclude` | | `Observation:has-member`, `DiagnosticReport:result` |
| **Operations** | | `$lastn` and `$lastn-encounters`: params `max`, `subject`/`patient`, `category`, `code` |

#### Location
`name`, `address-city|country|postalcode|state`, `_tag` (location tags, e.g. `Login Location`),
`partof` [`name`, `address-*`], `_id`, `_lastUpdated`, `_sort`;
`_include=Location:partof`; `_revinclude=Location:partof`, `Encounter:location`.

#### Condition
`patient`/`subject` [`identifier`, `name`, `given`, `family`], `code`, `clinical-status`, `onset-date`, `onset-age` (quantity),
`recorded-date`, `_id`, `_lastUpdated`, `_sort`; `_include=Condition:patient`.

#### AllergyIntolerance
`patient`/`subject` [chains], `category` (`food|medication|environment`), `code`, `severity` (`mild|moderate|severe`),
`manifestation`, `clinical-status`, `_id`, `_lastUpdated`, `_sort`; `_include=AllergyIntolerance:patient`.

#### DiagnosticReport
`encounter`, `patient`/`subject` [chains], `issued` (date), `code`, `result` (→ Observation), `_id`, `_lastUpdated`, `_sort`;
`_include=DiagnosticReport:encounter`, `DiagnosticReport:patient`, `DiagnosticReport:result`.

#### ServiceRequest (lab test orders, `test_order`)
`patient`/`subject` [chains], `code`, `encounter`, `requester` [chains → Practitioner], `occurrence` (date), `_id`, `_lastUpdated`;
`_include=ServiceRequest:patient`, `ServiceRequest:requester`, `ServiceRequest:encounter`.

#### Task (FHIR2 `fhir_task`; used by LabOnFHIR)
| Param | Type | Notes |
|---|---|---|
| `based-on` | reference | e.g. `ServiceRequest/<order-uuid>` |
| `owner` | reference | e.g. `Practitioner/<lis-user-uuid>` |
| `status` | token | `requested`, `accepted`, `rejected`, `in-progress`, `completed`, … |
| `_id`, `_lastUpdated`, `_sort` | | |
| `_include` | | `Task:patient`, `Task:owner`, `Task:based-on`, `Task:encounter` |

#### Medication
`code`, `form`, `ingredient-code`, `_id`, `_lastUpdated`; `_revinclude=MedicationRequest:medication`, `MedicationDispense:prescription`.

#### MedicationRequest
`patient`/`subject` [chains], `encounter`, `code`, `requester` [chains], `medication`, `status`, `_id`, `_lastUpdated`;
`_include=MedicationRequest:medication|requester|patient|encounter`; `_revinclude=MedicationDispense:prescription`.

#### MedicationDispense (OpenMRS ≥ 2.6)
`patient`/`subject` [chains], `context` (→ Encounter), `prescription` (→ MedicationRequest), `_id`, `_lastUpdated`, `_sort`;
`_include=MedicationDispense:patient|context|prescription|medication|performer`.

#### Immunization
`patient` [`identifier`], `_sort`.

#### Group (cohorts)
`managing-entity` [`_id`, `given`, `family`, `name`] → Practitioner. Operation `Group/{id}/$members`.

#### ValueSet (concept sets)
`title` (string). Read by concept-set UUID.

