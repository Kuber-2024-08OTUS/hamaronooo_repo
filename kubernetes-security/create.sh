kubectl create \
    -f namespace.yml \
    -f ./security/serviceAccountMonitoring.yml \
    -f ./security/serviceAccountAdmin.yml \
    -f ./security/secrets.yml \
    -f storageClass.yml \
    -f cm.yml \
    -f deployment.yml \
    -f pvc.yml \
    -f service.yml \
    -f ingress.yml

./security/create-kubeconfig.sh

kubectl create token cd -n homework --duration=24h > token