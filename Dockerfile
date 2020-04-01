FROM grafana/grafana
MAINTAINER kjake

USER root

ADD conf/grafana.db /var/lib/grafana/grafana.db
ADD conf/home.json /usr/share/grafana/public/dashboards/home.json

RUN chown -R 472:472 /var/lib/grafana

#ENV GF_SERVER_ROOT_URL http://localhost
#ENV GF_SECURITY_ADMIN_PASSWORD admin
#ENV GF_AUTH_ANONYMOUS_ENABLED true

USER grafana

ENTRYPOINT ["/run.sh"]
