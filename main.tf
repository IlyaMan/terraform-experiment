provider "google" {
  project = "groovy-autumn-377820"
  region  = "us-central1"
  zone    = "us-central1-c"
}

resource "google_compute_network" "vpc_network" {
  name                    = "my-custom-mode-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "default" {
  name          = "my-custom-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
}

module "backend-1" {
  source = "./backend-module"
  name   = "backend-1"
  metadata = {
    web_page_content = "Hello, Group 1!"
  }
  network = google_compute_subnetwork.default.id
}

module "backend-2" {
  source = "./backend-module"
  name   = "backend-2"
  metadata = {
    web_page_content = "Hello, Group 2!"
  }
  network = google_compute_subnetwork.default.id
}


resource "google_compute_region_url_map" "url_map" {
  name            = "http-lb-map"
  default_service = module.backend-1.backend_service.id
  host_rule {
    hosts        = ["*"]
    path_matcher = "path-matcher"
  }
  path_matcher {
    name            = "path-matcher"
    default_service = module.backend-1.backend_service.id
    path_rule {
      paths   = ["/backend-1/*"]
      service = module.backend-1.backend_service.id
    }
    path_rule {
      paths   = ["/backend-2/*"]
      service = module.backend-1.backend_service.id
    }
  }
}

resource "google_compute_region_target_http_proxy" "tp" {
  name = "http-lb-proxy"

  url_map = google_compute_region_url_map.url_map.self_link
}

resource "google_compute_forwarding_rule" "lb" {
  name                  = "http-lb"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"

  target = google_compute_region_target_http_proxy.tp.self_link
}
