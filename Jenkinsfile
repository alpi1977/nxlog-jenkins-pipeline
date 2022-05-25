pipeline {

    agent any

    environment {
        INPUT_SERVER=""
        INPUT_APP_VERSION=""
    }

    stages {

        stage("Interactive Input") {
            steps {
                script {

                    // Get the input
                    def userInput = input(
                            id: 'userInput', message: 'Enter path of test reports:?',
                            parameters: [
                                [$class: 'ChoiceParameterDefinition',
                    choices: ['Ubuntu_18_04','Amazon_Linux_2'].join('\n'),
                    name: 'Server',
                    description: 'Select the Operating System'],
                                [$class: 'ChoiceParameterDefinition',
                    choices: ['v1','v2'].join('\n'),
                    name: 'AppVersion',
                    description: 'Select Your App Version']
                            ])

                    // Save to variables. Default to empty string if not found.
                    INPUT_SERVER = userInput.Server?:''
                    INPUT_APP_VERSION = userInput.AppVersion?:''

                    // Echo to console
                    echo("Selected Server: ${INPUT_SERVER}")
                    echo("Selected Version: ${INPUT_APP_VERSION}")
                }
            }
        }
        stage("Create Server and App") {
            steps {
                script {
                    // def WORKING_DIR
                    echo 'Creating Prod Server via Terraform...'
                    sh "rm -rf nxlog*"
                    sh "cp -r /tmp/.aws ~/"
                    sh "git clone https://github.com/alpi1977/nxlog-jenkins-pipeline.git"
                    // WORKING_DIR=sh(script:'pwd', returnStdout:true).trim()
                    dir("${env.WORKSPACE}/nxlog-jenkins-pipeline/${INPUT_SERVER}"){  
                        // env.WORKSPACE = /var/lib/jenkins/workspace/nxlog-pipeline
                        sh "sed -i 's/branchX/${INPUT_APP_VERSION}/' ./bookstoreapi.tf"
                        sh "terraform init"
                        sh "terraform apply --auto-approve"
                    }

                }
            }
        }
        stage('Destroy Resources') {
            steps {
                script {
                    input message: 'Proceed?', ok: 'Yes', submitter: 'admin'
                }
                echo "Good luck!"
            }
            post {
                aborted{
                    echo "Aborting Resources..."
                    dir("${env.WORKSPACE}/nxlog-jenkins-pipeline/${INPUT_SERVER}"){
                        sh "terraform destroy --auto-approve"
                    }
                }            
            }
        }
    }
}