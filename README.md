##  Nomad Failover Demo

### Instructions

- Start up the VM

`vagrant up`

Once complete, Nomad should be available at http://localhost:4646
Configure your local Nomad client with the following command
`NOMAD_ADDR=http://127.0.0.1:4646`

The services API is available at http://localhost:4646/services

- Start the backend service
`nomad job run jobs/backend_service.hcl`

- Start the traefik load balancer
`nomad job run jobs/wordpress`

The dashboard should now be available at http://localhost:8080/dashboard/

