### About this guide

This implementation guide describes the FHIR R4 interface of the Bahmni / OpenMRS deployment as it actually behaves:

* the **OpenMRS FHIR2 module 1.9.0-SNAPSHOT**, which serves OpenMRS data as FHIR R4 (and a subset as STU3) at `/openmrs/ws/fhir2/R4`;
* the **Lab on FHIR module 1.3.1-SNAPSHOT**, which sends laboratory orders to an external LIS FHIR server and brings the results back, customised for the Lesotho eRegister / DISA laboratory system;
* the **Bahmni FHIR2 Additional Extension 1.0.0-SNAPSHOT**, described for completeness although it is **not deployed** on the instance.

It is a *descriptive* guide. It documents what the software does today, so integrators, the LIS team and the implementation team work from the same facts.
Where the behaviour looks wrong, the guide says so on the [Findings](findings.html) page instead of describing what the software should do.
The one exception is the [Prescription Workflow](prescription-workflow.html) page, which records an agreed design; its artifacts have status *draft*.

### How this guide was produced

| Source | What it gave |
|---|---|
| FHIR2 1.9.0 module jar | Every resource provider, search parameter, `_include` / `_revinclude` and operation (read from the compiled HAPI annotations) |
| Lab on FHIR 1.3.1 module jar | The order, push, poll and retry logic, global properties and database changes (read from the bytecode) |
| Bahmni extension source | Its providers, operations and extensions |
| **Live instance**, `GET /openmrs/ws/fhir2/R4/metadata` and `/R3/metadata` on 2026-11-18 | Confirmation that the server exposes exactly the 18 R4 resources found in the jar, and that the Bahmni extension is not loaded. The [server CapabilityStatement](CapabilityStatement-openmrs-fhir2-r4-server.html) is generated from it |

Instance-specific configuration needs an authenticated session and is **not yet included**. That covers the loaded module list, the `labonfhir.*` global property values and record counts.
Until it is added, values on these pages are the module **defaults**.

### What is in the guide

<figure>
<img src="architecture.svg" alt="FHIR2 layers over the OpenMRS database, with Lab on FHIR exchanging bundles with the LIS" style="max-width:100%"/>
<figcaption>FHIR2 turns OpenMRS data into FHIR; Lab on FHIR uses FHIR2 to exchange lab orders and results with the LIS.</figcaption>
</figure>

| Page | Contents |
|---|---|
| [Architecture](architecture.html) | Module layers, packaging, component responsibilities, order and result sequences |
| [FHIR2 Server API](server.html) | The 18 R4 resources: interactions, search parameters, includes, operations |
| [Query Cookbook](queries.html) | Copy-paste `curl` queries for browsing every resource |
| [Lab Workflow](lab-workflow.html) | What Lab on FHIR sends to and reads from the LIS, with profiles and examples |
| [Prescription Workflow (draft)](prescription-workflow.html) | **Agreed design, not yet implemented**: Bonolo prescriptions sent to the HAPI server and dispensing read back, with draft profiles and examples |
| [Identifiers and Terminology](terminology.html) | Identifier systems, code systems and extension URLs on the wire |
| [Findings and Known Issues](findings.html) | Defects, risky defaults and security observations |
| [Bahmni Extension](bahmni-extension.html) | What the extension would add once FHIR2 is upgraded |
| [Artifacts](artifacts.html) | Profiles, capability statements, operation definitions, terminology and examples |

### Conformance artifacts at a glance

* **CapabilityStatements**: [OpenMRS FHIR2 R4 server](CapabilityStatement-openmrs-fhir2-r4-server.html) (from the live server), [Lab on FHIR client](CapabilityStatement-labonfhir-client.html), [LIS server requirements](CapabilityStatement-lis-server-requirements.html).
* **Profiles**: [Lab Order Task](StructureDefinition-lab-order-task.html), [Lab Order ServiceRequest](StructureDefinition-lab-order-service-request.html), [Lab Order Transaction Bundle](StructureDefinition-lab-order-transaction-bundle.html), [Lab Result DiagnosticReport](StructureDefinition-lab-result-diagnostic-report.html), [Lab Result Observation](StructureDefinition-lab-result-observation.html).
* **OperationDefinitions** for FHIR2's non-standard operations: [Patient and Encounter $everything](OperationDefinition-EncounterPatient-everything.html), [Observation $lastn-encounters](OperationDefinition-Observation-lastn-encounters.html), [Group $members](OperationDefinition-Group-members.html), [encountersWithMedicationRequests](OperationDefinition-Encounter-encountersWithMedicationRequests.html). `Observation/$lastn` is the standard FHIR operation ([base definition](http://hl7.org/fhir/R4/operation-observation-lastn.html)).
* **Terminology**: [OpenMRS encounter tag](CodeSystem-openmrs-encounter-tag.html), [Lesotho DISA laboratory codes](CodeSystem-lsmoh-disa-lab-services.html) and two value sets, plus the [task](NamingSystem-openmrs-task-identifier.html) and [patient](NamingSystem-openlis-patient-identifier.html) identifier naming systems.

### Status

Release 1.0.1. Canonical URL: `https://lesotho-eregister-v1.github.io/eregister-fhir-ig` (published from the [eregister-fhir-ig](https://github.com/Lesotho-eRegister-v1/eregister-fhir-ig) repository).
All examples are synthetic.
