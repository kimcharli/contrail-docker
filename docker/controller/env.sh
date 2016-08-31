#!/usr/bin/env bash
set -x
source /common.sh

IPADDRESS=${IPADDRESS:-${primary_ip}}

## Environment for Config Database
MY_INDEX=$(index_of_ip $SEED_LIST $IPADDRESS)
DATABASE_IP=${DATABASE_IP:-$IPADDRESS}
CASSANDRA_DIRECTORY=${CASSANDRA_DIRECTORY}
INITIAL_TOKEN=${INITIAL_TOKEN:-0}
SEED_LIST=${SEED_LIST:-$DATABASE_IP}
DATA_DIR=${DATA_DIR}
SSD_DATA_DIR=${SSD_DATA_DIR}
ZOOKEEPER_IP_LIST=${ZOOKEEPER_IP_LIST:-$SEED_LIST}
#  The index of this databse node
DATABASE_INDEX=${DATABASE_INDEX:-${MY_INDEX}}
# Required minimum disk space for contrail database
MINIMUM_DISKGB=${MINIMUM_DISKGB:-200}
#The broker id of the database node
KAFKA_BROKER_ID=${KAFKA_BROKER_ID:-${MY_INDEX}}
# The DB node to remove from the cluster
NODE_TO_DELETE=${NODE_TO_DELETE}
CASSANDRA_USER=${CASSANDRA_USER}
CASSANDRA_PASSWORD=${CASSANDRA_PASSWORD}

# Specify cloud orchestrator,
# NOTE: if there are lot of variable configuration steps for different cloud orchestrator,
# It may make sense to create different set of containers for specific cloud orchestrator like
# contrail-config-liberty etc for openstack
# contrail-config-mesos for mesos
# contrail-config-kubernates for kubernates
#
CLOUD_ORCHESTRATOR=${CLOUD_ORCHESTRATOR:-"openstack"}

if [[ $CLOUD_ORCHESTRATOR == "openstack" ]]; then
    MULTI_TENANCY=${MULTI_TENANCY:-True}
else
    MULTI_TENANCY=False
fi

CONFIG_IP=${CONFIG_IP:-$IPADDRESS}
CONFIG_SERVER_LIST=${CONFIG_SERVER_LIST:-$CONFIG_IP}

# Listen to standard port in case of single node setup,
# this will eliminate the need of haproxy in single node environment
num_config_servers=$(echo $CONFIG_SERVER_LIST | sed -r 's/\s+/\n/g'| wc -l)

if [[ $num_config_servers -eq 1 ]]; then
    NEUTRON_LISTEN_PORT_DEFAULT=9696
    CONFIG_API_LISTEN_PORT_DEFAULT=8082
    DISCOVERY_LISTEN_PORT_DEFAULT=5998
else
    NEUTRON_LISTEN_PORT_DEFAULT=9697
    CONFIG_API_LISTEN_PORT_DEFAULT=9100
    DISCOVERY_LISTEN_PORT_DEFAULT=9110
fi


CONTRAIL_INTERNAL_VIP=${CONTRAIL_INTERNAL_VIP}
OPENSTACK_INTERNAL_VIP=${OPENSTACK_INTERNAL_VIP}

OPENSTACK_IP=${OPENSTACK_IP:- ${OPENSTACK_INTERNAL_VIP:-$CONFIG_IP}}

API_SERVER_LISTEN=${API_SERVER_LISTEN:-0.0.0.0}
API_SERVER_LISTEN_PORT=${API_SERVER_LISTEN_PORT:-$CONFIG_API_LISTEN_PORT_DEFAULT}
API_SERVER_IP=${API_SERVER_IP:-${CONTRAIL_INTERNAL_VIP:-$CONFIG_IP}}
API_SERVER_PORT=${API_SERVER_PORT:-8082}
API_SERVER_USE_SSL=${API_SERVER_USE_SSL:-"False"}
API_SERVER_LOG_FILE=${API_SERVER_LOG_FILE:-"/var/log/contrail/contrail-api.log"}
API_SERVER_LOG_LEVEL=${API_SERVER_LOG_LEVEL:-"SYS_NOTICE"}
API_SERVER_INSECURE=${API_SERVER_INSECURE:-"False"}
SCHEMA_LOG_FILE=${SCHEMA_LOG_FILE:-"/var/log/contrail/contrail-schema.log"}
SCHEMA_LOG_LEVEL=${SCHEMA_LOG_LEVEL:-SYS_NOTICE}

