FROM grafana/grafana
MAINTAINER kjake

USER root

ADD conf/grafana.db /home/grafana/template.db
ADD conf/home.json /home/grafana/template.json
RUN chown -R 472:472 /var/lib/grafana
COPY docker-entrypoint /
USER grafana
CMD ["/docker-entrypoint"]