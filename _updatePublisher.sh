#!/bin/sh
# Downloads the latest HL7 FHIR IG Publisher into input-cache/.
set -e
mkdir -p input-cache
curl -L -o input-cache/publisher.jar https://github.com/HL7/fhir-ig-publisher/releases/latest/download/publisher.jar
echo "IG Publisher saved to input-cache/publisher.jar"
