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
Codes from the Lesotho Ministry of Health DISA laboratory system that the Lab on FHIR module adds to Observations
before sending them to the LIS, and uses when it saves HIV viral-load results.
This fragment lists only the codes found in Lab on FHIR 1.3.1. The module writes the system both with and without
a trailing slash; see [Findings](findings.html).
"""
* ^url = $disa
* ^status = #active
* ^publisher = "Lesotho eRegister Team"
* ^content = #fragment
* ^experimental = false
* ^caseSensitive = true
* #CTREA "Current Treatment" "Added to the 'Current Regimen' supporting observation sent with a lab order."
* #PTREA "Previous Treatment" "Added to the 'Previous Regimen' supporting observation."
* #PVLD "Previous VL Results" "Added to the 'Prev VL Results' supporting observation."
* #FCD4 "First CD4" "Added to the 'First CD4' supporting observation."
* #LCD4 "Last CD4" "Added to the 'Last CD4' supporting observation."
* #HIVTCVL "HIVTC, Viral Load" "Derived categorical viral-load result saved in OpenMRS."
* #HIVTCVLResult "Viral Load Result" "Derived viral-load result saved in OpenMRS."
* #HIVTCVLDATAAbnormal "Viral Load Abnormal" "Derived abnormal flag saved in OpenMRS."
* #HIVTCVLReturnDate "Viral load blood results return date" "Date the result came back from the LIS."
* #HIVVL-HIVVM "HIV viral load (HIVVM)" "Result code from the LIS that triggers viral-load handling (display not confirmed)."
* #HIVVL-HIVVT "HIV viral load (HIVVT)" "Result code from the LIS that triggers viral-load handling (display not confirmed)."
* #HIVVL-HIVVC "HIV viral load low value (HIVVC)" "Low-value result code; saved as 'Undetectable' (display not confirmed)."
* #HIVVL-HIVVH "HIV viral load low value (HIVVH)" "Low-value result code; saved as 'Undetectable' (display not confirmed)."
* #"<20" "Less than 20 copies/ml" "Value of HIVTCVL when the viral load is below 20 copies/ml."
* #">=20" "Greater or Equal to 20 copies/ml" "Value of HIVTCVL when the viral load is 20 copies/ml or more."
* #Undetectable "Undetectable" "Value of HIVTCVLResult for the low-value result codes."

ValueSet: LabOnFHIRSupportingInfoCodes
Id: labonfhir-supporting-info-codes
Title: "Lab on FHIR supporting-information codes"
Description: "DISA codes that Lab on FHIR adds to clinical-context observations sent with a lab order."
* ^status = #active
* ^publisher = "Lesotho eRegister Team"
* ^experimental = false
* $disa#CTREA
* $disa#PTREA
* $disa#PVLD
* $disa#FCD4
* $disa#LCD4

ValueSet: LabOnFHIRViralLoadTriggerCodes
Id: labonfhir-viral-load-trigger-codes
Title: "Lab on FHIR viral-load trigger codes"
Description: "Result codes that make Lab on FHIR derive the Lesotho HIV viral-load observations when importing results."
* ^status = #active
* ^publisher = "Lesotho eRegister Team"
* ^experimental = false
* $loinc#20447-9 "HIV 1 RNA [#/volume] (viral load) in Serum or Plasma by Probe and target amplification method"
* $loinc#70241-5
* $disa#HIVVL-HIVVM
* $disa#HIVVL-HIVVT
* $disa#HIVVL-HIVVC
* $disa#HIVVL-HIVVH

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
Description: "Identifier system that Lab on FHIR registers in FHIR2 at startup for the patient identifier type `labonfhir.openmrsPatientIdentifier.uuid` (default `05a29f94-c0ed-11e2-94be-8c13b969e334`), so that Patient.identifier carries a system the LIS recognises. The URL comes from `labonfhir.lisIdentifierSystem.url` and may be configured differently on an instance."
* name = "OpenLISPatientIdentifier"
* description = "Identifier system that Lab on FHIR registers in FHIR2 at startup for the patient identifier type `labonfhir.openmrsPatientIdentifier.uuid` (default `05a29f94-c0ed-11e2-94be-8c13b969e334`), so that Patient.identifier carries a system the LIS recognises. The URL comes from `labonfhir.lisIdentifierSystem.url` and may be configured differently on an instance."
* status = #active
* kind = #identifier
* date = "2026-11-18"
* publisher = "Lesotho eRegister Team"
* uniqueId[0].type = #uri
* uniqueId[0].value = "http://openelis-global.org/pat_nationalId"
* uniqueId[0].preferred = true
