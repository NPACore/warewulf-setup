# 20250514 - init

# sudo apt install osinfo-db-tools
# sudo osinfo-db-import --latest -v


# https://wiki.debian.org/KVM#Installation
#
virt-install --virt-type kvm \
   --name "head" \
   --location https://deb.debian.org/debian/dists/bookworm/main/installer-amd64/ \
   --os-variant debian12 \
   --disk size=5 \
   --memory 2048 \
   --graphics none \
   --console pty,target_type=serial \
   --extra-args "console=ttyS0"

# https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/virtualization_deployment_and_administration_guide/sect-network_booting_with_libvirt-booting_a_guest_using_pxe#sect-Booting_a_guest_using_PXE-Using_bridged_networking
# virt-install --pxe --network network=default --name "node01" --memory 1024 --graphics none --console pty,target_type=serial --disk size=2
