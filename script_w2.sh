#!/bin/bash
sudo apt-get update


if [ ! -d "disks" ]; then
  # Si no existe, crea la carpeta
  mkdir disks

sudo ovs-vsctl add-br br-int-w2
sudo ip link set dev br-int-w2 up
sudo ip tuntap add mode tap name t-r1-21-vm2
sudo ip tuntap add mode tap name t-r1-23-vm2
sudo ip tuntap add mode tap name t-b1-25-vm2
sudo ip tuntap add mode tap name t-b1-52-vm5
sudo ip tuntap add mode tap name t-b1-56-vm5
sudo apt-get install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager
wget https://github.com/adawa111/cloud_g9/blob/main/cirros-0.6.2-x86_64-disk.img
wget https://download1479.mediafire.com/o9n7q0fxt5ygx36Y76kkHs13UC1T3TBlF0Fy3JBRDXaPU2_hY6NJfEqSgn0lt5HJgAJrk8hkj9fdQHJnoDMjkC2D1EyJbcXbEIcUbQKMirqwd4RlDZTAHE6TAEAOEi2NYhjWYCinXejU4-gf2VB4kzcxcl2UOr2CLUU35lCHUNSUbw/atqax0ra7d2pk1r/focal-server-cloudimg-amd64.img

qemu-img create -f qcow2 ./disks/disk_r1_VM2.qcow2 1G
cp cirros-0.6.2-x86_64-disk.img ./cirros-0.6.2-x86_64-disk-r1-VM2.img
qemu-img create -f qcow2 ./disks/disk_r1_VM5.qcow2 1G
cp focal-server-cloudimg-amd64.img ./focal-server-cloudimg-amd64_r1_VM5.img
sudo qemu-system-x86_64 -enable-kvm -vnc 0.0.0.0:1 \
    -netdev tap,id=t-r1-21-vm2,ifname=t-r1-21-vm2,script=no,downscript=no \
    -device e1000,netdev=t-r1-21-vm2,mac=20:19:00:57:aa:21 \
    -netdev tap,id=t-r1-23-vm2,ifname=t-r1-23-vm2,script=no,downscript=no \
    -device e1000,netdev=t-r1-23-vm2,mac=20:19:00:57:aa:22 \
    -netdev tap,id=t-b1-25-vm2,ifname=t-b1-25-vm2,script=no,downscript=no \
    -device e1000,netdev=t-b1-25-vm2,mac=20:19:00:57:aa:23 \
    -daemonize -snapshot cirros-0.6.2-x86_64-disk-r1-VM2.img \
    -smp cores=1 -m 512 -drive file=/home/ubuntu/disks/disk_r1_VM2.qcow2,if=virtio -cpu host

sudo qemu-system-x86_64 -enable-kvm -vnc 0.0.0.0:2 \
    -netdev tap,id=t-b1-52-vm5,ifname=t-b1-52-vm5,script=no,downscript=no \
    -device e1000,netdev=t-b1-52-vm5,mac=20:19:00:57:aa:24 \
    -netdev tap,id=t-b1-56-vm5,ifname=t-b1-56-vm5,script=no,downscript=no \
    -device e1000,netdev=t-b1-56-vm5,mac=20:19:00:57:aa:25 \
    -daemonize -snapshot focal-server-cloudimg-amd64_r1_VM5.img \
    -smp cores=1 -m 512 -drive file=/home/ubuntu/disks/disk_r1_VM5.qcow2,if=virtio -cpu host


sudo ovs-vsctl add-port br-int-w2 t-r1-21-vm2
sudo ovs-vsctl add-port br-int-w2 t-r1-23-vm2
sudo ovs-vsctl add-port br-int-w2 t-b1-25-vm2

sudo ovs-vsctl add-port br-int-w2 t-b1-52-vm5
sudo ovs-vsctl add-port br-int-w2 t-b1-56-vm5

sudo ovs-vsctl set port t-r1-21-vm2 tag=100
sudo ovs-vsctl set port t-r1-23-vm2 tag=200
sudo ovs-vsctl set port t-b1-25-vm2 tag=500
sudo ovs-vsctl set port t-b1-52-vm5 tag=500
sudo ovs-vsctl set port t-b1-56-vm5 tag=600

sudo ip link set t-r1-21-vm2 up
sudo ip link set t-r1-23-vm2 up
sudo ip link set t-b1-25-vm2 up
sudo ip link set t-b1-52-vm5 up
sudo ip link set t-b1-56-vm5 up

sudo ovs-vsctl add-port br-int-w2 ens4

sudo ovs-vsctl set port ens4 trunk=100,200,500,600


