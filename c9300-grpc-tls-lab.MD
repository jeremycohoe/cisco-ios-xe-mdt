## Secure gRPC

# Create SSL Certificates


## Define certificate details

Create the **ssl.conf** file and specify the ip address where the secure grpc server is. In this case Telegraf is configured to receive the secure gRPC connection on port 57501, and the server is at IP 10.85.134.66.

```
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
[req_distinguished_name]
countryName                 = Country Name (2 letter code)
countryName_default         = CA
stateOrProvinceName         = State or Province Name
stateOrProvinceName_default = Some-State
localityName                = Name (eg, city)
localityName_default        = Kanata
organizationName            = Organization Name
organizationName_default    = Cisco
commonName                  = Common
commonName_max              = 64
commonName_default          = grpc

[v3_req]
subjectAltName = @alt_names

[alt_names]
IP.1 = 10.85.134.66
```

## Create SSL certificate with openssl 
Now that the ssl.conf SSL configuration file has been created the next step is to use openssl to generate the required certificates that will be used to secure the session:

```
openssl genrsa -out myca.key 2048
openssl genrsa -out server.key 2048
openssl req -x509 -new -nodes -key myca.key -sha256 -days 365 -out myca.cert
openssl req -out server.csr -key server.key -new -config ./ssl.conf
openssl x509 -req -in server.csr -CA myca.cert -CAkey myca.key -CAcreateserial -out server.cert -days 365 -extensions v3_req -extfile ./ssl.conf
```

# Start Telegraf

The Telegraf tool is used as the gRPC telemetry receiver using the **cisco_telemetry_mdt** input plugin as the secure server, configured to listen for secure connections on port 57501, that are secured with the same RootCA used to sign the server certficiate file described in the configuration.

Start telegraf from the Linux/Ubuntu server with command:

**/usr/bin/telegraf --config /etc/telegraf/telegraf-grpc-tls.conf**

## telegraf-grpc-tls.conf

The configuration file for telegraf is telegraf-grpc-tls.conf and should look similar to below, specifically the **tls_cert** and **tls_key** files as well as the **service_address** - these are the certificates used and the port that Telegraf listens on for secure telemetry sessions from the IOS XE device

```
# Global Agent Configuration
[agent]
  hostname = "jcohoe-ubuntu"
  flush_interval = "15s"
  interval = "15s"

# gRPC + TLS
[[inputs.cisco_telemetry_mdt]]
transport = "grpc"
service_address = ":57501"
tls_cert = "/etc/telegraf/ssl/server.cert"
tls_key = "/etc/telegraf/ssl/server.key"

[[outputs.file]]
  files = ["/tmp/telegraf-grpc-tls.log"]
```


# Enable trustpoint profile on IOS XE

Now that the certificates have been created and installed into the tooling, the next step is to install the certificate into IOS XE's certificate truststore using the CLI commands:

```
conf t
 crypto pki trustpoint myca
  enrollment terminal
  chain-validation stop
  revocation-check  none
  exit
 crypto pki authenticate myca
	<< paste contents of myca.cert >>
```

# Enable gRPC-TLS telemetry subscription
Now that the certificate truststore profile has been created and the root certificate authority certificate installed, the next step is to enable gRPC with the secure telemetry profile:

```
conf t
telemetry ietf subscription 1
 encoding encode-kvgpb
 filter xpath /process-cpu-ios-xe-oper:cpu-usage/cpu-utilization/five-seconds
 source-address 10.85.134.65
 stream yang-push
 update-policy periodic 2000
 receiver ip address 10.85.134.66 57501 protocol grpc-tls profile myca
```

# Verify the connection

Now that the grpc-tls telemetry subscription is in place there are some CLI commands that can be used to confirm the connection and xpath is correct:

show telemetry ietf subscription 1 receiver

show telemetry ietf subscription 1 detail

The output should be similar to the below, specifically the  **State: Connected**

```
C9300-24UX#show telemetry ietf subscription 1 receiver
Telemetry subscription receivers detail:

  Subscription ID: 1
  Address: 10.85.134.66
  Port: 57501
  Protocol: grpc-tls
  Profile: myca
  Connection: 3220
  State: Connected
  Explanation:


C9300-24UX#show telemetry ietf subscription 1 de
C9300-24UX#show telemetry ietf subscription 1 detail
Telemetry subscription detail:

  Subscription ID: 1
  Type: Configured
  State: Valid
  Stream: yang-push
  Filter:
    Filter type: xpath
    XPath: /process-cpu-ios-xe-oper:cpu-usage/cpu-utilization/five-seconds
  Update policy:
    Update Trigger: periodic
    Period: 2000
  Encoding: encode-kvgpb
  Source VRF:
  Source Address: 10.85.134.65
  Notes:

  Receivers:
    Address                                    Port     Protocol         Protocol Profile
    -----------------------------------------------------------------------------------------
    10.85.134.66                               57501    grpc-tls         myca


C9300-24UX#
```

# Validate telemetry data

The telegraf configuration file will log any output it receives to the **/tmp/telegraf-grpc-tls.log** file. The telemetry data for the subscription configured above is shown below 

```
tail -F telegraf-grpc-tls.log
Cisco-IOS-XE-process-cpu-oper:cpu-usage/cpu-utilization,host=jcohoe-ubuntu,path=Cisco-IOS-XE-process-cpu-oper:cpu-usage/cpu-utilization,source=C9300-24UX,subscription=1 five_seconds=1i 1606184775478000000
Cisco-IOS-XE-process-cpu-oper:cpu-usage/cpu-utilization,host=jcohoe-ubuntu,path=Cisco-IOS-XE-process-cpu-oper:cpu-usage/cpu-utilization,source=C9300-24UX,subscription=1 five_seconds=0i 1606184795465000000
Cisco-IOS-XE-process-cpu-oper:cpu-usage/cpu-utilization,host=jcohoe-ubuntu,path=Cisco-IOS-XE-process-cpu-oper:cpu-usage/cpu-utilization,source=C9300-24UX,subscription=1 five_seconds=1i 1606184815471000000
Cisco-IOS-XE-process-cpu-oper:cpu-usage/cpu-utilization,host=jcohoe-ubuntu,path=Cisco-IOS-XE-process-cpu-oper:cpu-usage/cpu-utilization,source=C9300-24UX,subscription=1 five_seconds=1i 1606184835458000000
```

Looking closer at the data the five second CPU utilization was reported as expected:

```
five_seconds=1i
five_seconds=0i
five_seconds=1i
five_seconds=1i
```

# Conclusion

This concludes the gRPC-TLS secure telemetry section
