
## **[IOS XE Programmability Lab](https://github.com/jeremycohoe/cisco-ios-xe-programmability-lab)**

## **Module: gNMI**

## Topics Covered 
Introduction to gNMI

Enabling the API

Tooling 

Use Cases and examples



## Introduction to gNMI

The Google Remote Proceudure Call (g) Network Management Interface (NMI), or gNMI, is a specification of RPC's and behaviours for managing the state on network devices. It is built on the open source gRPC framework and uses the Protobuf IDL (protocol buffers interactive data language)

Details of Protocol Buffers is available at from Google Developers at [https://developers.google.com/protocol-buffers/docs/overview](https://developers.google.com/protocol-buffers/docs/overview) while the specification for gNMI itself is available on Github/Openconfig at [https://github.com/openconfig/gnmi](https://github.com/openconfig/gnmi) and the actual gnmi.proto file is defined at [https://github.com/openconfig/gnmi/blob/master/proto/gnmi/gnmi.proto](https://github.com/openconfig/gnmi/blob/master/proto/gnmi/gnmi.proto) - These resrouces can be refered if needed however for the purpose of this lab the it is not necessary to have a deeper understaning of these concepts.

![](gnmi_intro.png)

Similar to the NETCONF and RESTCONF programmatic interfaces, gNMI can be used for a variety of operations including retreiving operational and runtime details using the GET operations, as well as making configurtion changes using the SET operation. The SUBSCRIBE operation supports Model Driven Telemetry, or streaming telemetry, to be enabled from this interface as well.

![](./api_operations.png)

All of the programmatic interfaces (NETCONF, RESTCONF, gNMI, and gRPC) share the same set of YANG data models. An example is to review the interface configurations including interface descriptions which can be completed by using **any** of the programmatic interfaces using the same YANG data model: **Cisco-IOS-XE-interface-oper.YANG**. 

![](./api_comparison.png)

## Enabling the GNMI Interface

The gNMI API has 2 mode of operating: secure and insecure. For production use insecure mode is **NOT RECOMMENDED** however for testing and validation in the lab and while learning about this API we can use insecure mode. 

To enable the gNMI insecure mode the following CLI is used. Insecure mode allows connections directly to the IP address of the device, however secure mode uses the DNS name of the device that is encoded into the SSL certificates. 

In the lab envrionment's Ubuntu server the /etc/hosts file is used to create the local DNS resoltion for the lab machine, including the c9300 which is mapped to 10.1.1.5:

![](./etc_hosts.png)

#### gNMI - Insecure server
To enable gNMI in insecure mode use the following CLI commands:

```
gnmi-yang
gnmi-yang server
gnmi-yang port 50052
```

Note: The default insecure gNMI port is 50052 and can be changed with the **gnmi-yang port** CLI and it may not appear in the **show run | i gnmi** depending if it has been set.

#### gNMI - Secure server

The process to enable the secure API is a 4 step process where the SSL certificates are generated using OpenSSL then installed into the IOS XE trustpoint. Next the gNMI API can be enabled using the trustpoint and certificates from the previous steps, and now the API is ready for secure communication using YANGSuite, Python, Go, or any other tooling. It is important to remember that when used in secure mode the **IP address is not used as the certificate is tied to the DNS name of 'c9300'.** Secure connections to the IP address will fail, so ensure the DNS name is used when connecting.

```
Step 1. Create SSL certificates
Step 2. Install certificates into IOS XE trustpoint
Step 3. Enable secure gNMI
Step 4. Connect and vlidate with tooling + cert
```
![](secure_gnmi_quickstart.png)

The IOS XE 16.12 configuration guide has details for creating and enabling gNMI - Refer to [https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/prog/configuration/1612/b_1612_programmability_cg/grpc_network_management_interface.html#id_89031](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/prog/configuration/1612/b_1612_programmability_cg/grpc_network_management_interface.html#id_89031) if needed.

### Step 1

Using the gen_certs.sh script from the Cisco Innovation Edge github at [https://raw.githubusercontent.com/cisco-ie/cisco-gnmi-python/master/scripts/gen_certs.sh](https://raw.githubusercontent.com/cisco-ie/cisco-gnmi-python/master/scripts/gen_certs.sh) we can easily generate the certificates

To generate the certifcation lets follow these steps:

```
cd ~/gnmi/ssl/
# rm -f *	# This will remove any old certs and files!
wget https://raw.githubusercontent.com/cisco-ie/cisco-gnmi-python/master/scripts/gen_certs.sh
bash gen_certs.sh
bash gen_certs.sh c9300 10.1.1.5 Cisco12345
```

![](gen_certs.png)

### Step 2

Now that the certificates are generated they need to be installed into the IOS XE device using the **crypto pki import** commands. Alternatley the [Cisco-IOS-XE-crypto-oper](https://github.com/YangModels/yang/blob/master/vendor/cisco/xe/1721/Cisco-IOS-XE-crypto-oper.yang) YANG file can be used to programmatically install the certificate via the API's

Execute the **ls** command to list the certificate files and use **cat** to read the file out to screen

![](ls_certs.png)

Next install/load the certificates into the trustpoint. Connect to the switch and follow the porocedure below to load the certificate into the trustpoint:

**configure terminal**

**crypto pki import trustpoint1 pem terminal password Cisco123**

Copy and paste the certificates as noted below: **rootCA.pem, devices.des3.key, and device.crt**

```
C9300# configure terminal
C9300(config)# crypto pki import trustpoint1 pem terminal password Cisco123 
 
# Send contents of rootCA.pem, followed by newline + 'quit' + newline:
-----BEGIN CERTIFICATE-----
<snip>
-----END CERTIFICATE-----

# Send contents of device.des3.key, followed by newline + 'quit' + newline:
-----BEGIN RSA PRIVATE KEY-----
Proc-Type: 4,ENCRYPTED
<snip>
-----END RSA PRIVATE KEY-----

# Send contents of device.crt, followed by newline + 'quit' + newline:
-----BEGIN CERTIFICATE-----
<snip>
-----END CERTIFICATE-----
```

Now that the certificate is loaded there is one more step to configure the revocation-check on the trustpoint:

```
C9300(config)# crypto pki trustpoint gnmitrustpoint1
C9300(ca-trustpoint)# revocation-check none
C9300(ca-trustpoint)# end
```

![](./install_certs.gif)

Finally we can review details of the trustpoint using the **show crypto pki trustpoints** CLI's

```
show crypto pki trustpoints  | i Trustpoint
show crypto pki trustpoints
```

![](./show_tp.png)

### Step 3

Next the gnmi-yang server is configured to use the newly installed trustpoint and associated certificates, using the **gnmi-yang secure-trustpoint gnmitrustpoint1** CLI:

```
gnmi-yang
gnmi-yang secure-trustpoint gnmitrustpoint1
gnmi-yang secure-server
gnmi-yang secure-port 9339
```

Note: The default gNMI secure port is 9339 and can be change with the **gnmi-yang secure-port** CLI and it may not appear in the **show run | i gnmi** depending if it has been set.

### Step 4

Eplore the tooling in the next section that can be used to now connect to the gNMI API securely using the certificates and trustpoint configuration that has ben enabled.


## Tooling

### YANGSuite

The YANGSuite GUI based tooling is used to visually interact with the gNMI API. Refer to the NETCONF/YANG module for details of YANGSuite workflows.

Follow the workflow below to build and run the GET RPC for the Vlan1 interface


![](./yangsuite_get_ocif_vlan1.png)

With YANGSuite the following JSON in generated based off of the YANG modeled data:

```
{
  "prefix": {"origin": "openconfig", "elem": [{"name": "interfaces"}]},
  "path": [
    {
      "origin": "openconfig",
      "elem": [{"name": "interface", "key": {"name": "Vlan1"}}]
    },
    {
      "origin": "openconfig",
      "elem": [
        {"name": "interface", "key": {"name": "Vlan1"}},
        {"name": "name"}
      ]
    }
  ],
  "encoding": "JSON_IETF",
  "action": "get_request"
}
```

The gRPC payload above in then sent to the gNMI server that replies with the following results for the interface configuration and state data:

```
{
  "notification": [
    {
      "timestamp": "1592936497525455890",
      "prefix": {"origin": "openconfig", "elem": [{"name": "interfaces"}]},
      "update": [
        {
          "path": {
            "origin": "openconfig",
            "elem": [
              {"name": "interfaces"},
              {"name": "interface", "key": {"name": "Vlan1"}}
            ]
          },
          "val": {
            "json_ietf_val": "{\"name\":\"Vlan1\",\"config\":{\"name\":\"Vlan1\",\"type\":\"iana-if-type:l3ipvlan\",\"enabled\":true},\"state\":{\"name\":\"Vlan1\",\"type\":\"iana-if-type:l3ipvlan\",\"enabled\":true,\"ifindex\":53,\"admin-status\":\"UP\",\"oper-status\":\"UP\",\"last-change\":\"1591938451589000000\",\"counters\":{\"in-octets\":\"10360\",\"in-unicast-pkts\":\"44\",\"in-broadcast-pkts\":\"0\",\"in-multicast-pkts\":\"0\",\"in-discards\":\"0\",\"in-errors\":\"0\",\"in-unknown-protos\":\"0\",\"in-fcs-errors\":\"0\",\"out-octets\":\"5925\",\"out-unicast-pkts\":\"70\",\"out-broadcast-pkts\":\"0\",\"out-multicast-pkts\":\"0\",\"out-discards\":\"0\",\"out-errors\":\"0\",\"last-clear\":\"1591938280000000000\"},\"openconfig-platform-port:hardware-port\":\"Vlan1\"}}"
          }
        }
      ]
    },
    {
      "timestamp": "1592936497551955750",
      "prefix": {"origin": "openconfig", "elem": [{"name": "interfaces"}]},
      "update": [
        {
          "path": {
            "origin": "openconfig",
            "elem": [
              {"name": "interfaces"},
              {"name": "interface", "key": {"name": "Vlan1"}},
              {"name": "name"}
            ]
          },
          "val": {"json_ietf_val": "\"Vlan1\""}
        }
      ]
    }
  ]
}
```

The actual payload is in the val/jason_ietf_val key-value pair

```
"val": {
            "json_ietf_val": "{"name":"Vlan1","config":{"name":"Vlan1","type":"iana-if-type:l3ipvlan","enabled":true},
            "state":{"name":"Vlan1","type":"iana-if-type:l3ipvlan","enabled":true,"ifindex":53,"admin-status":"UP",
            "oper-status":"UP","last-change":"1591938451589000000","counters":{"in-octets":"10360","in-unicast-pkts":"44",
            "in-broadcast-pkts":"0","in-multicast-pkts":"0","in-discards":"0","in-errors":"0","in-unknown-protos":"0",
            "in-fcs-errors":"0","out-octets":"5925","out-unicast-pkts":"70","out-broadcast-pkts":"0","out-multicast-pkts":"0",
            "out-discards":"0","out-errors":"0","last-clear":"1591938280000000000"},"openconfig-platform-port:hardware-port":"Vlan1"}}"
```


### py_gnmi_cli.py ( STOP HERE - CONTINUE WORKING ON THIS PART DOWN )

The gnxi tooling is available from the Google Github repository and can be used for validation of the gNMI API on the C9300 switch for sending payloads and for retreiving operational data. Download and install the tooling with the following commands from the Ubunut SSH:

```
$ git clone https://github.com/google/gnxi.git
$ virtualenv venv --no-site-packages --no-download
. venv/bin/activate
cd gnxi/gnmi_cli_py/
pip install -r requirements.txt
```

After the git glone and pip install complete the next step is to run the py_gnmicli.py tool.

![](./git_gnxi.png)

The py_gnmicli.py script can be used to easily read the interface details from the IOS XE gNMI API with the following command and option flags:

```
python2 py_gnmicli.py -m get -t c9300 -p 50051 -x /interfaces/interface --cert_chain ~/gnmi/ssl/certs/client.crt --root_cert ~/gnmi/ssl/certs/rootCA.pem --private_key ~/gnmi/ssl/certs/client.key -user admin -pass Cisco123
```

![](./pygnmicli_get.png)

### Docker with py_gnmi_cli.py (NOT WORKING ?)

We can also pull a Docker image that has the py_gnmi_cli.py script with a simple 1-liner command:

```
docker run --rm -it mike909/py_gnmicli:v0.4 python /gnxi/gnmi_cli_py/py_gnmicli.py -t 10.1.1.5 -m get -u admin -p Cisco123 -x /interfaces/interface -p 50052 -n
``` 

Using the YANGSUite and py_gnmi_cli.py tooling we have successfully sent the GET operation to the gNMI API to retreive interface state and configuration details.

## Use Cases and examples (NOT TESTED ?!)

Use the set-update operation to create a new loopback interface with the **py_gnmicli.py** script:

```
python py_gnmicli.py -m set-update -t jcohoe-cat9300.cisco.com -p 9339 -x /interfaces/ --cert_chain ./client.crt --root_cert ./rootCA.pem --private_key client.key -user cisco -pass cisco -val @payload_4_set_loopback.json
```

Review the payload to create the loopback interface: **cat payload_4_set_loopback.json**
```
{
	"interface": [
		{
			"name": "Loopback6",
			"config": {
				"name" : "Loopback6",
				"type" : "iana-if-type:softwareLoopback",
				"description": "TESTING"
			}
		},
		{
			"name": "Loopback7",
			"config": {
				"name" : "Loopback7",
				"type" : "iana-if-type:softwareLoopback",
				"description": "TESTING"
			}
		}
	]
}
```

Using the py_gnmi_cli.py tooling we have successfully sent the SET operation to the gNMI API to create a new loopback interface.





