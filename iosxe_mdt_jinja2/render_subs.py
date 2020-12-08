from jinja2 import Environment, FileSystemLoader
import yaml
import argparse

parser = argparse.ArgumentParser(description='Render Telemetry Config')
parser.add_argument('-o', dest='output_type',required=True,
                    help='Output Type')
parser.add_argument('-t', dest='type',required=True,
                    help='Type of device')

parser.add_argument('--seq', dest='seq_num',required=False, default=1,
                    help='Subscription # to start at')

parser.add_argument('--src', dest='source_ip',required=False,
                    help='Source IP Address')

parser.add_argument('--src_vrf', dest='source_vrf',required=False,
                    help='Source VRF')

parser.add_argument('--dst', dest='dst_ip',required=True,
                    help='Receiver IP Address')

parser.add_argument('-s', dest='seconds',required=False, default=1000,
                    help='Seconds for perodic')

parser.add_argument('--version', dest='version',required=True,
                    help='Version of device')


args = parser.parse_args()

#This line uses the current directory
file_loader = FileSystemLoader('.')
# Load the enviroment
env = Environment(loader=file_loader)
template = env.get_template('sub_templates.j2')

file = open('sub_list.yaml')

subs_load = yaml.load(file, Loader=yaml.FullLoader)

sub_type = args.type
sub_version = float(args.version)
ip = args.dst_ip
seconds = args.seconds
source_ip = args.source_ip
source_vrf = args.source_vrf
output_type = args.output_type

if 'cli' in output_type:
    output_type = True
else:
    output_type = False
subs = subs_load[sub_type][sub_version]

sub_list = []

seq_num = int(args.seq_num)

sub_length = len(subs)
i = 0
if subs['periodic']:
    for sub in subs['periodic']:
        sub_dict = {}
        sub_dict['sub'] = sub
        sub_dict['seq_num'] = seq_num + i
        sub_dict['sub_type'] = 'periodic'
        sub_list.append(sub_dict)
        i = i + 1

if subs['on-change']:
    for sub in subs['on-change']:
        sub_dict = {}
        sub_dict['sub'] = sub
        sub_dict['seq_num'] = seq_num + i
        sub_dict['sub_type'] = 'on-change'
        sub_list.append(sub_dict)
        i = i + 1


output = template.render(subs=sub_list, ip=ip, seconds=seconds, source_ip=source_ip, cli = output_type, source_vrf=source_vrf)
#Print the output
print(output)