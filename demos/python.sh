#!/bin/bash

docker run --rm -it -v "$PWD:/data" registry-gitlab.wsl.ch/envidat/containers/python:latest code/script.py
