# Grafana is no longer published to the public Wolfi repository, so the
# Grafana distribution (a static binary plus assets) comes from the upstream
# image and the OS layer comes from Wolfi.
FROM grafana/grafana AS grafana

FROM cgr.dev/chainguard/wolfi-base
LABEL maintainer="kjake"

# Unpinned on purpose so each build picks up the latest patched packages.
RUN apk upgrade --no-cache && \
    apk add --no-cache bash tzdata

ENV PATH=/usr/share/grafana/bin:$PATH \
    GF_PATHS_CONFIG=/etc/grafana/grafana.ini \
    GF_PATHS_DATA=/var/lib/grafana \
    GF_PATHS_HOME=/usr/share/grafana \
    GF_PATHS_LOGS=/var/log/grafana \
    GF_PATHS_PLUGINS=/var/lib/grafana/plugins \
    GF_PATHS_PROVISIONING=/etc/grafana/provisioning

COPY --from=grafana /usr/share/grafana /usr/share/grafana
COPY --from=grafana /etc/grafana /etc/grafana
COPY --from=grafana /run.sh /run.sh

RUN mkdir -p "$GF_PATHS_PLUGINS" "$GF_PATHS_LOGS" /home/grafana

COPY conf/grafana.db /home/grafana/template.db
COPY conf/home.json /usr/share/grafana/public/dashboards/
COPY docker-entrypoint /

WORKDIR /usr/share/grafana
EXPOSE 3000
ENTRYPOINT ["/docker-entrypoint"]
