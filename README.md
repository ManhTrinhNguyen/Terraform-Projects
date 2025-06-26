- [Clone Java Maven Application](#Clone-Java-Maven-Application)

- [Build Dockerfile for Java Maven Application](#Build-Dockerfile-for-Java-Maven-Application)

- [Set up Jenkins CI CD pipeline](#Build-Jenkins-CI-CD-pipeline)

  - [Create a Server for Jenkins on Digital Ocean](#Create-a-Server-for-Jenkins-on-Digital-Ocean)
 
  - [Run Jenkins as a Docker Container](#Run-Jenkins-as-a-Docker-Container)
 
  - [Install Docker inside Jenkins container](#Install-Docker-inside-Jenkins-container)

  - [Install Stage View Plugin](#Install-Stage-View-Plugin)
 
- [CI Stage](#CI-Stage)

  - [Configure Jenkins](#Configure-Jenkins)
 
  - [Dynamically Increment Application Version](#Dynamically-Increment-Application-Version)
 
  - [Configure Webhook to Trigger CI Pipeline Automatically on Every Change](#Configure-Webhook-to-Trigger-CI-Pipeline-Automatically-on-Every-Change)
 
  - [Build Artifact](#Build-Artifact)
 
  - [Build And Push Docker Image to ECR](#Build-And-Push-Docker-Image-to-ECR)
 
  - [Make Jenkin commit and push to Repo](#Make-Jenkin-commit-and-push-to-Repo)
 
- [Terraform](#Terraform)

  - [Configure AWS Provider](#Configure-AWS-Provider) 

  - [Provision AWS Infrastructure](#Provision-AWS-Infrastructure)
 
  - [Create VPC and Subnet](#Create-VPC-and-Subnet)
 
  - [Provision Route Table](#Provision-Route-Table)
 
  - [Connect VPC to Internet using Internet Gateway](#Connect-this-VPC-to-Internet-using-Internet-Gateway)
 
  - [Provision Security Group](#Provision-Security-Group)
 
  - [Subnet Association with Route Table](#Subnet-Association-with-Route-Table)
 
  - [Execute Terraform](#Execute-Terraform)
 
  - [Create Security Group](#Create-Security-Group)
 
  - [Create EC2 Instance](#Create-EC2-Instance)
 
  - [Variables](#Variables)
 
  - [Deploy Nginx in EC2 Server](#Deploy-Nginx-in-EC2-Server)
 
- [CD Stage](#CD-Stage)

  - [Automatically provision EC2 instance using TF](#Automatically-provision-EC2-instance-using-TF)
 
    - [Install Terraform inside Jenkins](#Install-Terraform-inside-Jenkins)
   
    - [SSH key pair for the server](#SSH-key-pair-for-the-server)
   
    - [Create AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY](#Create-AWS_ACCESS_KEY_ID-and-AWS_SECRET_ACCESS_KEY)
 
  - [Deploy new application version on the provisioned EC2 instance with Docker Compose](#Deploy-new-application-version-on-the-provisioned-EC2-instance-with-Docker-Compose)
 
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

## Set up Jenkins CI CD pipeline 

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

- And open port 8080 for Jenkins Application

![Screenshot 2025-06-16 at 13 42 42](https://github.com/user-attachments/assets/e15f3e88-b1e0-4668-8754-9571bca39fce)

Now I can ssh into a server `ssh -i ~/.ssh/id_rsa root@<Ip address>`

![Screenshot 2025-06-16 at 13 22 05](https://github.com/user-attachments/assets/758211eb-6fe8-4e62-ac59-fd545d04f71c)

To update a Server Package Manager : `apt update`

- apt is an package manager for Ubuntu 

#### Run Jenkins as a Docker Container

To install Docker `apt install docker.io`

I need to create another user named `jenkins` to run a Jenkins Application . 

- Best Practice Security : Never run Services as a Root User 

To create `jenkins` user : `adduser jenkins`

- This command will create a jenkins user also a jenkins group

I want `jenkin user` can execute command which root can do . I will add `sudo` group to `jenkins user` : `usermod -aG sudo jenkins`

Also I want `jenkins` can execute docker command without using `sudo` I will also add `docker group` to `jenkins user` : `usermode -aG docker jenkins`

Now I can switch to `jenkins user`: `su - jenkins`

I also want to ssh to a server as a `jenkins user` from my local machine (by default I can not) 

- I need to take a public ssh key from my local machine `cat ~/.ssh/id_rsa.pub` and copy it into a `jenkins user` server at a `~/.ssh/authorized_keys` file

- I need to create this `~/.ssh/authorized_keys` file inside `jenkins user` server 

- Now I can ssh to a server as a `jenkins user`

**Jenkins Image Docs** (https://github.com/jenkinsci/docker/blob/master/README.md)

**Run Docker Container** : `docker run -d -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins/jenkins`

- `-d` : Run as detach mode

- `-p 8080:8080`: Open port 8080 for the Host and the Container

- `-p 50000:50000`: This is for Jenkins Agents (slave) connections

- `-v jenkins_home:/var/jenkins_home`: This will automatically create a `'jenkins_home'` docker volume on the host machine. Docker volumes retain their content even when the container is stopped, started, or deleted.

![Screenshot 2025-06-16 at 13 49 36](https://github.com/user-attachments/assets/f813d0e0-2b9a-4c58-90cd-3a00713b7440)

I will use `docker ps` if the container is running 

To check if the container running : `docker logs [container-id]`

To see Jenkins Process is running on the Server : `ps aux | grep jenkins`

![Screenshot 2025-06-16 at 13 58 45](https://github.com/user-attachments/assets/badd13a3-7e52-4cd1-90ec-19c8e5f4e857)

To see Active Connection on my Server : `netstat -ltpn` (I need to install net-tools in order to use netstat) : `apt install net-tools`

- Now I can see a port 50000 and 8080 and 22 open on the Server
  
![Screenshot 2025-06-16 at 14 00 47](https://github.com/user-attachments/assets/ba6ae5f5-f98c-460f-9df3-684120c23946)

Once success I start access it from the UI using `public-ip:port` -> `165.232.141.93:8080/`

<img width="500" alt="Screenshot 2025-06-16 at 13 55 35" src="https://github.com/user-attachments/assets/870d8963-6db7-4345-889d-375a1d6781dc" />

#### Install Docker inside Jenkins container

Most of scenerio I will need to build Docker Image in Jenkins . That mean I need Docker Command in Jenkins . The way to do that is attaching a volume to Jenkins from the host file

  - In the Server (Droplet itself) I have Docker command available, I will mount Docker directory from Droplet into a Container as a volume . This will make Docker available inside the container

  - To do that I first need to kill current Container and create a new : `docker stop <container-id>`

  - Check the volume : `docker ls volume` . All the data from the container before will be persist in here and I can use that to create a new Container

  - Start a new container : `docker run -d -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock jenkins/jenkins:lts`

    -  /var/run/docker.sock:/var/run/docker.sock : I mount a Docker from Droplet to inside Jenkins
   
  - Get inside Jenkins as Root : `docker exec -it -u 0 <container_id> bash`

    - Things need to fix :

      - `curl https://get.docker.com/ > dockerinstall && chmod 777 dockerinstall && ./dockerinstall` . With this Curl command Jenkins container is going to fetch the latest Version of Docker from official size so it can run inside the container, then I will set correct permission the run through the Install

      - Run `bash ./dockerinstall`  
      
      - Set correct Permission on `docker.sock` so I can run command inside the container as Jenkins User  `chmod 666 /var/run/docker.sock`: docker.sock is a Unix socket file used by Docker daemon to communicate with Docker Client


#### Install Stage View Plugin

This Plugins help me see diffent stage defined in the UI . This mean Build Stage, Test, Deploy will displayed as separate stage in the UI 

Go to Available Plugin -> Stage View

## CI Stage 

#### Configure Jenkins

1. I want to use Maven tool for my Java App

- Go to Setting -> Tools -> Scroll down I can see Jenkins Installation Section 

2. I want Jenkins to connect to my Github Repo to git my Source Code

- I need to create my Github Credentials in Jenkins -> Go to setting -> Credentials -> Create one with Username and Password

- I also need to give Jenkins my Github Repo URL

3. Once everything configured I can start to create my Multil branch pipeline

- I want to create Multi branch Pipeline Bcs I may have multiple different Branch 

#### Dynamically Increment Application Version 

I will use this command to Dynamically Increment Maven Application `mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.nextIncrementalVersion} versions:commit`

- `parse-version` : It goes and find pom file and it find a version tag . When it find a version tag it parses the version inside into 3 parts Major, Minor, Increment

- `version:set` : Set a version between version tag

- `-DnewVersion` : This is a Parameter for versions:set

- `\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.nextIncrementalVersion}` : This is How I know what is the next version that I need to increment to. I use next so it the parse-version know that Incremental part need to increase . If I don't use next it will keep it as it is

- `version:commit` : Replace pom.xml with new Version

To execute the command in the sh command in Jenkinsfile the syntax to escape dollar sign a little different: `mvn build-helper:parse-version versions:set -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} versions:commit`

I need to read `pom.xml` and access the version value then set it as a Variable

To read `pom.xml` file and looking for version tag inside and put the `(.+)` regular expression to dynamic set a version value and set a variable to it called matcher: `def matcher = readFile(pom.xml) =~ <version>(.+)</version>` . This will give me an array of all the verions tags that it could find in this case I just have 1 and also the version value (child of version tag), so I would get that element like this : `matcher[0][1]`

Then I would set a `IMAGE_NAME` as a ENV like this : `env.IMAGE_NAME = "java-app:$version"`

My entire code will look like this: 

```
stage("increment Version") {
    steps {
        script {
            echo "Increment Version"

            sh "mvn build-helper:parse-version versions:set -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} versions:commit"

            def matcher = readFile('pom.xml') =~ '<version>(.+)</version>'

            def version = matcher[0][1]

            env.IMAGE_NAME = "java-app:$version"
        }
    }
}
```

#### Configure Webhook to Trigger CI Pipeline Automatically on Every Change

<img width="600" alt="Screenshot 2025-03-27 at 09 43 53" src="https://github.com/user-attachments/assets/41f70a4b-aa1d-49e0-ae0f-c2365357aec5" />

For Multibranch pipeline for every Repository: 

- I need another Plugin call `Scan Multibranch Pipeline Triggers`

Once it installed I will go to my Mutil branch job -> Configure -> Scroll down to Periodically if not otherwise run -> And make sure it checked 

After that Go to my Gitub repo -> Settings -> Webhook -> configure `http://<your-jenkins-domain>/github-webhook/` 

After that I need to go to Jenkins UI -> Settings -> System -> Scroll down to Github section and set this 

<img width="500" alt="Screenshot 2025-06-25 at 20 26 02" src="https://github.com/user-attachments/assets/18bf5353-58cd-46e7-a79f-45d9cb657937" />

- Make sure credentials set in Global and as Secrect Text

#### Build Artifact 

I want to add another stage To build a Java Maven Artifact 

```
stage("build jar") {
    steps {
        script {
            echo "Building Maven Jar"
            sh "mvn clean package"      
        }
    }
}
```

#### Build And Push Docker Image to ECR 

I need to create my ECR . Go to AWS console -> ECR -> Create Repository 

I also need to create my ECR Credentials in Jenkins for Jenkins to `docker login` into my ECR 

- To get a password : `aws ecr get-login-password --region us-west-1`

- Username should be : `AWS`

Once I have Username and Password I can create ECR Credentials in Jenkins 

To Build Docker Image : `docker build 660753258283.dkr.ecr.us-west-1.amazonaws.com/java-maven:${IMAGE_VERSION}`

- My Docker Image have to have a ECR URL endpoint attached to it for Docker to know this Image should push to ECR.

- I also configure my DOCKER REPO as a ENV

```
environment {
  DOCKER_REPO = "660753258283.dkr.ecr.us-west-1.amazonaws.com/java-maven"
}
```

- So I build docker image will look cleaner `sh "docker build -t ${DOCKER_REPO}:${IMAGE_VERSION}"`

In order to get Credentials from Jenkins to login to ECR I use a built-in function `withCredentials([])`

- `sh "echo ${PWD} | docker login --username ${USER} --password-stdin ${ECR_URL}"` I put ECR_URL as the end bcs Docker need the ECR endpoint in order to login to it

- I also configured my `ECR_URL` as a ENV

```
environment {
    ECR_URL = "660753258283.dkr.ecr.us-west-1.amazonaws.com"
    DOCKER_REPO = "660753258283.dkr.ecr.us-west-1.amazonaws.com/java-maven"
}
```

Then I will push that Image to ECR 

This is my entire code : 

```
stage("build and push Docker Image") {
    steps {
        script {
            withCredentials([
                usernamePassword(credentialsId: 'ECR_Credentials', usernameVariable: 'USER', passwordVariable: 'PWD')
            ]){
                echo "Build Docker Image"
                sh "docker build -t ${DOCKER_REPO}:${IMAGE_VERSION}"

                echo "Login to ECR"
                sh "echo ${PWD} | docker login --username ${USER} --password-stdin ${ECR_URL}"
                
                echo "Push Docker Image to ECR"
                sh "push ${DOCKER_REPO}:${IMAGE_VERSION}"
            }
        }
    }
}
```

#### Make Jenkin commit and push to Repo

Everytime pipeline run in Jenkins, it will create a new Image Version and then will commit that `pom.xml` change back into repository so now other Developer want to commit something to that Branch they first need to fetch that change that Jenkin Commited and continus working from there 

I will add another Git commit version update Stage :

First I need Credentials to git Repository . I will use `withCredentials()`

Inside` withCredentials()` block :

```
sh 'git config --global user.email "jenkins@gmail.com"'
sh 'git config --global user.name "Jenkins"'

// Set origin Access 
sh "git remote set-url origin https://${USER}:${PWD}@github.com/ManhTrinhNguyen/Terraform-Projects.git"

sh 'git add .'
sh 'git commit -m "ci: version bump"'
sh 'git push origin HEAD:main'
```

When Jenkins check outs up to date code in order to start a pipeline it doesn't check out the Branch, it checkout the commit hash (the last commit from that branch). That is the reason why I need to do sh `'git push origin HEAD:<job-branch>'`. So it saying that push all the commits that we have made inside this commit Branch inside this Jenkin Job

#### Ignore Jenkins Commit for Jenkins Pipeline Trigger

I need someway to detect that commit was made by Jenkin not the Developer and Ignore the Trigger when the Commit is from Jenkins

I need a Plugin : Ignore Commiter Strategy

Go to my Pipeline Configuration -> Inside the Branch Sources I see the Build Strategy (This is an option just got through the plugin) -> In this option I will put the email address of the committer that I want to Ignore . I can provide a list of email

Also checked `Allow builds when a changeset contains non-ignored author(s)`

## Terraform 

Create TF project to automate provisioning AWS Infrastructure and its components, such as: VPC, Subnet, Route Table, Internet Gateway, EC2, Security Group

Configure TF script to automate deploying Docker container to EC2 instance

#### Install Terraform 

Terraform installation Docs (https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

To install Terraform on MacOS: 

```
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

#### Terraform Structure 

I will create a `mkdir terraform` folder in this project 

In terraform folder I will create  `touch main.tf providers.tf variables.tf output.tf`

`main.tf`: Is a acutal configuration file where I put my Desire State in it 

`variables.tf`: Is to define a variables in Terraform . And I can define its values in `terraform.tfvars` should be list in `.gitignore`

`terraform.tfstate` and `terraform.tfstate.backup` should be list in `.gitignore`

`.gitignore`:

- Ignore .`terraform/*` folder . Doesn't have to part of the code bcs when I do terraform init it will be downloaded on my computer locally

- Ignore `*.tfstate`, `*.tfstate.*` bcs Terraform is a generated file that gets update everytime I do terraform apply.

- Ignore *.tfvars the reason is Terraform variables are a way to give users of terraform a way to set Parameter for the configurations file this parameters will be different base on the Environment . Also Terraform file may acutally contain some sensitive data


#### Configure AWS Provider 

Provider is a software that allow me to talk to specific techologies like AWS, Google Cloud etc .... 



In `terraform` folder I create `touch providers.tf` file 

- To use a Providers I need to provide a Provider like this in `providers.tf`

```
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.0.0-beta3"
    }
  }
}

provider "aws" {
  region = "us-west-1"
}
```

- If I need another Provider I can add into a `required_providers` with specific version

- `provider "aws"` I will work on my region `us-west-1` . It also need a Credentials in order to interact with my AWS . I will go to `~/.aws/credentials` and take my credentials from there

  - I can also put a credentials direct in the Block but for Security issue Never do that 


To install a Provider : `terraform init` 

- This will generate a `.terraform` folder and `.terraform.lock.hcl` files

  -  `.terraform` folder: This folder contains files downloaded by Terraform, like provider plugins and modules, that Terraform will use to interact with services like AWS. It’s basically the setup that enables Terraform to do its job when applying your infrastructure changes.
 
  -  `.terraform.lock.hcl`: This file keeps track of the exact versions of provider plugins (like AWS) that are installed. It ensures that Terraform always uses the same versions, so your infrastructure behaves consistently across different machines or team members. If you add a new provider, it will show up in this file.

#### Provision AWS Infrastructure 

#### Overview 

I will Deploy EC2 Instances on AWS and I will run a simple Docker Container on it

However before I create that Instance I will Provision AWS Infrastructure for it

To Provision AWS Infrastructure :

- I need create custom VPC

- Inside VPC I will create Subnet in one of AZs, I can create multiple Subnet in each AZ

- Create a Route Table and Subnet Association with Route Table

- Connect this VPC to Internet using Internet Gateway on AWS . Allow traffic to and from VPC with Internet

- And then In this VPC I will deploy an EC2 Instance

- Deploy Nginx Docker container

- Create SG (Firewall) in order to access the nginx server running on the EC2

- Also I want to SSH to my Server. Open port for that SSH as well

#### Create VPC and Subnet 

In `main.tf`

**To create VPC** I will use `resource "aws_vpc"` (https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc))

- I need to configure a `cidr_block` for a VPC .

  - `cidr_block` is a Range of IP address that I assign to my VPC. It use CIDR (Classless Inter-Domain Routing) notation like `10.0.0.0/16` to define the size of private IP address space that my VPC can use 

```
resource "aws" "my-vpc" {
  cidr_block = "10.0.0.0/16"

  tag = {
    Name: "my-vpc"
  }
}
```

**To create Subnet** I will use `resource "aws_subnet"` (https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)

I need to configure `vpc_id` for my subnet . 

- I want to create my subnet in the VPC that I just created above . So I will give its `vpc_id` to it : `vpc_id     = aws_vpc.main.id`

- I also create a `cidr_block` for it  : `cidr_block = "10.0.1.0/24"`

- I can decide which AZ this Subnet will be in `availability_zone = "us-west-1a"`

```
resource "aws_subnet" "my_subnet" {
  vpc_id = aws_vpc.my-vpc.vpc_id
  cidr_block = "10.0.0.1/24"
  availability_zone = "us-west-1a"

  tags = {
    Name: "my-subnet"
  }
}
```

#### Connect VPC to Internet using Internet Gateway

I will provision `resource "aws_internet_gateway"` (https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)

I need the vpc_id : `vpc_id = aws_vpc.my-vpc.vpc_id`

#### Provision Route Table

Route Table is a Virtual Router in VPC that is a set of Rules that tells my Network where to send traffic

When I click Inside Route Table: (https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)

- I see `Target: Local` and `Destination: 172.31.0.0/16` this mean only route traffic inside VPC within range `172.31.0.0/16`

- And `Target: igw-***` and `Destination: 0.0.0.0/0` This mean my VPC can connect to an Internet
  
<img width="600" alt="Screenshot 2025-06-17 at 14 30 35" src="https://github.com/user-attachments/assets/4fec67b9-d359-43e5-969d-3cd25cd135b7" />

I will create a new Route Table to associate with my newly created VPC and Subnet : `resource "aws_route_table"` with:

- Local Target : Connect within VPC

- Internet Gateway: Connect to the Internet

By default the entry for VPC internal routing is configured automatically. So I just need to create the Internet Gateway route

I need to provide `vpc_id = aws_vpc.my-vpc.vpc_id`

And then create a Internet Gateway route by using its ID that I provisioned above 

```
resource "aws_route_table" "myapp-route-table" {
vpc_id = aws_vpc.myapp-vpc.id

  route {
    cidr_block = "0.0.0.0/0" ## Destination . Any IP address can access to my VPC 
    gateway_id = aws_internet_gateway.myapp-igw.id ## This is a Internet Gateway for my Route Table 
  }

  tags = {
    Name = "my-rtb"
  }
}
```

#### Subnet Association with Route Table

I have created a Route Table inside my VPC. However I need to associate Subnet with Route TAble so that Traffic within a Subnet also can handle by Route Table 

By default when I do not associate subnets to a route table they are automatically assigned or associated to the main route table in VPC where the Subnet is running

(https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)

I need to provide a subnet_id which I want to associate with

Also the Route Table ID that I provisoned above 

```
resource "aws_route_table_association" "my-rtb-association" {
  subnet_id = aws_subnet.my_subnet.subnet_id
  route_table_id = aws_route_table.my-rtb.id
}
```

#### Typical Best Practice Setup:

Create a Public Route Table → route to Internet Gateway → associate with public subnets.

Create a Private Route Table → route to NAT Gateway → associate with private subnets.

Create an Internal Route Table → no external route → for database/backend subnets.

#### Execute Terraform 

I will use `terraform apply --auto-approve` to execute my infrastructure 

![Screenshot 2025-06-20 at 12 48 51](https://github.com/user-attachments/assets/2be27280-0936-4632-9495-c6f865199d82)

Now I my AWS console I should see my VPC with a new `my-vpc`

![Screenshot 2025-06-20 at 13 03 49](https://github.com/user-attachments/assets/9d5f093a-072c-4db4-af28-c630cfffad12)

My subnet :

<img width="400" alt="Screenshot 2025-06-20 at 13 04 25" src="https://github.com/user-attachments/assets/ba938518-88bd-4fae-8349-b7462169f285" />

My Route table with a `Target: igw-*` and `Target: local` 

<img width="500" alt="Screenshot 2025-06-20 at 13 06 00" src="https://github.com/user-attachments/assets/2888b2d4-859e-4368-bd47-7304bf3f48dc" />

Also my subnet associate with my RTB:

<img width="500" alt="Screenshot 2025-06-20 at 13 06 34" src="https://github.com/user-attachments/assets/2924fcb2-74c0-4721-bad3-80a4da1bcd61" />

#### Create Security Group

I want to Create a SG for my Instance  (https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)

- To open port 22 to SSH from my local machine

- To open port 8080 for my Application .

```
resource "aws_security_group" "my-sg" {
  name = "My SG"
  description = "Allow SSH for only my Address and Open port 8080 for my Application"
  vpc_id = aws_vpc.my-vpc.id 

  tags = {
    Name = "my-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow-SSH" {
  security_group_id = aws_security_group.my-sg.id
  cidr_ipv4 = "157.131.152.31/32" # I only allow my ipaddress to SSH to a Server 
  from_port = 22
  ip_protocol = "tcp"
  to_port = 22 
}

resource "aws_vpc_security_group_ingress_rule" "application-port-8080" {
  security_group_id = aws_security_group.my-sg.id
  cidr_ipv4 = "0.0.0.0/0" # I allow every IP address to connect to my Application 
  from_port = 8080
  ip_protocol = "tcp"
  to_port = 8080 
}

resource "aws_vpc_security_group_egress_rule" "allow-to-egress-to-internet" {
  security_group_id = aws_security_group.my-sg.id
  cidr_ipv4 = "0.0.0.0/0" # I allow my Server to egress every where in the Internet 
  ip_protocol = "tcp"
  from_port = 0
  to_port = 0
}
```

#### Create EC2 Instance

I will use `resource aws_instance` (https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) to create my ec2 instance 

But first I want to dynamically get an `aws_ami` id bcs for each Region `AMI_ID` might change . I will use `data aws_ami` to query the ami_id (https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami)

```
data "aws_ami" "my-ami" {
  most_recent = true
  owners = [ "amazon" ]

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}
```

Now this my resource for create EC2 Instance: 

```
resource "aws_instance" "my-ec2" {
  ami = data.aws_ami.my-ami.id
  instance_type = "t3.micro"
  subnet_id = aws_subnet.my_subnet.id
  availability_zone = "us-west-1a"
  vpc_security_group_ids = [ aws_security_group.my-sg.id ]

  associate_public_ip_address = true
  
  key_name = "terraform"
  tags = {
    Name = "dev-ec2"
  }
}
```

`ami` : This is a ami_id that I query above 

`instance_type`: I choose my instance type is `t3.mircro`

`subnet_id`: I want my EC2 instance launched inside my subnet VPC that I created above 

`availability_zone`: I want my EC2 to launched in specific Zone 

`vpc_security_group_ids`: I apply the secuiry group by using its ID that I create above 

`associate_public_ip_address: true`: I want to it automatically create my IP Public for me to SSH into it . (The Public IP take from the VPC)

`key_name`: This is my key `.pem` for me to ssh to a server

- Make sure to change `.pem` to `chmod 400 ~/.ssh/*.pem` for security  

Now I do `terraform apply --auto-approve` I can see my EC2 instance create inside my Subnet VPC and have a SG applied with it 

<img width="500" alt="Screenshot 2025-06-20 at 14 38 01" src="https://github.com/user-attachments/assets/ae3125c8-066d-42c5-99fd-c2f4cd15aed2" />

<img width="500" alt="Screenshot 2025-06-20 at 14 38 21" src="https://github.com/user-attachments/assets/f28898a1-dc6a-4826-9287-00711d481d7f" />

#### Variables 

Instead of hardcode the Value in the `main.tf` file I want to define a variable for it . 

- I can reuse it for any Configuration file

- I can also dynamic set value for it 

I will create `touch variables.tf` to store the variables 

```
variables.tf

variable "cidr_block" {}
variable "subnet_cidr_block" {}
variable "availability_zone" {}
variable "my_ip_address" {}
variable "instance_type" {}
variable "env_prefix" {}
variable "my_key_name" {}
```

I will create `touch terraform.tfvars` to put a value into it 

```
terraform.tfvars

cidr_block = "10.0.0.0/16"
subnet_cidr_block = "10.0.0.0/24"
availability_zone = "us-west-1a"
my_ip_address = "157.131.152.31/32"
instance_type = "t3.micro"
env_prefix = "development"
my_key_name = "terraform"
```

If my `terraform.tfvars` have another name other than that like `terraform-dev.tfvars` I have to explicity define it in the command like this : `terraform apply --var-file terraform-dev.tfvars`

#### Deploy Nginx in EC2 Server 

Now I have create my VPC and my EC2 Instance . I also want to automate deploy my Nginx App to an EC2 Instances .

- I will automate ssh into a Server . Install Docker and Deploy Nginx app as a Docker container

With Terraform there is a way to do that at the time EC2 Server Creation is called `user_data`

`user_data` is an entry point script that get executed on EC2 Instance .

This `user_data` is one of a Attribute of `resource aws_instance` (https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance)

I will create a bash script called `touch entry-script.sh` . Inside this file I will write a script that :

- Update a server

- Install Docker

- Run Docker

- Add `ec2-user` to Docker groups so `ec2-user` can execute docker command without using `sudo`

- Then run Nginx container on port 8080:80

My Script file will look like this :

```
entry-script.sh

#!/bin/bash

#!/bin/bash

sudo yum update -y ## Update Server 

sudo yum install -y docker ## Install Docker  

sudo systemctl enable docker

sudo systemctl start docker ## Start Docker 

sleep 5 # Wait for Docker to be fully ready

sudo usermod -aG docker ec2-user 

docker run -d -p 8080:80 nginx
```

Then I will add `user_data` into `resource aws_instance` and give it an `entry-script.sh` file a location to it

```
resource "aws_instance" "my-ec2" {
  ami = data.aws_ami.my-ami.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.my_subnet.id
  availability_zone = var.availability_zone
  vpc_security_group_ids = [ aws_security_group.my-sg.id ]

  associate_public_ip_address = true
  
  key_name = var.my_key_name

  user_data = "./entry-script.sh"
  tags = {
    Name = "${var.env_prefix}-dev-ec2"
  }
}
```

Now I will `terraform destroy --auto-approve` and `terraform apply --auto-approve` it again I should see my Nginx container running

![Screenshot 2025-06-22 at 13 00 30](https://github.com/user-attachments/assets/b1a000bf-c640-43c4-9f04-f60d31b4b256)

<img width="706" alt="Screenshot 2025-06-22 at 13 01 14" src="https://github.com/user-attachments/assets/5a73a2ba-4823-42d6-b617-9964daebeddc" />


## CD Stage

### Automatically provision EC2 instance using TF

#### Install Terraform inside Jenkins

SSH into a Server where I deployed Jenkins : `ssh root@<ip-address>`. 

Then I will `docker exec -it <container-id> -u 0 /bin/bash` inside the jenkins container as root user . 

To check what Linux distribution of my container is  : `cat /etc/os-release`

This is a Document to install Terraform in Linux Debian (https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

#### SSH key pair for the server 

I will give my `.pem` key that I created from AWS before to Jenkins 

Go to Jenkins UI -> Credentials -> Add Credentials -> Choose SSH username with private key

- Username would be `ec2-user`

- Private I will get from `cat ~/.ssh/terraform.pem`

#### Configure variables.tf file 

I need to added default value into my variables.tf file so I don't have to commit my `terraform.tfvars` in the Repo . Jenkins will use it as a default value 

If I want to Change any value of it I use `TF_VAR_<variable-name>` inside my Jenkinsfile 


```
variable "cidr_block" {
  default = "10.0.0.0/16"
}
variable "subnet_cidr_block" {
  default = "10.0.0.0/24"
}
variable "availability_zone" {
  default = "us-west-1a"
}
variable "my_ip_address" {
  default = "157.131.152.31/32"
}
variable "instance_type" {
  default = "t3.micro"
}
variable "env_prefix" {
  default = "development"
}
variable "my_key_name" {
  default = "terraform"
}
```

#### Create AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY 

Terraform need my AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY in order to connect to my AWS

Goto Jenkins UI -> Credentials -> Create Credentials -> Choose Secret Text 

#### Provision Server 

I will Create a `Provision Server` Stage 

First Inside the Stage I need to set ENV to reference my AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY 

Also If I need to override any Terraform value I can use `TF_VARS_<variables-name>` in that 

Then inside step I need to use `dir('terraform')` to make sure Jenkins work on that folder 

This is what my stage look like 

```
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
````























