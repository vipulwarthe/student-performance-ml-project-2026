# student-performance-ml-project

## Deploy end to end student performance ML model with AWS ECR and AWS ECS

## Problem Statement

The objective of this project is to build a machine learning model that predicts students' mathematics scores using features such as gender, ethnicity, parental education level, lunch type, and test preparation course completion.

## Data Collection

'Dataset Source - https://www.kaggle.com/datasets/spscientist/students-performance-in-exams?datasetId=74977'
'The data consists of 8 column and 1000 rows.'

## Project links:

    Original link: Krish naik Repo link: https://github.com/krishnaik06/mlproject/

    My repo link:  https://github.com/vipulwarthe/student-performance-ml-project-2026.git

## First we Create instance with ubuntu AMI with t2.medium instance type with 30GB storage and sg-SSH/All Traffic-anywhere

    sudo apt-get update && sudo apt-get upgrade -y    (download packages and installs the updates on the server)

    sudo apt install python3-venv -y          (install python environment)

    python3 -m venv MLPRO                     (create an isolated Python environment)

    source MLPRO/bin/activate                 (activate envirnoment mlpro env)

    mkdir mlproject                           (create one project directory)

    cd mlproject                              (enter in project directory)

## clone the repository and go to the project repo

    git clone https://github.com/vipulwarthe/student-performance-ml-project-2026.git
    pip install -r requirements.txt

## select the kernel and run the both notebooks so we can build and save the model and then run below commands
    
    python3 src/logger.py
    python src/components/data_ingestion.py
    python src/components/data_transformation.py
    python src/components/model_trainer.py

## Run the application 

    python application.py

## access the application on "Public IP:5000" or you can use this as well "public ip:5000/predictdata"

# Deployment of the application using EC2, ECR, ECS : 

## Install AWSCLI

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    sudo apt install unzip -y
    unzip awscliv2.zip
    sudo ./aws/install 

## configure aws with access and secret key along with region name

    aws configure

## Install Docker

    sudo vi docker-install.sh

    # Add Docker's official GPG key:
    sudo apt update
    sudo apt install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
    Types: deb
    URIs: https://download.docker.com/linux/ubuntu
    Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
    Components: stable
    Signed-By: /etc/apt/keyrings/docker.asc
    EOF

    sudo apt update -y
    sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    docker --version
    sudo usermod -aG docker $USER         #OR you can use "newgrp docker" as a next commmand
    sudo chown $USER /var/run/docker.sock 
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo systemctl status docker

    sudo chmod +x docker-install.sh
    ./docker-install.sh

## create ECR repo name sp-repo
*  push the commands from repository page

       aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 459499397844.dkr.ecr.us-east-1.amazonaws.com
       docker build -t sp-repo .
       docker tag sp-repo:latest 459499397844.dkr.ecr.us-east-1.amazonaws.com/sp-repo:latest
       docker push 459499397844.dkr.ecr.us-east-1.amazonaws.com/sp-repo:latest

## create ECS cluster

*  create ECS cluster
*  create TaskDefination
*  create service
*  go to the cluster click on Task and copy the public ip

## access the application using <public ip of cluster:5000>  with /predicdata to predict the performancre

## Deletion Process:

- First stop the task

- deregister the task defination 

- delete the task defination

- Delete cluster

- Delete Image and delete Repo

- Delete IAM Role related to ECS

- Terminate the EC2 instance


    
