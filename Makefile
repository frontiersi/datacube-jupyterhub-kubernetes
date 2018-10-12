## Initial Setup
# Create the cluster

create-cluster:
	kops create cluster \
		--zones us-west-2a,us-west-2b,us-west-2c opendatacube.staging.frontiersi.io \
		--ssh-public-key ~/.ssh/frontiersi.pub \
		--master-size t2.micro \
		--node-size t2.large \
		--node-count 2 \
		--yes

# Note taht the cluster needs this added to it after it's deployed with:
# `kops edit cluster` and `kops update cluster --yes`
#   additionalPolicies:
#     node: |
#       [
#         {
#           "Effect": "Allow",
#           "Action": ["S3:ListBucket"],
#           "Resource": ["arn:aws:s3:::landsat-pds","arn:aws:s3:::dea-public-data","arn:aws:s3:::dea-public-data-dev"]
#         },
#         {
#           "Effect": "Allow",
#           "Action": ["S3:GetObject"],
#           "Resource": ["arn:aws:s3:::landsat-pds/*","arn:aws:s3:::dea-public-data/*","arn:aws:s3:::dea-public-data-dev/*"]
#         }
#       ]

validate:
	kops validate cluster

## Dashboard components
# This is optional, but is quite nice
deploy-dashboard:
	kubectl create -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/influxdb.yaml
	kubectl create -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/grafana.yaml
	kubectl create -f https://raw.githubusercontent.com/kubernetes/heapster/master/deploy/kube-config/influxdb/heapster.yaml
	kubectl create -f https://raw.githubusercontent.com/kubernetes/kops/master/addons/kubernetes-dashboard/v1.8.3.yaml

dashboard-admin:
	kubectl create -f dashboard/dashboard-admin.yaml

# And this enables you to access the dashboard securely.
proxy:
	open http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
	kubectl proxy

## JupyterHub
# https://docs.helm.sh/using_helm/#securing-your-helm-installation
helm-all: init-helm init-helm-rbac

init-helm:
	helm init

init-helm-rbac:
	kubectl create -f rbac-conf.yaml
	helm init --service-account tiller
	kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
	kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

repo-add:
	helm repo add jupyterhub \
		https://jupyterhub.github.io/helm-chart/
	
repo-update:
	helm repo update

install-jupyterhub:
	helm upgrade --install odchub jupyterhub/jupyterhub --namespace odchub --version 0.7.0 --values config.yaml

update-jupyterhub:
	helm upgrade odchub jupyterhub/jupyterhub --values config.yaml

get-deployment:
	kubectl --namespace=odchub get deployment

## AWS Infrastructure ##
create-rds:
	aws cloudformation create-stack \
		--region us-west-2 \
		--stack-name odc-kube-jupyterhub-rds \
		--template-body file://cloudformation//rds.yaml \
		--parameter file://cloudformation//parameters-rds.json \
		--tags Key=app,Value=opendatacube-jupyterhub \
		--capabilities CAPABILITY_NAMED_IAM

update-rds:
	aws cloudformation update-stack \
		--region us-west-2 \
		--stack-name odc-kube-jupyterhub-rds \
		--template-body file://cloudformation//rds.yaml \
		--parameter file://cloudformation//parameters-rds.json \
		--tags Key=app,Value=odc-jupyterhub \
		--capabilities CAPABILITY_NAMED_IAM
		
create-indexer:
	aws cloudformation create-stack \
		--region us-west-2 \
		--stack-name odc-kube-jupyterhub-indexer \
		--template-body file://cloudformation//indexer.yaml \
		--parameter file://cloudformation//parameters-indexer.json \
		--tags Key=app,Value=opendatacube-jupyterhub \
		--capabilities CAPABILITY_NAMED_IAM
		
update-indexer:
	aws cloudformation update-stack \
		--region us-west-2 \
		--stack-name odc-kube-jupyterhub-indexer \
		--template-body file://cloudformation//indexer.yaml \
		--parameter file://cloudformation//parameters-indexer.json \
		--tags Key=app,Value=opendatacube-jupyterhub \
		--capabilities CAPABILITY_NAMED_IAM

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
