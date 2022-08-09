job "backend_service" {

    datacenters = ["dc1"]
    type        = "service"

    constraint {
        attribute = "${attr.cpu.arch}"
        value = "amd64"
    }

    group "backend_service" {
        count = 2

        scaling {
            enabled = true
            min     = 1
            max     = 3
        }

        network {
            port "http" {
                to = 8080
            }
        }

        restart {
            attempts = 10
            interval = "5m"
            delay    = "25s"
            mode     = "delay"
        }

        task "backend_service" {
            driver = "docker"

            env = {
            }

            config {
                image = "hashicorp/http-echo"
                args  = ["-listen", ":8080", "-text", "Backend service #${NOMAD_ALLOC_INDEX}"]
                ports = ["http"]
            }

            resources {
                cpu    = 100
                memory = 64
            }

            service {
                provider = "nomad"
                
                name = "backend-service"
                port = "http"  
                tags = ["instance-id-${NOMAD_ALLOC_INDEX}"]      
            }
        }
    }
}