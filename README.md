- [Clone Java Maven Application](#Clone-Java-Maven-Application)

- [Build Dockerfile for Java Maven Application](#Build-Dockerfile-for-Java-Maven-Application)


## Complete CI/CD with Terraform

#### Technologies used:

Terraform, Jenkins, Docker, AWS, Git, Java, Maven, Linux, Docker Hub

#### Project Description:

Integrate provisioning stage into complete CI/CD Pipeline to automate provisioning server instead of deploying to an existing server

Create SSH Key Pair

Install Terraform inside Jenkins container

Add Terraform configuration to application’s git repository

Adjust Jenkinsfile to add “provision” step to the CI/CD pipeline that provisions EC2 instance So the complete CI/CD project we build has the following configuration:

a. CI step: Build artifact for Java Maven application
b. CI step: Build and push Docker image to Docker Hub
c. CD step: Automatically provision EC2 instance using TF
d. CD step: Deploy new application version on the provisioned EC2 instance with Docker Compose

### Clone Java Maven Application 

To clone a Java Maven App `git clone https://gitlab.com/twn-devops-bootcamp/latest/12-terraform/java-maven-app.git`

### Build Dockerfile for Java Maven Application

First I need to test If a Java App is running in my Local Machine .

- Build the Jar file : `cd java-maven` and `mvn package`

- After success I should have a Jar file in `target` folder 

![Screenshot 2025-06-16 at 12 30 35](https://github.com/user-attachments/assets/0be6a604-4f89-4df1-bce3-3c71d5a1b2a2)

To run a JAR file : `java -jar target/java-maven-app-1.1.0-SNAPSHOT.jar` (Need Java install before run)

Now I should see my Java app is running okay

![Screenshot 2025-06-16 at 12 32 28](https://github.com/user-attachments/assets/0799ac77-03e5-48de-98cb-665217723285)

To check a processes running I can do `ps aux | grep java`. I can see my java app `process id is 30692`

![Screenshot 2025-06-16 at 12 38 07](https://github.com/user-attachments/assets/22f17e8e-352c-4dc6-a735-7e75e98042fb)

To check which port java is listening to (Check active internet connection) : `netstat -ltpn` 

- To use `netstat` I need to install `net-tools`

Check Active Internet Connection on MacOS : `lsof -iTCP -sTCP:LISTEN -n -P`

![Screenshot 2025-06-16 at 12 47 47](https://github.com/user-attachments/assets/c6155277-92d7-4e55-9d0f-b483bd19e3a2)

To kill a process that running in the backgroud : `kill <process-id>`

I can start and build a Dockerfile : 

```
FROM amazoncorretto:8-alpine3.19-jre 

EXPOSE 8080

COPY ./target/java-maven-app-*.jar /usr/app/

WORKDIR /usr/app

CMD [ "java", "-jar", "java-maven-app-*.jar"]
```

`FROM amazoncorretto:8-alpine3.19-jre`: I start to build a Image from a Based Java Image amazoncorretto (https://hub.docker.com/_/amazoncorretto)

`EXPOSE 8080`: My Java app is listening on port 8080 

`COPY ./target/java-maven-app-*.jar /usr/app/`: From the Location of Dockefile I will copy a JAR file into a container location is `/usr/app` 

`WORKDIR /usr/app`: Make sure the conainter run at this Folder 

`CMD [ "java", "-jar", "java-maven-app-*.jar"]`: Run a Command inside a container . CMD is to execute Entry point  
























