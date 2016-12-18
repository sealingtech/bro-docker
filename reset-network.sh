#!/bin/bash
if [[ $# -eq 0 ]] ; then
    echo 'ERROR: No Arg found'
    echo 'Usage: reset-network.sh <num of VFs>'
    exit 1
fi
ip -all netns delete
echo 0 > /sys/class/net/ens2f0/device/sriov_numvfs
sleep 1
echo $1 > /sys/class/net/ens2f0/device/sriov_numvfs

for i in $(eval echo {1..$1})
do
if [ "$i" -gt '10' ]
then
#Set the interfaces required
ip link set dev ens2f0 vf $(($i - 1)) trust on
ip link set dev ens2f0 vf $(($i - 1)) vlan 10$(($i - 1))
ip link set dev ens2f0 vf $(($i - 1)) spoofchk off
ip link set dev ens2f0 vf $(($i - 1)) mac 0:52:44:11:22:$(($i - 1))
else 
ip link set dev ens2f0 vf $(($i - 1)) trust on
ip link set dev ens2f0 vf $(($i - 1)) vlan 100$(($i - 1))
ip link set dev ens2f0 vf $(($i - 1)) spoofchk off
ip link set dev ens2f0 vf $(($i - 1)) mac 0:52:44:11:22:3$(($i - 1))
fi
done

#Reload VF Kernel Module
rmmod i40evf
modprobe i40evf

