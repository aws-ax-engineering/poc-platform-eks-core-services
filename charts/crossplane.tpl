replicas: 2
nodeSelector:
  nodegroup: "management-x86-al2-mng"
tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: ${management_node_group}
    effect: "NoSchedule"
provider:
   packages:
     - "xpkg.upbound.io/upbound/provider-aws:v0.44.0"
     - "xpkg.upbound.io/upbound/provider-aws-dynamodb:v0.45.0"
rbacManager:
  replicas: 2
  nodeSelector:
    nodegroup: "management-x86-al2-mng"
  tolerations:
    - key: "dedicated"
      operator: "Equal"
      value: ${management_node_group}
      effect: "NoSchedule"