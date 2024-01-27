# External-DNS Notes

## Name Servers Issue
When you create a new hosted zone in Amazon Route 53 for your domain, it generates a set of name servers (NS) specific to that zone. These name servers are responsible for resolving DNS queries for your domain. To ensure that internet users can find your domain, you need to update your domain registrar (where your domain name is registered) with these new name servers. This process is called delegating the domain to the Amazon Route 53 name servers.

By copying the Route 53 name servers to your domain registrar's settings, you are essentially directing all traffic for your domain to the Route 53 name servers. This is necessary because the domain registrar needs to know which name servers to point to when requests for your domain come in. Without this update, the registrar would continue to direct traffic to the old name servers, and your AWS-hosted resources might not be accessible via the domain name.

I have automated this process in the [deploy-infra pipeline](azure-devops/00-deploy-infra.yml).

## DNS Propagation
Updating the name servers for a domain might to take some time to propagate fully. This delay is due to the DNS propagation process, which involves updating the new name server information across the global network of DNS servers. 

DNS propagation typically takes anywhere from a few hours up to 48 hours, and sometimes even longer in rare cases. This variability is due to the different caching policies of DNS servers around the world.