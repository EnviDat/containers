#!/bin/bash

docker run --rm -it -v "$PWD:/data" python-test code/script.py
