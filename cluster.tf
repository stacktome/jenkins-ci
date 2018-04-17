resource "google_container_cluster" "jenkins" {
  name = "jenkins"
  zone = "europe-west1-d"
  initial_node_count = "2"
  enable_legacy_abac = "true"

  // https://cloud.google.com/compute/docs/machine-types
  node_config {
    machine_type = "n1-standard-2"
    preemptible = false

    // monitoring_service = "none"

    oauth_scopes = [
      "compute-rw",
      "storage-rw",     // this is needed for accessing container registry
      "logging-write",
      "monitoring",
      "cloud-platform"
    ]
  }
}

output "jenkins-cluster-instance-group" {
  value = "${basename(google_container_cluster.jenkins.instance_group_urls.0)}"
}

resource "google_compute_disk" "jenkins-volume" {
  name = "jenkins-volume"
  size = 100
  zone = "europe-west1-d"
  image = "projects/fuzzylabs-1314/global/images/image-jenkins-home-060218"
}

resource "google_compute_global_address" "jenkins" {
  name = "jenkins"
}

output "jenkins-ip" {
  value = "${google_compute_global_address.jenkins.address}"
}

resource "google_compute_global_forwarding_rule" "jenkins" {
  name       = "jenkins-forwarding-rule"
  target     = "${google_compute_target_https_proxy.jenkins.self_link}"
  port_range = "443"
  ip_address = "${google_compute_global_address.jenkins.address}"
}

resource "google_compute_target_https_proxy" "jenkins" {
  name             = "jenkins"
  url_map          = "${google_compute_url_map.jenkins.self_link}"
  ssl_certificates = ["projects/stacktome-prod/global/sslCertificates/stacktome-com"]
}

resource "google_compute_url_map" "jenkins" {
  name            = "jenkins-url-map"
  default_service = "${google_compute_backend_service.jenkins.self_link}"
}

resource "google_compute_backend_service" "jenkins" {
  name        = "jenkins-backend"
  port_name   = "jenkins"
  protocol    = "HTTP"
  timeout_sec = 30
  connection_draining_timeout_sec = 0

  backend {
    group = "${google_container_cluster.jenkins.instance_group_urls.0}"
    balancing_mode = "RATE"
    max_rate_per_instance = 1
  }

  iap {
    oauth2_client_id = "412045756898-18uiup10oiuvqspou0heo0bisbdmaim9.apps.googleusercontent.com"
    oauth2_client_secret = "25abc2f68ed1aa5e498348791c25ae94042815059276cb7351c37e63459b6302"
  }

  health_checks = ["${google_compute_health_check.jenkins.self_link}"]
}

resource "google_compute_health_check" "jenkins" {
  name = "jenkins-frontend-health-check"

  check_interval_sec = 1
  timeout_sec        = 1

  http_health_check {
    request_path = "/login"
    port = 30000
  }
}

resource "google_compute_firewall" "jenkins" {
  name    = "jenkins-health-check-firewall-rule"
  network = "default"

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]

  allow {
    protocol = "tcp"
    ports    = ["30000"]
  }
}

//--------- nexus - dependency repo -------------
resource "google_compute_global_address" "nexus" {
  name = "nexus"
}

output "nexus-ip" {
  value = "${google_compute_global_address.nexus.address}"
}

resource "google_compute_global_forwarding_rule" "nexus" {
  name       = "nexus-forwarding-rule"
  target     = "${google_compute_target_https_proxy.nexus.self_link}"
  port_range = "443"
  ip_address = "${google_compute_global_address.nexus.address}"
}

resource "google_compute_target_https_proxy" "nexus" {
  name             = "nexus"
  url_map          = "${google_compute_url_map.nexus.self_link}"
  ssl_certificates = ["projects/stacktome-prod/global/sslCertificates/stacktome-com"]
}

resource "google_compute_url_map" "nexus" {
  name            = "nexus-url-map"
  default_service = "${google_compute_backend_service.nexus.self_link}"
}

resource "google_compute_backend_service" "nexus" {
  name        = "nexus-backend"
  port_name   = "nexus"
  protocol    = "HTTP"
  timeout_sec = 30
  connection_draining_timeout_sec = 0

  backend {
    group = "${google_container_cluster.jenkins.instance_group_urls.0}"
    balancing_mode = "RATE"
    max_rate_per_instance = 1
  }

  health_checks = ["${google_compute_health_check.nexus.self_link}"]
}

resource "google_compute_health_check" "nexus" {
  name = "nexus-frontend-health-check"

  check_interval_sec = 1
  timeout_sec        = 1

  http_health_check {
    request_path = "/"
    port = 30001
  }
}

resource "google_compute_firewall" "nexus" {
  name    = "nexus-health-check-firewall-rule"
  network = "default"

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]

  allow {
    protocol = "tcp"
    ports    = ["30001"]
  }
}
