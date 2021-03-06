#!/bin/bash
#
# To debug your container:
#
#   DOCKERARGS="--entrypoint /bin/bash" bash -x ./run.sh
#

# Name of Docker-Machine
MACHINE_NAME=${MACHINE_NAME:-default}

# Name of config file
conf=config_server/config.py

# Image name
image=mokemokechicken/oictest

# Name of container
name=oictest

# relative path to volume
volume=etc


c_path=$(pwd)
cddir=$(dirname $0)
cd $cddir

dir=$(pwd)

docker_ports=""

openPort() {
    for (( p=${1}; p<=${2}; p++))
    do
        docker_ports="${docker_ports} -p ${p}:${p}"
    done

}

HOST_PORT=$(cat ${volume}/${conf} | grep PORT | head -1 | sed 's/[^0-9]//g')

DYN_PORT_RANGE_MIN=$(cat ${volume}/${conf} | grep DYNAMIC_CLIENT_REGISTRATION_PORT_RANGE_MIN | grep -v "#" | head -1 | sed 's/[^0-9]//g')
DYN_PORT_RANGE_MAX=$(cat ${volume}/${conf} | grep DYNAMIC_CLIENT_REGISTRATION_PORT_RANGE_MAX | grep -v "#" | head -1 | sed 's/[^0-9]//g')
STATIC_PORT_RANGE_MIN=$(cat ${volume}/${conf} | grep STATIC_CLIENT_REGISTRATION_PORT_RANGE_MIN | grep -v "#" | head -1 | sed 's/[^0-9]//g')
STATIC_PORT_RANGE_MAX=$(cat ${volume}/${conf} | grep STATIC_CLIENT_REGISTRATION_PORT_RANGE_MAX | grep -v "#" | head -1 | sed 's/[^0-9]//g')

if ! [ $HOST_PORT ]; then
    HOST_PORT=8000
    DYN_PORT_RANGE_MIN=8001
    DYN_PORT_RANGE_MAX=8010
    STATIC_PORT_RANGE_MIN=8501
    STATIC_PORT_RANGE_MAX=8510
fi

centos_or_redhat=$(cat /etc/centos-release 2>/dev/null | wc -l)

DOCKERARGS=${DOCKERARGS}" -e BUILD_CONF=1 -e BUILD_METADATA=1 -e UPDATE_METADATA=1"

if [ ${centos_or_redhat} = 1 ]; then
    $(chcon -Rt svirt_sandbox_file_t ${dir}/${volume})
fi

openPort $DYN_PORT_RANGE_MIN $DYN_PORT_RANGE_MAX "DYN_PORT"
openPort $STATIC_PORT_RANGE_MIN $STATIC_PORT_RANGE_MAX "STATIC_PORT"
openPort $HOST_PORT $HOST_PORT "HOST_PORT"

# Check if running on mac
if [ $(uname) = "Darwin" ]; then
    echo "When using docker-machine"
    DOCKERENV="-e HOST_IP=$(docker-machine ip $MACHINE_NAME)"
fi

if ${sudo} docker ps | awk '{print $NF}' | grep -qx ${name}; then
    echo "$0: Docker container with name $name already running. Press enter to restart it, or ctrl+c to abort."
    read foo
    ${sudo} docker kill ${name}
fi

mkdir log > /dev/null 2> /dev/null
mkdir server_logs > /dev/null 2> /dev/null

$sudo docker rm ${name} > /dev/null 2> /dev/null

echo open "https://$(docker-machine ip $MACHINE_NAME):8000"

${sudo} docker run --rm=true \
    --name ${name} \
    --hostname localhost \
    -v ${dir}/${volume}:/opt/oictest/etc \
    -v ${dir}/server_logs:/opt/oictest/src/oictest/test/oic_op/rp/server_log \
    -v ${dir}/log:/opt/oictest/src/oictest/test/oic_op/rp/log \
    ${docker_ports} \
    ${DOCKERENV} \
    $DOCKERARGS \
    -i -t \
    ${image}

cd $c_path
