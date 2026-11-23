<div class="stu-note" markdown="1">
**Draft: agreed design, not yet implemented.** Unlike the rest of this guide, this page does not describe current
behaviour. It records the design agreed on 2026-11-23 for sending Bonolo Health prescriptions from OpenMRS to the HAPI
FHIR server and reading dispensing events back. Nothing sends prescriptions today. The `http://health.gov.ls/fhir/...`
URLs are proposed and must be confirmed by the Lesotho MoH.
</div>

These artifacts formalise the design: the [Bonolo Prescription Transaction Bundle](StructureDefinition-bonolo-prescription-bundle.html),
[MedicationRequest](StructureDefinition-bonolo-prescription-medication-request.html),
[Patient](StructureDefinition-bonolo-prescription-patient.html),
[Medication](StructureDefinition-bonolo-prescription-medication.html),
[Facility Location](StructureDefinition-bonolo-facility-location.html),
[Regimen](StructureDefinition-bonolo-regimen-observation.html),
[Pickup Point](StructureDefinition-bonolo-pickup-point-observation.html) and
[Next Pickup Date](StructureDefinition-bonolo-next-pickup-date-observation.html) Observations, the
[MedicationDispense](StructureDefinition-bonolo-medication-dispense.html) that the dispensing system writes, the
[Originating facility](StructureDefinition-originating-facility.html) extension, and the worked examples
[transaction Bundle](Bundle-example-bonolo-prescription-bundle.html) and
[MedicationDispense](MedicationDispense-example-bonolo-dispense.html).

### Scope

* The existing lab workflow ([Lab Workflow](lab-workflow.html)) is unchanged. Prescriptions are **added** alongside it.
* Target versions: the eRegister **FHIR2 1.9.0-SNAPSHOT** and **Lab on FHIR 1.3.1-SNAPSHOT** (not upstream FHIR2 2.x).
* Readers: an **external dispensing system** (e-lockers, retail pharmacies, outreach health posts). OpenMRS reads
  dispensing events back.
* Only prescriptions of patients whose *Bonolo Health Client* answer is **Yes** are sent.

### Why configuration is not enough

| Gap in FHIR2 1.9.0 / Lab on FHIR 1.3.1 | Consequence |
|---|---|
| Lab on FHIR handles `TestOrder` only | Nothing sends drug orders |
| MedicationRequest is read/search only, with no `identifier` (order number), no group number and no facility | The push must add them |
| Pickup point, next pickup date and regimen are **obs** in the *Bonolo Health* form section, not drug-order fields | The push must read them and send them as Observations |
| `Dosage.text` is Bahmni's raw dosing JSON | The push rewrites it as readable text |
| FHIR2 sends every active patient identifier and every person attribute | The push filters the Patient |

### What sends the data

A new **prescription handler in the eRegister Lab on FHIR fork**, in its own package, with its own switch (e.g.
`labonfhir.activatePrescriptionPush`). It reuses the existing HAPI connection (`labonfhir.lisUrl`, authentication), the
failed-send retry and the scheduler.

| Item | Design |
|---|---|
| Trigger | OpenMRS **Encounter** saved or updated |
| Condition | The encounter has drug orders **and** the patient's *Bonolo Health Client* = Yes |
| Bonolo answers | Regimen, pickup point and next pickup date must be in the **same encounter**. If any is missing the send waits; older values are never used |
| Re-send | On every change: new, cancelled, revised, Bonolo answers edited, dispensed (`PUT` by id, so HAPI always holds the current version) |
| Write rights | OpenMRS is the only writer of MedicationRequests. The dispensing system writes only MedicationDispense |

### What is sent: one transaction Bundle per prescription

A prescription is all drug orders written in one OpenMRS encounter. Each drug order is one MedicationRequest; all of
them share `groupIdentifier` = the encounter UUID.

| Resource | Content |
|---|---|
| Patient | Identifiers (only these, each with a system): Patient Identifier, National ID, HIV Program ID, New HIV Program ID. Names, sex, birth date. `telecom`: the *Primary Contact* (attribute `telephoneNumber`) as `phone`/`mobile`, 8 digits. **No** person-attribute extensions |
| Practitioner | The prescriber |
| Location | Originating facility: the encounter location's **parent**, with its *IdentifierSourceName* code (no `WXYZ` fallback) |
| Medication | One per drug: concept code, drug name and strength (`http://fhir.openmrs.org/ext/medicine`) |
| MedicationRequest | One per drug order: `identifier` = order number; `groupIdentifier` = prescription number; `status` as FHIR2 maps it; `authoredOn`; `requester`; `dosageInstruction` (readable text + `additionalInstruction`); `dispenseRequest`; `supportingInformation` → the three Observations; extension *originating-facility* → Location. `encounter` is removed |
| Observation × 3 | Regimen (*HIVTC, ART Regimen*); pickup point; next pickup date (*HIVTC, Bonolo Health next collection date*) |

