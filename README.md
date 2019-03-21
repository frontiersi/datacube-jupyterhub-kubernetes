

# How to deploy an ODC JupyterHub environment running on a Kubernetes cluster in AWS
This repository has all the code required to create your own Kubernetes cluster with JupterHub running in an AWS environment.

There are four steps required to create the AWS infrastructure, deploy a Kubernetes cluster and finally to deploy JupyterHub into the cluster.

## Step 1 - Run Terraform to create the required AWS infrastructure 

In the first step we create the following AWS infrastruture with Terraform:
- VPC
- Internet gateway
- 2 public subnets with routes to the internet gateway
- 2 private subnets with NAT gateways with routes to the public subnets
- IAM instance profiles to be used for the master and nodes, as well as roles to be used for indexing and jupyter pods
- A postgres RDS instance to store the ODC's metadata index
- An S3 bucket to hold the Kubernetes state store.

### 1.1 Download and configure required tools
This step requires you have the **AWS CLI** and **Terraform** to be installed:
 - AWS CLI:
   - Download: https://aws.amazon.com/cli/
   - How to configure: https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html
 - Terraform:
   - Download: https://www.terraform.io/downloads.html
   - How to use: https://www.terraform.io/intro/examples/index.html

### 1.2 Clone repo to your environment
Now that you have the AWS Cli and Terraform installed please clone this repo into your environment.
```Shell
git clone https://github.com/frontiersi/datacube-jupyterhub-kubernetes.git
```
### 1.3 Variables

Familiarise yourself with the below variables that are located in the **vars.tfvars** file which you can change to suit your environment:

| Variable               | Example                        | Notes                                                                              |
| -----------------------|--------------------------------|------------------------------------------------------------------------------------|
| vpc_cidr               | 10.1.0.0/16                    | What VPC CIDR to use.            |
| public_subnet_cidr1    | 10.1.1.0/24                    | This is allocating 254 addresses for public subnet 1 which is plenty for us.       |
| public_subnet_cidr2    | 10.1.2.0/24                    | Make sure your subnets do not overlap.                                             |
| private_subnet_cidr1   | 10.1.3.0/24                    |                                                                                    |
| private_subnet_cidr2   | 10.1.4.0/24                    |                                                                                    |
| region                 | ap-southeast-2                 | Choose what region to deploy the resources.                                        |
| public_az1             | ap-southeast-2a                | Choose what availabilty zone for each subnet.                                      |
| public_az2             | ap-southeast-2b                | Good practice to spread your subnets across Availability zones |
| private_az1            | ap-southeast-2a                |                                                                 |
| private_az2            | ap-southeast-2b                |                                                                                    |
| db_instance_type       | db.t2.medium                   | Choose what size DB instance you want.                                                 |
| db_instance_size       | 20                             | Choose how much storage for your database.                                           |
| node_count             | 2                              | Choose how many Kubernetes nodes you want.                                         |
| node_size              | t2.medium                      | Choose the type of those nodes.                                                    |
| master_count           | 1                              | Amount of Kubernetes masters you want. Needs to be an odd number so a consensus can be made.  |
| master_size            | t2.micro                       | Choose the size of the master    


Terraform will prompt you for these variables:

| Variable               | Example                        | Notes                                                                              |
| -----------------------|--------------------------------|------------------------------------------------------------------------------------|
| name                   | sample-odc-cluster             | The name of your cluster. Only use letters, hyphens, or digits (0-9)               |
| domain                 | test.your-domain.io            | Domain to use. If you want a local cluster use. k8s.local.                         |
| db_name                | dbname                         | Must be alphanumeric characters, underscores, or digits (0-9).                       |
| db_username            | dbusername                     | Must contain 1 to 63 alphanumeric characters. First character must be a letter.    |
| db_password            | password                       | Must contain 8 to 128 characters.                                                  |
| kubernetes_state_store | sample-odc-cluster-state-store-your-account-name | S3 bucket to use to store the Kubernetes state store. S3 two s3 buckets cannot be named the same so make yours unique.|

### 1.4 Run terraform to create your infrastructure

