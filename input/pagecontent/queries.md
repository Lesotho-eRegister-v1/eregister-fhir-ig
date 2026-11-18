
Every query below matches a handler that exists in FHIR2 1.9.0 (or the Bahmni extension, where marked **[Bahmni ext]**).

### Setup

```bash
# Bahmni behind its proxy:   https://<bahmni-host>/openmrs/ws/fhir2/R4
# Plain OpenMRS:              http://localhost:8080/openmrs/ws/fhir2/R4
export BASE="https://<host>/openmrs/ws/fhir2/R4"
export AUTH="<username>:<password>"          # any OpenMRS user with the needed privileges
alias fhir='curl -sk -u "$AUTH" -H "Accept: application/fhir+json"'

fhir "$BASE/metadata" | jq '.rest[0].resource[].type'   # list exposed resource types
```

Use `?_format=json` or `?_format=xml` to override the Accept header, and `&_pretty=true` for readable output.

#### Common parameters (all search endpoints)
| Param | Example | Meaning |
|---|---|---|
| `_count` | `_count=50` | page size (default 10, max 100) |
| `_getpagesoffset` | via `link[rel=next].url` | follow the `next` link from the Bundle for further pages |
| `_summary` | `_summary=count` | return only `total` |
| `_summary` | `_summary=true` / `data` / `text` | trimmed representations |
| `_elements` | `_elements=id,name,birthDate` | restrict fields |
| `_sort` | `_sort=-_lastUpdated`, `_sort=birthdate` | where supported (marked on [FHIR2 Server API](server.html)) |
| `_id` | `_id=uuid1,uuid2` | OpenMRS UUIDs (FHIR ids = OpenMRS uuids) |
| `_lastUpdated` | `_lastUpdated=ge2026-01-01&_lastUpdated=lt2026-02-01` | changed in range |
| `_include` / `_revinclude` | `_include=Encounter:patient` | only the values listed on [FHIR2 Server API](server.html) are accepted |

Modifiers: string params accept `:exact` and `:contains`. Token params accept `system|code`, `|code` and `code`. Date params accept the prefixes `eq ne gt lt ge le sa eb`.
Comma = OR (`gender=male,female`). Repeating a param = AND.

---

### Patient
```bash
fhir "$BASE/Patient?_count=20"                                     # browse all
fhir "$BASE/Patient/<patient-uuid>"                                # read
fhir "$BASE/Patient?name=John"                                     # any name part
fhir "$BASE/Patient?given=John&family=Doe"
fhir "$BASE/Patient?name:exact=John"
fhir "$BASE/Patient?identifier=GAN200001"                          # any identifier type
fhir "$BASE/Patient?identifier=X0000000001/26"   # identifiers have no system on this instance; search by value only
fhir "$BASE/Patient?gender=female&birthdate=ge1990-01-01&birthdate=le1999-12-31"
fhir "$BASE/Patient?deceased=true"
fhir "$BASE/Patient?death-date=ge2025-01-01"
fhir "$BASE/Patient?address-city=Maseru&address-country=Lesotho"
fhir "$BASE/Patient?_lastUpdated=ge2026-11-01&_sort=-_lastUpdated"
fhir "$BASE/Patient?_summary=count"                                # total patients
# reverse includes: patient + their data in one bundle
fhir "$BASE/Patient?_id=<uuid>&_revinclude=Encounter:patient&_revinclude=Observation:patient"
fhir "$BASE/Patient?_id=<uuid>&_revinclude=AllergyIntolerance:patient&_revinclude=DiagnosticReport:patient"
fhir "$BASE/Patient?_id=<uuid>&_revinclude=MedicationRequest:patient&_revinclude=ServiceRequest:patient"
# $everything
fhir "$BASE/Patient/<uuid>/\$everything"
fhir "$BASE/Patient/\$everything"
```

