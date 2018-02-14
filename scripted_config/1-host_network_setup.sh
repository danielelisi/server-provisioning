# Declare variables for testing
declare network_name="sys_net_prov"
declare network_address="192.168.254.0"
declare cidr_bits="24"

# Remove NAT network if already exist
# vboxmanage natnetwork remove --netname $network_name

# Add NAT Network 
vboxmanage natnetwork add --netname $network_name --network "$network_address/$cidr_bits" --dhcp off

# Network Port Forwarding Configuration
vboxmanage natnetwork modify --netname $network_name --port-forward-4 "SSH:TCP:[127.0.0.1]:50022:[192.168.254.10]:22"
vboxmanage natnetwork modify --netname $network_name --port-forward-4 "HTTP:TCP:[127.0.0.1]:50080:[192.168.254.10]:80"
vboxmanage natnetwork modify --netname $network_name --port-forward-4 "HTTPS:TCP:[127.0.0.1]:50443:[192.168.254.10]:443"
vboxmanage natnetwork modify --netname $network_name --port-forward-4 "PXE SSH:TCP:[127.0.0.1]:50222:[192.168.254.5]:22"
