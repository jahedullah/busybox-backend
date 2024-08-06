# Provider configuration
# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region  # Change this to your preferred region
}

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region

  initial_node_count = var.node_count

  node_config {
    machine_type = var.node_machine_type
  }
  # well, this removes the default node pool right immediate after the cluster creation
  remove_default_node_pool = true
  ## this disables the ability to features of kubernetes that are in alpha stage.
  enable_kubernetes_alpha = false
}

# Create a separately managed node pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  node_config {
    machine_type = var.node_machine_type
  }
}


# Configure Kubernetes provider
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.primary.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
}

# Kubernetes resources
resource "kubernetes_deployment" "backend" {
  metadata {
    name = "busybox-backend-deployment"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "busybox-backend"
      }
    }

    template {
      metadata {
        labels = {
          app = "busybox-backend"
        }
      }

      spec {
        container {
          image = "jahedulislam/busybox-backend:latest"
          name  = "busybox-backend"

          port {
            container_port = 8080
          }

          env {
            name = "DB_HOST"
            value_from {
              config_map_key_ref {
                name = "db-config"
                key  = "host"
              }
            }
          }

          env {
            name = "DB_NAME"
            value_from {
              config_map_key_ref {
                name = "db-config"
                key  = "dbName"
              }
            }
          }

          env {
            name = "DB_USERNAME"
            value_from {
              secret_key_ref {
                name = "mysql-secrets"
                key  = "username"
              }
            }
          }

          env {
            name = "DB_PASSWORD"
            value_from {
              secret_key_ref {
                name = "mysql-secrets"
                key  = "password"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "backend" {
  metadata {
    name = "busybox-backend-service"
  }

  spec {
    selector = {
      app = "busybox-backend"
    }

    port {
      port        = 8080
      target_port = 8080
      node_port   = 32500
    }

    type = "NodePort"
  }
}

resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "frontend-deployment"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "angular"
      }
    }

    template {
      metadata {
        labels = {
          app = "angular"
        }
      }

      spec {
        container {
          image = "jahedulislam/busybox-frontend:latest"
          name  = "angular"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name = "frontend-service"
  }

  spec {
    selector = {
      app = "angular"
    }

    port {
      port        = 80
      target_port = 80
      node_port   = 31000
    }

    type = "NodePort"
  }
}

resource "kubernetes_persistent_volume_claim" "mysql" {
  metadata {
    name = "mysql-pv-claim"
    labels = {
      app  = "mysql"
      tier = "database"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "mysql" {
  metadata {
    name = "mysql"
    labels = {
      app  = "mysql"
      tier = "database"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app  = "mysql"
        tier = "database"
      }
    }

    template {
      metadata {
        labels = {
          app  = "mysql"
          tier = "database"
        }
      }

      spec {
        container {
          image = "mysql:8.3.0"
          name  = "mysql"

          port {
            container_port = 3306
            name           = "mysql"
          }

          env {
            name = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = "mysql-secrets"
                key  = "password"
              }
            }
          }

          env {
            name = "MYSQL_DATABASE"
            value_from {
              config_map_key_ref {
                name = "db-config"
                key  = "dbName"
              }
            }
          }

          volume_mount {
            name       = "mysql-persistent-storage"
            mount_path = "/var/lib/mysql"
          }
        }

        volume {
          name = "mysql-persistent-storage"
          persistent_volume_claim {
            claim_name = "mysql-pv-claim"
          }
        }
      }
      #
      #       depends_on = [
      #         kubernetes_config_map.db_config,
      #         kubernetes_secret.mysql_secrets,
      #         kubernetes_persistent_volume_claim.mysql
      #       ]

    }
  }
}

resource "kubernetes_service" "mysql" {
  metadata {
    name = "mysql"
    labels = {
      app  = "mysql"
      tier = "database"
    }
  }

  spec {
    selector = {
      app  = "mysql"
      tier = "database"
    }

    port {
      port        = 3306
      target_port = 3306
    }

    cluster_ip = "None"
  }
}

resource "kubernetes_config_map" "db_config" {
  metadata {
    name = "db-config"
  }

  data = {
    host   = "mysql"
    dbName = "busyBox"
  }
}

resource "kubernetes_secret" "mysql_secrets" {
  metadata {
    name = "mysql-secrets"
  }

  data = {
    username = "root"
    password = "root"
  }

  type = "Opaque"
}

provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}

resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://helm.traefik.io/traefik"
  chart      = "traefik"
  version = "24.0.0"  # You can specify the version you want to use

  namespace        = "default"
  create_namespace = true

  set {
    name  = "ingressClass.enabled"
    value = "true"
  }

  set {
    name  = "ingressClass.isDefaultClass"
    value = "true"
  }

  depends_on = [google_container_node_pool.primary_nodes]
}

resource "kubernetes_ingress_v1" "busybox_ingress" {
  metadata {
    name = "busybox-ingress"
  }

  spec {
    ingress_class_name = "traefik"

    rule {
      host = "localhost"
      http {
        path {
          path      = "/busyBox"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.backend.metadata[0].name
              port {
                number = 8080
              }
            }
          }
        }

        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.frontend.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}