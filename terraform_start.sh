#/!bin/bash
echo Making sure aws works
aws ec2 describe-instances >/dev/null || exit 1

echo Making sure terraform works
terraform --version >/dev/null || exit 1

echo Starting terraform
terraform init || exit 1

echo Starting terraform apply (this take a while)
terraform apply -auto-approve || exit 1

echo Configuring kubectl
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name) || exit 1

echo Deploying Kubernetes Metrics Server
wget -O v0.3.6.tar.gz https://codeload.github.com/kubernetes-sigs/metrics-server/tar.gz/v0.3.6 && tar -xzf v0.3.6.tar.gz || exit 1
kubectl apply -f metrics-server-0.3.6/deploy/1.8+/ || exit 1
kubectl get deployment metrics-server -n kube-system || exit 1

echo List nodes in the cluster
kubectl get nodes -o wide || exit 1

echo Deploying Kubernetes Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml || exit 1

echo Authenticating the dashboard
kubectl apply -f kubernetes-dashboard-admin.rbac.yaml || exit 1

echo Generating the authorization token.
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep service-controller-token | awk '{print $1}') || exit 1

echo Starting the proxy
echo ** proxy will require the "token" from the previous commands output
echo ** Accessing the api can done via "curl http://127.0.0.1:8080/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
kubectl proxy --port=8080 || exit 1
