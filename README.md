![](https://i.imgur.com/g9usDqJ.png)

## pfMon - Zero Touch Influx and Grafana for pfSense

### Note: The default login for this installation of Grafana is: admin:password

This project is a work in progresss, but aims to make it easy to setup InfluxDb and Grafana to show Telegraf stats from a pfSense firewall, including a flexible out-of-the-box dashboard on your Grafana landing page.

1. Deploy Containers (note Grafana port in Example is 4000 and InfluxDb port is 8088, which are different than their defaults)
1. From pfSense, install Telegraf on your pfSense firewall from the built-in package manager (only tested on 2.4.x)
1. From pfSense > Diagnostics > Command Prompt, Upload `gateways.py` from https://gist.github.com/fastjack/a0feb792a9655da7aa3e2a7a1d9f812f
1. From pfSense > Diagnostics > Command Prompt, Execute Shell Commands `mv /tmp/gateways.py /usr/local/bin/gateways.py` and `chmod +x /usr/local/bin/gateways.py`
1. Configure Telegraf to send data to your InfluxDb instance
   1. Enable Telegraf
   1. In Server, enter `http://dockerhost:port` for your InfluxDb container 
   1. In Database, enter `speedtest` (I need to fix this)
   1. For username and password, use the `INFLUXDB_ADMIN_USER` and `INFLUXDB_ADMIN_PASSWORD` from `docker-compose.yml`
   1. Enable HAProxy, if you use it and set the port if it isn't the default
   1. Enable Ping for 8.8.8.8
   1. Finally, in `Additional configuration for Telegraf` paste the below Telegraf input text.


Example Telegraf input for reading pfBlockerNG logs and sending additional gateway info:
```toml
[[inputs.exec]]
        commands = ["/usr/local/bin/gateways.py"]
        timeout = "5s"
        data_format = "influx"

[[inputs.logparser]]
  files = ["/var/log/pfblockerng/dnsbl.log"]
  from_beginning=true
  [inputs.logparser.grok]
    measurement = "dnsbl_log"
    patterns = ["^%{WORD:BlockType}-%{WORD:BlockSubType},%{SYSLOGTIMESTAMP:timestamp:ts-syslog},%{IPORHOST:destination:tag},%{IPORHOST:source:tag},%{GREEDYDATA:call},%{WORD:BlockMethod},%{WORD:BlockList},%{IPORHOST:tld:tag},%{WORD:DefinedList:tag},%{GREEDYDATA:hitormiss}"]
    timezone = "Local"
    [inputs.logparser.tags]
      value = "1"

[[inputs.logparser]]
    files = ["/var/log/pfblockerng/ip_block.log"]
    from_beginning=true
    [inputs.logparser.grok]
        measurement = "ip_block_log"
        patterns = ["^%{SYSLOGTIMESTAMP:timestamp:ts-syslog},%{NUMBER:TrackerID},%{GREEDYDATA:Interface},%{WORD:InterfaceName},%{WORD:action},%{NUMBER:IPVersion},%{NUMBER:ProtocolID},%{GREEDYDATA:Protocol},%{IPORHOST:SrcIP:tag},%{IPORHOST:DstIP:tag},%{NUMBER:SrcPort},%{NUMBER:DstPort},%{WORD:Dir},%{WORD:GeoIP:tag},%{GREEDYDATA:AliasName},%{GREEDYDATA:IPEvaluated},%{GREEDYDATA:FeedName:tag},%{HOSTNAME:ResolvedHostname},%{HOSTNAME:ClientHostname},%{GREEDYDATA:ASN},%{GREEDYDATA:DuplicateEventStatus}"]
        timezone = "Local"
```


Example `docker-compose.yml`:
```yaml
version: '2'

volumes:
  pfmon_influxdb:
  pfmon_config:

services:
  db:
    image: influxdb:1.8
    container_name: influxdb-pfmon
    restart: always
    ports:
      - "8088:8086"
    networks:
      - default
    volumes:
      - pfmon_influxdb:/var/lib/influxdb
    environment:
      - INFLUXDB_ADMIN_USER=admin
      - INFLUXDB_ADMIN_PASSWORD=password
      - INFLUXDB_DB=speedtest
  web:
    image: kjake/pfmon-docker:latest
    container_name: pfweb
    restart: always
    ports:
      - "4000:3000"
    networks:
      - default
    volumes:
      - pfmon_config:/var/lib/grafana
    environment:
      - GF_INSTALL_PLUGINS=https://github.com/panodata/panodata-map-panel/releases/download/0.16.0/panodata-map-panel-0.16.0.zip;panodata-map-panel
      - GF_PLUGINS_ALLOW_LOADING_UNSIGNED_PLUGINS=panodata-map-panel
      - GF_SERVER_ROOT_URL=http://localhost
      - GF_SERVER_HTTP_PORT=3000
      - GF_AUTH_ANONYMOUS_ENABLED=true
      - GF_AUTH_ANONYMOUS_ORG_ROLE=Viewer
#      - GF_SERVER_CERT_FILE=/tmp/crt
#      - GF_SERVER_CERT_KEY=/tmp/key
#      - GF_SERVER_PROTOCOL=https
networks:
  default:
    driver: bridge
```
