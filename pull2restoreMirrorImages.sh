#!/bin/bash
hubName=$DOCKER_USERNAME
test -z "$images" && images=./image_list.txt
test -f "$images" && images=$(cat $images)

for imageName in ${images[@]} ; do
    ns=$(echo ${imageName} | cut -d"/" -f2)
	name=$(echo ${imageName} | cut -d"/" -f3)
	imgName="${ns}_${name}";
	echo "pull image $imgName and tag to  $imageName ...";
    docker pull $hubName/$imgName
    docker tag $hubName/$imgName $imageName
done