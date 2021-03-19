# creating issuer
kubectl apply -f issuer.yaml

# create cert and wait 10 seconds
kubectl apply -f backend-cert.yaml
sleep 10
# extract crt and key. crt has to be a bundle
kubectl get secret backend-tls -o go-template='{{ index .data "ca.crt" | base64decode }}' > tls.crt
kubectl get secret backend-tls -o go-template='{{ index .data "tls.crt" | base64decode }}' >> tls.crt
kubectl get secret backend-tls -o go-template='{{ index .data "tls.key" | base64decode }}' > tls.key

# create the new tls secret
kubectl --dry-run=client --output=yaml create secret tls backend-service-tls --cert=tls.crt --key=tls.key | kubectl apply -f -

# apply nginx.conf as configmap and deploy pod.
kubectl --dry-run=client --output=yaml create configmap nginx-conf --from-file=nginx.conf | kubectl apply -f -
kubectl apply -f backend-1.yaml
kubectl apply -f backend-1-svc.yaml

# now choose one of those ingress
kubectl apply -f ingress.yaml
# OR !!! (Not both of course)
# kubectl apply -f ingress-with-ssl-backend.yaml
