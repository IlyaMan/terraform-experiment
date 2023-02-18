#Terraform Config for HTTP Load Balancer with Autoscaler and Packer Config (Experimental)

This Terraform configuration is an experiment that creates an HTTP load balancer on Google Cloud Platform (GCP) that distributes incoming traffic between two backend groups. Each backend group consists of a group of instances that serve Nginx responses to incoming requests. The Nginx responses are configured via metadata in the Terraform configuration.

In addition, the backend groups are managed by an autoscaler that starts with one image and ramps up to three as demand increases. This allows for dynamic scaling of the backend groups based on incoming traffic.

This project also includes a Packer config for an Ubuntu image with Nginx installed and prepared. 

Please note that this project is intended for experimental and learning purposes and is not suitable for production use.