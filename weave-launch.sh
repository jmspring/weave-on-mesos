#!/bin/bash
# A script for getting Weave Net up and going on a Mesos/Marathon cluster.
# The script:
#   - Installs Weave Net on the node if not present and reboots the node
#   - Starts Weave Net
#   - Given the "HOST_PREFIX", connect the local Weave Net instance to peers
#       - This assumes that nodes are of the form HOST_PREFIX${n}
#       - The script simply tries to connect to n-1 and n+1, where n is the current node
#   - Once Weave is running, the script just goes into an endless sleep loop

# Required environment arguments are:
#   - HOST_PREFIX:      This helps figure out other nodes running Weave Net
#   - IPALLOC_RANGE:    An IP address range of the form (10.32.0.0/12) to have Weave issue IPs to containers

if [ -z "$HOST_PREFIX" ]; then
    echo "HOST_PREFIX required."
    exit 1
fi

if [ -z "$IPALLOC_RANGE" ]; then
    echo "IPALLOC_RANGE required."
    exit 1
fi

# The assumption is that the script is run as a Marathon job on each node using
# the "UNIQUE" constraint.

# This script also assumes you are using Ubuntu on the agent machines.

# Does Weave Net need to be installed?
grep MESOS_DOCKER_SOCKET /etc/default/mesos-slave
if [ $? -ne 0 ]; then 
    echo MESOS_DOCKER_SOCKET=/var/run/weave/weave.socket >> /etc/default/mesos-slave
    curl -L git.io/weave -o /usr/local/bin/weave
    chmod +x /usr/local/bin/weave
    
    # reboot is necessary to have mesos-slave pick up the configuration change
    reboot
fi

# Start Weave Net
# Is Weave Net already running?
weave status
if [ $? -eq 0 ]; then
    # If it is, stop it.
    weave stop
fi
weave launch --ipalloc-range $IPALLOC_RANGE

# Notify other nodes
HOSTNAME=`hostname`
HOSTNUM=${HOSTNAME#$HOST_PREFIX}
let LOWER_HOSTNUM=HOSTNUM-1
let UPPER_HOSTNUM=HOSTNUM+1
if [ "$LOWER_HOSTNUM" -ge 0 ]; then
    ping -w 10 -c 1 -q "$HOST_PREFIX$LOWER_HOSTNUM"
    if [ $? -eq 0 ]; then
        weave connect "$HOST_PREFIX$LOWER_HOSTNUM"
    else
        echo "Skipping $HOST_PREFIX$LOWER_HOSTNUM, does not appear to be a valid host."
    fi
fi

ping -w 10 -c 1 -q "$HOST_PREFIX$UPPER_HOSTNUM"
if [ $? -eq 0 ]; then
    weave connect "$HOST_PREFIX$UPPER_HOSTNUM"
else
    echo "Skipping $HOST_PREFIX$UPPER_HOSTNUM, does not appear to be a valid host."
fi

# Go into loop
while [ true ]; do 
    sleep 60;
done