### Person and RelatedPerson
```bash
fhir "$BASE/Person?name=Doe&gender=male"
fhir "$BASE/Person?birthdate=1980"
fhir "$BASE/Person?address-state=Maseru"
fhir "$BASE/Person/<person-uuid>"
fhir "$BASE/Person?_id=<uuid>&_include=Person:patient"
fhir "$BASE/Person?name=Doe&_include=Person:link:Patient"

fhir "$BASE/RelatedPerson?name=Mary"
fhir "$BASE/RelatedPerson/<relationship-uuid>"
fhir "$BASE/RelatedPerson?name=Mary&_include=RelatedPerson:patient"
```

### Practitioner (providers)
```bash
fhir "$BASE/Practitioner"
fhir "$BASE/Practitioner/<provider-uuid>"
fhir "$BASE/Practitioner?name=Super"
fhir "$BASE/Practitioner?identifier=PRV001"
fhir "$BASE/Practitioner?given=Jane&family=Doe"
fhir "$BASE/Practitioner/<lis-user-uuid>"            # LabOnFHIR's LIS user (labonfhir.lisUserUuid)
fhir "$BASE/Practitioner?_id=<uuid>&_revinclude=Encounter:participant"
fhir "$BASE/Practitioner?_id=<uuid>&_revinclude=ServiceRequest:requester"
```

### Encounter (OpenMRS encounters **and** visits)
```bash
fhir "$BASE/Encounter?patient=<patient-uuid>&_sort=-date"
fhir "$BASE/Encounter/<encounter-uuid>"
fhir "$BASE/Encounter?subject:Patient.identifier=GAN200001"                # chained
fhir "$BASE/Encounter?patient.name=John"
fhir "$BASE/Encounter?date=ge2026-11-01&date=le2026-11-17"
fhir "$BASE/Encounter?type=<encounter-type-uuid>"
fhir "$BASE/Encounter?location=<location-uuid>"
fhir "$BASE/Encounter?location.address-city=Maseru"
fhir "$BASE/Encounter?participant=<provider-uuid>"
fhir "$BASE/Encounter?participant.identifier=PRV001"
# encounters only / visits only
fhir "$BASE/Encounter?patient=<uuid>&_tag=http://fhir.openmrs.org/ext/encounter-tag|encounter"
fhir "$BASE/Encounter?patient=<uuid>&_tag=http://fhir.openmrs.org/ext/encounter-tag|visit"
# includes / revincludes
fhir "$BASE/Encounter?patient=<uuid>&_include=Encounter:location&_include=Encounter:participant&_include=Encounter:patient"
fhir "$BASE/Encounter?_id=<enc-uuid>&_revinclude=Observation:encounter"
fhir "$BASE/Encounter?_id=<enc-uuid>&_revinclude=ServiceRequest:encounter&_revinclude=DiagnosticReport:encounter"
fhir "$BASE/Encounter?_id=<enc-uuid>&_revinclude=MedicationRequest:encounter"
# _has
fhir "$BASE/Encounter?_has:MedicationRequest:encounter:intent=order"
# named query (pharmacy queue)
fhir "$BASE/Encounter?_query=encountersWithMedicationRequests&date=ge2026-11-01&status=active"
fhir "$BASE/Encounter?_query=encountersWithMedicationRequests&patientSearchTerm=John"
# everything for one encounter
fhir "$BASE/Encounter/<enc-uuid>/\$everything"
```

