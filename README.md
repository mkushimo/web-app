# Jenkins Pipeline for Building and Pushing Docker Images

This repository contains a Jenkins pipeline script to automate the process of:

1. Cloning source code from a Git repository.
2. Building and packaging the application using Maven.
3. Building a Docker image with the application artifact.
4. Pushing the Docker image to a Docker Hub repository.

---

## **Pipeline Overview**

This pipeline is implemented using **Jenkins Declarative Pipeline** syntax and performs the following steps:

### **1. Code Clone**

- **Description**: This stage clones the source code from a GitHub repository.
- **Tool**: Git plugin in Jenkins.
- **Details**:
    - Uses Jenkins credentials (`Github-Cred`) for secure access to the repository.
    - The repository URL is configured in the pipeline.

### **2. Build**

- **Description**: This stage builds and packages the application using Maven.
- **Tool**: Maven (configured as a tool in Jenkins).
- **Details**:
    - Executes the Maven command `mvn clean package` to generate a deployable artifact (e.g., `.jar` or `.war` file).
    - Maven is referenced as a Jenkins tool (`maven3.9.1`).

### **3. Build Docker Image**

- **Description**: This stage creates a Docker image using the application artifact and a `Dockerfile`.
- **Tool**: Docker.
- **Details**:
    - The `Dockerfile` is fetched from the repository.
    - The `docker build` command creates an image tagged with the application name and version.

### **4. Push to Docker Hub**

- **Description**: This stage pushes the Docker image to a Docker Hub repository.
- **Tool**: Docker.
- **Details**:
    - Uses Jenkins credentials (`docker-cred`) to securely authenticate with Docker Hub.
    - The image is tagged and pushed to the repository under the format:
        
        ```
        <docker-username>/<image-name>:<tag>
        
        ```
        

---

## **Pipeline Script**

```groovy
pipeline {
    agent any

    tools {
        maven "maven3.9.1"
    }

    environment {
        DOCKER_IMAGE_NAME = "rbc-webapps" // Name of the Docker image
        DOCKER_IMAGE_TAG = "1.0.0"        // Version of the Docker image
    }

    stages {
        stage("Code Clone") {
            steps {
                echo "Cloning the Git repository..."
                git credentialsId: 'Github-Cred', url: '<https://github.com/mkushimo/web-app.git>'
            }
        }

        stage("Build") {
            steps {
                echo "Building the application with Maven..."
                sh "mvn clean package"
            }
        }

        stage("Build Docker Image") {
            steps {
                echo "Building Docker image..."
                sh "docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} ."
            }
        }

        stage("Push to Docker Hub") {
            steps {
                echo "Pushing Docker image to Docker Hub..."
                withCredentials([usernamePassword(credentialsId: 'docker-cred', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker tag ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} $DOCKER_USER/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                    docker push $DOCKER_USER/${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG}
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully and image pushed to Docker Hub!"
        }
        failure {
            echo "Pipeline failed. Check logs for details."
        }
    }
}

```

## **Pipeline Details**

### **Tools and Plugins**

- **Maven**: Used to build and package the application.
- **Git**: Used to clone the repository.
- **Docker**: Used to build and push the Docker image.
- **Jenkins Credentials**:
    - `Github-Cred`: Stores GitHub credentials for secure repository access.
    - `docker-cred`: Stores Docker Hub credentials for secure login and image push.

### **Environment Variables**

- `DOCKER_IMAGE_NAME`: Specifies the name of the Docker image to build (e.g., `rbc-webapps`).
- `DOCKER_IMAGE_TAG`: Specifies the version of the Docker image (e.g., `1.0.0`).

## **Pre-Requisites**

1. **Jenkins Server**:
    - Ensure Jenkins is installed and running.
    - Jenkins agents must have Docker and Maven installed.
2. **Credentials Setup**:
    - **GitHub Credentials (`Github-Cred`)**:
        - Add GitHub username/password or personal access token in Jenkins under `Manage Jenkins > Manage Credentials`.
    - **Docker Hub Credentials (`docker-cred`)**:
        - Add Docker Hub username/password in Jenkins under `Manage Jenkins > Manage Credentials`.
3. **Dockerfile**:
    - A valid `Dockerfile` must be present in the root directory of the repository. Example:
        
        ```
        dockerfile
        CopyEdit
        FROM openjdk:11-jre-slim
        WORKDIR /app
        COPY target/webapp.jar /app/webapp.jar
        ENTRYPOINT ["java", "-jar", "webapp.jar"]
        
        ```
        

---

## **Running the Pipeline**

1. Configure the Jenkins job:
    - Select "Pipeline" as the job type.
    - Copy and paste the pipeline script into the job configuration.
2. Trigger the job:
    - Click "Build Now" to execute the pipeline.
3. Verify:
    - Check the logs to ensure the pipeline runs successfully.
    - Verify the Docker image in your Docker Hub repository:

