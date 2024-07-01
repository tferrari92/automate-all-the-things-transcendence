# CROSSPLANE-NOTES

## Deletion
In order for any Managed Resource to be destroyed succesfully we need 4 things to exist during the deletion process:
1. The ProviderConfig that manages that Managed Resource
2. The secret that that ProviderConfig uses to connect to the provider, in our case AWS.
3. The Provider which provides the API for that Managed Resource.
4. Crossplane itself to be deployed in the cluster to work its magic.

If any of these things gets deleted before the Manged Resource is, the Managed Resource deletion will fail, leaving resources deployed in AWS consuming money. We don't want this.

So what did I do? 

We created 4 separate ArgoCD applications:
1. [crossplane application](/argo-cd/applications/infra/crossplane-application.yaml)
2. [providers application](/argo-cd/applications/infra/crossplane-providers-application.yaml)
3. [provider-configs application](/argo-cd/applications/infra/crossplane-provider-configs-application.yaml)
4. [managed-resources application](/argo-cd/applications/infra/crossplane-managed-resources-application.yaml)

We usually use this finalizer on applications:
```yaml
 finalizers:
    - resources-finalizer.argocd.argoproj.io 
```
This finalizer enables cascading deletes when implementing the App of Apps pattern. If this isn't used, when you remove the application yaml from git, the application will be removed from ArgoCD but the resources will remain active in the cluster. 

This is the behaviour we usually want. But not in this specific case. In this case we do want the resources we mentioned to remain active in the cluster until all Manged Resources are gone.

So I removed the finalizer from [crossplane application](/argo-cd/applications/infra/crossplane-application.yaml), [providers application](/argo-cd/applications/infra/crossplane-providers-application.yaml) and [provider-configs application](/argo-cd/applications/infra/crossplane-provider-configs-application.yaml). These resources don't create any Ingresses or PersistentVolumes, so there is no issue with them remaining active in the cluster until it's destruction.

This makes it possible for the [managed-resources application](/argo-cd/applications/infra/crossplane-managed-resources-application.yaml) to delete all its resources.


<!-- ## Cascade deployment & deletion
si pones los providers y rpoviderconfig en el mismo char t q crossplane nunca levanta ningunrecurso
"The Kubernetes API could not find pkg.crossplane.io/Provider for requested resource crossplane-system/provider-aws-ec2. Make sure the "Provider" CRD is installed on the destination cluster."
provider needs crossplane to deploy, providerconfig need provider

Sync waves don't seem to work in this case. So I had to:
1. Create a [providers application](/helm-charts/infra/crossplane/templates/custom-templates/providers-application.yaml) as a custom template inside the [Crossplane helm chart](/helm-charts/infra/crossplane/) with an Argo sync-wave of "1" so that it deploys only after al Crossplane chart resources are deployed. This application has all the Provider manifest but also:
2. A [provider-configs application](helm-charts/infra/crossplane/providers/provider-configs-application.yaml) with an Argo sync-wave of "1" so that it deploys only after all Providers have been deployed. It will deploy the [ProviderCofigs](/helm-charts/infra/crossplane/provider-configs/). In this case just one which is the AWS one... BUT ALSO:
3. A [crossplane-demo application](/helm-charts/infra/crossplane/provider-configs/crossplane-demo-application.yaml) which will deploy the [actual AWS Managed Resources... BUT ALSO!!!... just kidding, that's it.

<p title="Crossplane diagram" align="center"> <img img width="1000" src="https://i.imgur.com/kDIQR9v.jpg"> </p>

I repeat, THIS IS NOT how one is supposed to use Crossplne. We'll only do it like this to get used to the fundamentals.

This way we resolve the order in which they nedd to be deployed so we have no errors.
I had to find this workaround. not then most elegant solution. If you have any better ideas, I'm all ears


## Cascade deletion
At the time of deletion we need to make sure of three things:
1. The ProviderConfig doesn't get deleted before the Managed Resources: If it did, there wouldn't be anyone to send the request to AWS to have the Managed Resources deleted.
2. The aws-secret holding the credentials doesn't get deleted before the ProviderConfig: If it does, the ProviderConfig won't be able to connect to AWS.
3. The Providers don't get deleted before the Managed Resources: If they do the ProviderConfig won't know how to interact with the AWS APIs.


I created a kind fo application cascading effect where ProviderConfig cant be deleted until managed resources are delted (this is by design from Crossplane through the use of ProviderConfigUsages), Provider cant be deleted until ProviderConfig is deleted (this is thanks to this application cascadde) and Crossplane application cant be deleted untip Providers application is deleted (also thanks to cascading effect), which means the secret is not deleted which would stop the ProviderConf from connecting to aws if it was

Managed Resources <- ProviderConfig <- Providers <- Crossplane


`The same behaviour doesnt exist for between Provider and Managed Resources, meaning the Managed Resources can be deleted before the Provider they are dependant on.

I thoufght this could be accomplished with sync waves but the managed resources exist iin a differnt application that the providers so it doesnt work

ARGO NO APPLICA EXITOSAMENTE LA APPLICATION DE CORSSPLANE POR LOS PROVIDER Y PROVEDR CONGI Q NO SE PUEDEN APLICAR PORQ NO EXISTEN LOS  CRDS CORRESPONDIENTES, EL TEMA ES Q LOS CRDS CORRESPONDIENTE NO SE EN QUE MOMENTO NI DE DONDE SALEN? LOS GENEREA LOS PODS? ARGO POR DEFAULT DEBERIA APLICAR PRIMERO ESTOS CRDS PERO EN EL CHART NO APARENCE LOS MANIFEST DE LOS CRD POR LO Q NO LOS RECONOCE COMO ALGO QUE TIENE QUE APLICARSE PRIMERO. COMO SE CREAN Y DE DONDE SALEN LOS CRD DE PROVIDEER Y PROVIDERCONFIG???? 

      # We also need to delete all Crossplane managed resources before the Crossplane application is deleted. If the ProviderConfig is deleted before the managed resources, the managed resources will be orphaned and not deleted. See: https://github.com/crossplane/crossplane/issues/1737

siempre me queda un securitygroupingressrules.ec2.aws.upbound.io random y hay q editarle el finalizer pa q no joda. Es por esto? https://github.com/crossplane-contrib/provider-upjet-aws/issues/1242

<br/> -->

<br/>

## Extra Providers and ProviderConfigs

I added some extra Provider and ProviderConfig manifests for Azure and GCP which are all commented out. They are there just to show that you could deploy to any hyperscaler if you wanted to. 

<br/>

## Elasticache still dependant on infra deployed through Terraform

We will be moving away from this approach, but for now, to keep things simple, the ElastiCache DBs that meme-web-backends use are still deployed within the original subnet created for them through Terraform. 

You can see that in the [deploy-infra pipeline](/.github/workflows/01-deploy-infra.yaml) we get the ID of the subnet with a Terraform output and save it to the [backend's helm chart values](/helm-charts/systems/meme-web/backend/values.yaml).

<br/>

## No more SealedSecret for meme-web-backend
We used to create a SealedSecret which in turn created a secret which held the password that the backend services used to connect to the ElastiCache DBs. We don't need to do this anymore because the [Crossplane ElastiCache ReplicationGroup](/helm-charts/systems/meme-web/backend/templates/crossplane/elasticache-replication-group.yaml) allows us to define ```autoGenerateAuthToken``. This function will automatically create a K8s Secret with autogenerated password. 

We then reference this secret in the [Deployment](/helm-charts/systems/meme-web/backend/templates/deployment.yaml). This way the value of the password will not be pushed to git and no person even needs to even know what the value is, which is even better.
