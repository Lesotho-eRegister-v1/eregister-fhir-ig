### Package

The NPM package for this guide (`package.tgz`) is produced by the IG Publisher in the `output` folder. It contains all conformance resources and examples.

### Definitions

* [JSON definitions](definitions.json.zip)
* [XML definitions](definitions.xml.zip)
* [Examples (JSON)](examples.json.zip)

### Building the guide

```bash
cd openmrs-fhir-ig
./_updatePublisher.sh     # downloads the HL7 IG Publisher into input-cache/
./_genonce.sh             # runs SUSHI + IG Publisher; the site is written to output/
```

The guide needs Java 17 or later, Node.js (for SUSHI) and internet access the first time, to fetch FHIR packages.
