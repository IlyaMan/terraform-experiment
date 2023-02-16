variable "name" {}

variable "metadata" {}

variable "network" {}


resource "google_compute_http_health_check" "nginx" {
  name               = "nginx-http-health-check"
  request_path       = "/"
  port               = "80"
  check_interval_sec = 10
  timeout_sec        = 1
}

resource "google_compute_instance_template" "nginx-instance-template" {
  name           = "${var.name}-vm"
  machine_type   = "f1-micro"
  tags           = ["ssh", "http-server", "https-server"]
  can_ip_forward = true


  disk {
    source_image = "nginx-ubuntu-custom"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = var.network
  }

  metadata = var.metadata

  metadata_startup_script = <<-EOF
  #!/bin/bash
  WEB_PAGE_CONTENT=$(curl -H "Metadata-Flavor:Google" "http://metadata/computeMetadata/v1/instance/attributes/web_page_content")
  export NGINX_MESSAGE="$WEB_PAGE_CONTENT"
  envsubst < /etc/nginx/default_template.conf > /etc/nginx/default_template.conf.subst
  sudo mv /etc/nginx/default_template.conf.subst /etc/nginx/conf.d/default.conf
  service nginx restart
EOF
}

resource "google_compute_target_pool" "nginx-pool" {
  name = "${var.name}-pool"

  health_checks = [
    google_compute_http_health_check.nginx.self_link,
  ]
}

resource "google_compute_instance_group_manager" "nginx-igm" {
  name = "${var.name}-igm"

  version {
    instance_template = google_compute_instance_template.nginx-instance-template.id
    name              = "primary"
  }

  target_pools       = [google_compute_target_pool.nginx-pool.id]
  base_instance_name = "autoscaler-sample"
}

resource "google_compute_autoscaler" "nginx-autoscaler" {
  name   = "${var.name}-autoscaler"
  target = google_compute_instance_group_manager.nginx-igm.id
  autoscaling_policy {
    min_replicas    = 1
    max_replicas    = 3
    cooldown_period = 30
    cpu_utilization {
      target = 0.3 # Set low for testing purposes
    }
  }
}

resource "google_compute_backend_service" "backend_service" {
  name = "${var.name}-http-backend"

  backend {
    group = google_compute_instance_group_manager.nginx-igm.instance_group
  }

  health_checks = [
    google_compute_http_health_check.nginx.self_link,
  ]

  protocol = "HTTP"
}

output "backend_service" {
  value       = google_compute_backend_service.backend_service
  description = "Backend service."
}
