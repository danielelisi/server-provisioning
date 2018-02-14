# Declare Variables for testing
declare vm_name="WordpressServer"

declare vms_folder="/Users/danielelisi/VirtualBox VMs"
declare size_in_mb=10000
declare iso_file_path="/Users/danielelisi/Documents/centos_server.iso"
declare memory_mb=1280

# Create VM
vboxmanage createvm --name $vm_name --register

declare vm_info=$(vboxmanage showvminfo "${vm_name}")
declare vm_conf_line=$(echo "${vm_info}" | grep "Config file")
declare vm_conf_file=$( echo "${vm_conf_line}" | grep -oE '(/[^/]+)+')
declare vbox_directory=$(dirname "${vm_conf_file}")

# 
vboxmanage createhd --filename "${vbox_directory}/${vm_name}.vdi" --size $size_in_mb -variant Standard

# Storage Controllers and Media Devices
vboxmanage storagectl $vm_name --name SATA --add sata --bootable on
vboxmanage storagectl $vm_name --name IDE --add ide --bootable on

vboxmanage storageattach $vm_name --storagectl IDE --port 0 --device 0 --type dvddrive --medium $iso_file_path
vboxmanage storageattach $vm_name --storagectl IDE --port 1 --device 0 --type dvddrive --medium "/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso"
vboxmanage storageattach $vm_name --storagectl SATA --port 0 --device 0 --type hdd --medium "${vbox_directory}/${vm_name}.vdi" --nonrotational on

# Configure VM
vboxmanage modifyvm $vm_name\
    --ostype "RedHat_64"\
    --cpus 1\
    --hwvirtex on\
    --nestedpaging on\
    --largepages on\
    --firmware bios\
    --nic1 natnetwork\
    --nictype1 82540EM\
    --nat-network1 "sys_net_prov"\
    --cableconnected1 on\
    --audio none\
    --boot1 disk\
    --boot2 dvd\
    --boot3 none\
    --boot4 none\
    --memory "${memory_mb}"

# Start VM
vboxmanage startvm $vm_name --type gui
