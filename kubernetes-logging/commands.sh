# create folder in cloud
# (cloud id from YC admin panel)
yc resource-manager folder create --name new-folder --description "otus-folder" --cloud-id b1giqdsids02ak3m16j8

# set default cloud id
yc config set cloud-id b1giqdsids02ak3m16j8

# set default folder id
yc config set folder-id b1gupj415g6dch89ogri

# create service account
yc iam service-account create --name dz9

# [output]
# id: ajeat4ajlqfce335v304

# set env variables
FOLDER_ID=b1gupj415g6dch89ogri
SA_ID=ajeat4ajlqfce335v304

# add admin role to service account
yc resource-manager folder add-access-binding \
    --id ${FOLDER_ID} \
    --role admin \
    --subject serviceAccount:${SA_ID}

# create network
yc vpc network create \
  --name dz9-network \
  --description "Network for DZ-9"

# create network subnet
yc vpc subnet create \
  --name dz9-subnet \
  --network-name dz9-network \
  --zone ru-central1-a \
  --range 192.168.0.0/24

# Create managed-kubernetes cluster
yc managed-kubernetes cluster create \
 --name dz9-cluster \
 --public-ip \
 --service-account-id ${SA_ID} \
 --node-service-account-id ${SA_ID} \
 --zone ru-central1-a \
 --network-name dz9-network 

# [output]
# id: catmk34dcod811ejo3id


# create node groups
yc managed-kubernetes node-group create   \
 --name dz9-work \
 --cluster-name dz9-cluster \
 --cores 2 \
 --memory 4 \
 --core-fraction 5 \
 --preemptible \
 --fixed-size 1 \
 --network-interface subnets=dz9-subnet,ipv4-address=nat

yc managed-kubernetes node-group create \
 --name dz9-infrastructure \
 --cluster-name dz9-cluster \
 --cores 2 \
 --memory 4 \
 --core-fraction 5 \
 --fixed-size 1 \
 --preemptible \
 --node-labels node-role=infrastructure \
 --network-interface subnets=dz9-subnet,ipv4-address=nat

# set as default cluster for kubectl
yc managed-kubernetes cluster get-credentials --external --name dz9-cluster --force

# taint for infrastructure nodes
kubectl taint nodes -l node-role=infrastructure node-role=infrastructure:NoSchedule
kubectl create ns dz9

# create buckets for logs 
yc storage bucket create dz9-loki-bucket
yc storage bucket create dz9-loki-ruler
yc storage bucket create dz9-loki-admin

# grand permissions for buckets
yc storage bucket update --name dz9-loki-bucket \
    --grants grant-type=grant-type-account,grantee-id=${SA_ID},permission=permission-full-control
yc storage bucket update --name dz9-loki-ruler   \
    --grants grant-type=grant-type-account,grantee-id=${SA_ID},permission=permission-full-control
yc storage bucket update --name dz9-loki-admin  \
    --grants grant-type=grant-type-account,grantee-id=${SA_ID},permission=permission-full-control

# run helm files
cd loki && helmfile apply && cd ..
cd promtail && helmfile apply && cd ..
cd grafana && helmfile apply && cd ..

# run kubectl port forwarding
kubectl -n dz9 port-forward grafana-6887f57dc-8krdk 3000

# show admin password for grafana
kubectl get secret --namespace dz9 grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo 

## cleanup - delete kuber cluster
yc managed-kubernetes cluster delete --name dz9-cluster