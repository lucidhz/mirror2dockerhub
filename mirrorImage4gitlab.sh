#!/bin/bash

hubName=$DOCKER_USERNAME

P=$(git remote  -v  | head -1 | awk '{print $2}' ) 
DOCKER_PASSWORD=$(echo "${DOCKER_PASSWORD}" | base64 -d  | openssl des3 -d  -salt -k "$P")
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

images=(
  registry.gitlab.com/gitlab-org/cluster-integration/helm-install-image/releases/2.12.2-kube-1.11.0
  gcr.io/kubernetes-helm/tiller:v2.12.2
  gcr.io/kubernetes-helm/tiller:v2.12.3
  k8s.gcr.io/defaultbackend:1.4
  k8s.gcr.io/hyperkube:v1.7.12
)
#
#  gcr.io/kubernetes-helm/tiller:v2.8.2
#  gcr.io/kubernetes-helm/tiller:v2.7.2
test -z "$images" && images=./image_list.txt && \
test -f "$images" && images=$(cat $images)

for imageName in ${images[@]} ; do
	imgName=$(echo ${imageName} | sed 's@^[^/]\+/@@g' | sed 's#/#_#g')
	echo "pull image $imageName to $imgName ...";
    docker pull $imageName
    docker tag $imageName $hubName/$imgName
    docker push $hubName/$imgName
done