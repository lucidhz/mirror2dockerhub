#!/bin/bash
set -x 
hubName=$DOCKER_USERNAME

P=$(git remote  -v  | head -1 | awk '{print $2}' ) 
DOCKER_PASSWORD=$(echo "${DOCKER_PASSWORD}" | base64 -d  | openssl des3 -d  -salt -k "$P")
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

cd /tmp
wget -O ./t.sh https://github.com/rancher/rancher/releases/download/v2.1.5/rancher-mirror-to-rancher-org.sh

awk '/(quay.io|gcr.io)/{print $0 }' ./t.sh | sed "s# rancher/# ${hubName}/rancher_#g" > ./t2.sh

cat ./t2.sh
sh ./t2.sh

docker info

docker images


images=$( docker images |  awk "/${hubName}/{print \$1\":\"\$2}" )
echo -e "====>\n$images"

for x in $images ; do 
  x="docker push $x"
  echo "$x..."
  $x
done
echo "mirror image script==>"
echo "$images"  | awk "{printf(\"docker pull %s\n docker tag %s %s\n\",\$1,\$1,gensub(/${hubName}\/rancher_/,\"rancher/\",1))}" > /tmp/pull_rancher_image.sh

grep -v -e '\(quay.io\|gcr.io\|push\|tag\)' ./t.sh  >> /tmp/pull_rancher_image.sh


cat /tmp/pull_rancher_image.sh


#转存rancher开头镜像都转存私有库中
# " docker images 'rancher/*' | awk '{a=$1":"$2;b="docker:5000/"a; printf("docker tag %s %s\n docker push %s\ndocker rmi %s\n",a,b,b,b)}' " 

