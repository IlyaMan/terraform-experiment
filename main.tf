provider "google" {
  project     = "groovy-autumn-377820"
  region      = "us-central1"
  zone        = "us-central1-c"
}

resource "google_compute_instance" "example" {
  name         = "example-instance"
  machine_type = "f1-micro"
  zone         = "us-central1-c"

  metadata = {
    web_page_content = "Hello, Group 1!"
  }

  boot_disk {
    initialize_params {
      image = "nginx-ubuntu-custom"
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = <<-EOF
  #!/bin/bash
  WEB_PAGE_CONTENT=$(curl -H "Metadata-Flavor:Google" "http://metadata/computeMetadata/v1/instance/attributes/web_page_content")
  export NGINX_MESSAGE="$WEB_PAGE_CONTENT"
  envsubst < /etc/nginx/default_template.conf > /etc/nginx/default_template.conf.subst
  sudo mv /etc/nginx/default_template.conf.subst /etc/nginx/conf.d/default.conf
  service nginx restart
EOF
}

#resource "google_compute_network" "vpc_network" {
#  name                    = "my-custom-mode-network"
#  auto_create_subnetworks = false
#  mtu                     = 1460
#}
#
#resource "google_compute_subnetwork" "default" {
#  name          = "my-custom-subnet"
#  ip_cidr_range = "10.0.1.0/24"
#  region        = "us-central1-c"
#  network       = google_compute_network.vpc_network.id
#}
#
#resource "google_compute_instance_template" "custom-nginx" {
#  name         = "nginx-vm"
#  machine_type = "f1-micro"
#  tags         = ["ssh","http-server","https-server"]
#  can_ip_forward = true
#
#
#  disk {
#    source_image = "nginx-ubuntu-custom"
#    auto_delete = true
#    boot = true
#  }
#
#  network_interface {
#    subnetwork = google_compute_subnetwork.default.id
#  }
#  metadata = {
#    web_page_content = "Hello from group 1"
#  }
#
#  metadata_startup_script = "export NGINX_MESSAGE='{{ metadata[\"web_page_content\"] }}'\n"
#
#}
#
