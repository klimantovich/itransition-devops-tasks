terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {
  host = "ssh://${var.ec2_user_name}@${module.dev_ec2.public_ip}:22"
  ssh_opts = [
    "-i", "${var.path_to_local_key}",
    "-o", "StrictHostKeyChecking=no",
    "-o", "UserKnownHostsFile=/dev/null"
  ]
}

# -------
# Images
# -------
resource "docker_image" "db" {
  name = "${var.repository}/${var.db_image}"
}
resource "docker_image" "front" {
  name = "${var.repository}/${var.frontend_image}"
}
resource "docker_image" "lb" {
  name = "${var.repository}/${var.loadbalancer_image}"
}

#----------------------
# Network
#----------------------
resource "docker_network" "frontend" {
  name = "frontend"
}
resource "docker_network" "backend" {
  name = "backend"
}

#----------------------
# Volume
#----------------------
resource "docker_volume" "db_data" {
}

#----------------------
# Containers
#----------------------
resource "docker_container" "db" {
  name  = var.db_container_name
  image = docker_image.db.image_id
  env = [
    "MYSQL_DATABASE=${var.mysql_database}",
    "MYSQL_ROOT_PASSWORD=${var.mysql_password}"
  ]
  restart = var.common_restart_policy
  networks_advanced {
    name = docker_network.backend.name
  }
  volumes {
    container_path = "/var/lib/mysql"
    volume_name    = docker_volume.db_data.name
  }
}

resource "docker_container" "front" {
  name  = var.front_container_name
  image = docker_image.front.image_id
  env = [
    "DB_NAME=${var.mysql_database}",
    "DB_USER=${var.mysql_user}",
    "DB_PASSWORD=${var.mysql_password}",
    "DB_HOST=${var.db_container_name}"
  ]
  restart = var.common_restart_policy
  networks_advanced {
    name = docker_network.backend.name
  }
}

resource "docker_container" "lb" {
  name    = var.lb_container_name
  image   = docker_image.lb.image_id
  restart = var.common_restart_policy
  networks_advanced {
    name = docker_network.frontend.name
  }
  networks_advanced {
    name = docker_network.backend.name
  }
  ports {
    internal = var.lb_internal_port
    external = var.lb_external_port
  }
}
