# student-performance-ml-project

## Problem Statement

The objective of this project is to build a machine learning model that predicts students' mathematics scores using features such as gender, ethnicity, parental education level, lunch type, and test preparation course completion.

## Data Collection

'Dataset Source - https://www.kaggle.com/datasets/spscientist/students-performance-in-exams?datasetId=74977'
'The data consists of 8 column and 1000 rows.'

## Project links:

    Original link: Krish naik Repo link: https://github.com/krishnaik06/mlproject/

    My repo link:  https://github.com/vipulwarthe/student-performance

## First we Create instance with ubuntu AMI with t2.medium instance type with 30GB storage and sg-SSH/All Traffic-anywhere

    sudo apt-get update && sudo apt-get upgrade -y    (download packages and installs the updates on the server)

    sudo apt install python3-venv -y          (install python environment)

    python3 -m venv MLPRO                     (create an isolated Python environment)

    source MLPRO/bin/activate                 (activate envirnoment mlpro env)

    mkdir mlproject                           (create one project directory)

    cd mlproject                              (enter in project directory)

## clone the repository and go to the project repo

    git clone <repo url>
    pip install -r requirements.txt

## select the kernel and run the both notebooks so we can build and save the model and then run below commands
    
    python3 src/logger.py
    python src/components/data_ingestion.py
    python src/components/data_transformation.py
    python src/components/model_trainer.py

## Run the application 

    python application.py

## access the application on "Public IP:5000" or you can use this as well "public ip:5000/predictdata"

# Deployment of this application using EC2, ECR, ECS : 
   



    
