- [Clone Java Maven Application](#Clone-Java-Maven-Application)

- [Build Dockerfile for Java Maven Application](#Build-Dockerfile-for-Java-Maven-Application)

- [Set up Jenkins CI CD pipeline](#Build-Jenkins-CI-CD-pipeline)

  - [Create a Server for Jenkins on Digital Ocean](#Create-a-Server-for-Jenkins-on-Digital-Ocean)
 
  - [Run Jenkins as a Docker Container](#Run-Jenkins-as-a-Docker-Container)
 
  - [Install Docker inside Jenkins container](#Install-Docker-inside-Jenkins-container)

  - [Install Stage View Plugin](#Install-Stage-View-Plugin)
 
- [Terraform](#Terraform)

  - [Configure AWS Provider](#Configure-AWS-Provider) 

  - [Provision AWS Infrastructure](#Provision-AWS-Infrastructure)
 
  - [Create VPC and Subnet](#Create-VPC-and-Subnet)
 
  - [Provision Route Table](#Provision-Route-Table)
 
  - [Connect VPC to Internet using Internet Gateway](#Connect-this-VPC-to-Internet-using-Internet-Gateway)
 
  - [Provision Security Group](#Provision-Security-Group)
 
  - [Subnet Association with Route Table](#Subnet-Association-with-Route-Table)
 
  
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

`variables.tf`: Is to define a variables in Terraform . And I can define its values in `terraform.tfvars` . `terraform.tfvars` should be list in `.gitignore`

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

























