#! /usr/bin/env bash
sudo yum -y install kernel-devel kernel-headers dkms gcc gcc-c++ kexec-tools curl bzip2
mkdir ${vb_ga_mnt}
sudo mount -t iso9660 -o loop,ro ${vb_ga_src} ${vb_ga_mnt}
sudo  ${vb_ga_mnt}/VBoxLinuxAdditions.run
sudo umount ${vb_ga_mnt}
sudo rm -rf ${vb_ga_mnt}
sudo rm -rf ${vb_ga_src}