No Encounter is sent: it would also need the Visit encounter it points to, and the dispensing system needs neither.

#### Status

| FHIR2 status | OpenMRS state | May be dispensed |
|---|---|---|
| `active` | Active order | **Yes** |
| `cancelled` | Discontinued or voided | No |
| `stopped` | Expired | No |
| `completed` | Fulfiller status COMPLETED (after dispensing) | No |
| `unknown` | Anything else | No |

#### Pickup point

The *Bonolo Health* section has nine pickup-point questions (see [BonoloPickupQuestions](ValueSet-bonolo-pickup-questions.html)).
The question that was answered gives the **type and district**; its answer is the **site**
(see [BonoloPickupSites](ValueSet-bonolo-pickup-sites.html)). The Observation sends both: `code` = question,
`value` = site, plus components for *Pick-up Locker Type* and *Pick-up District*.

| Question | Answers (sites) in the dictionary |
|---|---|
| E-locker Pickup Location Maseru | 11 |
| E-locker Pickup Location Mafeteng | 2 |
| E-locker Pickup Location Mohales Hoek | 2 |
| Retail Pharmacy Pickup location Maseru | 25 |
| Retail Pharmacy Pickup location Mafeteng | 3 |
| Retail Pharmacy Pickup location Mohales Hoek | 4 |
| Outreach/Health Post Pickup location Maseru | 17 |
| Outreach/Health Post Pickup location Mafeteng | **0**: answers must be defined before go-live |
| Outreach/Health Post Pickup location Mohales Hoek | **0**: answers must be defined before go-live |

### What is read back: dispensing

OpenMRS polls HAPI for MedicationDispense resources changed since the last run, like the lab workflow's Task poll, and
finds the drug order through `authorizingPrescription` = `MedicationRequest/<order uuid>`. FHIR2 1.9.0 has no
MedicationDispense support, so the order is updated through the OpenMRS order API.

| MedicationDispense `status` | Effect in OpenMRS |
|---|---|
| `completed` | Fulfiller status COMPLETED; *Dispensed* order attribute = true; MedicationRequest re-sent as `completed` |
| `in-progress` | Fulfiller status IN_PROGRESS (partly collected) |
| `declined`, `entered-in-error` | Logged only |

Missed pickups (no dispense by the next pickup date plus a grace period) are detected by the dispensing system. A feed
into the CAG module's `missed_drug_pickup` table is a possible later project.

### Configuration and data prerequisites

| # | Action |
|---|---|
| C1 | Set `labonfhir.openmrsPatientIdentifier.uuid` to *Patient Identifier* (`81433852-3f10-11e4-adec-0800271c1b75`) and `labonfhir.lisIdentifierSystem.url` to `http://health.gov.ls/fhir/identifier/patient-identifier`. Confirm with the OpenELIS team which system they match patients on |
| C2 | Delete the `fhir_patient_identifier_system` rows with no identifier type (see [Findings](findings.html) L9) |
| C3 | Add `fhir_patient_identifier_system` rows for National ID, HIV Program ID and New HIV Program ID (see [Identifiers and Terminology](terminology.html)) |
| C4 | Define answers for *Outreach/Health Post Pickup location Mafeteng* and *… Mohales Hoek* |
| C5 | Give every facility (parent location) an *IdentifierSourceName* attribute |
| C6 | Keep `fhir2.personContactPointAttributeTypeUuid` = `c66d5786-60f1-4cdf-8292-77e601c007cb` (*telephoneNumber*, labelled "Primary Contact"); leave `otherContactPersonAttributeUUID` and `saNumberAttributeUUID` unset |

### Accepted risk

Security of the HAPI server (TLS, a credential per client, replacing the default `labonfhir.lisUrl`) is **not** a
go-live condition for this design: the setup is treated as a test environment. Patient names, ART regimens and pickup
locations together reveal HIV status, so this should be revisited before real patient data is sent.
See [Findings](findings.html) S4.

### Out of scope

* Fixing the Bahmni report *ART-094 Bonolo Health Prescriptions*, which reads only the Maseru e-locker question.
* A missed-pickup feed into the CAG module.
* National or standard drug codes (concept mappings).
* Moving to FHIR2 2.x.
