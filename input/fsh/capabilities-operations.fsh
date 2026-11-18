// ---------------------------------------------------------------------------
// CapabilityStatements for the Lab on FHIR exchange, and OperationDefinitions
// for the FHIR2 operations that are not defined by the base specification.
// The FHIR2 server CapabilityStatement itself is in input/resources (from the live /metadata).
// ---------------------------------------------------------------------------

Instance: labonfhir-client
InstanceOf: CapabilityStatement
Usage: #definition
Title: "Lab on FHIR 1.3.1 (client)"
* url = "https://lesotho-eregister-v1.github.io/eregister-fhir-ig/CapabilityStatement/labonfhir-client"
* name = "LabOnFHIRClient"
* title = "Lab on FHIR 1.3.1 (client)"
* status = #draft
* publisher = "Lesotho eRegister Team"
* experimental = false
* date = "2026-11-18"
* kind = #capability
* software.name = "OpenMRS Lab on FHIR module"
* software.version = "1.3.1-SNAPSHOT"
* fhirVersion = #4.0.1
* format[0] = #json
* description = "The calls that the Lab on FHIR module makes to the LIS FHIR server at labonfhir.lisUrl, using HTTP Basic (labonfhir.userName / labonfhir.password) or mutual TLS (labonfhir.authType = SSL)."
* rest[0].mode = #client
* rest[0].documentation = "Push: one transaction per new lab-order Task. Pull: scheduler 'OpenELIS Pull Task' every 30 s. Retry: scheduler 'Retry Failed Tasks' every 3600 s re-sends rows of the failed_task table."
* rest[0].interaction[0].code = #transaction
* rest[0].interaction[0].documentation = "POST [base] with a LabOrderTransactionBundle (all entries PUT)."
* rest[0].resource[0].type = #Task
* rest[0].resource[0].supportedProfile = Canonical(LabOrderTask)
* rest[0].resource[0].interaction[0].code = #search-type
* rest[0].resource[0].interaction[0].documentation = "GET [base]/Task?identifier=http://fhir.openmrs.org/ext/task/identifier|&status=completed&_lastUpdated=ge{last poll}&_lastUpdated=le{now}, following 'next' links."
* rest[0].resource[0].searchParam[0].name = "identifier"
* rest[0].resource[0].searchParam[0].type = #token
* rest[0].resource[0].searchParam[1].name = "status"
* rest[0].resource[0].searchParam[1].type = #token
* rest[0].resource[0].searchParam[2].name = "_lastUpdated"
* rest[0].resource[0].searchParam[2].type = #date
* rest[0].resource[1].type = #DiagnosticReport
* rest[0].resource[1].supportedProfile = Canonical(LabResultDiagnosticReport)
* rest[0].resource[1].interaction[0].code = #search-type
* rest[0].resource[1].interaction[0].documentation = "GET [base]/DiagnosticReport?_id={Task.output reference}&_include=DiagnosticReport:result&_include=DiagnosticReport:subject"
* rest[0].resource[1].searchInclude[0] = "DiagnosticReport:result"
* rest[0].resource[1].searchInclude[1] = "DiagnosticReport:subject"
* rest[0].resource[1].searchParam[0].name = "_id"
* rest[0].resource[1].searchParam[0].type = #token

Instance: lis-server-requirements
InstanceOf: CapabilityStatement
Usage: #definition
Title: "LIS FHIR server requirements"
* url = "https://lesotho-eregister-v1.github.io/eregister-fhir-ig/CapabilityStatement/lis-server-requirements"
* name = "LISServerRequirements"
* title = "LIS FHIR server requirements"
* status = #draft
* publisher = "Lesotho eRegister Team"
* experimental = false
* date = "2026-11-18"
* kind = #requirements
* fhirVersion = #4.0.1
* format[0] = #json
* description = "What a LIS FHIR server (for example a HAPI FHIR JPA server in front of OpenELIS or DISA) must support so that Lab on FHIR 1.3.1 can exchange lab orders and results with it."
* rest[0].mode = #server
* rest[0].interaction[0].code = #transaction
* rest[0].interaction[0].documentation = "SHALL accept transaction Bundles whose entries are PUT (update-as-create) with client-assigned ids."
* rest[0].resource[0].type = #Task
* rest[0].resource[0].supportedProfile = Canonical(LabOrderTask)
* rest[0].resource[0].interaction[0].code = #update
* rest[0].resource[0].interaction[1].code = #search-type
* rest[0].resource[0].updateCreate = true
* rest[0].resource[0].searchParam[0].name = "identifier"
* rest[0].resource[0].searchParam[0].type = #token
* rest[0].resource[0].searchParam[0].documentation = "SHALL support system-only form: identifier=http://fhir.openmrs.org/ext/task/identifier|"
* rest[0].resource[0].searchParam[1].name = "status"
* rest[0].resource[0].searchParam[1].type = #token
* rest[0].resource[0].searchParam[2].name = "_lastUpdated"
* rest[0].resource[0].searchParam[2].type = #date
* rest[0].resource[1].type = #DiagnosticReport
* rest[0].resource[1].supportedProfile = Canonical(LabResultDiagnosticReport)
* rest[0].resource[1].interaction[0].code = #update
* rest[0].resource[1].interaction[1].code = #search-type
* rest[0].resource[1].updateCreate = true
* rest[0].resource[1].searchInclude[0] = "DiagnosticReport:result"
* rest[0].resource[1].searchInclude[1] = "DiagnosticReport:subject"
* rest[0].resource[1].searchParam[0].name = "_id"
* rest[0].resource[1].searchParam[0].type = #token
* rest[0].resource[2].type = #Patient
* rest[0].resource[2].interaction[0].code = #update
* rest[0].resource[2].updateCreate = true
* rest[0].resource[3].type = #Practitioner
* rest[0].resource[3].interaction[0].code = #update
* rest[0].resource[3].updateCreate = true
* rest[0].resource[4].type = #Encounter
* rest[0].resource[4].interaction[0].code = #update
* rest[0].resource[4].updateCreate = true
* rest[0].resource[5].type = #ServiceRequest
* rest[0].resource[5].supportedProfile = Canonical(LabOrderServiceRequest)
* rest[0].resource[5].interaction[0].code = #update
* rest[0].resource[5].updateCreate = true
* rest[0].resource[6].type = #Location
* rest[0].resource[6].interaction[0].code = #update
* rest[0].resource[6].updateCreate = true
* rest[0].resource[7].type = #Observation
* rest[0].resource[7].interaction[0].code = #update
* rest[0].resource[7].updateCreate = true

