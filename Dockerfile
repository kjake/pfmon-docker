FROM grafana/grafana
MAINTAINER kjake

USER root

ADD conf/grafana.db /var/lib/grafana/grafana.db
ADD conf/grafana.db /tmp/template.db
ADD conf/home.json /usr/share/grafana/public/dashboards/home.json
ADD conf/home.json /tmp/template.json

COPY docker-entrypoint /
USER grafana
ENTRYPOINT ["/docker-entrypoint"]

#CMD ["/run.sh"]