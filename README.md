# weave-on-mesos
[Weave Net](http://www.weave.works/products/weave-net/) is simple method of 
building a network of containers.  [Mesos](https://github.com/apache/mesos) 
is a cluster manager and container orchestration system that helps facilitate
the running of distributed applications.

What isn't so easy is finding the right tooling for service discovery and 
networking amongst apps in container-based distributed apps.  Docker has
their own [approach](https://docs.docker.com/engine/userguide/networking/).
Mesos has [MesosDNS] https://github.com/mesosphere/mesos-dns.  And there are
other solutions out there.

The draw of Weave Net is it's simplicity.  It pools an IP range and 
automatically gives out IPs to containers on each host.  Weave DNS then
allows the application to discover applications by their name.

So, this is another spin on getting Weave to deploy on a Mesos cluster.

The approach taken here is a simple one, use the Marathon scheduler to set 
up Weave on each agent machine.  This is done by configuring the Marathon
job definition to run as many (or more (**1**) instances of the task and use 
the UNIQUE constraint to limit it to one process per agent machine.

For a five agent Mesos cluster, the definition for the file might look 
something like (assume it's named **weave-launch.json**):

        {
          "id": "weave-launch",
          "cpus": 0.01,
          "mem": 1.0,
          "cmd": "chmod u+x weave-launch.sh && ./weave-launch.sh",
          "uris": [
            "https://raw.githubusercontent.com/jmspring/weave-on-mesos/master/weave-launch.sh"
          ],
          "constraints": [["hostname", "UNIQUE"]],
          "instances": 10,
          "env": {
            "HOST_PREFIX": "c1agent",
            "IPALLOC_RANGE": "10.32.0.0/12"
          }
        }

Note, the two required environment variables -- **HOST_PREFIX** and **IPALLOC_RANGE**.
This project makes the following assumptions about your Mesos deployment:

- Agent nodes have a common naming scheme of **HOST_PREFIX**[n], where [n] is a number that is sequential to other agent nodes.
- Your Mesos cluster machines are deployed in some sort of IP address range, and Weave Net needs to be informed of an IP address range that does not overlap with the host machines.  If they ranges do overlap, Weave Net will not start.
- The under lying OS is based on **Ubuntu**.

What the above Marathon task definition does is pull down the script **weave-launch.sh** 
and runs it on unique nodes up to **10** of them at a time.  It assumes that Mesos agent 
machines names that start with **c1agent**, so machines may be named **c1agent0**, 
**c1agent1**, **c1agent2**, etc.  Weave Net is allocated an IP range of **10.32.0.0/12**.

## What does **weave-launch.sh** do?

**weave-launch.sh** is a stand alone script that runs in two phases.  The first phase 
configures the Mesos agent if it has not yet been configured and then reboots.  The second
phase launches Weave Net and notifies the neighboring (n-1, n+1) agents that it is running 
Weave Net, and thus joins the Weave Net cluster.

## How to run weave-on-mesos?

To run this job, assuming your Marathon node is reachable, it's as simple as:

    curl -X POST http://<marathon master ip>/v2/apps -d @weave-launch.json  -H "Content-type: application/json"
    
Fire it up and watch Mesos and Marathon UIs.

## Notes

(**1**) Marathon currently has no way to request that a process be run
on every agent machine.  There is an open [request](https://github.com/mesosphere/marathon/issues/846)
for the issue, however.