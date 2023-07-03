function git_configure() {
  local email=$1
  local username=$2

  git config --global user.email "$email"
  git config --global user.name "$username"
}

function initialize_lab() {
  PROJECT_ID=$(gcloud config get-value project)
  PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')
  REGION=us-central1

  gcloud config set compute/region $REGION

  gcloud services enable container.googleapis.com \
    cloudbuild.googleapis.com sourcerepo.googleapis.com \
    containeranalysis.googleapis.com

  gcloud artifacts repositories create my-repository \
    --repository-format=docker --location=$REGION
  
  gcloud container clusters create hello-cloudbuild --num-nodes 1 \
    --region $REGION

  echo "Enter your email address: "
  read -r email

  echo "Enter your username: "
  read -r username

  git_configure "$email" "$username"
}

function create_git_repository() {
  gcloud source repos create hello-cloudbuild-app
  gcloud source repos create hello-cloudbuild-env

  cd ~

  git clone https://github.com/GoogleCloudPlatform/gke-gitops-tutorial-cloudbuild hello-cloudbuild-app

  cd ~/hello-cloudbuild-app

  PROJECT_ID=$(gcloud config get-value project)

  git remote add google "https://source.developers.google.com/p/${PROJECT_ID}/r/hello-cloudbuild-app"
}

function create_container_image() {
  cd ~/hello-cloudbuild-app

  COMMIT_ID="$(git rev-parse --short=7 HEAD)"
  PROJECT_ID=$(gcloud config get-value project)
  REGION=us-central1

  gcloud builds submit --tag="${REGION}-docker.pkg.dev/${PROJECT_ID}/my-repository/hello-cloudbuild:${COMMIT_ID}" .
}

echo "Welcome to the Lab Initialization Menu:"
echo "1. Initialize Lab"
echo "2. Create Git Repository"
echo "3. Create Container Image"
echo "Enter your choice (1, 2, or 3):"
read -r choice

case $choice in
  1)
    initialize_lab
    ;;
  2)
    create_git_repository
    ;;
  3)
    create_container_image
    ;;
  *)
    echo "Invalid choice. Exiting."
    ;;
esac