# Sustainability Workshop

### Introduction
In this workshop, you will learn how to configure telemetry subscriptions for sustainablity use cases. We will complete the following
 * configure sustainability telemetry subscriptions using Zero Touch Provisioning (ZTP) at Day 0 
 * modify the previously configured sustainability telemetry subscriptions using Terraform at Day 1

### Pre-requisites
This workshop has the following pre-req's: 
* Bring your own Catlayst device (any running Cisco IOS XE and compatiable with the PoE feature). We will show a demo using a Catalyst 9300X.
* A machine (Virtual Machine or laptop) with connectivity to your Catalyst device. We will provide a docker container for the telemetry vizualization and examples

## Getting started
On the machine with access to the Catalyst device, pull down the docker container using the following commands
```
docker pull jeremycohoe/tig_mdt

docker run -dti -p 3000:3000 -p 57500:57500 jeremycohoe/tig_mdt

```

## Zero Touch Provisioning (ZTP)
We will configure the Catalyst device at Day 0 as soon as it is plugged in and connected to the network 
1. Review the [ztp.py](cisco-ios-xe-mdt/sustainability/ztp.py) and the 8 Xpaths that will be added. Note that the data for each feature/Xpath will come at an interval of 60000 centiseconds (every 10 minutes)
1. Run `write erase` and `reload` on the Catalyst device
1. As the device comes back online, notice the logging messages to confirm that ZTP ran properly
1. Validate that the telemetry subscriptions are configured on the Catalyst device and confirm the telemetry is flowing to the receiver

### ZTP Resources
To learn more about ZTP, check out these in-depth resources here: 
* ZTP Examples: https://github.com/jeremycohoe/IOSXE-Zero-Touch-Provisioning/blob/master/logs/pod08-xelab-vlan1.txt
* ZTP Lab: https://github.com/sdeweese/CLUS23-LTROPS-1836-IOS-XE-Device-Programmability-and-Automation-Lab/blob/main/ZTP2.md
* YouTube Video: https://www.youtube.com/watch?v=EAXnftG6odg
* ZTP Blog: https://blogs.cisco.com/developer/device-provisioning-with-ios-xe-zero-touch-provisioning
* SZTP Blog: https://blogs.cisco.com/developer/secureztp01


## Terraform 
We will configure the Catalyst device at Day 1 after it has been given initial configs in the ZTP process above. 
1. Review the terraform files. Note that [terraform.tf](cisco-ios-xe-mdt/sustainability/terraform.tf) will configure the same 8 Xpaths that were origionally configured in [ztp.py](cisco-ios-xe-mdt/sustainability/ztp.py). However, in the Terraform file, the periodic interval is reduced to 6000 centiseconds (1 minute). This will provide us with the same data, but now, more often.
1. Update [terraform.tfvars](cisco-ios-xe-mdt/sustainability/terraform.tfvars) to reflect the source (your Catalyst device) and receiver (the machine where you're running the docker container)
1. Initialize Terraform to ensure you have the most updated version of the Cisco IOS XE Terraform provider `terraform init`
1. Plan to see what changes Terraform will make to your Catalyst device `terraform plan`
1. Once you're confident in the changes Terraform will make, apply those configuration changes. Run `terraform apply --auto-approve`
1. Validate that the telemetry subscription configuration is changed from `update-policy periodic 60000` to `update-policy periodic 6000`
1. Confirm that the data is coming in at a faster rate than before

### Cisco IOS XE Terraform Resources
To learn more about the Cisco IOS XE Terraform provider, check out these in-depth tutorials and resources here: 
* GitHub page: https://github.com/CiscoDevNet/terraform-provider-iosxe/   
* Documentation https://registry.terraform.io/search/providers?namespace=CiscoDevNet 
* Hands-on Learning Lab: https://developer.cisco.com/learning/labs/cisco-ios-xe-terraform/introduction/
* Hands-on with Cisco U: https://ondemandelearning.cisco.com/apollo-alpha/tc-terraform-ios-xe/pages/1
* Intro to Cisco IOS XE Terraform provider: https://blogs.cisco.com/developer/terraformiosxe01
* YouTube videos:
    * https://www.youtube.com/watch?v=bPS0bhPacDw
    * https://www.youtube.com/watch?v=GEY_hyXimbA
    * https://www.youtube.com/watch?v=WkgDlE0HpXs


You did it! Congrats, you're well on your way to having a more sustainable network and managing it programmatically!
