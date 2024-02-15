# Prometheus Operator Notes

## Steps to monitor third-party application 
1. Deploy the application you want to monitor.
2. Deploy an exporter for the application.
3. Create a service monitor for the exporter.

</br>

## Concepts

### Exporter
Prometheus works by pulling (scraping) metrics from monitored targets at regular intervals. It looks for these metrics at an HTTP endpoint which by defaut is <host-address\>/metrics. 

For this to work, the target must expose metrics in /metrics path and they also have to be in a format that Prometheus understands. Some applications/services do both of these thing by default, but others don't.

For those applications/services that don't, we have exporters. An exporter is a software that exposes metrics from third-party systems in a format that Prometheus can scrape. They serve as an intermediary between Prometheus and the applications or services that don't natively expose metrics in a format Prometheus understands. They collect metrics from these sources, transform them into the Prometheus data model, and then expose them via an HTTP endpoint at <exporter-host-address\>/metrics.

The kube-prometheus-stack helm chart already comes with some exporters by default, like node-exporter, which exposes metrics from the nodes of out cluster.

In order for the exporter to work we need three things:
1. A pod (which is the exporter itself).
2. A service to connect to the exporter pod.
3. A PodMonitor or ServiceMonitor, which lets Prometheus Operator know that there is a new application/service ready to be scraped.
</br>

### PodMonitor & ServiceMonitor
PodMonitor and ServiceMonitor are both custom resource definitions (CRDs) used in the Prometheus Operator. They let the Prometheus Operator know that there is a new application/service ready to be scraped.

Differences:
- Scope of Monitoring: ServiceMonitor is for services, facilitating the discovery of services and the pods behind them, while PodMonitor is for direct pod monitoring, irrespective of services.
- Use Cases: ServiceMonitor is ideal when services are the primary abstraction for your applications, and you're interested in metrics at the service level. PodMonitor is better suited for scenarios where direct pod metrics are necessary, such as monitoring specific sidecar containers or jobs without a service.

#### IMPORTANT:
- By default PodMonitors and ServiceMonitors MUST be deployed in the same namespace as the Prometheus Operator.
- In our PodMonitors and ServiceMonitors we must include a "release" label. This label allows Prometheus Operator to automatically discover the new PodMonitor/ServiceMonitor in the cluster. The value of the "release" label is defined in the Prometheus Operator configuration. In our case the value of release must be "kube-prometheus-stack". Look at [this manifest](helm/infra/istio-gateway/templates/custom-templates/servicemonitor.yaml) for example.

</br>

# How we implement it

Some tools like Flagger have the option to enable monitoring in the chart by default. We enabled Flagger's monitoring through the chart's [values](helm/infra/flagger/values-custom.yaml).

For Istio Gateway, we created a Service that connects to the Istio Gateway Pod and a ServiceMonitor for this Service. The Istio Gateway Pod exports metrics in the stats/prometheus path by default, so we didn't need to create an exporter.

For the my-app services (backend and frontend), we created a PodMonitor for the Canary pods and another PodMonitor for the Primary pods. Since we are using Istio, the Envoy sidecar container will be the responsible for exposing metrics in the stats/prometheus path, so there was no need to create exporters for these either.
