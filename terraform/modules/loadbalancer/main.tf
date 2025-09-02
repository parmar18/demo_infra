# Global IP stays the same
resource "google_compute_global_address" "lb_ip" {
  name = "search-app-ip"
}

# Health check
resource "google_compute_health_check" "app_check" {
  name = "search-app-hc"
  http_health_check {
    port         = 8080
    request_path = "/health"
  }
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}

# Backend service
resource "google_compute_backend_service" "backend" {
  name          = "search-backend"
  protocol      = "HTTP"
  port_name     = "http"
  timeout_sec   = 30
  health_checks = [google_compute_health_check.app_check.id]

  backend {
    group = var.instance_group
  }
}

# NEW SSL cert
resource "google_compute_managed_ssl_certificate" "cert_for" {
  name = "search-app-cert-for"

  managed {
    domains = ["hackforindia.com", "www.hackforindia.com"]
  }
}

# NEW URL map
resource "google_compute_url_map" "urlmap_new" {
  name            = "search-urlmap-new"
  default_service = google_compute_backend_service.backend.id
}

# NEW HTTP proxy
resource "google_compute_target_http_proxy" "http_proxy_new" {
  name    = "search-http-proxy-new"
  url_map = google_compute_url_map.urlmap_new.id
}

# NEW HTTPS proxy
resource "google_compute_target_https_proxy" "https_proxy_new" {
  name             = "search-https-proxy-new"
  ssl_certificates = [google_compute_managed_ssl_certificate.cert_for.id]
  url_map          = google_compute_url_map.urlmap_new.id
}

# Forwarding rule for HTTP (update to new proxy)
resource "google_compute_global_forwarding_rule" "http_rule" {
  name       = "search-http-rule"
  ip_address = google_compute_global_address.lb_ip.address
  port_range = "80"
  target     = google_compute_target_http_proxy.http_proxy_new.id
}

# Forwarding rule for HTTPS (update to new proxy)
resource "google_compute_global_forwarding_rule" "https_rule" {
  name       = "search-https-rule"
  ip_address = google_compute_global_address.lb_ip.address
  port_range = "443"
  target     = google_compute_target_https_proxy.https_proxy_new.id
}