### Observation
```bash
fhir "$BASE/Observation?patient=<patient-uuid>&_sort=-date&_count=50"
fhir "$BASE/Observation/<obs-uuid>"
fhir "$BASE/Observation?subject.identifier=GAN200001"
fhir "$BASE/Observation?encounter=<encounter-uuid>"
fhir "$BASE/Observation?encounter.type=<encounter-type-uuid>"
fhir "$BASE/Observation?patient=<uuid>&code=5089AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"          # by concept uuid (weight)
fhir "$BASE/Observation?patient=<uuid>&code=http://loinc.org|20447-9"                   # by mapping (HIV viral load)
fhir "$BASE/Observation?patient=<uuid>&code=http://health.gov.ls/laboratory-services/|HIVVL-HIVVM"   # DISA code (Lesotho): VL result in copies/ml
fhir "$BASE/Observation?patient=<uuid>&category=laboratory"
fhir "$BASE/Observation?patient=<uuid>&category=vital-signs"
fhir "$BASE/Observation?patient=<uuid>&date=ge2026-01-01"
fhir "$BASE/Observation?patient=<uuid>&value-quantity=gt1000"
fhir "$BASE/Observation?patient=<uuid>&value-concept=<answer-concept-uuid>"
fhir "$BASE/Observation?patient=<uuid>&value-string:contains=positive"
fhir "$BASE/Observation?patient=<uuid>&value-date=ge2026-01-01"
fhir "$BASE/Observation?has-member=<child-obs-uuid>"                                    # parent obs group
fhir "$BASE/Observation?has-member.code=<concept-uuid>"
fhir "$BASE/Observation?patient=<uuid>&_include=Observation:encounter"
fhir "$BASE/Observation?_id=<group-obs-uuid>&_include=Observation:has-member"
fhir "$BASE/Observation?_id=<obs-uuid>&_revinclude=DiagnosticReport:result"             # which report contains this result
# last-N
fhir "$BASE/Observation/\$lastn?patient=<uuid>&category=vital-signs&max=3"
fhir "$BASE/Observation/\$lastn?patient=<uuid>&code=<concept-uuid>&max=1"
fhir "$BASE/Observation/\$lastn-encounters?patient=<uuid>&category=laboratory&max=2"
# [Bahmni ext] all obs of an encounter, no paging cap
fhir "$BASE/Observation/\$fetch-all?encounter=Encounter/<enc-uuid>"
```

### ServiceRequest (lab orders)
```bash
fhir "$BASE/ServiceRequest?patient=<patient-uuid>"
fhir "$BASE/ServiceRequest/<order-uuid>"
fhir "$BASE/ServiceRequest?encounter=<encounter-uuid>"
fhir "$BASE/ServiceRequest?code=<test-concept-uuid>"
fhir "$BASE/ServiceRequest?requester=<provider-uuid>"
fhir "$BASE/ServiceRequest?occurrence=ge2026-11-01"
fhir "$BASE/ServiceRequest?patient=<uuid>&_include=ServiceRequest:requester&_include=ServiceRequest:encounter&_include=ServiceRequest:patient"
# [Bahmni ext]
fhir "$BASE/ServiceRequest?patient=<uuid>&category=<order-type-uuid>"              # e.g. Lab Order / Radiology Order
fhir "$BASE/ServiceRequest?patient=<uuid>&numberOfVisits=3"
fhir "$BASE/ServiceRequest?patient=<uuid>&numberOfVisits=3&category=<order-type-uuid>"
fhir "$BASE/ServiceRequest?patient=<uuid>&_revinclude=ImagingStudy:basedon"
```

### Task (lab workflow; written by LabOnFHIR)
```bash
fhir "$BASE/Task?_sort=-_lastUpdated"
fhir "$BASE/Task/<task-uuid>"
fhir "$BASE/Task?status=requested"                                    # sent to LIS, waiting
fhir "$BASE/Task?status=completed&_lastUpdated=ge2026-11-01"           # results received
fhir "$BASE/Task?status=rejected,cancelled,failed"
fhir "$BASE/Task?based-on=ServiceRequest/<order-uuid>"                 # task for a given order
fhir "$BASE/Task?owner=Practitioner/<lis-user-uuid>"   # all tasks owned by the LIS
# exactly what LabOnFHIR assembles before sending (see [Lab Workflow](lab-workflow.html)):
fhir "$BASE/Task?_id=<task-uuid>&_include=Task:patient&_include=Task:owner&_include=Task:encounter&_include=Task:based-on"
```

