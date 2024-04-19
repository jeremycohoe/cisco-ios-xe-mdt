# Create Sustainability/POE Telemetry Subscriptions 2024001 - 2024008
# Dial-Out MDT 2024001
cli.configurep(["telemetry ietf subscription 2024001","encoding encode-kvgpb","filter xpath /environment-sensors","stream yang-push","update-policy periodic 60000","receiver ip address 10.1.1.3 57500 protocol grpc-tcp","end"])
# Dial-Out MDT 2024002
cli.configurep(["telemetry ietf subscription 2024002","encoding encode-kvgpb","filter xpath /oc-platform:components","stream yang-push","update-policy periodic 60000","receiver ip address 10.1.1.3 57500 protocol grpc-tcp","end"])
# Dial-Out MDT 2024003
cli.configurep(["telemetry ietf subscription 2024003","encoding encode-kvgpb","filter xpath /platform-ios-xe-oper:components/component","stream yang-push","update-policy periodic 60000","receiver ip address 10.1.1.3 57500 protocol grpc-tcp","end"])
# Dial-Out MDT 2024004
cli.configurep(["telemetry ietf subscription 2024004","encoding encode-kvgpb","filter xpath /platform-ios-xe-oper:components/component/platform-properties/platform-property","stream yang-push","update-policy periodic 60000","receiver ip address 10.1.1.3 57500 protocol grpc-tcp","end"])
# Dial-Out MDT 2024005
cli.configurep(["telemetry ietf subscription 2024005","encoding encode-kvgpb","filter xpath /poe-oper-data/poe-module","stream yang-push","update-policy periodic 60000","receiver ip address 10.1.1.3 57500 protocol grpc-tcp","end"])
# Dial-Out MDT 2024006
cli.configurep(["telemetry ietf subscription 2024006","encoding encode-kvgpb","filter xpath /poe-oper-data/poe-port-detail","stream yang-push","update-policy periodic 60000","receiver ip address 10.1.1.3 57500 protocol grpc-tcp","end"])
# Dial-Out MDT 2024007
cli.configurep(["telemetry ietf subscription 2024007","encoding encode-kvgpb","filter xpath /poe-oper-data/poe-stack","stream yang-push","update-policy periodic 60000","receiver ip address 10.1.1.3 57500 protocol grpc-tcp","end"])
# Dial-Out MDT 2024008
cli.configurep(["telemetry ietf subscription 2024008","encoding encode-kvgpb","filter xpath /poe-oper-data/poe-switch","stream yang-push","update-policy periodic 60000","receiver ip address 10.1.1.3 57500 protocol grpc-tcp","end"])

