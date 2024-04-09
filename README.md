# Table of Contents <!-- omit in toc -->
<div id="user-content-toc">
  <ul>
    <li><a href="#deploy-to-kubernetes">Deploy to Kubernetes</a></li>
    <li>
        <a href="#github">GitHub</a>
        <ul>
        <li>
            <a href="#authenticate-with-github-app">Authenticate with GitHub App</a>
            <ul>
                <li><a href="#create-github-app">Create Github App</a></li>
                <li><a href="#generate-private-key-for-auth-to-the-github-app">Generate private key for auth to the GitHub App</a></li>
                <li><a href="#install-app-to-your-org">Install App to your orgs</a></li>
                <li><a href="#add-app-creds-to-jenkins">Add App creds to Jenkins</a></li>
                <li><a href="#access-github-repos-from-pipeline">Access GitHub Repos from Pipeline</a></li>
            </ul>
        </li>
        </ul>
    </li>
    <li>
        <a href="#mulitbracnh-pipeline">Mulitbracnh pipeline</a>
        <ul>
            <li><a href="#create-multibranch-pipeline-for-github-private-repo">Create Multibranch pipeline for GitHub private repo</a></li>
        </ul>
    </li>
    <li>
        <a href="#environment">Evironment</a>
        <ul>
            <li><a href="#add-global-env-variables">Add global env variables</a></li>
            <li><a href="#set-env-variables-in-pipeline">Set env variables in Pipeline</a></li>
        </ul>
    </li>
    <li>
        <a href="#gcp">GCP</a>
        <ul>
            <li><a href="#bind-k8s-service-acc-to-gcp-service-acc">Bind K8s service acc to GCP service acc</a></li>
        </ul>
    </li>
  </ul>
</div>

## Deploy to Kubernetes
Use the Helm Chart from the repo
```sh
helm upgrade --install jenkins ./helm/ -f ./helm/vars.yaml --namespace=jenkins-ci
```

## GitHub
### Authenticate with GitHub App
So let's do this step by step starting from scratch

#### Create Github App
For first you need to crete GitHub App. Open "Your organizations" page on GitHub and select Settings for org. From there go to Developer Settings -> GitHub App -> New GitHub App.
<div>
    <video 
        width="600" 
        height="400" 
        controls 
        src="https://www.dropbox.com/scl/fi/ytvxu6fefeuvsbfou1gve/01.mp4?rlkey=jim10uiyiap7su2kcz0uk2oyw&dl=1"
        style="margin-top: -20px; margin-bottom: 10px">
    </video>
</div> 
Perform next actions:
<div>
    <video 
        width="600" 
        height="400" 
        controls src="https://www.dropbox.com/scl/fi/a1x559gi0z5kpuzcv2cd2/02.mp4?rlkey=wiyaqxfaajim7u3o6bo0lbaie&dl=1"
        style="margin-top: -20px; margin-bottom: 10px">
    </video>
</div>

- Fill the "App Name" and "Description" fields
- Put your org url on GitHub the "Homepage URL" field
- Put your Jenkins instance URL with path "/github-webhook" to the "Webhook URL"
- Grant next repo permissions:
    - Administration: Read-only
    - Checks: Read & write
    - Contents: Read & write
    - Metadata: Read-only
    - Pull requests: Read-only
- Subscribe to following events:
    - Check run
    - Check suite
    - Pull request
    - Push
    - Repository
- In "Where can this GitHub App be installed?" block choose:
  - "Only on this account" if you want to install app only for the current org
  - "Any account" if you want to use it elsewhere (for the multiple org maybe)
- Click "Create GitHub App" Button 


#### Generate private key for auth to the GitHub App
Go again to the GitHub Apps in your org "Developer Settings" and press "Edit" on created app. Under Private keys, select "Generate a private key" and download the key
<div>
    <video 
        width="600" 
        height="400" 
        controls src="https://www.dropbox.com/scl/fi/p4twk94azhewuexxql70i/03.mp4?rlkey=oh5wjj095gbrmjmdh1fqh076h&raw=1"
        style="margin-top: -20px; margin-bottom: 10px">
    </video>
</div>
Convert key to acceptible for Jenkins format:```openssl pkcs8 -topk8 -inform PEM -outform PEM -in github-key.pem -out converted-github-key.pem -nocrypt```
<div>
    <video 
        width="600" 
        height="400" 
        controls src="https://www.dropbox.com/scl/fi/zxv25hk0h83hqeoyu6v85/04.mp4?rlkey=so0flwicfy3ncd8ul3ik3j7ht&raw=1"
        style="margin-top: -7px; margin-bottom: 10px">
    </video>
</div>

#### Install App to your org
Now it's time to install app to your org. Last time, navigate to the "Edit" page for your GitHub App and choose "Install app" in the sidebar menu.
Then Select organiztion where you wish to install App and org repos to which you grant permissions:
<div>
    <video 
        width="600" 
        height="400" 
        controls src="https://www.dropbox.com/scl/fi/mwrpynn7pprl135u4vr4h/05.mp4?rlkey=gcmrjrj5jmm0ez5jk5wuc48b2&raw=1"
        style="margin-top: -20px; margin-bottom: 10px">
    </video>
</div>

