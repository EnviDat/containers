# Containers

Container images for simple script execution.

## Python

- The Python image can run any Python script, including any required dependencies.
- The default images for Python 3.9, 3.10, 3.11 contains dependencies:

```txt
requests
numpy
scipy
pandas
matplotlib
scikit-learn
```

- The python-geo (3.11 only) contains dependencies:

```txt
requests
pandas
geopandas
gdal
rasterio
shapely
```

### Running your code

- Navigate to the directory containing your code.
- Run your script in the container environment with:

```bash
docker run --rm -it \
    -v $PWD:/data \
    registry-gitlab.wsl.ch/envidat/containers/python:latest \
    script_name.py
```

> Note: Change the `latest` in the image name to run in different environments: `3.9`, `3.9`, `3.11-geo`.
> Note: The `latest` tag is shorthand for the `3.11` image.

### Adding additional pip packages

- The pre-built containers may not have all of the dependencies required by your Python script.
- To install dependencies before your script runs, use the `ADDITIONAL_PIP_PACKAGES` variable:

```bash
docker run --rm -it \
    -v $PWD:/data \
    -e ADDITIONAL_PIP_PACKAGES=requests,sqlalchemy \
    registry-gitlab.wsl.ch/envidat/containers/python:latest \
    script_name.py
```

---

## R

- The R image can run any R script, including any required dependencies.
- The default image for R v4.2.2 contains dependencies:

```txt
data.table
httr
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

- Navigate to the directory containing your code.
- Run your script in the container environment with:

```bash
docker run --rm -it \
    -v $PWD:/data \
    registry-gitlab.wsl.ch/envidat/containers/r:latest \
    script_name.R
```

> Note: The `latest` tag is shorthand for the `4.2.2` image.

### Adding additional R packages

- The pre-built containers may not have all of the dependencies required by your R script.
- To install dependencies before your script runs, use the `ADDITIONAL_R_PACKAGES` variable:

```bash
docker run --rm -it \
    -v $PWD:/data \
    -e ADDITIONAL_R_PACKAGES=packagename1,packagename2 \
    registry-gitlab.wsl.ch/envidat/containers/r:latest \
    script_name.R
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

- Navigate to the directory containing your code.
- Run your script in the container environment with:

```bash
docker run --rm -it \
    -v $PWD:/data \
    registry-gitlab.wsl.ch/envidat/containers/bash:latest \
    script_name.sh
```

> Note: Change the `latest` in the image name to run in different environments: `geo`.

### Adding additional Debian packages

- The pre-built containers may not have all of the dependencies required by your bash script.
- To install dependencies before your script runs, use the `ADDITIONAL_PACKAGES` variable.
- This will install Debian packages uses `apt` prior to script execution.

```bash
docker run --rm -it \
    -v $PWD:/data \
    -e ADDITIONAL_PACKAGES=tzdata,nano \
    registry-gitlab.wsl.ch/envidat/containers/bash:latest \
    script_name.sh
```

---

## Demos

- See working demos in the `demos` directory.
- Navigate to `demos`, then run each demo script with bash: `bash core.sh`.
- The Python and R demos simply transpose a online CSV file.
- The BASH example generates CORE files, using underlying jpg2 files (see CORE spec on EnviDat).

---

## Additional Tips

### Saving a container plus code to EnviDat

1. Run your container: `docker run -d --name code-container registry-gitlab.wsl.ch/envidat/containers/bash:geo sleep`.
2. Copy your code: `docker cp /path/to/script.sh code-container:/code/`.
3. Commit the container changes to an image: `docker commit code-container code-container-image`.
4. Save the image as a .tar: `docker save code-container-image | gzip > code-container-image.tar.gz`.
5. Upload the image (code + dependencies) as a dataset to your EnviDat entry.

### Using absolute paths

- Running a script as described requires the relative path.
- It's possible to use absolute paths if `-v $PWD:/data` is changed to `-v $PWD:$PWD`.
- Then the paths like `/home/username/path/to/script.py` can be used.
- Note that you must handle directory permissions in this case (they are not handled for you).
- To find the absolute current working directory in Linux, run: `echo $PWD`.
