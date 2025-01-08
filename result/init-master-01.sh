# запуск на debian дистрибутиве
# !!! предварительно выполните руками скрипты из файла machine-preset.md
# перед выполнением скрипта получить права root (sudo -i)

######
# 2 master | 1 worker
######


## установка базовых пакетов на ноде
apt -y update
apt -y upgrade
apt -y install      \
    net-tools           \
    apt-transport-https \
    ca-certificates     \
    nano mc curl        \
    gpg gnupg2 wget     \
    software-properties-common 

## установка containerd в качестве контейнер-рантайма 
apt install -y containerd
mkdir -p /etc/containerd

cat <<EOF | sudo tee /etc/containerd/config.toml
version = 2
[plugins]
  [plugins."io.containerd.grpc.v1.cri"]
   [plugins."io.containerd.grpc.v1.cri".containerd]
      [plugins."io.containerd.grpc.v1.cri".containerd.runtimes]
        [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
          runtime_type = "io.containerd.runc.v2"
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true
EOF

systemctl restart containerd
systemctl enable containerd

## установка компонентов kubernetes
rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

apt -y update
apt -y install kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl

## инициализация кластера 
systemctl enable kubelet.service
systemctl start kubelet.service

### reset prev installations
yes | kubeadm reset --v=5 
rm -rf /etc/kubernetes/*
rm -rf /etc/cni/net.d
rm -rf $HOME/.kube/config
ipvsadm --clear

### init
kubeadm init \
  --apiserver-advertise-address 192.168.31.231 \
  --control-plane-endpoint 192.168.31.231 \
  --pod-network-cidr 10.244.0.0/16 
## wait wait wait ....

## start
mkdir -p $HOME/.kube
yes | sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

## check kuber state
kubectl get nodes
kubectl get pods -A

# install cni flannel
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

## create token to join node
# kubeadm token create --print-join-command 
## create cert to join 2nd master node
# kubeadm init phase upload-certs --upload-certs

