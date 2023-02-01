package main

import (
	_ "k8s.io/apiserver/pkg/apis/config/v1"
	_ "k8s.io/kube-controller-manager/config/v1alpha1"
	_ "k8s.io/kube-proxy/config/v1alpha1"
	_ "k8s.io/kube-scheduler/config/v1"
	_ "k8s.io/kubelet/config/v1beta1"
)
