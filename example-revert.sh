#!/bin/bash
# place this in '/etc/libvirt/hooks/qemu.d/{VM Name}/release/end'
# Logs can be found under /var/log/libvirt/qemu/[VM name].log

set -x

# Unload VFIO Kernel Module
modprobe -r vfio-pci
modprobe -r vfio_iommu_type1
modprobe -r vfio

# Re-Bind GPU drivers to display
# Use '0000:$(lspci -nn | grep VGA | head -n 1 | grep -Eo "[0-9a-fA-F]{2}:[0-9a-fA-F]{2}" | head -n 1):0'
# 0000:2D:00:0 Intel Corporation DG2 [Arc A770]
# 0000:2E:00:0 Intel Corporation DG2 Audio Controller
virsh nodedev-reattach 0000:2E:00:0 # pci_0000_0c_00_1
virsh nodedev-reattach 0000:2D:00:0 # pci_0000_0c_00_0

# Reload nvidia modules
#modprobe nvidia
#modprobe nvidia_modeset
#modprobe nvidia_uvm
#modprobe nvidia_drm

# Reload amd modules
#modprobe amdgpu
#modprobe radeon

# Reload intel modules
modprobe i915 # old intel driver
modprobe xe   # new intel driver

# Rebind VT consoles
echo 1 > /sys/class/vtconsole/vtcon0/bind
# Some machines might have more than 1 virtual console. Add a line for each corresponding VTConsole
#echo 1 > /sys/class/vtconsole/vtcon1/bind

#nvidia-xconfig --query-gpu-info > /dev/null 2>&1
echo "efi-framebuffer.0" > /sys/bus/platform/drivers/efi-framebuffer/bind

# Restart Display Manager
systemctl start display-manager.service

