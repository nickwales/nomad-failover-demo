job "traefik" {
    datacenters = ["dc1"]

    type = "system"

    group "traefik" {

        network {
            mode = "host"
            port "http" { 
              static = 80
              to = 80
            }
            port "api" {
              static = 8080
              to = 8080
            }
            port "ping" {
              static = 8082
              to = 8082
            }
            port "metrics" {
              static = 8083
              to = 8083
            }
        }

    task "traefik" {
      driver = "docker"

      config {
        image = "traefik"
        args = ["--configFile=local/traefik.yaml"]
        ports = ["http", "api", "ping", "metrics"]
      }

      service {
        provider = "nomad"
        name = "traefik-admin"
        port = "api"
      }

      template {
        destination = "local/traefik.yaml"
        data = <<DATA
api:
  insecure: true
  dashboard: true
providers:
  file:
    filename: /local/traefik_dynamic.yaml
entryPoints:
  http:
    address: ":80"
  ping:
    address: ":8082"
  metrics:
    address: ":8083"
metrics:
  prometheus:
    entrypoint: "metrics"
DATA
      }

      template {
        destination = "local/traefik_dynamic.yaml"
        data = <<DATA
http:
  routers:
    backend-service:
      rule: "Path(`/`)"
      service: backend-service      
  services:
    backend-service:
      failover:
        service: main
        fallback: backup
    main:
      loadBalancer:
        healthCheck:
          path: /
          interval: 10s
          timeout: 3s
        servers:
{{- range nomadService "instance-id-1.backend-service" }}
        - url: http://{{ .Address }}:{{ .Port }}/
{{- end }}
    backup:
      loadBalancer:
        healthCheck:
          path: /
          interval: 10s
          timeout: 3s      
        servers:
{{- range nomadService "instance-id-0.backend-service" }}
        - url: http://{{ .Address }}:{{ .Port }}/
{{- end }}
DATA        
      }
      service {
        provider = "nomad"
        name = "traefik"
        tags =["slb", "traefik", "demo"]
      }

      resources {
        cpu    = 250
        memory = 100
      }  
    }
  }
}
