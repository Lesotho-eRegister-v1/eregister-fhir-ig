# OpenMRS FHIR2 and Lab on FHIR Implementation Guide (draft 0.1.0)

A FHIR R4 implementation guide (FHIR Shorthand + HL7 IG Publisher). It describes:

- the **OpenMRS FHIR2 module 1.9.0** server API, as served by the Bahmni instance,
- the **Lab on FHIR 1.3.1** laboratory workflow with the LIS (eRegister / DISA),
- the **Bahmni FHIR2 Additional Extension**, which is not deployed yet.

## Sources

- Analysis of the module builds in `../openmrs-module-fhir2-release`, `../openmrs-module-labonfhir-release` and `../bahmni-module-fhir2-addl-extension`.
- The instance's public capability statement (`GET /openmrs/ws/fhir2/R4/metadata`, 2026-11-18). It is stored as
  `input/resources/CapabilityStatement-openmrs-fhir2-r4-server.json`.
- Not yet included: instance settings that need a login (loaded modules, `labonfhir.*` global properties, record counts).

## Layout

| Path | Contents |
|---|---|
| `sushi-config.yaml` | IG metadata, pages and menu |
| `input/fsh/` | Profiles, terminology, capability statements, operation definitions, synthetic examples |
| `input/resources/` | The server CapabilityStatement generated from the live `/metadata` |
| `input/pagecontent/` | Narrative pages (architecture, API, query cookbook, lab workflow, terminology, findings) |
| `input/images/` | Diagrams |

## Build

```bash
# 1. Compile the FSH only (fast check):
npx fsh-sushi build .          # writes fsh-generated/

# 2. Full website (needs Java 17+):
./_updatePublisher.sh          # downloads the HL7 IG Publisher
./_genonce.sh                  # output/index.html
```

## Before sharing outside the team

- Replace the placeholder canonical `http://example.org/fhir/ig/openmrs-fhir2`, the package id `example.openmrs.fhir2.lab` and the publisher in `sushi-config.yaml`.
- Credentials, the LIS host and the LIS service-user UUID are masked in the pages. Keep it that way.
