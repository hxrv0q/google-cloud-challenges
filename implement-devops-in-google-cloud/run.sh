#!/usr/bin/sh

function git_configure() {
  echo "Configuring git..."

  echo "Enter your git username: "
  read -r git_username
  echo "Enter your git email: "
  read -r git_email

  git config --global user.name "$git_username"
  git config --global user.email "$git_email"
}

function create_lab_resources() {
  gcloud services enable container.googleapis.com \
    cloudbuild.googleapis.com \
    sourcerepo.googleapis.com
  
  export PROJECT_ID=$(gcloud config get-value project)
  gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$(gcloud projects describe $PROJECT_ID \
    --format="value(projectNumber)")@cloudbuild.gserviceaccount.com --role="roles/container.developer"

  gcloud artifacts repositories create my-repository \
    --repository-format=docker \
    --location=us-central1 \
    --description="My Artifact Registry repository"

  gcloud container clusters create hello-cluster \
    --num-nodes=3 --zone=us-central1-a \
    --release-channel=regular --cluster-version='1.26.5-gke.1200' \
    --enable-autoscaling --min-nodes=2 --max-nodes=6

  kubectl create namespace prod
  kubectl create namespace dev
}

function create_git_repository() {
  cd ~
  gcloud source repos create sample-app
  gcloud source repos clone sample-app

  cd ~
  gsutil cp -r gs://spls/gsp330/sample-app/* sample-app


  cd sample-app
  git add .
  git commit -m "Initial commit"

  git push origin master

  git checkout -b dev
  git push -u origin dev
}

function create_cloud_trigger() {
  gcloud beta builds triggers create cloud-source-repositories \
    --repo=sample-app \
    --branch-pattern="^master$" \
    --build-config=cloudbuild.yaml \
    --description="Builds the sample-app for production" \
    --name="sample-app-prod-deploy"

  gcloud beta builds triggers create cloud-source-repositotries \
    --repo=sample-app \
    --branch-pattern="^dev$" \
    --build-config=cloudbuild-dev.yaml \
    --description="Builds the sample-app for development" \
    --name="sample-app-dev-deploy"
}

function run_script() {
  echo "1. Configure git"
  echo "2. Create lab resources"
  echo "3. Create git repository"
  echo "4. Create cloud trigger"

  echo "Enter your choice: "
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
    4)
      create_cloud_trigger
      ;;
    *)
      echo "Invalid choice"
      exit 1
      ;;
  esac
}

run_script