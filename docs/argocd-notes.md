# ARGOCD IS SELF-MANAGING
As you can see, in the repository under helm-charts directory there's an ["argo-cd" directory](/helm-charts/infra/argo-cd/). There's also an [application.yaml](/argo-cd/self-manage/argocd-application.yaml) that points to this directory where the ArgoCD Helm Chart is located. This means that ArgoCD is managing itself.

If we wanted, for example, to add a new Ingress for ArgoCD, we would make the necessary changes within this directory, ArgoCD would identify the changes and apply them, effectively monitoring and operating itself.

# CUSTOMIZING HELM CHARTS
When using Helm charts, it's important never to modify the original chart files.

If we need to make changes, we will do so in the values-custom.yaml file, never in the original values.yaml. This way, we ensure an easy record of the changes we made and what the original chart configurations are.

The ArgoCD applications we create are configured to fetch the custom values and prioritize them over the default values.

If, for some reason, making changes in the values-custom.yaml is not enough to achieve the results we are looking for, we can create new manifests within the chart's “templates” directory, but we will always save these new manifests within the “templates-custom” subdirectory inside templates. This serves the same purpose as the values-custom, keeping track of which changes are ours and what the original configurations are.

## Creating new ArgoCD applications
If we wanted to deploy a new tool in the cluster, let's use Jenkins as an example, we would upload the Jenkins Helm chart to the repository within its own directory.
Once the "jenkins" directory is created with its Helm chart inside, we would move on to create an application in ArgoCD that monitors the jenkins directory. DO NOT DO THIS YET! Keep reading.
The manifest for this application would look like this:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: jenkins
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io # Adding the finalizer enables cascading deletes when implementing the App of Apps pattern. If this isn't used, when you remove the application yaml from git, the application will be removed from ArgoCD but the resources will remain active in the cluster
spec:
  project: default
  destination:
    namespace: jenkins
    server: https://kubernetes.default.svc
  source:
    repoURL: https-infra-tools-helm-charts
    path: jenkins
    helm:
      valueFiles:
        - values-custom.yaml
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true

```

We could go to the ArgoCD UI and create the application there, or directly execute a “kubectl create” on this application.yaml. But we won't do that; instead, we will use the pattern called App of Apps.

## WHAT IS THE APP OF APPS PATTERN?
The "App of Apps" pattern in Argo CD is a deployment management strategy in Kubernetes that allows for the efficient and scalable handling of multiple applications.
In this pattern, a master application is created in ArgoCD, which in turn manages other secondary applications. Each secondary application is defined in its own directory in a Git repository and is configured individually.

The master application contains references to the application.yaml of the secondary applications, allowing ArgoCD to deploy and update all the secondary applications in a coordinated manner. This approach offers modular organization and better management of dependencies between applications, facilitating scalability and maintenance.


# OW DO WE IMPLEMENT IT AT? (PART 2)
For the implementation of the App of Apps pattern , we create a new repository: http/argocd-application-manifests.
Here, we will find the Application type manifests for each of the tools we have in the repo httpa/k8s-infra-tools-helm-charts.

# Creating new applications in ArgoCD
Continuing with the creation of new applications. We already have:
Our Helm chart or the individual manifests of our new tool saved in its own directory at the root of https/k8s-infra-tools-helm-charts.
The application.yaml (like the one we saw for Jenkins) ready with all its appropriate values.

With these two things ready, we will go to this new repository (argocd-application-manifests) and in the "applications" directory we will create a new file (in this case jenkins-application.yaml) and paste the content of the application.yaml.

Once that file is committed, it's just a matter of waiting for the master application in ArgoCD to detect this jenkins-application.yaml. At that moment, it will create a new application in ArgoCD, and this second application will be the one monitoring the "jenkins" directory in https/k8s-infra-tools-helm-charts.

This completes the process of deploying new tools in the cluster. All that's left is to wait for ArgoCD to do its job.
IMPORTANT: ArgoCD pulls from the repos to look for changes every 3 minutes.

<!-- # App of Projects Pattern
One last clarification is that at , we are also using the App of Apps pattern for ArgoCD projects.

Projects in Argo CD are units of organization and access control that group related applications. They allow for the definition of deployment policies and security restrictions, such as which clusters and Kubernetes resources can be used and who can make changes.

For the creation of new projects, we need to go to the self-manage/appprojects directory in https:argocd-application-manifests. Continuing with the example of Jenkins, we would add a manifest like this there:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: jenkins
  namespace: argocd
spec:
  clusterResourceWhitelist:
  - group: '*'
    kind: '*'
  destinations:
  - namespace: '*'
    server: '*'
  orphanedResources:
    warn: false
  sourceRepos:
  - '*'
```

This example leaves the project completely open, but if we wanted to limit it, we could modify those values. -->

# Deleting Tools
Continuing with the example of Jenkins, all we need to do to remove the Jenkins deployment from the cluster is to delete the jenkins-application.yaml file in the repo httpst/argocd-application-manifests.
The master application in our App of Apps pattern will detect the absence of the Jenkins application and will trigger the necessary steps to remove Jenkins from the cluster.
Although it is not necessary, we should also delete the Jenkins directory in the repo https:/k8s-infra-tools-helm-charts for the sake of order and neatness.

# USERS AND TOKENS
Users and their passwords can be created through GitOps as it can be seen in the [values-custom.yaml](/helm-charts/infra/argo-cd/values-custom.yaml). 

API tokens must be created through argocd cli. Admin user cannot issue tokens. A user doesn't need to have a password to issue a token, in othe words, users that have no password can still issue tokens. You can see how to issue a token with argocd cli in the [deploy-in-minikube.sh script](/deploy-in-minikube.sh).
