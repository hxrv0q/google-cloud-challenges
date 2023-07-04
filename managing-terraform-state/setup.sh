#!/usr/bin/sh

docker run --name hashicorp-learn --detach --publish 8080:80 nginx:latest

docker ps

git clone https://github.com/hashicorp/learn-terraform-import.git

cd learn-terraform-import

terraform init

sed -i 's/host = ".*"/#&/' main.tf

echo "resource "docker_container" "web" {}" >> docker.tf

terraform import docker_container.web $(docker inspect -f {{.ID}} hashicorp-learn)

terraform show -no-color > docker.tf
