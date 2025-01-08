# Предварительные настройки для каждой машины

*! все команды из этого файла перенесены в один* `./preset.sh`

Edit Hosts file

```
echo '192.168.31.231 kube-node-01.home.local' >> /etc/hosts
echo '192.168.31.232 kube-node-02.home.local' >> /etc/hosts
echo '192.168.31.233 kube-node-03.home.local' >> /etc/hosts
systemctl restart networking.service
```

## Установка пакетов

1. Установить

   ```
   apt install sudo -y
   ```
2. Добавить своего пользователя в группу sudoers

   ```
   sudo adduser kutumov sudo
   sudo -i
   ```
3. Установим параметры ядра и сохраним

   ```
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
   ```
4. Отключить firewall

   ```
   sudo systemctl stop firewalld
   ```




## Отключение swap

Для некоторых OS необходимо отключить swap

Запустите скрипт с отключением swap:

```
chmod +x ./enviroment/disable_swap.sh
./enviroment/disable_swap.sh
```




## Настройка статического `ip` для удобства

1. Открыть файл с настройками

```
nano /etc/network/interfaces
```

1. Заменить строки вида:

```
allow-hotplug ens192
iface ens192 inet dhcp
```

2. На текст вида:

```
auto ens192
iface ens192 inet static
	address 192.168.31.<ip from pool>
	netmask 255.255.255.0
	gateway 192.168.31.1
	dns-nameservers 192.168.31.1 8.8.8.8 77.88.8.8
```


end.
