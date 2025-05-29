#!/usr/bin/env bash
#
# create 'head' and 'node01' debian VMs to experiment with
#
# 20250514 - init

# locally, for qemu's os-varient to know what 'debian12' is
# sudo apt install osinfo-db-tools
# sudo osinfo-db-import --latest -v


# https://wiki.debian.org/KVM#Installation
# SHOULD HAVE USED:
# https://cloud.debian.org/images/cloud/bookworm-backports/20250428-2096/debian-12-backports-genericcloud-amd64-20250428-2096.qcow2
virsh list --all | grep head ||
 dryrun virt-install --virt-type kvm \
   --name "head" \
   --location https://deb.debian.org/debian/dists/bookworm/main/installer-amd64/ \
   --os-variant debian12 \
   --disk size=10 \
   --memory 2048 \
   --graphics none \
   --console pty,target_type=serial \
   --extra-args "console=ttyS0"

# https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/sect-network_booting_with_libvirt-booting_a_guest_using_pxe#sect-Booting_a_guest_using_PXE-Using_bridged_networking
virsh list --all | grep node01 ||
  dryrun virt-install \
    --network network=default \
    --pxe `# Network Boot` \
    --name "node01" \
    --disk size=5 \
    --memory 1024 \
    --graphics none --console pty,target_type=serial
