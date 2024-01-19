# will need to shift to core-service pipeline 
module "eks_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.9.2"

  cluster_name      = data.aws_eks_cluster.existing_cluster.id
  cluster_endpoint  = data.aws_eks_cluster.existing_cluster.endpoint
  cluster_version   = data.aws_eks_cluster.existing_cluster.version
  oidc_provider_arn = data.aws_eks_cluster.existing_cluster.identity[0].oidc[0].issuer

  # While available as add-ons, would not recommend actually managing in this manner.
  # This pattern is followed only because of the extremely short time frame of this poc.

  enable_metrics_server = true
  metrics_server = {
    values = [
      <<-EOT
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
          runAsUser: 1000
          seccompProfile:
            type: RuntimeDefault
          capabilities:
            drop:
              - ALL
            add: ["CAP_NET_BIND_SERVICE"]
        priorityClassName: system-cluster-critical
        containerPort: 10250
        hostNetwork:
          enabled: false
        replicas: 3
        updateStrategy:
          type: RollingUpdate
          rollingUpdate:
            maxSurge: 1
            maxUnavailable: 1
        podDisruptionBudget:
          enabled: true
          maxUnavailable: 1
        affinity:
          podAntiAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
              - labelSelector:
                  matchExpressions:
                    - key: app.kubernetes.io/name
                      operator: In
                      values:
                        - metrics-server
                topologyKey: kubernetes.io/hostname
            preferredDuringSchedulingIgnoredDuringExecution:
              - weight: 100
                podAffinityTerm:
                  topologyKey: failure-domain.beta.kubernetes.io/zone
                  labelSelector:
                    matchLabels:
                      app.kubernetes.io/name: metrics-server
        resources:
          requests:
            cpu: 10m
            memory: 50Mi
          limits:
            cpu: 100m
            memory: 200Mi
        nodeSelector:
          nodegroup: "management-x86-al2-mng"
        tolerations:
          - key: "dedicated"
            operator: "Equal"
            value: ${var.management_node_group}
            effect: "NoSchedule"
        topologySpreadConstraints:
          - maxSkew: 1
            topologyKey: topology.kubernetes.io/zone
            whenUnsatisfiable: ScheduleAnyway
            labelSelector:
              matchLabels:
                app.kubernetes.io/name: metrics-server
          - maxSkew: 1
            topologyKey: kubernetes.io/hostname
            whenUnsatisfiable: ScheduleAnyway
            labelSelector:
              matchLabels:
                app.kubernetes.io/name: metrics-server
      EOT
    ]
  }

  enable_gatekeeper = true
  gatekeeper = {
    values = [
      <<-EOT
        nodeSelector:
          nodegroup: "management-x86-al2-mng"
        controllerManager:
          tolerations:
            - key: "dedicated"
              operator: "Equal"
              value: "${var.management_node_group}"
              effect: "NoSchedule"  
        audit:
          tolerations:
            - key: "dedicated"
              operator: "Equal"
              value: "${var.management_node_group}"
              effect: "NoSchedule"  
        crds:
          tolerations:
            - key: "dedicated"
              operator: "Equal"
              value: "${var.management_node_group}"
              effect: "NoSchedule"  
        postInstall:
          tolerations:
            - key: "dedicated"
              operator: "Equal"
              value: "${var.management_node_group}"
              effect: "NoSchedule" 
        preUninstall:
          tolerations:
            - key: "dedicated"
              operator: "Equal"
              value: "${var.management_node_group}"
              effect: "NoSchedule" 
      EOT
    ]
  }

  enable_kube_prometheus_stack = true
  kube_prometheus_stack = {
    values = [
      <<-EOT
        alertmanager:
          podDisruptionBudget:
            enabled: true
            minAvailable: 1
          alertmanagerSpec:
            logFormat: json
            replicas: 3
            nodeSelector:
              nodegroup: "management-x86-al2-mng"
            tolerations:
              - key: "dedicated"
                operator: "Equal"
                value: ${var.management_node_group}
                effect: "NoSchedule"
        kube-state-metrics:
          podDisruptionBudget:
            minAvailable: 0
          nodeSelector:
            nodegroup: "management-x86-al2-mng"
          tolerations:
            - key: "dedicated"
              operator: "Equal"
              value: ${var.management_node_group}
              effect: "NoSchedule"
        prometheusOperator:
          admissionWebhooks:
            enabled: false
            patch:
              enabled: true
              nodeSelector:
                nodegroup: "management-x86-al2-mng"
              tolerations:
                - key: "dedicated"
                  operator: "Equal"
                  value: ${var.management_node_group}
                  effect: "NoSchedule"
          networkPolicy:
            enabled: false
          nodeSelector:
            nodegroup: "management-x86-al2-mng"
          tolerations:
            - key: "dedicated"
              operator: "Equal"
              value: ${var.management_node_group}
              effect: "NoSchedule"
        grafana:
          autoscaling:
            enabled: true
            minReplicas: 3
          podDisruptionBudget:
            minAvailable: 1
          nodeSelector:
            nodegroup: "management-x86-al2-mng"
          tolerations:
            - key: "dedicated"
              operator: "Equal"
              value: ${var.management_node_group}
              effect: "NoSchedule"
        prometheus:
          podDisruptionBudget:
            enabled: true
            minAvailable: 1
          prometheusSpec:
            tolerations:
              - key: "dedicated"
                operator: "Equal"
                value: ${var.management_node_group}
                effect: "NoSchedule"
            nodeSelector:
              nodegroup: "management-x86-al2-mng"
            replicas: 3
            logFormat: json
      EOT
    ]
  }

  enable_argocd = var.argo_server
  argocd = {
    chart_version = "5.51.6"
    values = [
      <<-EOT
        dex:
          enabled: false
        controller:
          serviceAccount:
            annotations:
              eks.amazonaws.com/role-arn: arn:aws:iam::599654392735:role/mapi-i01-aws-us-east-2-argocd-server-sa
        applicationSet:
          serviceAccount:
            annotations:
              eks.amazonaws.com/role-arn: arn:aws:iam::599654392735:role/mapi-i01-aws-us-east-2-argocd-server-sa
        notifications:
          serviceAccount:
            annotations:
              eks.amazonaws.com/role-arn: arn:aws:iam::599654392735:role/mapi-i01-aws-us-east-2-argocd-server-sa
        server:
          service:
            type: LoadBalancer
          serviceAccount:
            annotations:
              eks.amazonaws.com/role-arn: arn:aws:iam::599654392735:role/mapi-i01-aws-us-east-2-argocd-server-sa
          extraArgs:
            - --insecure
      EOT
    ]
  }
}

