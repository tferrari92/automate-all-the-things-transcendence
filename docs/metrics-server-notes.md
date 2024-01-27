# Metrics Server Notes
Some Kubernetes implementation include Matrics Server by defaults. EKS doesn't, so we added the [helm chart](/helm/infra/metrics-server/).

Wel'l be using metrics-server for horizontal pod auto-scaling (HPA). You could also set up HPA to get metrics from Prometheus.

If you want to test HPA, just change spec.targetCPUUtilizationPercentage value to '1' in the horizontal-pod-autoscaler manifests for the [backend](/helm/my-app/backend/templates/horizontal-pod-autoscaler.yaml) or [frontend](/helm/my-app/frontend/templates/horizontal-pod-autoscaler.yaml). This will mean that when CPU utilization goes over just 1%, a new replica of that pod should be deployed. After the change, go to your browser and on the appropiate URL hit refresh a lot of times. This will increase CPU utilization over 1% and you'll see the new replicas being deployed. You will also see it going back to one replica when you stop stressing it.
