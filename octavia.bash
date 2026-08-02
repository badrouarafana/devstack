openstack loadbalancer create --wait --name lb1 --vip-subnet-id private-subnet
openstack loadbalancer listener create --wait --protocol HTTP --protocol-port 80 --name listener1 lb1
openstack loadbalancer pool create --wait --lb-algorithm ROUND_ROBIN --listener listener1 --protocol HTTP --name pool1
openstack loadbalancer healthmonitor create --wait --delay 5 --timeout 2 --max-retries 1 --type HTTP pool1
openstack loadbalancer member create --wait --subnet-id private-subnet --address <web server 1 address> --protocol-port 80 pool1
openstack loadbalancer member create --wait --subnet-id private-subnet --address <web server 2 address> --protocol-port 80 pool1
