.PHONY: cluster kubeconfig

cluster:
	eksctl create cluster --config-file cluster.yml

kubeconfig:
	eksctl utils write-kubeconfig --region us-west-1 --cluster nebhale
