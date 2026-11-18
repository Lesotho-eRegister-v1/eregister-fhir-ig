// ---------------------------------------------------------------------------
// Code systems used on the wire. These are FRAGMENTS: they document only the
// codes that the OpenMRS modules emit or expect. The authoritative owners are
// OpenMRS (fhir.openmrs.org) and the Lesotho MoH laboratory services.
// ---------------------------------------------------------------------------

CodeSystem: OpenMRSEncounterTag
Id: openmrs-encounter-tag
Title: "OpenMRS Encounter Tag (fragment)"
Description: "Meta tag that FHIR2 puts on Encounter resources to show whether the FHIR Encounter came from an OpenMRS `encounter` row or a `visit` row. Searchable with `_tag`."
* ^url = $encounter-tag
* ^status = #active
* ^publisher = "Lesotho eRegister Team"
* ^content = #fragment
* ^experimental = false
* ^caseSensitive = true
* #encounter "Encounter" "The FHIR Encounter represents an OpenMRS encounter."
* #visit "Visit" "The FHIR Encounter represents an OpenMRS visit."

CodeSystem: LSMOHDISALabServices
Id: lsmoh-disa-lab-services
Title: "Lesotho MoH DISA Laboratory Services codes (fragment)"
Description: """
Codes from the Lesotho Ministry of Health DISA laboratory system, as they appear on the wire.

* **Observed on the live instance (2026-11-18)**: FHIR2 emits these as extra codings on concepts that have a mapping to the
  `LSMOH DISA` concept source, whose `fhir_concept_source` URL is `http://health.gov.ls/laboratory-services/`
  (**with** trailing slash). Displays are the OpenMRS concept names that FHIR2 copies into every coding; DISA's own
  display texts are not known.
* **From Lab on FHIR 1.3.1 code analysis, not observed live**: the derived viral-load codes (`HIVTCVL…`, `<20`, `>=20`,
  `Undetectable`). A code search for them on the live instance returned nothing.

Lab on FHIR's send-time re-coding (`CTREA`, `PTREA`, `PVLD`, `FCD4`, `LCD4`) uses the system **without** the slash, so
those codes are not part of this code system. See [Findings](findings.html) L1.
"""
* ^url = $disa
* ^status = #active
* ^publisher = "Lesotho eRegister Team"
* ^content = #fragment
* ^experimental = false
* ^caseSensitive = true
// --- Observed: orders and specimens
* #HIVVL "HIVTC, Lab Test, Viral Load" "Viral-load test. Observed on ServiceRequest.code, DiagnosticReport.code and Task.output.type (with LOINC 20447-9)."
* #B "Blood" "Specimen type. Observed on the Specimen contained in each lab-order ServiceRequest."
// --- Observed: results returned by the LIS
* #HIVVL-HIVVM "DISA, VL Result [#/vol]" "Viral load in copies/ml (valueQuantity). Mapped together with LOINC 70241-5. Triggers Lab on FHIR's viral-load handling."
* #HIVVL-HIVML "DISA, VL Result [log#/vol]" "Viral load as log10 (valueQuantity, no unit). Mapped together with LOINC 51780-5."
* #HIVVL-HIVVH "DISA, VL Result (low value)" "Low-value viral-load result (valueCodeableConcept, e.g. LDL)."
* #LDL "DISA, VL Lower Than Detectable Limit" "Value of HIVVL-HIVVH."
// --- Observed: clinical-context (supportingInfo) observations
* #DAIN "HIVTC, ART start date" "ART start date (valueDateTime)."
* #RFVL "HIVTC, Viral Load Monitoring Type" "Reason for viral-load test."
* #ROUT "Routine" "Value of RFVL."
* #CPREG "HIVTC, VL Pregnancy Status" "Pregnancy status at time of order."
* #CLACT "HIVTC, VL Breastfeeding Status" "Breastfeeding status at time of order."
* #NO "No" "Answer used by CPREG and CLACT."
// --- Observed: ART regimens (value of the 'HIVTC, ART Regimen' observation)
* #D4T1 "1a=d4T-3TC-NVP" "ART regimen."
* #AZT1 "1c=AZT-3TC-NVP" "ART regimen."
* #AZT2 "1d=AZT-3TC-EFV" "ART regimen."
* #TDF1 "1e=TDF-3TC-NVP" "ART regimen."
* #TDF2 "1f=TDF-3TC-EFV" "ART regimen."
* #ABC1 "1g=ABC-3TC-NVP" "ART regimen."
* #ABC2 "1h=ABC-3TC-EFV" "ART regimen."
* #TDF5 "1j=TDF-3TC-DTG" "ART regimen."
* #ABC5 "1k=ABC-3TC-DTG" "ART regimen."
* #AZT5 "1m=AZT-3TC-DTG" "ART regimen."
* #AZT3 "2c=AZT-3TC-LPV/r" "ART regimen."
* #AZT7 "4d=AZT-3TC-EFV" "ART regimen."
// --- From Lab on FHIR code analysis only (not observed live)
* #HIVVL-HIVVT "HIV viral load (HIVVT)" "Result code that triggers viral-load handling. From code analysis; not observed live."
* #HIVVL-HIVVC "HIV viral load low value (HIVVC)" "Low-value result code; saved as 'Undetectable'. From code analysis; not observed live."
* #HIVTCVL "HIVTC, Viral Load" "Derived categorical viral-load result. From code analysis; not observed live."
* #HIVTCVLResult "Viral Load Result" "Derived viral-load result. From code analysis; not observed live."
* #HIVTCVLDATAAbnormal "Viral Load Abnormal" "Derived abnormal flag. From code analysis; not observed live."
* #HIVTCVLReturnDate "Viral load blood results return date" "Date the result came back from the LIS. From code analysis; not observed live."
* #"<20" "Less than 20 copies/ml" "Value of HIVTCVL below 20 copies/ml. From code analysis."
* #">=20" "Greater or Equal to 20 copies/ml" "Value of HIVTCVL at 20 copies/ml or more. From code analysis."
* #Undetectable "Undetectable" "Value of HIVTCVLResult for low-value result codes. From code analysis."

