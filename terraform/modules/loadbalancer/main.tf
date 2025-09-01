# Global, anycast IP for the LB
resource "google_compute_global_address" "lb_ip" {
  name = "search-app-ip-http"
}

# Health check (LB→VM on app port)
resource "google_compute_health_check" "app_check" {
  name = "search-app-hc-http"
  http_health_check {
    port = 8080
    request_path = "/health"
  }
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2
}

# Backend service points at your MIG
resource "google_compute_backend_service" "backend" {
  name          = "search-backend-http"
  protocol      = "HTTP"
  port_name     = "http"
  timeout_sec   = 30
  health_checks = [google_compute_health_check.app_check.id]

  backend {
    group = var.instance_group
  }
}

# URL map (all paths → backend)
resource "google_compute_url_map" "urlmap" {
  name            = "search-urlmap-http"
  default_service = google_compute_backend_service.backend.id
}

# HTTP proxy (no TLS)
resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "search-http-proxy"
  url_map = google_compute_url_map.urlmap.id
}

# Entry point: port 80 on the global IP
resource "google_compute_global_forwarding_rule" "http_rule" {
  name       = "search-http-rule"
  ip_address = google_compute_global_address.lb_ip.address
  port_range = "80"
  target     = google_compute_target_http_proxy.http_proxy.id
}
