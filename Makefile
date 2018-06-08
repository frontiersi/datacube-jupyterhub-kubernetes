## Initial Setup
# Create the cluster
create-cluster:
	kops create -f cluster/cluster.yaml --yes

validate:
	kops validate cluster

## Dashboard components
# This is optional, but is quite nice
deploy-dashboard:
	kubectl create -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml
	kubectl create -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/grafana.yaml
	kubectl create -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/heapster.yaml
	kubectl create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/kubernetes-dashboard/v1.8.3.yaml

# And this enables you to access the dashboard securely.
proxy:
	open http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
	kubectl proxy

## JupyterHub
# https://docs.helm.sh/using_helm/#securing-your-helm-installation
init-helm:
	helm init

init-helm-rbac:
	kubectl create -f rbac-conf.yaml
	helm init --service-account tiller

repo-add:
	helm repo add jupyterhub \
		https://jupyterhub.github.io/helm-chart/
	
repo-update:
	helm repo update

install-jupyterhub:
	helm install ./chart \
		--timeout=5000 \
		--version=v0.6 \
		--name=odchub \
		--namespace=odchub \
		--set rbac.enabled=false \
		-f config.yaml

update-jupyterhub:
	helm upgrade odchub jupyterhub/jupyterhub --version=v0.6 --set rbac.enabled=false -f config.yaml

get-deployment:
	kubectl --namespace=odchub get deployment

## SSL Magic ##
# May not be required, but definitely works.
# Ingress
create-ingress-namespace:
	kubectl create namespace ingress-controller

create-ingress-configmap:
	kubectl create -f ingress/nginx-configmap.yaml

create-ingress-controller:
	kubectl create -f ingress/nginx-ingress.yaml

# Self-signed SSL
create-ssl:
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ./ingress/nginx-selfsigned.key -out ./ingress/nginx-selfsigned.crt
	openssl dhparam -out ./ingress/dhparam.pem 2048

create-ssl-secrets:
	kubectl create secret --namespace ingress-controller tls tls-certificate --key ./ingress/nginx-selfsigned.key --cert ./ingress/nginx-selfsigned.crt
	kubectl create secret --namespace ingress-controller generic tls-dhparam --from-file=./ingress/dhparam.pem

deploy-letsencrypt:
	kubectl apply -f ingress/namespace.yaml
	kubectl apply -f ingress/configmap.yaml
	kubectl apply -f ingress/service-account.yaml
	kubectl apply -f ingress/cluster-role.yaml
	kubectl apply -f ingress/cluster-role-binding.yaml
	kubectl apply -f ingress/deployment.yaml

## Encryption and decryption of parameters
# Staging
KEY_ID=2791e2c4-dd09-41c6-ab0f-6c0d61c0dc32
encrypt-params:
	aws kms encrypt \
		--key-id $(KEY_ID) \
		--plaintext file://config.yaml \
		--query CiphertextBlob \
		--output text | base64 --decode $(IGNORE_FLAG) > encrypted/config.yaml.encrypted

	aws kms encrypt \
		--key-id $(KEY_ID) \
		--plaintext file://cloudformation/parameters-rds.json \
		--query CiphertextBlob \
		--output text | base64 --decode $(IGNORE_FLAG) > encrypted/parameters-rds.json.encrypted

	aws kms encrypt \
		--key-id $(KEY_ID) \
		--plaintext file://cloudformation/parameters-vpc.json \
		--query CiphertextBlob \
		--output text | base64 --decode $(IGNORE_FLAG) > encrypted/parameters-vpc.json.encrypted
