source state_file

elastic_ip_allocation_id=$(aws ec2 allocate-address  --domain vpc  --query AllocationId  --output text)
elastic_ip=$(aws ec2 describe-addresses \
                          --allocation-ids $elastic_ip_allocation_id \
                          --query Addresses[*].PublicIp \
                          --output text)

echo "elastic_ip_allocation_id=$elastic_ip_allocation_id" >> state_file
echo "elastic_ip=$elastic_ip" >> state_file
