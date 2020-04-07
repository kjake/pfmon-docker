FROM grafana/grafana
MAINTAINER kjake

USER root

COPY conf/grafana.db /home/grafana/template.db
COPY conf/home.json /usr/share/grafana/public/dashboards/
COPY docker-entrypoint /
ENTRYPOINT ["/docker-entrypoint"]