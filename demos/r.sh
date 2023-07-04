#!/bin/bash

docker run --rm -it -v "$PWD:/data" r-test code/script.R
