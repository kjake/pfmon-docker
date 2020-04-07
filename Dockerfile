FROM grafana/grafana
MAINTAINER kjake

USER root

ADD conf/grafana.db /home/grafana/template.db
ADD conf/home.json /usr/share/grafana/public/dashboards/home.json
COPY docker-entrypoint /
ENTRYPOINT ["/docker-entrypoint"]