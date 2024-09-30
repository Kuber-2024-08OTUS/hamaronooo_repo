kubectl create -f namespace.yaml \
    && kubectl create -f sa.yaml \
    && kubectl create -f crd.yaml \
    && kubectl create -f custom-resource.yaml \
    && kubectl create -f deployment.yaml