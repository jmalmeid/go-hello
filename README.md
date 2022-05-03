# Simple time application
 
1) Create an application on Go/Python that serve HTTP requests at the next routes:
- 8080:/
- 8080:/health
 
/ - returns local time in New-York, Berlin, Tokyo in HTML format
/health - return status code 200, in JSON format
 
2) Dockerize your app.
 
3) Provision your infra using Terraform:
- VPC
- Subnets
- SGs
- Routing tables
- EKS cluster
- ECR
 
4) Create and deploy Helm3 chart for your application.
 
5) Ensure that you have an access to the application endpoint externally
 
6) Provide an external http link

## Solution

### Create Infra
<p> cd terraform
<p> terraform init
<p> terraform plan
<p> terraform apply

### Build
<p> cd ..
<p> docker build . --tag #ID#.dkr.ecr.eu-central-1.amazonaws.com/go-hello-ecr:0.1.0
<p> docker push #ID#.dkr.ecr.eu-central-1.amazonaws.com/go-hello-ecr:0.1.0

### Install
<p> aws eks update-kubeconfig --name go-hello-eks --alias go-hello-eks
<p> helm install go-hello -n default --set image.repository=#ID#.dkr.ecr.eu-central-1.amazonaws.com/go-hello-ecr

### Get external url
<p> kubectl get svc go-hello -n default
