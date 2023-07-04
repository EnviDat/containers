# Containers

Container images for simple script execution.

## Python

- The Python image can run any Python script, including any required dependencies.
- The default images for Python 3.9, 3.10, 3.11 contains dependencies:

```txt
numpy
scipy
pandas
matplotlib
scikit-learn
```

- The python-geo (3.11 only) contains dependencies:

```txt
pandas
geopandas
gdal
rasterio
shapely
```

### Running your code

Run your script in the container environment with:

```bash
docker run --rm -it \
    -v $PWD:$PWD \
    registry-gitlab.wsl.ch/envidat/containers/python:latest \
    /path/to/your/script.py
```

> Note: Change the `latest` in the image name to run in different environments: `3.9`, `3.9`, `3.11-geo`.
> Note: The `latest` tag is shorthand for the `3.11` image.

### Adding additional pip packages

- The pre-built containers may not have all of the dependencies required by your Python script.
- To install dependencies before your script runs, use the `ADDITIONAL_PIP_PACKAGES` variable:

```bash
docker run --rm -it \
    -v $PWD:$PWD \
    -e ADDITIONAL_PIP_PACKAGES=requests,sqlalchemy \
    registry-gitlab.wsl.ch/envidat/containers/python:latest \
    /path/to/your/script.py
```

---

## R

- The R image can run any R script, including any required dependencies.
- The default image for R v4.2.2 contains dependencies:

```txt
hmisc
foreign
readxl
readr
jsonlite
rpostgresql
rmysql
stringr
ggpubr
sampling
survey
```

### Running your code

Run your script in the container environment with:

```bash
docker run --rm -it \
    -v $PWD:$PWD \
    registry-gitlab.wsl.ch/envidat/containers/r:latest \
    /path/to/your/script.R
```

> Note: The `latest` tag is shorthand for the `4.2.2` image.

### Adding additional R packages

- The pre-built containers may not have all of the dependencies required by your R script.
- To install dependencies before your script runs, use the `ADDITIONAL_R_PACKAGES` variable:

```bash
docker run --rm -it \
    -v $PWD:$PWD \
    -e ADDITIONAL_R_PACKAGES=packagename1,packagename2 \
    registry-gitlab.wsl.ch/envidat/containers/r:latest \
    /path/to/your/script.R
```

---

## Bash

- The BASH image can run any bash script, including any required dependencies.
- The default `latest` image contains a slimmed down version of default Debian bookworm dependencies:
- The `bash:geo` image contains dependencies:

```txt
wget
gdal
ffmpeg
```

### Running your code

Run your script in the container environment with:

```bash
docker run --rm -it \
    -v $PWD:$PWD \
    registry-gitlab.wsl.ch/envidat/containers/bash:latest \
    /path/to/your/script.sh
```

> Note: Change the `latest` in the image name to run in different environments: `geo`.

### Adding additional Debian packages

- The pre-built containers may not have all of the dependencies required by your bash script.
- To install dependencies before your script runs, use the `ADDITIONAL_PACKAGES` variable.
- This will install Debian packages uses `apt` prior to script execution.

```bash
docker run --rm -it \
    -v $PWD:$PWD \
    -e ADDITIONAL_PACKAGES=tzdata,nano \
    registry-gitlab.wsl.ch/envidat/containers/bash:latest \
    /path/to/your/script.sh
```

---

## Saving a container plus code to EnviDat

1. Run your container: `docker run -d --name code-container registry-gitlab.wsl.ch/envidat/containers/bash:geo sleep infinity`.
2. Copy your code: `docker cp code-container:/opt/ /path/to/script.sh`.
3. Commit the container changes to an image: `docker commit code-container code-container-image`.
4. Save the image as a .tar: `docker save code-container-image | gzip > code-container-image.tar.gz`.
5. Upload as a dataset to your EnviDat entry.
