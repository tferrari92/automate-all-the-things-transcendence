# Cert-Manager Notes

## Staging And Production Issuers
Let's Encrypt offers two types of issuers for their SSL/TLS certificates: staging and production. These issuers serve different purposes in the certificate issuing process.

#### Staging Issuer:
**Purpose**: Primarily used for testing and development purposes.<br>
**Rate Limits**: More lenient, allowing for frequent generation of certificates without hitting rate limits that are imposed in the production environment.<br>
**Trust Level**: Certificates issued by the staging issuer are not trusted by browsers or operating systems, meaning they will generally trigger security warnings if used in a live environment.<br>
**Use Case**: Ideal for developers to ensure their systems are correctly configured for SSL/TLS without the risk of hitting rate limits or impacting live environments.

#### Production Issuer:
**Purpose**: Used for issuing certificates intended for live, public-facing websites.<br>
**Rate Limits**: Stricter rate limits compared to the staging environment. This is to prevent abuse and to manage the load on Let's Encrypt servers.<br>
**Trust Level**: Certificates issued are trusted by most browsers and operating systems, ensuring secure, encrypted connections without warnings.<br>
**Use Case**: Should be used when you are ready to deploy a secure website to the public.

In summary, the staging issuer is for testing and development, with more relaxed rate limits and untrusted certificates, while the production issuer is for live websites, with trusted certificates but stricter rate limits.

<br/>

