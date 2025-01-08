echo '192.168.31.231 kube-node-01.home.local' >> /etc/hosts
echo '192.168.31.232 kube-node-02.home.local' >> /etc/hosts
echo '192.168.31.233 kube-node-03.home.local' >> /etc/hosts
systemctl restart networking.service


apt install sudo -y
sudo adduser kutumov sudo
sudo -i


echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
# -- 
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf 
overlay 
br_netfilter
EOF
sudo modprobe overlay 
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1 
net.bridge.bridge-nf-call-ip6tables = 1 
EOF
# apply
sudo sysctl --system


sudo systemctl stop firewalld


chmod +x ./enviroment/disable_swap.sh
./enviroment/disable_swap.sh