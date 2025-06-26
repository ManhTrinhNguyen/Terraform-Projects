
pipeline {   
    agent any
    tools {
        maven 'maven-3.9'
    }

    environment {
        ECR_URL = "660753258283.dkr.ecr.us-west-1.amazonaws.com"
        DOCKER_REPO = "660753258283.dkr.ecr.us-west-1.amazonaws.com/java-maven"
    }

    stages {
        stage("increment Version") {
            steps {
                script {
                    echo "Increment Version !!!!"

                    sh "mvn build-helper:parse-version versions:set -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} versions:commit"

                    def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'

                    def version = matcher[0][1]

                    env.IMAGE_VERSION = "$version-$BUILD_NUMBER"
                }
            }
        }
        stage("build jar") {
            steps {
                script {
                    echo "Building Maven Jar !"
                    sh "mvn clean package"      
                }
            }
        }

        stage("build and push Docker Image") {
            steps {
                script {
                    withCredentials([
                        usernamePassword(credentialsId: 'ECR_Credentials', usernameVariable: 'USER', passwordVariable: 'PWD')
                    ]){
                        echo "Build Docker Image"
                        sh "docker build -t ${DOCKER_REPO}:${IMAGE_VERSION} ."

                        echo "Login to ECR"
                        sh "echo ${PWD} | docker login --username ${USER} --password-stdin ${ECR_URL}"
                        
                        echo "Push Docker Image to ECR"
                        sh "docker push ${DOCKER_REPO}:${IMAGE_VERSION}"
                    }
                }
            }
        }

        stage("Provision Server") {
            environment {
                AWS_ACCESS_KEY_ID = credentials("AWS_ACCESS_KEY_ID")
                AWS_SECRET_ACCESS_KEY = credentials("AWS_SECRET_KEY_ID")
                TF_VAR_my_ip_address = "71.202.102.216/32"
            }
            steps {
                script {
                    echo "Provision EC2 Server"
                    dir('terraform') {
                      echo "provision Terraform ...."
                      sh "terraform init" 
                      sh "terraform destroy --auto-approve"
                    }
                }
            }
        }

        stage("deploy") {
            steps {
                script {
                    echo "Deploy !!!!!!!!!!!!!!"
                }
            }
        } 

        stage("Commit to Git Repo"){
            steps {
                script {
                    withCredentials([
                        usernamePassword(credentialsId: 'Github_Credential', usernameVariable: 'USER', passwordVariable: 'PWD')
                    ]){
                        // Set Jenkins email and user name
                        sh 'git config user.email "trinh-bot@gmail.com"'
                        sh 'git config user.name "trinh-bot"'

                        // Set origin Access 
                        sh "git remote set-url origin https://${USER}:${PWD}@github.com/ManhTrinhNguyen/Terraform-Projects.git"

                        sh 'git add .'
                        sh 'git commit -m "ci: version bump"'
                        sh "git push origin HEAD:${BRANCH_NAME}"
                    }
                }
            }
        }              
    }
} 
