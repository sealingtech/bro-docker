#!/bin/bash
#
# Starts a Docker instance of the Bro IDS and tunes some settings for high throughput
# - Requires RHEL/CentOS 7.3+ or kernel 4.4+.
# - Uses AF-Packet with fanout as the multi-core session load balancer
#
# Usage: start-bro-docker <interface>'

if [[ $# -eq 0 ]] ; then
    echo 'ERROR: No interface found'
    echo 'Usage: start-bro-docker <interface>'
    echo 'File contains editable variables'
    exit 1
fi

###############################
#Edit these varibles as needed#
###############################

#CONTAINERINT is the interface within the Container
CONTAINERINT=eth1

#These varibles are auto-populated
CONTAINERID=$(docker run -it -d bro-docker)
pid=$(docker inspect --format='{{ .State.Pid }}' $CONTAINERID)
ln -s /proc/$pid/ns/net /var/run/netns/$CONTAINERID
ip link set $1 netns $CONTAINERID
sleep 2
ip netns exec $CONTAINERID ip link set $1 name $CONTAINERINT
sleep 2
ip netns exec $CONTAINERID ip link set $CONTAINERINT up
docker exec $CONTAINERID sed -i "/const fanout_id/c\ \tconst fanout_id = $RANDOM &redef;" /usr/local/bro/lib/bro/plugins/Bro_AF_Packet/scripts/init.bro
docker exec $CONTAINERID sh -c "printf '[logger] \ntype=logger \nhost=localhost \n# \n[manager] \ntype=manager \nhost=localhost \n# \n[proxy-1] \ntype=proxy \nhost=localhost \n# \n[worker-1] \ntype=worker \nhost=localhost \ninterface=af_packet::$CONTAINERINT \nlb_method=custom \nlb_procs=14 \npin_cpus=1,2,3,4,5,6,7,9,10,11,12,13,14,15' > /usr/local/bro/etc/node.cfg"
docker exec -d $CONTAINERID /usr/local/bro/bin/broctl deploy
