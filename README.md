# poc-platform-eks-core-services.

Installs the following core-services using aws-ia eks-addon blueprint. Each is configured to run  
on the management node group.  

* metrics-server
* gatekeeper
* kube-prometheus-stack
  * prometheus
  * grafana
  * kube-state-metrics
  * alertmanager
  * node-exporter
* karpenter
  * includes a single, default scaling nodegroup for general deployments, "mkt-scale-x86-al2-node-group-"
* upbound universal-crossplane controller with aws family provisioner
* argoCD (only on mapi cluster)
