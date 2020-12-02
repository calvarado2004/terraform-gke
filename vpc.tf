variable "project_id" {
  description = "project id"
}

variable "region" {
  description = "region"
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# VPC
resource "google_compute_network" "vpc-gke" {
  name                    = "${var.cluster_name}-vpc"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.cluster_name}-subnet"
  region        = var.region
  network       = google_compute_network.vpc-gke.name
  ip_cidr_range = "172.35.0.0/24"

}

#Peering between OLD VMs vpc and GKE K8s vpc
resource "google_compute_network_peering" "to-vms-vpc" {
  name         = "to-vms-vpc-vpc-network"
  network      = google_compute_network.vpc-gke.id
  peer_network = "projects/sigma-scheduler-297405/global/networks/vms-vpc-network"
}

resource "google_compute_network_peering" "to-gke-cluster" {
  name         = "to-gke-cluster-vpc-network"
  network      = "projects/sigma-scheduler-297405/global/networks/vms-vpc-network"
  peer_network = google_compute_network.vpc-gke.id
}

output "region" {
  value       = var.region
  description = "region"
}

#Enable communication from GKE pods to external instances, networks and services outside the Cluster.
resource "google_compute_firewall" "gke-cluster-to-all-vms-on-network" {
  name    = "gke-cluster-k8s-to-all-vms-on-network"
  network = google_compute_network.vpc-portal.id

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "esp"
  }

  allow {
    protocol = "ah"
  }

  allow {
    protocol = "sctp"
  }

  source_ranges = ["10.96.0.0/14"]
}