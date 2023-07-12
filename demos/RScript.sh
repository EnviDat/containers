#!/bin/bash

docker run --rm -it -v "$PWD:/data" registry-gitlab.wsl.ch/envidat/containers/Rscript:latest code/script.R
