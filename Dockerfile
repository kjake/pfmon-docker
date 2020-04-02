FROM grafana/grafana
MAINTAINER kjake

USER root

ADD conf/grafana.db /var/lib/grafana/grafana.db
ADD conf/home.json /usr/share/grafana/public/dashboards/home.json

RUN chown -R 472:472 /var/lib/grafana

RUN grafana-cli \
  --homepath=/usr/share/grafana \
  --config=/etc/grafana/grafana.ini \
  --pluginUrl https://packages.hiveeyes.org/grafana/grafana-map-panel/grafana-map-panel-0.9.0.zip \
  plugins install grafana-map-panel

USER grafana

ENTRYPOINT ["/run.sh"]