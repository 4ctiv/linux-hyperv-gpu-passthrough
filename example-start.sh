#!/bin/bash
# place this in '/etc/libvirt/hooks/qemu.d/{VM Name}/prepare/begin'
# Logs can be found under /var/log/libvirt/qemu/[VM name].log

# Helpful to read output when debugging
set -x

# Stop display manager
systemctl stop display-manager.service
## Uncomment the following line if you use GDM
#killall gdm-x-session

# Unbind VTconsoles
echo 0 > /sys/class/vtconsole/vtcon0/bind
echo 0 > /sys/class/vtconsole/vtcon1/bind

# Unbind EFI-Framebuffer
echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

# Avoid a Race condition by waiting 2 seconds. This can be calibrated to be shorter or longer if required for your system
sleep 2

# Disable nvidia gpu driver
#modprobe -r nvidia-drm
#modprobe -r nvidia-uvm
#modprobe -r snd_hda_intel
#modprobe -r i2c_nvidia_gpu
#modprobe -r nvidia

# Disable intel gpu driver
modprobe -r i915
modprobe -r xe

# Unbind the GPU from display driver
# Use '0000:$(lspci -nn | grep VGA | head -n 1 | grep -Eo "[0-9a-fA-F]{2}:[0-9a-fA-F]{2}" | head -n 1):0'
# 0000:2D:00:0 Intel Corporation DG2 [Arc A770]
# 0000:2E:00:0 Intel Corporation DG2 Audio Controller
virsh nodedev-detach 0000:2D:00:0 # pci_0000_0c_00_0
virsh nodedev-detach 0000:2E:00:0 # pci_0000_0c_00_1

# Load VFIO Kernel Module
modprobe vfio-pci
modprobe vfio
modprobe vfio_iommu_type1

