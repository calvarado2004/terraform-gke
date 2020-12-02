# Provision a GKE Cluster

This repo is a companion repo to the [Provision a GKE Cluster learn guide](https://learn.hashicorp.com/terraform/kubernetes/provision-gke-cluster), containing
Terraform configuration files to provision an GKE cluster on
GCP.


## Install and configure GCloud

First, install the [Google Cloud CLI](https://cloud.google.com/sdk/docs/quickstarts) 
and initialize it.

```shell
$ gcloud init
```

Once you've initialized gcloud (signed in, selected project), add your account 
to the Application Default Credentials (ADC). This will allow Terraform to access
these credentials to provision resources on GCloud.

```shell
$ gcloud auth application-default login
```

## Install Terraform on Ubuntu

You need to have at least terraform 0.12, below you will see the Terraform installation instructions for Ubuntu:

```shell
$ curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
$ sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
$ sudo apt-get update && sudo apt-get install terraform
```

## Initialize Terraform workspace and provision GKE Cluster

The most important file to check is `gke.tf`, which include the whole definition of this GKE Cluster.

But also check the `vpc.tf` file, which include the GCP network and the subnet that will be used to deploy this GKE Cluster.

```shell
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "google" (hashicorp/google) 3.13.0...
Terraform has been successfully initialized!
```

Check the current definition of the GKE Cluster and save the plan to a file:

```shell
$ terraform plan -out=gke-cluster.plan
```

Then, provision your GKE cluster by running `terraform apply` and using the plan file that you previously saved.

```shell
$ terraform apply "gke-cluster.plan"

# Output truncated...

Plan: 7 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

# Output truncated...

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

kubernetes_cluster_name = gke-cluster
region = us-east1-b
```

## Configure kubectl

To configure kubetcl, by running the following command. 

```shell
$ gcloud container clusters get-credentials gke-cluster --zone us-east1-b --project sigma-scheduler-297405

```

The
[Kubernetes Cluster Name](https://github.com/hashicorp/learn-terraform-provision-gke-cluster/blob/master/gke.tf#L63)
and [Region](https://github.com/hashicorp/learn-terraform-provision-gke-cluster/blob/master/vpc.tf#L29)
 correspond to the resources spun up by Terraform.
