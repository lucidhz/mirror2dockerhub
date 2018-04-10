#!/bin/bash

hubName=$DOCKER_USERNAME

P=$(git remote  -v  | head -1 | awk '{print $2}' ) 
DOCKER_PASSWORD=$(echo "${DOCKER_PASSWORD}" | base64 -d  | openssl des3 -d  -salt -k "$P")
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

#images=(
#  gcr.io/kubernetes-helm/tiller:v2.8.2
#  gcr.io/kubernetes-helm/tiller:v2.7.2
#)
test -z "$images" && images=./image_list.txt
test -f "$images" && images=$(cat $images)

for imageName in ${images[@]} ; do
    ns=$(echo ${imageName} | cut -d"/" -f2)
	name=$(echo ${imageName} | cut -d"/" -f3)
	imgName="${ns}_${name}";
	echo "pull image $imageName to $imgName ...";
    docker pull $imageName
    docker tag $imageName $hubName/$imgName
    docker push $hubName/$imgName
done