# Rabbitmq server list is a comma seperated list of rabbitmq server *NAMES* which are
# resolvable from the container or a list of ip1:host1,ip2:host2. e.g, 192.168.0.10:rabbit1,192.168.0.11:rabbit2
RABBITMQ_SERVER_LIST=${RABBITMQ_SERVER_LIST:-"$IPADDRESS:$MYHOSTNAME"}
RABBITMQ_SERVER_PORT=${RABBITMQ_SERVER_PORT:-5672}
RABBITMQ_LISTEN_IP=${RABBITMQ_LISTEN_IP:-$IPADDRESS}
DISABLE_RABBITMQ=${DISABLE_RABBITMQ}
RABBITMQ_CLUSTER_UUID=${RABBITMQ_CLUSTER_UUID:-$(uuidgen)}

ANALYTICS_SERVER=${ANALYTICS_SERVER:-${CONTRAIL_INTERNAL_VIP:-$IPADDRESS}}
ANALYTICS_SERVER_PORT=${ANALYTICS_SERVER_PORT:-8081}

CASSANDRA_SERVER_LIST=${CASSANDRA_SERVER_LIST:-$DATABASE_IP}
CASSANDRA_SERVER_PORT=${CASSANDRA_SERVER_PORT:-9160}
ZOOKEEPER_SERVER_LIST=${ZOOKEEPER_SERVER_LIST:-$DATABASE_IP}
ZOOKEEPER_SERVER_PORT=${ZOOKEEPER_SERVER_PORT:-2181}
CONTROL_SERVER_LIST=${CONTROL_SERVER_LIST:-$IPADDRESS}

IFMAP_SERVER=${IFMAP_SERVER:-$IPADDRESS}
IFMAP_SERVER_PORT=${IFMAP_SERVER_PORT:-8443}
IFMAP_USERNAME=${IFMAP_USERNAME:-"api-server"}
IFMAP_PASSWORD=${IFMAP_PASSWORD:-"api-server"}

DISCOVERY_SERVER=${DISCOVERY_SERVER:-${CONTRAIL_INTERNAL_VIP:-$CONFIG_IP}}
DISCOVERY_SERVER_LISTEN=${DISCOVERY_SERVER_LISTEN:-"0.0.0.0"}
DISCOVERY_SERVER_LISTEN_PORT=${DISCOVERY_SERVER_LISTEN_PORT:-$DISCOVERY_LISTEN_PORT_DEFAULT}
DISCOVERY_SERVER_PORT=${DISCOVERY_SERVER_PORT:-5998}
DISCOVERY_LOG_FILE=${DISCOVERY_LOG_FILE:-"/var/log/contrail/contrail-discovery.log"}
DISCOVERY_LOG_LEVEL=${DISCOVERY_LOG_LEVEL:-"SYS_NOTICE"}
DISCOVERY_TTL_MIN=${DISCOVERY_TTL_MIN:-300}
DISCOVERY_TTL_MAX=${DISCOVERY_TTL_MAX:-1800}
DISCOVERY_HC_INTERVAL=${DISCOVERY_HC_INTERVAL:-5}
DISCOVERY_HC_MAX_MISS=${DISCOVERY_HC_MAX_MISS:-3}
DISCOVERY_TTL_SHORT=${DISCOVERY_TTL_SHORT:-1}
DISCOVERY_DNS_SERVER_POLICY=${DISCOVERY_DNS_SERVER_POLICY:-fixed}

SVC_MONITOR_LOG_FILE=${SVC_MONITOR_LOG_FILE:-"/var/log/contrail/contrail-svc-monitor.log"}
SVC_MONITOR_LOG_LEVEL=${SVC_MONITOR_LOG_LEVEL:-SYS_NOTICE}
COLLECTOR_SERVER=${COLLECTOR_SERVER:-${CONTRAIL_INTERNAL_VIP:-$CONFIG_IP}}
KEYSTONE_SERVER=${KEYSTONE_SERVER:-${OPENSTACK_INTERNAL_VIP:-$IPADDRESS}}

