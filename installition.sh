### helm


sudo dnf install openssl -y
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

#Install AWS-CLI
echo "--------------------Installing AWS-CLI--------------------"
sudo apt-get install zip -y
sudo curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip
sudo ./aws/install

## eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version


###### eks cli ex.
# eksctl create cluster --name my-cluster --region us-west-2 --nodegroup-name linux-nodes --node-type t2.micro --nodes 3
# eksctl get cluster --region us-west-2
# aws eks update-kubeconfig --name my-cluster --region us-west-2

#### creating cluster using cli

eksctl create cluster \
--name test-eksctl \
--version 1.30 \
--region us-east-1 \
--nodegroup-name eks-test \
--node-type t2.micro \
--nodes 2

# using yaml file 
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: test-eksctl
  region: us-east-1
  version: "1.30"

nodeGroups:
  - name: eks-test
    instanceType: t2.micro
    desiredCapacity: 2
# eksctl create cluster -f cluster.yaml
