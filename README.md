# Project NXLog-Jenkins-Pipeline: 

The purpose of this pipeline project is to prepare a high-level overview of an ideal Jenkins pipeline for the following process: 

A user chooses: 
    •	an operating system from a pre-populated list  
    •	version of the piece of software the company develops 
        and starts the pipeline that creates a VM for the given operating system 
    •	configures remote access for the user who executed the pipeline 
    •	installs the software for the given version 

## Project Architecture

![](NXLog%20Pipeline%20Project%20Architecture.png) 

## Outline

- Part 1 - Creating Local Project Files

- Part 2 - Pushing Project Files from Local Repository to GitHub Repository 

- Part 3 - Launch Jenkins Server via Terraform

- Part 4 - Building Jenkins Pipeline via Jenkins Server


## Part 1 - Creating Local Project Files


- Create the required project files as follows:

    1. Create a Terraform file (install_jenkins_server.tf) to launch two resources:
        * Amazon Linux2 EC2 instance as a Jenkins Server 
        * Security Group  (jenkins-server-sec-gr) (SSH PORT 22, HTTP PORT 80 and 8080)
    
    2. Create a userdata script file (install-jenkins-server.sh) to launch Jenkins Server including Jenkins, Docker and Git installed 
    
    3. Create a Dockerfile with an alpine image pulled, flask and MySQL installed, bookstore-api.py ran on it

    4. Create a requirements.txt file in order to get the flask and flask-mysql apps installed
    
    5. Create a docker-compose.yaml file including two services namely, MySQL 5.7 database and Bookstore webserver of those images are pulled from the related Docker Hub repositories 
    
    6. Prepare two bookstoreapi python file (already created by developers) for both versions (v1 and v2) of Amazon Linux2 and Ubuntu 18.04 EC2 instances, including Flask module, MySQL database and functions of listing, creating, updating and deleting books from the database of the webserver of bookstore application
    
    7. Create a Jenkinsfile in order to build a Jenkins pipeline icluding 3 stages :
       * interactive input from user (server/operating system and app version choices)
       * Create server and app
       * Destroy resources (proceed or abort choices) that runs the terraform destroy command or keep going on 



## Part 2 - Pushing Project Files from Local Repository to your GitHub Repository

- Create a new public repo in your GitHub account and clone this repo into your local PC with the command below:

```bash
$ git clone <https link of your new GitHub repository> 
```

- Copy all the files (except Jenkins server's terraform and script files) created in Part 1 to your local repo/directory

- Push all the files to your GitHub repo:
  
```bash
$ git add .
  git commit -m "write down your commit comment/update here" 
  git push 
```

- Create two new git branches for your new GitHub repo, namely v1 and v2, modify  bookstore-api.py file (line 141 should be "Welcome .... Service v1" and "Welcome ... Service v2"), save each of them respectively and push these changes to the new branches you have just created (v1 and v2):
  
```bash
$ git branch v1
  git checkout/switch v1
  # modify and save the python file as specified "Welcome ... Service v1" 
  git add . 
  git commit -m "xxx updated" 
  git push
  
  # do the same changes for v2 branch
  
  git checkout/switch main
  git branch v2
  git checkout/switch v2
  git add . 
  git commit -m "xxx updated" 
  git push 
```

## Part 3 - Launch Jenkins Server via Terraform

- Go to the folder where your Jenkins server terraform and script files are

- Run the commands below:


```bash
$ terraform init
  terraform plan
  terraform apply
```

- Wait for a while (about 3 minutes) and check your AWS console if the Jenkins Server EC2 instance and security group is ready or not.

- Upon the readiness of your resources, copy the Jenkins Server initial password given, which will be shown on your local terminal's bottom lines and click the link given (http address including Jenkins Server's Public IP) at the bottom in order to log in your Jenkins Server the initial password you just copied and with the user name and other login informations such as your new password, full name and email address you will specify afterwards.


## Part 4 - Building Jenkins Pipeline via Jenkins Server

- Enter the initial Jenkins Server password you just copied to unlock Jenkins server

- Click "Install suggested plugins" including pipeline plugin

- Write down the required login information to create your first admin user and click "save and continue"

- Push the "save and finish" button on the next step

- Click "Start using Jenkins"

- Click "New Item" on the Jenkins interface, enter an item name, choose "Pipeline" and click "OK"

- Click the "GitHub project" choice in the "General" tab, copy your GitHub repo link you use for this pipeline project and paste it to the "Project url" space.

- Click "Advanced Project Options" tab, go to your local terminal, copy your Jenkinsfile's text, paste it to the "Pipeline Script" section and push the "Save" button

- Afterwards, push the "Build Now" button on the left-hand side menu to start the Jenkins pipeline building process

- On the "Stage View" part, you will see the pipeline building stages

- During the first stage, right click on the blue box under the "Interactive Input" stage, choose the server (Amazon Linux2 or Ubuntu 18.04) and AppVersion (v1 or v2) you wanted and click "Proceed".

- Upon proceeding, the building process moves to the next stage, that is "Create Sever and App" stage.

- You can check the pipeline Build process and logs on the left-hand menu at the bottom by clicking the blue colored #1 button.

- Click "Console Output" button on the left-hand menu and check the ongoing process. These steps are the ones in your Jenkinsfile's stages such as "terraform init", "terraform apply" commands in order to create your bookstore webserver

- Go back to the previous pipeline menu by clicking on your pipeline name (top-left of the screen, next to Dashboard)

- Upon the completion of the pipeline building process, you see the "abort or proceed" buttons on the screen as mentioned on the 3rd stage (Destroy resources) of your Jenkinsfile

- Do not click any button, go to you AWS console and check if the "Web Server of Bookstore" EC2 instance is running or not

- Click the new Web Server instance and connect via SSH or Amazon EC2 console.

- Check the Web Server by using the commands below:

```bash
$ docker image ls # check the image, but it might take a while to create an image via your terraform file bookstoreapi.tf. You should see 3 images created by your dockerfile and docker-copmose.yaml file. These are python alpine image, mysql 5.7 image and bookstore image
```
- Upon seeing your image creation, go to your web browser and paste your new Web Server Bookstore instance's Public IP.

- You will see the main page shows the "Welcome to Developer's Bookstore API Service V1 (or V2 according to your choice in the beginning of Jenkins pipeline building process)" 

- If you type "/books" at the end of the browser's address tab, you will see the book list as coded in the bookstore-api.py file

- You can type "/1" or "/3" (first book or third book in the web server bookstore database) next to the /books on browser in order to check the books with their ID numbers.

- You can go back to Jenkins Server, push the abort button, destroy the instance on the Jenkins Server menu and try the other server (Ubuntu 18.04 and its version). Please make sure that the webserver instance is terminated and security group is deleted on your AWS console. Upon termination, you can push the "Build Now" button again for the next Jenkins pipeline building process.