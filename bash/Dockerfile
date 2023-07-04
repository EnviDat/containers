ARG EXTERNAL_REG



FROM ${EXTERNAL_REG}/debian:bookworm-slim as runtime
ARG MAINTAINER
LABEL envidat.ch.maintainer="${MAINTAINER}"
RUN set -ex \
    && apt-get update || true \
    && DEBIAN_FRONTEND=noninteractive apt-get install \
        -y --no-install-recommends \
            locales \
            gosu \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*
# Set locale
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
WORKDIR /home/appuser
# Add appuser user, permissions
RUN useradd -r -u 900 -m -c "appuser account" -d /home/appuser -s /bin/false appuser \
    && chown -R appuser:appuser /opt /home/appuser
# Set entrypoint and make executable
COPY entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["bash"]