ValueSet: LabOnFHIRSupportingInfoCodes
Id: labonfhir-supporting-info-codes
Title: "Lab on FHIR send-time supporting-information codes"
Description: """
DISA codes that Lab on FHIR 1.3.1 adds (by display-name match) to clinical-context observations while building the
transaction for the LIS. They are **not stored** in OpenMRS and are not visible through FHIR2. They use the system
`http://health.gov.ls/laboratory-services` **without** the trailing slash (Findings L1), which this guide does not define.

The codes that the supporting observations actually carry in OpenMRS come from concept mappings; see
[LabOrderSupportingInfoCodes](ValueSet-lab-order-supporting-info-codes.html).
"""
* ^status = #active
* ^publisher = "Lesotho eRegister Team"
* ^experimental = false
* $disa-noslash#CTREA "Current Treatment"
* $disa-noslash#PTREA "Previous Treatment"
* $disa-noslash#PVLD "Previous VL Results"
* $disa-noslash#FCD4 "First CD4"
* $disa-noslash#LCD4 "Last CD4"

ValueSet: LabOrderSupportingInfoCodes
Id: lab-order-supporting-info-codes
Title: "Lab order supporting-information observation codes (observed)"
Description: """
Observation codes found on the observations referenced from `ServiceRequest.supportingInfo` on the live instance
(508 observations across 85 orders, 2026-11-18). Each observation also carries a system-less coding with the OpenMRS
concept UUID. `ServiceRequest.supportingInfo.display` holds a short label (e.g. "Current Regimen", "VL Reason").
"""
* ^status = #active
* ^publisher = "Lesotho eRegister Team"
* ^experimental = false
* $ciel#162240
* $loinc#45260-7
* $ciel#159599
* $disa#DAIN "HIVTC, ART start date"
* $disa#RFVL "HIVTC, Viral Load Monitoring Type"
* $disa#CLACT "HIVTC, VL Breastfeeding Status"
* $loinc#63895-7
* $disa#CPREG "HIVTC, VL Pregnancy Status"
* $loinc#82810-3
* $ciel#856
* $loinc#25836-8
* $loinc#80721-4