### DiagnosticReport (lab results)
```bash
fhir "$BASE/DiagnosticReport?patient=<patient-uuid>"
fhir "$BASE/DiagnosticReport/<report-uuid>"
fhir "$BASE/DiagnosticReport?encounter=<encounter-uuid>"
fhir "$BASE/DiagnosticReport?code=http://loinc.org|20447-9"
fhir "$BASE/DiagnosticReport?issued=ge2026-11-01"
fhir "$BASE/DiagnosticReport?result=<obs-uuid>"
fhir "$BASE/DiagnosticReport?patient=<uuid>&_include=DiagnosticReport:result"           # report + its observations
fhir "$BASE/DiagnosticReport?patient=<uuid>&_include=DiagnosticReport:encounter&_include=DiagnosticReport:patient"
# [Bahmni ext]
fhir "$BASE/DiagnosticReport?based-on=ServiceRequest/<order-uuid>"
fhir "$BASE/DiagnosticReport/<report-uuid>/\$fetch-bundle"
```

### Condition, AllergyIntolerance
```bash
fhir "$BASE/Condition?patient=<uuid>"                                        # FHIR2 alone
fhir "$BASE/Condition?patient=<uuid>&clinical-status=active"
fhir "$BASE/Condition?patient=<uuid>&code=<concept-uuid>"
fhir "$BASE/Condition?patient=<uuid>&onset-date=ge2025-01-01"
fhir "$BASE/Condition?patient=<uuid>&recorded-date=ge2025-01-01"
fhir "$BASE/Condition?patient.identifier=GAN200001&_include=Condition:patient"
# [Bahmni ext] category is REQUIRED
fhir "$BASE/Condition?category=problem-list-item&patient=<uuid>"
fhir "$BASE/Condition?category=encounter-diagnosis&patient=<uuid>&verification-status=confirmed"

fhir "$BASE/AllergyIntolerance?patient=<uuid>"
fhir "$BASE/AllergyIntolerance/<allergy-uuid>"
fhir "$BASE/AllergyIntolerance?patient=<uuid>&category=medication&severity=severe"
fhir "$BASE/AllergyIntolerance?patient=<uuid>&clinical-status=active"
fhir "$BASE/AllergyIntolerance?patient=<uuid>&code=<allergen-concept-uuid>&manifestation=<reaction-concept-uuid>"
```

### Medications
```bash
fhir "$BASE/Medication?code=<drug-concept-uuid>"
fhir "$BASE/Medication/<drug-uuid>"
fhir "$BASE/Medication?form=<dosage-form-concept-uuid>"
fhir "$BASE/Medication?ingredient-code=<concept-uuid>"
fhir "$BASE/Medication?_id=<drug-uuid>&_revinclude=MedicationRequest:medication"
fhir "$BASE/Medication?name=Paracetamol"                                      # [Bahmni ext]

fhir "$BASE/MedicationRequest?patient=<uuid>"
fhir "$BASE/MedicationRequest/<drug-order-uuid>"
fhir "$BASE/MedicationRequest?patient=<uuid>&status=active"
fhir "$BASE/MedicationRequest?encounter=<enc-uuid>"
fhir "$BASE/MedicationRequest?medication=<drug-uuid>&requester=<provider-uuid>"
fhir "$BASE/MedicationRequest?patient=<uuid>&_include=MedicationRequest:medication&_include=MedicationRequest:requester"
fhir "$BASE/MedicationRequest?patient=<uuid>&_revinclude=MedicationDispense:prescription"

fhir "$BASE/MedicationDispense?patient=<uuid>"                               # OpenMRS core >= 2.6
fhir "$BASE/MedicationDispense?prescription=<drug-order-uuid>"
fhir "$BASE/MedicationDispense?context=<enc-uuid>&_include=MedicationDispense:medication"
```

### Location
```bash
fhir "$BASE/Location"
fhir "$BASE/Location/<location-uuid>"
fhir "$BASE/Location?name=Registration Desk"
fhir "$BASE/Location?_tag=Login Location"
fhir "$BASE/Location?address-city=Maseru"
fhir "$BASE/Location?partof=<parent-location-uuid>"
fhir "$BASE/Location?partof.name=General Hospital"
fhir "$BASE/Location?_id=<uuid>&_include=Location:partof"
fhir "$BASE/Location?_id=<uuid>&_revinclude=Location:partof"                 # children
fhir "$BASE/Location?_id=<uuid>&_revinclude=Encounter:location"
```

