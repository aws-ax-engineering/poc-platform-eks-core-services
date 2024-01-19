#!/usr/bin/env bats

@test "evaluate metrics-server status" {
  run bash -c "kubectl get po -n kube-system -o wide | grep 'metrics-server'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate metrics-server results" {
  run bash -c "kubectl get --raw '/apis/metrics.k8s.io/v1beta1/nodes'"
  [[ "${output}" =~ "NodeMetricsList" ]]
}

@test "evaluate gatekeeper status" {
  run bash -c "kubectl get po -n gatekeeper-system -o wide | grep 'gatekeeper-controller-manager'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate gatekeeper audit status" {
  run bash -c "kubectl get po -n gatekeeper-system -o wide | grep 'gatekeeper-audit'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate alertmanager deployment" {
  run bash -c "kubectl get po -n kube-prometheus-stack -o wide | grep 'alertmanager-kube-prometheus-stack-alertmanager'"
  [[ "${output}" =~ "Running" ]]
}
@test "evaluate grafana deployment" {
  run bash -c "kubectl get po -n kube-prometheus-stack -o wide | grep 'kube-prometheus-stack-grafana'"
  [[ "${output}" =~ "Running" ]]
}
@test "evaluate kube-state-metrics deployment" {
  run bash -c "kubectl get po -n kube-prometheus-stack -o wide | grep 'kube-prometheus-stack-kube-state-metrics'"
  [[ "${output}" =~ "Running" ]]
}
@test "evaluate stack-operator deployment" {
  run bash -c "kubectl get po -n kube-prometheus-stack -o wide | grep 'kube-prometheus-stack-operator'"
  [[ "${output}" =~ "Running" ]]
}
@test "evaluate node-exporter deployment" {
  run bash -c "kubectl get po -n kube-prometheus-stack -o wide | grep 'kube-prometheus-stack-prometheus-node-exporter'"
  [[ "${output}" =~ "Running" ]]
}
@test "evaluate prometheus deployment" {
  run bash -c "kubectl get po -n kube-prometheus-stack -o wide | grep 'prometheus-kube-prometheus-stack-prometheus'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate karpenter status" {
  run bash -c "kubectl get po -n karpenter -o wide | grep 'karpenter'"
  [[ "${output}" =~ "Running" ]]
}

@test "evaluate crossplane" {
  run bash -c "kubectl get po -n upbound-system -o wide | grep 'crossplane'"
  [[ "${output}" =~ "Running" ]]
}
@test "evaluate crossplane-rbac-manager" {
  run bash -c "kubectl get po -n upbound-system -o wide | grep 'crossplane-rbac-manager'"
  [[ "${output}" =~ "Running" ]]
}
