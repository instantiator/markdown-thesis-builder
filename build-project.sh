#!/bin/sh

docker build . -t instantiator/project-builder
docker run --rm --volume "`pwd`/source:/source" instantiator/project-builder
