sudo useradd -s /bin/bash -d /opt/stack -m stack
sudo chmod +x /opt/stack
echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
sudo -u stack -i
git clone https://opendev.org/openstack/devstack
cd devstack
cat > local.conf <<'EOF'
#
# Sample DevStack local.conf for Neutron ML2 OVS.
#

[[local|localrc]]

DATABASE_PASSWORD=password
RABBIT_PASSWORD=password
SERVICE_PASSWORD=password
SERVICE_TOKEN=password
ADMIN_PASSWORD=password

GIT_BASE=https://opendev.org

# Optional settings:
# OCTAVIA_AMP_BASE_OS=centos
# OCTAVIA_AMP_DISTRIBUTION_RELEASE_ID=9-stream
# OCTAVIA_AMP_IMAGE_SIZE=3
# OCTAVIA_LB_TOPOLOGY=ACTIVE_STANDBY
# OCTAVIA_ENABLE_AMPHORAV2_JOBBOARD=True
# LIBS_FROM_GIT+=octavia-lib,

# Logging
LOGFILE=$DEST/logs/stack.sh.log
VERBOSE=True
LOG_COLOR=True

HOST_IP=192.168.56.103

#
# Plugins
#
enable_plugin neutron $GIT_BASE/openstack/neutron
enable_plugin octavia $GIT_BASE/openstack/octavia master
enable_plugin octavia-dashboard $GIT_BASE/openstack/octavia-dashboard
enable_plugin octavia-tempest-plugin $GIT_BASE/openstack/octavia-tempest-plugin
enable_plugin barbican $GIT_BASE/openstack/barbican

#
# Services
#
enable_service q-qos
enable_service placement-api placement-client

enable_service octavia
enable_service o-api
enable_service o-cw
enable_service o-hm
enable_service o-hk
enable_service o-da

enable_service key

#
# Horizon
#
enable_service horizon
#disable_service horizon

#
# Storage
#
disable_service cinder c-sch c-api c-vol
disable_service swift

#
# Networking
#
disable_service ovn
disable_service ovn-controller
disable_service ovn-northd
disable_service q-ovn-agent

Q_AGENT=openvswitch

enable_service q-svc
enable_service q-agt
enable_service q-dhcp
enable_service q-l3
enable_service q-meta

[[post-config|$NEUTRON_CONF]]
[DEFAULT]
debug = True
verbose = True

[[post-config|/$Q_PLUGIN_CONF_FILE]]
[ml2]
type_drivers=flat,gre,vlan,vxlan
project_network_types=vxlan
mechanism_drivers=openvswitch,l2population

[agent]
tunnel_types=vxlan,gre

#[ml2_type_vxlan]
#vni_ranges=1:10000

#[ml2_type_flat]
#flat_networks = *

#[ml2_type_gre]
#tunnel_id_ranges = 1:10000

#[ml2_type_vlan]
#network_vlan_ranges = project:1:1000
EOF
