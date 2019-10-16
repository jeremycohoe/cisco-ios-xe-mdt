# TIG_MDT Docker Container

### Docker container on DockerHub
The pre-packaged docker container is available from DockerHub at 
[https://hub.docker.com/r/jeremycohoe/tig_mdt
](https://hub.docker.com/r/jeremycohoe/tig_mdt)

### Downloading and Running
First download or pull the docker image from dockerhub. Then start the docker container and call the /start.sh script that automatically starts Telegraf, InfluxDB, and Grafana.

$ docker pull jeremycohoe/tig_mdt

$ docker run -dit -p 3000:3000 -p 57500:57500 tig_mdt /start.sh

### Configure MDT on Cisco IOS XE device
Ensure the Cisco IOS XE device is running 16.10 or later and has the following configuration enabled:

netconf-yang

####Configuration Example
```
telemetry ietf subscription 102
 encoding encode-kvgpb
 filter xpath /interfaces-ios-xe-oper:interfaces/interface
 source-address 10.85.134.65
 stream yang-push
 update-policy periodic 2000
 receiver ip address 10.85.134.66 57500 protocol grpc-tcp
```

## Container Components
### Telegraf
Telegraf has been configured with the cisco_telemetry_mdt plugin to listen for gRPC telemetry on port 57500

Details about the "cisco\_telemetry\_mdt"  can be found at the [Telegraf Inputs Plugin github page](https://github.com/influxdata/telegraf/tree/master/plugins/inputs/cisco_telemetry_mdt).

It will sent it to the local InfluxDB database "cisco_mdt"

```
# Global Agent Configuration
[agent]
  hostname = "jcohoe-ubuntu"
  flush_interval = "15s"
  interval = "15s"

# gRPC Dial-Out Telemetry Listener
[[inputs.cisco_telemetry_mdt]]
  transport = "grpc"
  service_address = ":57500"

# Output Plugin InfluxDB
[[outputs.influxdb]]
  database = "cisco_mdt"
  urls = [ "http://127.0.0.1:8086" ]

[[outputs.file]]
  files = ["/root/telegraf/telegraf.log"]
```

### InfluxDB
The "cisco_mdt" database has been created within Influx

To check if data is present, run these commands:

```
root@c582f6c6e9eb:~# influx
Connected to http://localhost:8086 version 1.7.7
InfluxDB shell version: 1.7.7
> show databases
name: databases
name
----
cisco_mdt
_internal
> use cisco_mdt
Using database cisco_mdt
> show measurements
name: measurements
name
----
Cisco-IOS-XE-environment-oper:environment-sensors/environment-sensor
Cisco-IOS-XE-interfaces-oper:interfaces/interface
Cisco-IOS-XE-interfaces-oper:interfaces/interface/statistics
Cisco-IOS-XE-memory-oper:memory-statistics/memory-statistic
Cisco-IOS-XE-process-cpu-oper:cpu-usage/cpu-utilization
Cisco-IOS-XE-process-memory-oper:memory-usage-processes/memory-usage-process
ietf-interfaces:interfaces-state/interface/statistics
openconfig-interfaces:interfaces/interface
>
```


### Grafana

Grafana has been configured to connect to the local InfluxDB's database "cisco_mdt" and can be access with the **admin** username with password **Cisco123**. Grafana can be accessed on the default HTTP port 3000

