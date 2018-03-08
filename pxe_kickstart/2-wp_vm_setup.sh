# Get absolute path of the current script
declare script_file="$(python -c "import os; print(os.path.realpath('$0'))")"
# Get the absolute path of the script enclosing directory
declare script_dir="$(dirname ${script_file})"

###### PXE Server File Setup ########################################################
# Don't start the script until PXE Server is online
until [[ $(ssh -q pxe exit && echo "online") == "online" ]] ; do
  echo "Waiting for PXE Server to come online"
  sleep 10s
done

# Copy files to home folder first then move to nginx folder using sudo
scp -r ${script_dir}/kickstart pxe:~
scp -r ${script_dir}/setup pxe:~
ssh pxe 'sudo mv -f ~/kickstart/wp_ks.cfg /usr/share/nginx/html/'
ssh pxe 'sudo rm -rf ~/kickstart'
ssh pxe 'sudo mv -f ~/setup /usr/share/nginx/html/setup'
ssh pxe 'sudo chown nginx:wheel /usr/share/nginx/html/wp_ks.cfg'
ssh pxe 'sudo chmod ugo+r /usr/share/nginx/html/wp_ks.cfg'
ssh pxe 'chmod ugo+rx /usr/share/nginx/html/setup'
ssh pxe 'chmod -R ugo+r /usr/share/nginx/html/setup/*'
###### End PXE Server File Setup ########################################################

###### PXE Client VirtualBox Setup ########################################################
# Declare Variables for testing
declare vm_name="WP_pxe_client"

declare vms_folder="/Users/danielelisi/VirtualBox VMs"
declare size_in_mb=10000
declare memory_mb=1280

# Create VM
vboxmanage createvm --name $vm_name --register

declare vm_info=$(vboxmanage showvminfo "${vm_name}")
declare vm_conf_line=$(echo "${vm_info}" | grep "Config file")
declare vm_conf_file=$( echo "${vm_conf_line}" | grep -oE '(/[^/]+)+')
declare vbox_directory=$(dirname "${vm_conf_file}")

# Create .vdi Hard Disk to be later attached to VM
vboxmanage createhd \
    --filename "${vbox_directory}/${vm_name}.vdi" \
    --size $size_in_mb -variant Standard

# Storage Controllers and Media Devices
vboxmanage storagectl $vm_name --name SATA --add sata --bootable on
vboxmanage storagectl $vm_name --name IDE --add ide --bootable off

vboxmanage storageattach $vm_name \
    --storagectl IDE \
    --port 0 \
    --device 0 \
    --type dvddrive \
    --medium "/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso"

vboxmanage storageattach $vm_name \
    --storagectl SATA \
    --port 0 \
    --device 0 \
    --type hdd \
    --medium "${vbox_directory}/${vm_name}.vdi" \
    --nonrotational on


# Configure VM
vboxmanage modifyvm $vm_name\
    --ostype "RedHat_64"\
    --cpus 1\
    --hwvirtex on\
    --nestedpaging on\
    --largepages on\
    --firmware bios\
    --nic1 natnetwork\
    --nat-network1 "sys_net_prov"\
    --nictype1 82543GC\
    --macaddress1 "020000000001"\
    --cableconnected1 on\
    --audio none\
    --boot1 disk\
    --boot2 net\
    --boot3 none\
    --boot4 none\
    --memory "${memory_mb}"
###### End PXE Client VirtualBox Setup ########################################################

# Start VM
vboxmanage startvm $vm_name --type gui
