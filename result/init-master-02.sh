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

# ручное добавление второго мастера
### init
# kubeadm join 192.168.31.231:6443  \
#   --control-plane \
#   --certificate-key f51b431ea7828692a6981c5b0dc760cf9964bc2318ca981a60432b294d0237d5 \
#   --token aaox6g.e32gunsaa44ju4h2 --discovery-token-ca-cert-hash sha256:f919ea521344e5f1fb8dd813c4151149ee9d2db0a05e59529538a14da8f91053 