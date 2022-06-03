.PHONY: cluster kubeconfig

### Cluster
CLUSTER_CONF ?= cluster.yml

cluster:
	eksctl create cluster --config-file $(CLUSTER_CONF)

kubeconfig:
	eksctl utils write-kubeconfig --config-file $(CLUSTER_CONF)
