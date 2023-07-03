#!/usr/bin/sh

function git_configure() {
  local username=$1
  local email=$2

  git config --global user.name $username
  git config --global user.email $email
}

function create_lab_resources() {
  gcloud services enable container googleapis.com \
    cloudbuild.googleapis.com sourcerepo.googleapis.com

  export PROJECT_ID=$(gcloud config get-value project)
  gcloud projects add iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$(gcloud projects describe $PROJECT_ID \
      --format="value(projectNumber)")@cloudbuild.gserviceaccount.com
    --role="roles/container.developer"

  echo "Enter a username for the Cloud Source Repositories: "
  read -r username
  echo "Enter an email for the Cloud Source Repositories: "
  read -r email

  git_configure $username $email

  sed -i "s/PROJECT_ID/$PROJECT_ID/g" main.tf

  terraform init
  terraform plan -out=tfplan
}

function create_git_repository() {
  cd ~

  gsutil cp -r gs://spls/gsp330/sample-app/* sample-app
}

echo "Welcome to the Lab Initialization Menu:"
echo "1. Configure git"
echo "2. Create lab resources"
echo "3. Create repository"
read -r choice

case $choice in
  1)
    git_configure
    ;;
  2)
    create_lab_resources
    ;;
  3)
    create_git_repository
    ;;
  *)
    echo "Invalid choice. Exiting."
    ;;
esac