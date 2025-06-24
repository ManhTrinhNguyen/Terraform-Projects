
pipeline {   
    agent any
    tools {
        maven 'maven-3.9'
    }
    stages {
        stage("increment Version") {
            steps {
                script {
                    echo "Increment Version"

                    sh "mvn build-helper:parse-version versions:set -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} versions:commit"

                    def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'

                    def version = matcher[0][1]

                    echo "${version}"
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
