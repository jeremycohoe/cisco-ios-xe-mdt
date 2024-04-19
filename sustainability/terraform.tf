terraform {
  required_providers {
    iosxe = {
      source = "CiscoDevNet/iosxe"
      version = "0.5.5"
    }
  }
}

provider "iosxe" {
  username = var.host_username
  password = var.host_password
  url      = var.host_url
}

variable host_username {
  type = string
  default = "admin"
  description = "The username for the Cisco IOS XE device to configure"
}

variable host_password {
  type = string
  default = "C1sco12345"
  description = "The password for the Cisco IOS XE device to configure"
}

variable host_url {
  type = string
  default = "https://devnetsandboxiosxe.cisco.com"
  description = "The public URL for the Cisco IOS XE device to configure"
}

variable cpu_periodic {
  type = string
  default = "6000"
  description = "Short update interval" 
}

variable source_address {
  type = string
  default = "1.1.1.1"
  description = "The source address for the telemetry subscription"
}

variable stream {
  type = string
  default = "yang-push"
  description = "The stream for the telemetry subscription"
}

variable encoding {
  type = string
  default = "encode-kvgpb"
  description = "The encoding for the telemetry subscription"
}

variable source_vrf {
  type = string
  default = "Mgmt-vrf"
  description = "The source_vrf for the telemetry subscription"
}

variable receiver_address {
  type = string
  default = "2.2.2.2"
  description = "The receiver address for the telemetry subscription"
}

variable receiver_port {
  type = string
  default = "57500"
  description = "The receiver_port address for the telemetry subscription"
}

variable receiver_protocol {
  type = string
  default = "grpc-tcp"
  description = "The receiver_protocol address for the telemetry subscription"
}

variable "xpaths" {
  default = {
    2024001 = {
      xpath = "/environment-sensors"
    },
    2024002 = {
      xpath = "/oc-platform:components"
    },
    2024003 = {
      xpath = "/platform-ios-xe-oper:components/component"
    },
    2024004 = {
      xpath = "/platform-ios-xe-oper:components/component/platform-properties/platform-property"
    },
    2024005 = {
      xpath = "/poe-oper-data/poe-module"
    },
    2024006 = {
      xpath = "/poe-oper-data/poe-port-detail"
    },
    2024007 = {
      xpath = "/poe-oper-data/poe-stack"
    },
    2024008 = {
      xpath = "/poe-oper-data/poe-switch"
    }
  }
}

resource "iosxe_mdt_subscription" "example" {
  for_each                = var.xpaths
  subscription_id         = each.key
  stream                  = var.stream
  encoding                = var.encoding
  #source_vrf              = var.source_vrf
  source_address          = var.source_address
  update_policy_periodic  = var.cpu_periodic
  filter_xpath            = each.value.xpath
  receivers = [
    {
      address  = var.receiver_address
      port     = var.receiver_port
      protocol = var.receiver_protocol
    }
  ]
}