#### Add App creds to Jenkins
The final counter is to save app creds to the Jenkins instance.
- Login to Jenkins
- Go to "Manage Jenkins" -> "Credentials" -> "Global"
- Select "Add Credentials"
- Choose GitHub App as the Kind
- Enter your GitHub App Name in the "ID" field
- Enter your GitHub App ID in the "App ID" field
- Copy converted private key to the "Key" field
- Click "OK"

### Access GitHub Repos from Pipeline
Now you can read and write to your GitHub repos from Jenkins Pipelines:
```groovy
pipeline {

  agent {
    kubernetes {
      inheritFrom "slave"
      defaultContainer "jnlp"
    }
  }

  stages {
    stage("Get Code from Repo") {
      steps {
        withCredentials([usernamePassword(credentialsId: 'creds-id',
                                        usernameVariable: 'GITHUB_APP',
                                        passwordVariable: 'GITHUB_ACCESS_TOKEN')]) {
            checkout scmGit(
            branches: [[name: "master"]],
            userRemoteConfigs: [[url: "https://${GITHUB_APP}:${GITHUB_ACCESS_TOKEN}@github.com/org/repo.git"]])
    }
      }
    }

    stage("Change something") {
      steps {
        container("python") {
          sh """
          echo 'Make some changes'
          """
        }
      }
    }


    stage("Push Changes to Repo") {
      steps {
        container("jnlp") {
          withCredentials([usernamePassword(credentialsId: 'jenkins-stacktome',
                                            usernameVariable: 'GITHUB_APP',
                                            passwordVariable: 'GITHUB_ACCESS_TOKEN')]) {
          sh """
          git add .
          git commit -m 'yeah, it works'
          git push --set-upstream origin master
          """
          }
        }
      }
    }

  }

}
```

## Mulitbracnh pipeline
Jenkins Multibranch Pipeline is quite straitforward. It is a folder of Jobs which are defined in one repo but on different branches. 
So if you branch has a Jenkinsfile with pipeline script, Jenkins will automatically recognize it and create separate Job. 

### Create Multibranch pipeline for GitHub private repo

- Login to Jenkins and nn Dasboard click "Add New Item" button <br>
<img src='./img/multibranch/01.png' width=70% style="margin: 17px">
- Choose "Multibranch Pipeline" and enter a name for it <br>
<img src='./img/multibranch/02.png' width=70% style="margin: 17px">
- Fill the "Display name" and "Descriptions" fields if you want to
<img src='./img/multibranch/03.png' width=70% style="margin: 17px">
- In "Branch Sources" select GitHub <br>
<img src='./img/multibranch/04.png' width=70% style="margin: 17px">
- Choose existing GitHub App private key as a creds <br>
<img src='./img/multibranch/05.png' width=70% style="margin: 17px">
- Specify your repo URL <br>
<img src='./img/multibranch/06.png' width=70% style="margin: 17px">
- Adjust other options by your current needs <br>
<img src='./img/multibranch/07.png' width=70% style="margin: 17px">
- Leave "Build Configuration" unchanged <br>
<img src='./img/multibranch/08.png' width=70% style="margin: 17px">
- Save. If you didn't mess up, folder with your Pipelines should appear on Dashboard <br>
<img src='./img/multibranch/09.png' width=70% style="margin: 17px">

# Environment
### Add global env variables
From Jenkins Dashboard go to the Manage Jenkins an then to the System. Scroll down to Global Properties. Check the Environment Variables box. 
Add key and value for env and save. Now you can use your env variable in all Pipelines like this:
```groovy
pipeline {

  agent {
    kubernetes {
      inheritFrom "slave"
      defaultContainer "jnlp"
    }
  }

  stages {
    stage("Access Global Env Var") {
      steps {
       sh "echo ${env.MY_GLOBAL_VAR}"
      }
    }
  }

}
```

### Set env variables in Pipeline 
You can define env vars specific to Pipeline using environment block:
```groovy
pipeline {

  agent {
    kubernetes {
      inheritFrom "slave"
      defaultContainer "jnlp"
    }
  }

  environment {
        USER = "Dwight Schrute"
        POSITION = "Assistant Regional Manager"
  }

  stages {
    stage("Access Pipeline Env Var") {
      steps {
        sh "echo ${USER} is ${POSITION}"
      }
    }
  }

}
```


# GCP
### Bind K8s service acc to GCP service acc
Enable Workload Identity Federation for existing cluster: 
```sh
gcloud container clusters update <cluster> \
    --workload-pool=<project-id>.svc.id.goog
```

Create IAM service account:
```sh
gcloud iam service-accounts create <iam-service-acc-name> \
    --project=<project-id>
```

Bind IAM service acc to role that you need:
```sh
gcloud projects add-iam-policy-binding <project-id> \
    --member "serviceAccount:<iam-service-acc-name>@<project-id>.iam.gserviceaccount.com" \
    --role "roles/container.clusterAdmin"
```

Create an IAM policy that gives Kubernetes service acc access to the IAM service acc:
```sh
gcloud iam service-accounts add-iam-policy-binding <iam-service-acc-name>r@<project-id>.iam.gserviceaccount.com \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:<project-id>.svc.id.goog[<namespace>/<kubernetes-service-acc-name>]"
```

Annotate the Kubernetes service acc so GKE can see the link between the service accounts
```sh
kubectl annotate serviceaccount jenkins-admin \
    --namespace jenkins-ci \
    iam.gke.io/gcp-service-account=<iam-service-acc-name>@<project-id>.iam.gserviceaccount.com
```







