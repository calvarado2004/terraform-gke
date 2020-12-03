variable "gke_username" {
  default     = ""
  description = "gke username"
}

variable "gke_password" {
  default     = ""
  description = "gke password"
}

variable "cluster_name" {
  default = "gke-cluster"
  description = "cluster name"
}

variable "zone" {
  default = "us-east1-b"
  description = "cluster zone"
}

#Your pods will have an IP address from this CIDR
variable "cluster_ipv4_cidr" {
  default = "10.96.0.0/14"
  description = "internal cidr for pods"
}

#Your Kubernetes services will have an IP from this range
variable "services_ipv4_cidr_block" {
  default = "10.99.240.0/20"
  description = "nternal range for the kubernetes services"
}

# GKE cluster
resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone

  remove_default_node_pool = true
  initial_node_count       = 1

  network                  = google_compute_network.vpc-gke.name
  subnetwork               = google_compute_subnetwork.subnet.name

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.cluster_ipv4_cidr
    services_ipv4_cidr_block = var.services_ipv4_cidr_block
  }
  
  min_master_version = "1.17.13-gke.2001"	

  master_auth {
    username = var.gke_username
    password = var.gke_password

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  cluster_autoscaling {
    enabled = false
  }

}

# Separately Managed Master Pool
resource "google_container_node_pool" "master-pool" {
  name       = "master-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  management {
    auto_repair  = true
    auto_upgrade = false
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]

    labels = {
      es_type = "master_nodes"
    }
    # 6 CPUs, 12GB of RAM
    preemptible  = false
    image_type   = "ubuntu_containerd"
    machine_type = "custom-6-12288"
    local_ssd_count = 0
    disk_size_gb    = 20
    disk_type       = "pd-standard"
    tags         = ["gke-node", "${var.cluster_name}-master"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

# Separately Managed Data Pool
resource "google_container_node_pool" "data-pool" {
  name       = "data-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = 2

  autoscaling {
    min_node_count = 2
    max_node_count = 4
  }

  management {
    auto_repair = true
    auto_upgrade = false
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]

    labels = {
      es_type = "data_nodes"
    }

    # 14 CPUs, 41GB of RAM
    preemptible  = false
    image_type   = "ubuntu_containerd"
    machine_type = "custom-14-41984"
    local_ssd_count = 0
    disk_size_gb    = 20
    disk_type       = "pd-standard"

    tags         = ["gke-node", "${var.cluster_name}-data"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

# Separately Managed Coordinator Pool
resource "google_container_node_pool" "coord-pool" {
  name       = "coord-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  management {
    auto_repair  = true
    auto_upgrade = false
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]

    labels = {
      es_type = "coordinator_nodes"
    }

    # 6 CPUs, 22GB of RAM
    preemptible  = false
    image_type   = "ubuntu_containerd"
    machine_type = "custom-6-22528"
    local_ssd_count = 0
    disk_size_gb    = 20
    disk_type       = "pd-standard"
    tags         = ["gke-node", "${var.cluster_name}-coord"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

# Separately Managed Kibana Pool
resource "google_container_node_pool" "kibana-pool" {
  name       = "kibana-pool"
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  node_count = 1

  autoscaling {
    min_node_count = 1
    max_node_count = 2
  }

  management {
    auto_repair  = true
    auto_upgrade = false
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]

    labels = {
      es_type = "kibana_nodes"
    }

    # 4 CPUs, 13GB of RAM
    preemptible  = false
    image_type   = "ubuntu_containerd"
    machine_type = "custom-4-13312"
    local_ssd_count = 0
    disk_size_gb    = 20
    disk_type       = "pd-standard"
    tags         = ["gke-node", "${var.cluster_name}-kibana"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}

output "kubernetes_cluster_name" {
  value       = google_container_cluster.primary.name
  description = "GKE Cluster Name"
}
