def gv

pipeline {   
    agent any
    tools {
        maven 'maven-3.9'
    }
    stages {
        stage("increment Version") {
            steps {
                script {
                    echo "Version"
                }
            }
        }
        stage("build jar") {
            steps {
                script {
                    echo "Build Jar"

                }
            }
        }

        stage("build image") {
            steps {
                script {
                    echo "Build Image"
                }
            }
        }

        stage("deploy") {
            steps {
                script {
                    echo "Deploy"
                }
            }
        }               
    }
} 
