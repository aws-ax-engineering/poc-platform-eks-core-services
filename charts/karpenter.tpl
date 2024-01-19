serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: ${role_arn}
settings:
  clusterName: ${instance_name}
  interruptionQueue: ${instance_name}
  featureGates:
    drift: true
controller:
  resources:
    requests:
      cpu: 1
      memory: 1Gi
    limits:
      cpu: 1
      memory: 1Gi
nodeSelector:
  nodegroup: "management-x86-al2-mng"
tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: "${management_node_group}"
    effect: "NoSchedule"