Now run the below commands to create the base infrastructure:
```Shell
cd infrastructure/
terraform init
terraform workspace new sample-odc-cluster
terraform apply -var-file="vars.tfvars"
```
Alernatively you can enter them with the -var parameter in one go:
```Shell
terraform apply -var "name=sample-odc-cluster" -var "domain=test.your-domain.io" -var "kubernetes_state_store=sample-odc-cluster-state-store" -var "vpc_cidr=10.1.0.0/16" -var "public_subnet_cidr1=10.1.1.0/24" -var "public_subnet_cidr2=10.1.2.0/24" -var "private_subnet_cidr1=10.1.3.0/24" -var "private_subnet_cidr2=10.1.4.0/24" -var "region=ap-southeast-2" -var "public_az1=ap-southeast-2a" -var "public_az2=ap-southeast-2b" -var "private_az1=ap-southeast-2a" -var "private_az2=ap-southeast-2b" -var "db_instance_type=db.t2.medium" -var "db_instance_size=20" -var "db_name=sampleodccluster" -var "db_username=master" -var "db_password=foobartest" -var "db_instance_type=db.t2.medium" -var "db_instance_size=20" -var "node_count=2" -var "node_size=t2.medium" -var "master_count=1" -var "master_size=t2.micro"
```

This will create all the base infrastructure which Kubernetes will run off. Can take up to **10 minutes** for all the resources to be created.

## Step 2 - Create the Kubernetes cluster
Now you have the AWS infrastructure in place you can create the Kubernetes cluster. 

### 2.1 Download required tools
First you need the kubernetes management tools called **kubectl** and **KOPS**:
- Kubectl:
  - Download and setup: https://kubernetes.io/docs/tasks/tools/install-kubectl/
- KOPS:
  - Download and setup: https://github.com/kubernetes/kops#installing


### 2.2 Create kubernetes cluster

To do this run these lines of code. 

```Shell
cd infrastructure/
# Set the clustername and state store variables
cluster_name=$(terraform output cluster_name)
state_store=$(terraform output state_store)
export KOPS_STATE_STORE=$state_store

# Generate the kubernetes cluster config file
terraform output cluster-config > cluster.yaml

# Use kops to create the cluster
kops create -f cluster.yaml

# Specify the location of a public key to use to be able to access your master and nodes
kops create secret --name $cluster_name sshpublickey admin -i ~/.ssh/id_rsa.pub

# Run the update cluster command. The lifecyle overrides are to enable the use of our pre-defined IAM roles and not use Kubernetes to create new IAM roles
kops update cluster --name=$cluster_name --lifecycle-overrides IAMRole=ExistsAndWarnIfChanges,IAMRolePolicy=ExistsAndWarnIfChanges,IAMInstanceProfileRole=ExistsAndWarnIfChanges --yes
```
This can take up to **15 minutes** for the cluster to create. Check the status of the cluster with the following command:
```Shell
kops validate cluster
```
**Wait until the you see your cluster is ready before the next step.**
```Shell
Your cluster  sample-odc-cluster.test.your-domain.io is ready
```

## Step 3 - Deploy Helm manager
We use the Helm package manager to install the required applications ontop of the kubernetes cluster.

### 3.1 Download required tool
This step requires you have **Helm** installed
- Helm:
  - Download: https://github.com/helm/helm#install

### 3.2 Configure Helm

Run these commands to install Helm on your kubernetes cluster:

```Shell
# Go to infrastructure Directory
cd infrastructure

# Get the clustername details
cluster_name=$(terraform output cluster_name)
state_store=$(terraform output state_store)

# Make sure kops and kubectl details are in correctly
export KOPS_STATE_STORE=$state_store
kubectl config use-context $cluster_name

# For Helm to work you need to create an account and pod for the helm tiller, commands to do that.
kubectl create serviceaccount --namespace kube-system tiller
kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller
```

It can take up to 5 minutess for Helm to be deployed into the cluster.

## Step 4 - Deploy Pod Based Security and JupyterHub

### 4.1 Deploy Kube2IAM

This step is to deploy pod based security Kube2IAM: https://github.com/jtblin/kube2iam#kube2iam.
This allows you to control what aws access your kubernetes master, nodes and containers have.

