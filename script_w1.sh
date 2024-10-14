#!/bin/bash
sudo apt-get update
sudo ovs-vsctl add-br br-int-w1
sudo ip link set dev br-int-w1 up
sudo ip tuntap add mode tap t-r1-int-vm1
sudo ip tuntap add mode tap name t-r1-14-vm1
sudo ip tuntap add mode tap name t-r1-12-vm1
sudo ip tuntap add mode tap name t-r1-43-vm4
sudo ip tuntap add mode tap name t-r1-41-vm4
sudo apt-get install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virt-manager


if [ ! -d "disks" ]; then
  # Si no existe, crea la carpeta
  mkdir disks

wget https://github.com/adawa111/cloud_g9/blob/main/cirros-0.6.2-x86_64-disk.img
wget https://download1479.mediafire.com/o9n7q0fxt5ygx36Y76kkHs13UC1T3TBlF0Fy3JBRDXaPU2_hY6NJfEqSgn0lt5HJgAJrk8hkj9fdQHJnoDMjkC2D1EyJbcXbEIcUbQKMirqwd4RlDZTAHE6TAEAOEi2NYhjWYCinXejU4-gf2VB4kzcxcl2UOr2CLUU35lCHUNSUbw/atqax0ra7d2pk1r/focal-server-cloudimg-amd64.img


qemu-img create -f qcow2 ./disks/disk_r1_VM1.qcow2 1G
qemu-img create -f qcow2 ./disks/disk_r1_VM4.qcow2 1G
cp focal-server-cloudimg-amd64.img ./focal-server-cloudimg-amd64_r1_VM1.img
cp focal-server-cloudimg-amd64.img ./focal-server-cloudimg-amd64_r1_VM4.img

sudo qemu-system-x86_64 -enable-kvm -vnc 0.0.0.0:1 \
    -netdev tap,id=t-r1-int-vm1,ifname=t-r1-int-vm1,script=no,downscript=no \
    -device e1000,netdev=t-r1-int-vm1,mac=20:19:00:57:aa:11 \
    -netdev tap,id=t-r1-14-vm1,ifname=t-r1-14-vm1,script=no,downscript=no \
    -device e1000,netdev=t-r1-14-vm1,mac=20:19:00:57:aa:12 \
    -netdev tap,id=t-r1-12-vm1,ifname=t-r1-12-vm1,script=no,downscript=no \
    -device e1000,netdev=t-r1-12-vm1,mac=20:19:00:57:aa:13 \
    -daemonize -snapshot focal-server-cloudimg-amd64_r1_VM1.img \
    -smp cores=1 -m 512 -drive file=/home/ubuntu/disks/disk_r1_VM1.qcow2,if=virtio -cpu host

sudo qemu-system-x86_64 -enable-kvm -vnc 0.0.0.0:2 \
    -netdev tap,id=t-r1-43-vm4,ifname=t-r1-43-vm4,script=no,downscript=no \
    -device e1000,netdev=t-r1-43-vm4,mac=20:19:00:57:aa:14 \
    -netdev tap,id=t-r1-41-vm4,ifname=t-r1-41-vm4,script=no,downscript=no \
    -device e1000,netdev=t-r1-41-vm4,mac=20:19:00:57:aa:15 \
    -daemonize -snapshot focal-server-cloudimg-amd64_r1_VM4.img \
    -smp cores=1 -m 512 -drive file=/home/ubuntu/disks/disk_r1_VM4.qcow2,if=virtio -cpu host


sudo ovs-vsctl add-port br-int-w1 t-r1-int-vm1
sudo ovs-vsctl add-port br-int-w1 t-r1-14-vm1
sudo ovs-vsctl add-port br-int-w1 t-r1-12-vm1
sudo ovs-vsctl add-port br-int-w1 t-r1-43-vm4
sudo ovs-vsctl add-port br-int-w1 t-r1-41-vm4

sudo ovs-vsctl set port t-r1-int-vm1 tag=700
sudo ovs-vsctl set port t-r1-14-vm1 tag=400
sudo ovs-vsctl set port t-r1-12-vm1 tag=100
sudo ovs-vsctl set port t-r1-43-vm4 tag=300
sudo ovs-vsctl set port t-r1-41-vm4 tag=400

sudo ip link set t-r1-int-vm1 up
sudo ip link set t-r1-14-vm1 up
sudo ip link set t-r1-12-vm1 up
sudo ip link set t-r1-43-vm4 up
sudo ip link set t-r1-41-vm4 up

sudo ovs-vsctl add-port br-int-w1 ens4

sudo ovs-vsctl set port ens4 trunk=100,300,400,700



