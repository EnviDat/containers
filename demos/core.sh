#!/bin/bash

docker run --rm -it -v "$PWD:/data" registry-gitlab.wsl.ch/envidat/containers/bash:geo code/generate_core.sh