Instance: Encounter-everything
InstanceOf: OperationDefinition
Usage: #definition
Title: "Encounter $everything (OpenMRS FHIR2)"
* url = "https://lesotho-eregister-v1.github.io/eregister-fhir-ig/OperationDefinition/Encounter-everything"
* name = "EncounterEverything"
* title = "Encounter $everything (OpenMRS FHIR2)"
* status = #draft
* publisher = "Lesotho eRegister Team"
* kind = #operation
* code = #everything
* description = "Returns the Encounter and the resources that belong to it (observations, orders, reports) as a searchset Bundle. FHIR2 handles Patient and Encounter $everything with one implementation."
* resource[0] = #Encounter
* system = false
* type = false
* instance = true
* affectsState = false
* parameter[0].name = #return
* parameter[0].use = #out
* parameter[0].min = 1
* parameter[0].max = "1"
* parameter[0].type = #Bundle

Instance: Observation-lastn-encounters
InstanceOf: OperationDefinition
Usage: #definition
Title: "Observation $lastn-encounters (OpenMRS FHIR2)"
* url = "https://lesotho-eregister-v1.github.io/eregister-fhir-ig/OperationDefinition/Observation-lastn-encounters"
* name = "ObservationLastnEncounters"
* title = "Observation $lastn-encounters (OpenMRS FHIR2)"
* status = #draft
* publisher = "Lesotho eRegister Team"
* kind = #operation
* code = #lastn-encounters
* description = "OpenMRS-specific variant of $lastn: returns the observations from the patient's last N encounters, optionally filtered by category and code."
* resource[0] = #Observation
* system = false
* type = true
* instance = false
* affectsState = false
* parameter[0].name = #max
* parameter[0].use = #in
* parameter[0].min = 0
* parameter[0].max = "1"
* parameter[0].type = #positiveInt
* parameter[0].documentation = "Number of most recent encounters to include (default 1)."
* parameter[1].name = #patient
* parameter[1].use = #in
* parameter[1].min = 0
* parameter[1].max = "1"
* parameter[1].searchType = #reference
* parameter[2].name = #subject
* parameter[2].use = #in
* parameter[2].min = 0
* parameter[2].max = "1"
* parameter[2].searchType = #reference
* parameter[3].name = #category
* parameter[3].use = #in
* parameter[3].min = 0
* parameter[3].max = "*"
* parameter[3].searchType = #token
* parameter[4].name = #code
* parameter[4].use = #in
* parameter[4].min = 0
* parameter[4].max = "*"
* parameter[4].searchType = #token
* parameter[5].name = #return
* parameter[5].use = #out
* parameter[5].min = 1
* parameter[5].max = "1"
* parameter[5].type = #Bundle

Instance: Group-members
InstanceOf: OperationDefinition
Usage: #definition
Title: "Group $members (OpenMRS FHIR2)"
* url = "https://lesotho-eregister-v1.github.io/eregister-fhir-ig/OperationDefinition/Group-members"
* name = "GroupMembers"
* title = "Group $members (OpenMRS FHIR2)"
* status = #draft
* publisher = "Lesotho eRegister Team"
* kind = #operation
* code = #members
* description = "Returns the members of an OpenMRS cohort (FHIR Group) as a Bundle."
* resource[0] = #Group
* system = false
* type = false
* instance = true
* affectsState = false
* parameter[0].name = #return
* parameter[0].use = #out
* parameter[0].min = 1
* parameter[0].max = "1"
* parameter[0].type = #Bundle

Instance: Encounter-encountersWithMedicationRequests
InstanceOf: OperationDefinition
Usage: #definition
Title: "Encounter named query encountersWithMedicationRequests"
* url = "https://lesotho-eregister-v1.github.io/eregister-fhir-ig/OperationDefinition/Encounter-encountersWithMedicationRequests"
* name = "EncountersWithMedicationRequests"
* title = "Encounter named query encountersWithMedicationRequests"
* status = #draft
* publisher = "Lesotho eRegister Team"
* kind = #query
* code = #encountersWithMedicationRequests
* description = "Named query (GET [base]/Encounter?_query=encountersWithMedicationRequests) used by pharmacy work lists: encounters that contain medication requests."
* resource[0] = #Encounter
* system = false
* type = true
* instance = false
* affectsState = false
* parameter[0].name = #date
* parameter[0].use = #in
* parameter[0].min = 0
* parameter[0].max = "1"
* parameter[0].searchType = #date
* parameter[1].name = #status
* parameter[1].use = #in
* parameter[1].min = 0
* parameter[1].max = "1"
* parameter[1].searchType = #token
* parameter[2].name = #patientSearchTerm
* parameter[2].use = #in
* parameter[2].min = 0
* parameter[2].max = "1"
* parameter[2].searchType = #token
* parameter[3].name = #return
* parameter[3].use = #out
* parameter[3].min = 1
* parameter[3].max = "1"
* parameter[3].type = #Bundle
