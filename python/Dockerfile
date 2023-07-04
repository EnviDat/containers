ARG EXTERNAL_REG
ARG BASE_IMG_TAG



FROM ${EXTERNAL_REG}/python:${BASE_IMG_TAG} as base
ARG BASE_IMG_TAG
ARG MAINTAINER
LABEL envidat.ch.python-img-tag="${BASE_IMG_TAG}" \
      envidat.ch.maintainer="${MAINTAINER}"
RUN set -ex \
    && apt-get update || true \
    && DEBIAN_FRONTEND=noninteractive apt-get install \
        -y --no-install-recommends locales \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*
# Set locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8



FROM base as extract-deps
WORKDIR /opt/python
COPY pyproject.toml pdm.lock /opt/python/
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir pdm==2.7.4
RUN pdm export > requirements.txt



FROM base as build
RUN set -ex \
    && apt-get update || true \
    && DEBIAN_FRONTEND=noninteractive apt-get install \
        -y --no-install-recommends \
            build-essential \
            gcc \
            cmake \
            pkg-config \
            gfortran \
            libopenblas-dev \
    && rm -rf /var/lib/apt/lists/*
COPY --from=extract-deps \
    /opt/python/requirements.txt /opt/python/
RUN pip install --user --no-warn-script-location \
    --no-cache-dir -r /opt/python/requirements.txt



FROM base as runtime
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    PATH="/home/appuser/.local/bin:$PATH"
RUN set -ex \
    && apt-get update || true \
    && DEBIAN_FRONTEND=noninteractive apt-get install \
        -y --no-install-recommends \
            nano \
            curl \
            libopenblas0 \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /home/appuser
COPY --from=build \
    /root/.local \
    ./.local
# Add appuser user, permissions
RUN useradd -r -u 900 -m -c "appuser account" -d /home/appuser -s /bin/false appuser \
    && chown -R appuser:appuser /opt /home/appuser
# Add entrypoint
COPY entrypoint.sh /docker-entrypoint.sh
# Pre-compile packages to .pyc (init perf gains)
RUN chmod +x /docker-entrypoint.sh \
    && python -c "import compileall; compileall.compile_path(maxlevels=10, quiet=1)"
USER appuser
ENTRYPOINT ["python"]
CMD []