module "karpenter_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.30.0"

  role_name = "${var.instance_name}-karpenter-controller"

  attach_karpenter_controller_policy = true

  karpenter_controller_cluster_name = var.instance_name

  oidc_providers = {
    ex = {
      provider_arn               = data.aws_iam_openid_connect_provider.eks.arn
      namespace_service_accounts = ["karpenter:karpenter"]
    }
  }
}

resource "helm_release" "karpenter" {
  depends_on       = [module.karpenter_irsa_role, module.eks_addons]
  name             = "karpenter"
  repository       = "oci://public.ecr.aws/karpenter"
  chart            = "karpenter"
  version          = "v0.32.1"
  namespace        = "karpenter"
  create_namespace = true

  values = [
    templatefile("charts/karpenter.tpl", {
      instance_name         = var.instance_name
      role_arn              = module.karpenter_irsa_role.iam_role_arn
      management_node_group = var.management_node_group
    }),
  ]

  wait = true
}

# create default karpenter provisioner
resource "kubernetes_manifest" "karpenter_provisioner" {
  depends_on = [ helm_release.karpenter ]
  manifest = yamldecode(<<-EOF
    apiVersion: karpenter.sh/v1alpha5
    kind: Provisioner
    metadata:
      name: mkt-scale-x86-al2-node-group
    spec:
      weight: 100
      limits:
        resources:
          cpu: 1k
          memory: 1000Gi
      provider:
        apiVersion: extensions.karpenter.sh/v1alpha1
        kind: AWS
        securityGroupSelector:
          Name: "${var.instance_name}*"
        subnetSelector:
          Name: "${var.instance_name}*"
        instanceProfile: ${var.instance_name}-common-node-role
        tags:
          managed-by: "karpenter"
          karpenter.sh/discovery: ${var.instance_name}
      requirements:
        - key: "karpenter.k8s.aws/instance-category"
          operator: In
          values: ["c", "m", "r"]
        - key: "karpenter.k8s.aws/instance-cpu"
          operator: In
          values: ["8", "16", "32", "64"]
        - key: "kubernetes.io/arch"
          operator: In
          values: ["amd64"]
        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
        - key: "karpenter.sh/capacity-type"
          operator: In
          values: ["spot", "on-demand"]
      consolidation:
        enabled: true
      ttlSecondsUntilExpired: 604800
      labels:
        nodegroup: mkt-scale-x86-al2-mng
    EOF
  )
}

# install uxp using Helm
# tflint-ignore: terraform_required_providers
resource "helm_release" "crossplane" {
  name       = "universal-crossplane"
  namespace  = "upbound-system"
  repository = "https://charts.upbound.io/stable"
  chart      = "universal-crossplane"
  version    = "1.14.3-up.1"

  create_namespace = true

  values = [
    templatefile("charts/crossplane.tpl", {
      management_node_group = var.management_node_group
    }),
  ]

  wait = true  
}


# install uxp using Helm
# tflint-ignore: terraform_required_providers
resource "helm_release" "fluentbit" {
  name       = "aws-for-fluent-bit"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-for-fluent-bit"
  # version    = "0.1.32"


  wait = true  
}