## Problems we found
You can skip right to [The Solution](#the-solution) if you want. I'm gonna explain everything that went wrong just as a note to myself.

### The Ingress Problem
First I ran into **the Ingress problem**. We'll use Grafana as an example. I was using the following values in the Grafana chart values-custom.yaml:
```yaml
ingress:
  enabled: true
  annotations: 
    cert-manager.io/cluster-issuer: alb-staging-cluster-issuer
    # cert-manager.io/cluster-issuer: alb-production-cluster-issuer 

  hosts:
    - grafana.yourdomian.com

  tls: 
    - secretName: grafana-ingress-certificate 
      hosts:
        - grafana.yourdomain.com
```

This would make the ingress automatically generate a certificate.

When you create a certificate with an http01 solver, the certificate in turn creates child resources, ultimately creating a pod, a service and an ingress. The ingress directs to the service which directs to the pod which exposes the token that Let's Encrypt is expecting for validation.

All is fine and good with that, the problem is that there is another ingress, the actual ingress Grafana. For some reason, the ingress of Grafana takes precedence over the ingress of the certificate challenge, so that when any requests come into grafana.yourdomain.com, they get sent to the grafana pod instead of the certificate challenge pod, even when the request specifies the appropiate path (/.well-known/acme-challenge).

There's an Cert-Manager annotation (acme.cert-manager.io/http01-edit-in-place: "true") which is supposed to fix this by instead of creating a new ingress for the challenge, it would modify the Grafana ingress to direct /.well-known/acme-challenge traffic to the certificate challenge pod, but I could never make it work.

So, the first fix was to do this manually. I added a new backend to the Grafana ingress in the values-custom.yaml like this:
```yaml
ingress:
  extraPaths: 
    - backend:
        service:
          name: acme-http-solver
          port:
            number: 8089
      path: /.well-known/acme-challenge
```
This would send traffic meant for /.well-known/acme-challenge to the certificate challenge service, right? Wrong. The certificate child resources are created dynamically with dynamic names, so the name of the service would be something like acme-http-solver-XXXX where XXXX are some random digits. So I had to also manually create a service with a fixed name. In Grafana's chart templates/custom-templates directory I created the following acme-http-solver-service.yaml:
```yaml
apiVersion: v1
kind: Service
metadata:
 name: acme-http-solver
spec:
 ports:
   - name: http
     port: 8089
     protocol: TCP
     targetPort: 8089
 selector:
   acme.cert-manager.io/http01-solver: 'true'
 type: ClusterIP
```

This would effectively solve our issue of not being able to reach the appropiate pod when looking for the validation token on grafana.yourdomain.com/.well-known/acme-challenge. Solver worked fine and the certificate was being generated succesfully.

Everything looked good, the future was bright... except...

### The Cert-Manager & Amazon ALB Problem
Cert-Manager does not work with AWSs ALB. ALB only works with certificates issued with ACM, that's Amazon Certificate Manager. And to this date, Cert-Manager doesn't have an option to use ACM as an issuer. I honestly don't know who I should be mad at.

Having a valid TLS certificate inside our cluster in the form of a secret (grafana-ingress-certificate) would make no difference. If you would try to reach https://grafana.yourdomain.com from inside the cluster it would work fine because the secret was valid and the ingres would have tls through this secret, but here's the problem:

When you are using ALB, for every ingress object you create in your cluster, a Load Balancer will be automatically created in AWS (assuming you added the required alb annotations to the ingress).

By default, these load balancers are created only with an HTTP (port 80) listener. So even if inside the cluster you have an ingress with a valid certificate, it makes no difference, because the AWS load balancer that points to that ingress has no HTTPS listener.

So you need to add a HTTPS (port 443) listener to the Load Balancer. How do you do this automatically? You add this annotation to the ingress: 
```yaml
ingress:
  annotations: 
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
```
The thing is, ALB ONLY works with certificates issued by ACM, so even for that annotation to work, you need to pass it in conjunction with another annotation that specifies the arn of the certificate you want to use, like this:
```yaml
ingress:
  annotations: 
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:373421766055:certificate/a6c8a2a6-4fec-4829-84b8-a3478dceeee8
```
At last!!! I could go to my browser, hit https://grafana.mydomain.com/ and see the most beautiful login page I'd ever seen (any would have been after so much work).

But what about all the work we had put into [The Ingress Problem](#the-ingress-problem)? Well, one could say it was all in vain, others might say that it helped us learn and grow as DevOps Engineers. I'll stick to it was all in vain. 

So...

### The Solution
Just ditch Cert-Manager for all services exposed through ALB (we still use it for services exposed through Istio Gateway). Instead of havaing Cert-Manger provide the certificates for us, we will create a wildcard certificate for our domain through [terraform](/terraform/aws/acm.tf).

ACM certificates can only be validated through DNS and not HTTP, so we also need to create a CNAME record in the hosted zone with the required values (this is also done through [terraform](/terraform/aws/acm.tf)). 

Then we'll pass in the arn of the certificate to the "alb.ingress.kubernetes.io/certificate-arn" ingress annotation in the values-custom.yaml of each service. I automated this task in the [deploy-infra pipeline](/azure-devops/00-deploy-infra.yml).

Another option would have been to send traffic through the Istio Gateway since that works for our application. But I wanted to keep Istio Gateway exclusive to the application traffic. I didn't want traffic to our tools (argocd, grafana, harbor, jaeger and kiali) mixed up with application traffic. This way we know that all Istio Gateway metrics are only application-related.

<br/>

## DNSSEC Issue
We could have enabled the DNSSEC signing in the hosted zone with this block:
```terraform
resource "aws_route53_hosted_zone_dnssec" "dnssec" {
  depends_on = [
    aws_route53_key_signing_key.dnssecksk
  ]
  hosted_zone_id = aws_route53_key_signing_key.dnssecksk.hosted_zone_id
}
```
But for it to work, first the name servers of the hosted zone must be copied to the domain registrar. If this is not done beforhand, we will receive the error:
```bash
Error: enabling Route 53 Hosted Zone DNSSEC (Z0381810UAZXEYO6ZOOB): enabling: HostedZonePartiallyDelegated: Due to DNS lookup failure, we cannot determine if hosted zone with ID 'Z0381810UAZXEYO6ZOOB' has NS records partially connected with its parent zone. Please retry later.
```
Therefore, we chose not to enable DNSSEC signing in the hosted zone through Terraform. Instead, we do it with AWS CLI in the deploy-infra pipeline. First, we use AWS CLI to copy the NS from the hosted zone to the domain. Once this is done, we can enable DNSSEC signing in the hosted zone also through AWS CLI."

<br/>

## Secrets
A thing that confused me a lot were all the secrets created in the Cert-Manager process. the Here's a concise explanation of the three different types of secrets used in Cert-Manager with the ACME protocol:

#### ACME Account Private Key Secret (privateKeySecretRef in ClusterIssuer):
**Purpose**: Stores the private key for the ACME account used to authenticate with the ACME server (like Let's Encrypt).<br>
**Usage**: Used by Cert-Manager to sign requests to the ACME server, ensuring secure and authenticated communication for operations like requesting and renewing certificates.

#### Certificate Secret (secretName in Certificate):
**Purpose**: Holds the TLS certificate and its corresponding private key issued for a specific domain (e.g., example.com).<br>
**Usage**: Used by Kubernetes resources like Ingress controllers to enable TLS/SSL encryption for services. It's the certificate actually used in your environment for securing traffic. This is the one the Gatwway object will use.

#### Temporary Secret for CertificateRequest:
**Purpose**: Temporarily stores the private key used to generate the Certificate Signing Request (CSR) for a particular CertificateRequest.<br>
**Usage**: The private key in this secret is used to create the CSR sent to the ACME server for the issuance of a certificate. Post-issuance, this secret's role is typically concluded.