### Immunization, Group, ValueSet
```bash
fhir "$BASE/Immunization?patient=<uuid>"
fhir "$BASE/Immunization?patient.identifier=GAN200001"
fhir "$BASE/Immunization/<obs-group-uuid>"

fhir "$BASE/Group/<cohort-uuid>"
fhir "$BASE/Group?managing-entity=<provider-uuid>"
fhir "$BASE/Group/<cohort-uuid>/\$members"

fhir "$BASE/ValueSet?title=Blood"
fhir "$BASE/ValueSet/<concept-set-uuid>"
fhir "$BASE/ValueSet/<concept-set-uuid>/\$expand"                             # [Bahmni ext]
fhir "$BASE/ValueSet/\$expand?filter=malaria"                                  # [Bahmni ext]
```

### Bahmni-only resources **[Bahmni ext]**
```bash
fhir "$BASE/Appointment?patient=<uuid>&date=ge2026-11-17&status=booked"
fhir "$BASE/Appointment/<appointment-uuid>"
fhir "$BASE/EpisodeOfCare?patient=<uuid>&_revinclude=Encounter:episode-of-care"
fhir "$BASE/EpisodeOfCare/<episode-uuid>"
fhir "$BASE/DocumentReference?patient=<uuid>"
fhir "$BASE/DocumentReference?encounter=<enc-uuid>"
fhir "$BASE/DocumentReference/<doc-uuid>"
fhir "$BASE/ImagingStudy?patient=<uuid>"
fhir "$BASE/ImagingStudy?basedon=ServiceRequest/<order-uuid>"
fhir "$BASE/ImagingStudy/<study-uuid>/\$fetch-quality-assessment"
fhir "$BASE/ConsultationBundle/<id>"
```

### Write examples (for completeness)
```bash
# create
curl -sk -u "$AUTH" -H 'Content-Type: application/fhir+json' -X POST "$BASE/Patient" -d @patient.json
# update
curl -sk -u "$AUTH" -H 'Content-Type: application/fhir+json' -X PUT "$BASE/Task/<task-uuid>" -d @task.json
# delete (voids/retires in OpenMRS)
curl -sk -u "$AUTH" -X DELETE "$BASE/Observation/<obs-uuid>"
```

### STU3 equivalents
Replace `/R4` with `/R3`. ServiceRequest becomes `ProcedureRequest`. Immunization is not available.
```bash
fhir "${BASE%/R4}/R3/ProcedureRequest?patient=<uuid>"
fhir "${BASE%/R4}/R3/Patient?name=John"
```

### LabOnFHIR's own REST endpoint (OpenMRS REST, not FHIR)
```bash
REST="https://<host>/openmrs/ws/rest/v1"
curl -sk -u "$AUTH" "$REST/failedtask"                 # all failed pushes
curl -sk -u "$AUTH" "$REST/failedtask?sent=false"      # still pending retry
curl -sk -u "$AUTH" "$REST/failedtask?sent=true&v=full"
curl -sk -u "$AUTH" "$REST/failedtask/<failed-task-uuid>"
```
Fields returned: `uuid`, `taskUuid`, `error`, `isSent`, `display`. The resource is read-only.

### Querying the LIS HAPI server directly (to see what LabOnFHIR sent)
```bash
export LIS="http://<lis-host>:<port>/fhir"          # value of labonfhir.lisUrl
alias lis='curl -sk -u "<lis-user>:<lis-password>" -H "Accept: application/fhir+json"'   # labonfhir.userName/password
lis "$LIS/Task/<task-uuid>"                                            # same id as in OpenMRS (PUT preserves ids)
lis "$LIS/Task?identifier=http://fhir.openmrs.org/ext/task/identifier|&status=completed&_lastUpdated=ge2026-11-17T00:00:00"
lis "$LIS/Task/<task-uuid>?_include=Task:based-on&_include=Task:patient"
lis "$LIS/ServiceRequest/<order-uuid>"
lis "$LIS/Patient/<patient-uuid>"
lis "$LIS/DiagnosticReport?_id=<id>&_include=DiagnosticReport:result&_include=DiagnosticReport:subject"
lis "$LIS/Task/<task-uuid>/_history"
```
