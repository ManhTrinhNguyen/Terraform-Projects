- [Clone Java Maven Application](#Clone-Java-Maven-Application)

- [Build Dockerfile for Java Maven Application](#Build-Dockerfile-for-Java-Maven-Application)

- [Build Jenkins CI CD pipeline](#Build-Jenkins-CI-CD-pipeline)

  - [Create a Server for Jenkins on Digital Ocean](#Create-a-Server-for-Jenkins-on-Digital-Ocean) 
  
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

COPY ./target/java-maven-app-*.jar /usr/app/app.jar

WORKDIR /usr/app

CMD [ "java", "-jar", "app.jar"]
```

`FROM amazoncorretto:8-alpine3.19-jre`: I start to build a Image from a Based Java Image amazoncorretto (https://hub.docker.com/_/amazoncorretto)

`EXPOSE 8080`: My Java app is listening on port 8080 

`COPY ./target/java-maven-app-*.jar /usr/app/app.jar`: From the Location of Dockefile I will copy a JAR file into a container location is `/usr/app` also rename it into `app.jar` 

`WORKDIR /usr/app`: Make sure the conainter run at this Folder 

`CMD [ "java", "-jar", "app.jar"]`: Run a Command inside a container . CMD is to execute Entry point  

From my Local Machine I will test building a Docker image and run it . 

- I am using Mac so I need to install Docker Desktop

- To build a Docker image : `docker build <app-repo>:<appname> .`
  
![Screenshot 2025-06-16 at 13 05 10](https://github.com/user-attachments/assets/62c64f5c-e0bd-450f-8cec-e35c60461767)

- To run a Image locally : `docker run -p 8080:8080 java-maven`

  - Port `8080:8080`: The first one is to expose from the host . The second one is to expost from the container 

![Screenshot 2025-06-16 at 13 06 12](https://github.com/user-attachments/assets/97bb9e87-f024-4334-800d-13e370320509)

Once everything work locally I can start to build a CI/CD pipeline to automatically build for me 

## Build Jenkins CI CD pipeline 

#### Create a Server for Jenkins on Digital Ocean

Before start I should have a account in Digital Ocean 

Go to Create Droplet . I will configure Region, Image, Size Disk, and Create an SSH key to connect to Digital Ocean 

To create a new ssh key . In my terminal : `ssh-keygen`

- I will be prompted to save and name the key.

- Next I will be asked to create and confirm a passphrase for the key (highly recommended)

- This will generate two files, by default called `id_rsa` and `id_rsa.pub` in `.ssh` folder.  Next, add this public key.

- Copy and paste the contents of the `.pub` file to Digital Ocean : `cat ~/.ssh/id_rsa.pub`

I need to configure Firewall to prevent everyone can access into my server

- I need to open Port 22 for ssh

- And open port 8081 for Jenkins Application

![Screenshot 2025-06-16 at 13 20 49](https://github.com/user-attachments/assets/76c99e58-2750-411b-8e91-75d3659db049)

Now I can ssh into a server `ssh -i ~/.ssh/id_rsa root@<Ip address>`

![Screenshot 2025-06-16 at 13 22 05](https://github.com/user-attachments/assets/758211eb-6fe8-4e62-ac59-fd545d04f71c)


