```Shell
# Go to the infrastructure Directory
cd infrastructure
# Get the clustername details
cluster_name=$(terraform output cluster_name)
state_store=$(terraform output state_store)
account_id=$(terraform output account_id)
domain=$(terraform output domain)
db_hostname=$(terraform output db_hostname)

# Make sure kops and kubectl details are in correctly
export KOPS_STATE_STORE=$state_store
kubectl config use-context $cluster_name

# Installing kube2iam for role based pod control
helm install stable/kube2iam --name kube2iam --namespace kube-system --set=extraArgs.base-role-arn=arn:aws:iam::$account_id:role/,extraArgs.default-role=kube2iam-default,host.iptables=true,rbac.create=true,verbose=true,host.interface=cali+
```

### 4.2 Deploy JupyterHub

Next step is to install jupyterhub. See refernece here: https://zero-to-jupyterhub.readthedocs.io/en/stable/setup-jupyterhub.html

First add the jupterhub helm repo
```Shell
helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
helm repo update
```

Next to deploy juypterhub. To do this you need to define variables either in a jupyterhub/config.yaml file or using the --set parameter

| Variable                        | Example  | Notes         |
| --------------------------------| -----------------------------------------------| ------- |
| proxy.secretToken               | hex32 number                                   | Run "openssl rand -hex 32" to generate your own" |
| https.hosts                     | juypter.sample-odc-cluster.test.your-domain.io | This is the domain that will directed to the jupyerhub load balancer.      |
| https.letsencrypt | systems@test.your-domain.io | email address for getting a ssl cert | 
| singleuser.extraEnv.DB_DATABASE | dbname | The db name you specified in step 1 |
| singleuser.extraEnv.DB_HOSTNAME | db_hostname=$(terraform output db_hostname) | This is generated as an output from Terraform |
| singleuser.extraEnv.DB_USERNAME | dbusername | The db username you specified in step 1 |
| singleuser.extraEnv.DB_PASSWORD | password | The db password you specified in step 1 | 

Run the following commands to deploy jupyterhub. Update the below values with the correct values for your environment making changes to the variables for your environment:
```Shell
# Generate a random token required for Jupyterhub
token="$(openssl rand -hex 32)"

# Now deploy JupyterHub
helm upgrade --install odchub jupyterhub/jupyterhub \
--namespace odchub --version 0.7.0 --debug \
--values ../jupyterhub/config.yaml \
--set proxy.secretToken=$token \
--set https.hosts=<enter a hostname that you own here, for example, jupyterhub.example.com> \
--set https.letsencrypt.contactEmail=<enter you email here> \
--set singleuser.extraEnv.DB_DATABASE=<enter you database name specified in step 1.4> \
--set singleuser.extraEnv.DB_HOSTNAME=$db_hostname \
--set singleuser.extraEnv.DB_USERNAME=<enter you database username specified in step 1.4> \
--set singleuser.extraEnv.DB_PASSWORD=<enter you database password specified in step 1.4>
```

Lastly manaully add a Route 53 record to match the https.hosts variable you defined pointing at the external-ip from this command
```Shell
kubectl --namespace=odchub get svc proxy-public --output=wide
```
Log into your AWS console and add a route 53 record with the CNAME pointing at the external-ip from the above command.

You should then be able to login at the url you provided, for example: https://juypterhub.example.com

# How to destroy your environment
When you want to remove your environment you need to remove the KOPS resources first followed by the Terraform resources. This is because Terraform will not be able to delete the subnets or vpc without the KOPS resources being removed first.

## Step 1 - Delete the kubernetes cluster
KOPS creates master and node servers as well as loadbalancers and autoscaling groups. You need to delete these via KOPS first before you can remove all the aws infrastructure.
To do this enter the following commnad:
```
kops delete cluster $cluster_name --yes
```
This will take a couple of minutes

## Step 2 - Remove your AWS infrastructure

You can remove your aws infrastruture with the following commands:
```
cd infrastructure
terraform destroy -var-file="vars.tfvars"
```
* This will prompt you for the some details but you can put dummy answers as for a destroy its not important.

This will take around 10 minutes to remove all the resources.

If you get any errors from Terraform, check what resource is not getting removed. You can then log into the AWS console and try manaully removing it. This will give you a more detailed error. Usually a dependant resource was not deleted, for example maybe KOPS delete cluster was not run and you need to remove all those resources. Another example is you have manually spun up a server or database in the VPC. These need to be deleted before terraform can remove the VPC or subnets.

Once you have removed all the dependant resources you can run terraform delete again.