ValueSet: LabOnFHIRViralLoadTriggerCodes
Id: labonfhir-viral-load-trigger-codes
Title: "Lab on FHIR viral-load trigger codes"
Description: "Result codes that make Lab on FHIR derive the Lesotho HIV viral-load observations when importing results (from code analysis). On the live instance, viral-load results carry LOINC 70241-5 together with DISA HIVVL-HIVVM."
* ^status = #active
* ^publisher = "Lesotho eRegister Team"
* ^experimental = false
* $loinc#20447-9 "HIV 1 RNA [#/volume] (viral load) in Serum or Plasma by Probe and target amplification method"
* $loinc#70241-5
* $disa#HIVVL-HIVVM
* $disa#HIVVL-HIVVT
* $disa#HIVVL-HIVVC
* $disa#HIVVL-HIVVH

ValueSet: LabOrderTestCodes
Id: lab-order-test-codes
Title: "Lab order test codes (observed)"
Description: "Codes found on `ServiceRequest.code`, `DiagnosticReport.code` and `Task.output.type` on the live instance. Every one is accompanied by a system-less coding with the OpenMRS concept UUID (`92d73e24-122e-4f3e-8447-fb972f01b617` for the viral-load test)."
* ^status = #active
* ^publisher = "Lesotho eRegister Team"
* ^experimental = false
* $loinc#20447-9
* $disa#HIVVL "HIVTC, Lab Test, Viral Load"

Instance: openmrs-task-identifier
InstanceOf: NamingSystem
Usage: #definition
Title: "OpenMRS Task identifier"
Description: "Identifier system that FHIR2 puts on every Task. The value is the Task's OpenMRS UUID. Lab on FHIR uses it to find completed Tasks on the LIS and match them back to OpenMRS."
* name = "OpenMRSTaskIdentifier"
* description = "Identifier system that FHIR2 puts on every Task. The value is the Task's OpenMRS UUID. Lab on FHIR uses it to find completed Tasks on the LIS and match them back to OpenMRS."
* status = #active
* kind = #identifier
* date = "2026-11-18"
* publisher = "Lesotho eRegister Team"
* uniqueId[0].type = #uri
* uniqueId[0].value = "http://fhir.openmrs.org/ext/task/identifier"
* uniqueId[0].preferred = true

Instance: openlis-patient-identifier
InstanceOf: NamingSystem
Usage: #definition
Title: "OpenLIS ID System (patient identifier)"
Description: "Identifier system that Lab on FHIR registers in FHIR2 at startup for the patient identifier type `labonfhir.openmrsPatientIdentifier.uuid` (default `05a29f94-c0ed-11e2-94be-8c13b969e334`), so that Patient.identifier carries a system the LIS recognises. The URL comes from `labonfhir.lisIdentifierSystem.url` and may be configured differently on an instance. On the live instance (2026-11-18) no patient has an identifier of the configured type, so this system never appears on Patient.identifier."
* name = "OpenLISPatientIdentifier"
* description = "Identifier system that Lab on FHIR registers in FHIR2 at startup for the patient identifier type `labonfhir.openmrsPatientIdentifier.uuid` (default `05a29f94-c0ed-11e2-94be-8c13b969e334`), so that Patient.identifier carries a system the LIS recognises. The URL comes from `labonfhir.lisIdentifierSystem.url` and may be configured differently on an instance. On the live instance (2026-11-18) no patient has an identifier of the configured type, so this system never appears on Patient.identifier."
* status = #active
* kind = #identifier
* date = "2026-11-18"
* publisher = "Lesotho eRegister Team"
* uniqueId[0].type = #uri
* uniqueId[0].value = "http://openelis-global.org/pat_nationalId"
* uniqueId[0].preferred = true
