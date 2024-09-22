export SERVICE_ACCOUNT_TOKEN=$(kubectl get secret cd-secret -n homework -o jsonpath="{.data.token}" | base64 --decode)
export CA_CRT=$(kubectl get secret cd-secret -n homework -o jsonpath="{.data['ca\.crt']}" | base64 --decode | base64 -w 0)
export SERVER_URL=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

envsubst < ./security/kubeconfig.template > ./security/kubeconfig.yml