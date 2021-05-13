def registryName = "acrsrvntestnc81.azurecr.io"
def imageName = "${registryName}/techchallengeapp"
def imageTag

pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo "Running Docker build for ${env.BUILD_ID}..."
                script {
                    // Gets version number from repo to use with image tage
                    versionJSON = readJSON file: 'version.json'
                    imageTagPrefix = versionJSON.version
                    if (env.BRANCH_NAME == 'master') {
                        // If running the main branch, (version).(build)
                        imageTag = "${imageTagPrefix}.${env.BUILD_ID}"
                    } else {
                        // If running another branch, dev-(version).(commit)
                        imageTag = "dev-${imageTagPrefix}.${env.GIT_COMMIT.substring(0,7)}"
                    }
                    docker.withServer('tcp://docker:2376', 'Docker-Certificate-Integration') {
                        docker.build("${imageName}:${imageTag}")
                    }
                }
            }
        }
        stage('Deploy') {
            steps {
                echo "Just imagine we're invoking the deploy pipeline to deploy ${env.BUILD_ID} to a dev or integration environment..."
            }
        }
        stage('Test') {
            steps {
                echo "Just imagine we're running functional tests for build ${env.BUILD_ID}..."
            }
        }
        stage('Push') {
            options {
                azureKeyVault(
                    credentialID: 'Azure-TestChallenge-SP', keyVaultURL: 'https://kvsrvntestnc81.vault.azure.net', 
                    secrets: [
                        [envVariable: 'ACR_USER', name: 'container-registry-user', secretType: 'Secret'],
                        [envVariable: 'ACR_PASS', name: 'container-registry-password', secretType: 'Secret']
                    ]
                )
            }
            steps {
                echo "Pushing build ${env.BUILD_ID} to container registry..."
                script {
                    docker.withServer('tcp://docker:2376', 'Docker-Certificate-Integration') {
                        docker.withRegistry('https://acrsrvntestnc81.azurecr.io', 'Container-Registry-Creds') {
                            sh(script: "docker push ${imageName}:${imageTag}", label: 'Pushing version tag...')
                        }
                    }
                }
            }
        }
    }
}