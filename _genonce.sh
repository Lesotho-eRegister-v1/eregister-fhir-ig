#!/bin/sh
# Builds the guide once: SUSHI (via the IG Publisher) and the IG Publisher. Output goes to output/index.html.
set -e
if [ ! -f input-cache/publisher.jar ]; then echo "Run ./_updatePublisher.sh first"; exit 1; fi
java -Xmx4g -jar input-cache/publisher.jar -ig . "$@"