DEVICE_MANAGER_LOG_FILE=${DEVICE_MANAGER_LOG_FILE:-"/var/log/contrail/contrail-device-manager.log"}
DEVICE_MANAGER_LOG_LEVEL=${DEVICE_MANAGER_LOG_LEVEL:-"SYS_NOTICE"}

SERVICE_TENANT=${SERVICE_TENANT:-service}
KEYSTONE_AUTH_PROTOCOL=${KEYSTONE_AUTH_PROTOCOL:-http}
KEYSTONE_AUTH_PORT=${KEYSTONE_AUTH_PORT:-35357}
KEYSTONE_INSECURE=${KEYSTONE_INSECURE:-False}
KEYSTONE_ADMIN_USER=${OS_USERNAME:-admin}
KEYSTONE_ADMIN_PASSWORD=${OS_PASSWORD:-admin}
KEYSTONE_ADMIN_TENANT=${OS_TENANT_NAME:-admin}
KEYSTONE_ADMIN_TOKEN=${OS_TOKEN:-$ADMIN_TOKEN}
REGION=${REGION:-RegionOne}

NEUTRON_IP=${NEUTRON_IP:-${CONTRAIL_INTERNAL_VIP:-$CONFIG_IP}}
NEUTRON_PORT=${NEUTRON_PORT:-$NEUTRON_LISTEN_PORT_DEFAULT}
NEUTRON_USER=${NEUTRON_USER:-neutron}

NEUTRON_PASSWORD=${NEUTRON_PASSWORD:-neutron}
NEUTRON_PROTOCOL=${KEYSTONE_AUTH_PROTOCOL:-http}
CONTRAIL_EXTENSIONS_DEFAULTS="ipam:neutron_plugin_contrail.plugins.opencontrail.contrail_plugin_ipam.NeutronPluginContrailIpam,policy:neutron_plugin_contrail.plugins.opencontrail.contrail_plugin_policy.NeutronPluginContrailPolicy,route-table:neutron_plugin_contrail.plugins.opencontrail.contrail_plugin_vpc.NeutronPluginContrailVpc,contrail:None"
NEUTRON_CONTRAIL_EXTENSIONS=${NEUTRON_CONTRAIL_EXTENSIONS:-$CONTRAIL_EXTENSIONS_DEFAULTS}
NEUTRON_SERVER_LIST=${NEUTRON_SERVER_LIST:-$CONFIG_SERVER_LIST}

##
# Control node environments
##

CONTROL_IP=${CONTROL_IP:-$IPADDRESS}
# Control ifmap user/password are control ip address
CONTROL_IFMAP_USER=${CONTROL_IFMAP_USER:-$IPADDRESS}
CONTROL_IFMAP_PASSWORD=${CONTROL_IFMAP_PASSWORD:-$CONTROL_IFMAP_USER}
CONTROL_LOG_FILE=${CONTROL_LOG_FILE:-"/var/log/contrail/contrail-control.log"}
CONTROL_CERTS_STORE=$CONTROL_CERTS_STORE
CONTROL_LOG_LEVEL=${CONTROL_LOG_LEVEL:-"SYS_NOTICE"}

ROUTER_ASN=${ROUTER_ASN:-64512}
BGP_MD5=${BGP_MD5}
EXTERNAL_ROUTERS_LIST=${EXTERNAL_ROUTERS_LIST}
DISCOVERY_PORT=${DISCOVERY_PORT:-5998}

DNS_LOG_FILE=${DNS_LOG_FILE:-"/var/log/contrail/contrail-dns.log"}
DNS_LOG_LEVEL=${DNS_LOG_LEVEL:-"SYS_NOTICE"}
DNS_IFMAP_USER=${DNS_IFMAP_USER:-${IPADDRESS}.dns}
DNS_IFMAP_PASSWORD=${DNS_IFMAP_PASSWORD:-$DNS_IFMAP_USER}
# This should be autogenerated rather than static value, could be done by installing rndc
DNS_RNDC_KEY=${DNS_RNDC_KEY:-"xvysmOR8lnUQRBcunkC6vg=="}