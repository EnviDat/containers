ARG EXTERNAL_REG



FROM ${EXTERNAL_REG}/debian:bookworm-slim as certs
# CA-Certs
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && update-ca-certificates



FROM ${EXTERNAL_REG}/debian:bookworm-slim as base
ARG BASE_IMG_TAG
ARG MAINTAINER
LABEL envidat.ch.python-img-tag="${BASE_IMG_TAG}" \
      envidat.ch.maintainer="${MAINTAINER}"
# CA-Certs
COPY --from=certs \
    /etc/ssl/certs/ca-certificates.crt \
    /etc/ssl/certs/ca-certificates.crt
RUN set -ex \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install \
        -y --no-install-recommends locales \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*
# Set locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8



FROM base as runtime
RUN set -ex \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install \
        -y --no-install-recommends \
            nano \
            curl \
            r-cran-data.table \
            r-cran-httr \
            r-cran-hmisc \
            r-cran-foreign \
            r-cran-readxl \
            r-cran-readr \
            r-cran-jsonlite \
            r-cran-rpostgresql \
            r-cran-rmysql \
            r-cran-stringr \
            r-cran-ggpubr \
            r-cran-sampling \
            r-cran-survey \
    && rm -rf /var/lib/apt/lists/*
VOLUME /data
WORKDIR /data
# Add appuser user, permissions
RUN useradd -r -u 900 -m -c "appuser account" -d /home/appuser -s /bin/false appuser \
    && chown -R appuser:appuser /data /home/appuser
# Set entrypoint and make executable
COPY entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
USER appuser
ENTRYPOINT ["/docker-entrypoint.sh"]
