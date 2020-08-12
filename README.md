# Wordpress ECS Terraform

This is an example for a DevOps test that I had taken.

Using an automation tool of your choice (eg. Ansible, Puppet, Chef, Terraform or a suitable combination thereof), produce the necessary manifests to deploy a basic web application into any cloud provider.

The service should be logically separated into 3 distinct areas:

1. A load balancer.
2. The software logic responsible for serving responding to HTTP requests.
3. A persistence backend.

## Solution

This is done all through terraform. It should not be run in production especially since passwords are hardcoded, and should only be used for example purposes.

This will launch an ECS Cluster, that deploys a wordpress docker container, and also an RDS database as a backend.

## How to spin up

Ensure you have AWS credentials in your device.
`terraform init && terraform apply`

Terraform will output the URL after the apply is complete, copy it into the browser and wordpress will load up for you to set up.

```bash
Outputs:

loadbalancer_url = wp-lb-1272703147.eu-west-2.elb.amazonaws.com
```
