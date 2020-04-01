##### Be kind, WIP
This project is a work in progresss, but aims to make it easy to setup InfluxDb and Grafana to show Telegraf stats from a pfSense firewall, including a flexible out-of-the-box dashboard on your Grafana landing page.

1. Deploy Containers
1. Install Telegraf on your pfSense firewall from the built-in package manager (only tested on 2.4.x)
1. Configure Telegraf to send data to your InfluxDb instance
   1. Enable Telegraf
   1. In Server, enter `http://dockerhost:port` (example uses 8088, but 8086 is the default InfluxDb port) 
   1. In Database, enter `speedtest` (I need to fix this)
   1. For username and password, use the `INFLUXDB_ADMIN_USER` and `INFLUXDB_ADMIN_PASSWORD` from `docker-compose.yml`
   1. Enable HAProxy, if you use it and set the port if it isn't the default
   1. Enable Ping for 8.8.8.8
   1. Finally, in `Additional configuration for Telegraf` paste the below Telegraf logparser input text.


Example Telegraf logparser input for reading pfBlockerNG logs:
```
[[inputs.logparser]]
  files = ["/var/log/pfblockerng/dnsbl.log"]
  from_beginning=true
  [inputs.logparser.grok]
    measurement = "dnsbl_log"
    patterns = ["^%{WORD:BlockType}-%{WORD:BlockSubType},%{SYSLOGTIMESTAMP:timestamp:ts-syslog},%{IPORHOST:destination:tag},%{IPORHOST:source:tag},%{GREEDYDATA:call},%{WORD:BlockMethod},%{WORD:BlockList},%{IPORHOST:tld:tag},%{WORD:DefinedList:tag},%{GREEDYDATA:hitormiss}"]
    timezone = "Local"
    [inputs.logparser.tags]
      value = "1"
```


Example `docker-compose.yml`:
```json
version: '2'
services:
  db:
    image: influxdb
    container_name: influxdb-pfmon
    restart: always
    ports:
      - "8088:8086"
    networks:
      - default
    volumes:
      - /mnt/nas/jails/pfmon/influxdb:/var/lib/influxdb
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
    environment:
      - GF_SERVER_ROOT_URL=http://localhost
      - GF_SERVER_HTTP_PORT=3000
      - GF_AUTH_ANONYMOUS_ENABLED=true
      - GF_AUTH_ANONYMOUS_ORG_ROLE=Admin
#      - GF_SERVER_CERT_FILE=/tmp/crt
#      - GF_SERVER_CERT_KEY=/tmp/key
#      - GF_SERVER_PROTOCOL=https
networks:
  default:
    driver: bridge
```
