#!/bin/sh

#  initPod.sh
#
#
#  Created by waynett on 2017/11/07.
#

repoName=$1

test -z ${repoName} && echo "Repo name required." 1>&2 && exit 1

#echo $repoName

IFS= #规避newline got lost问题
podspec=$(cat podspec.txt)
#echo $podspec

lowerRepoName=$(echo ${repoName} | tr "[:upper:]" "[:lower:]")

echo "repo name : $lowerRepoName"

newPodspec=$(echo $podspec | sed "s/repoName/${lowerRepoName}/g" | sed "s/originRepoName/${repoName}/g") #gitlab api通过命令行都会转为小写，这里podspec也需要单独处理。另外工程目录需要保留大小写

echo $newPodspec  > ${repoName}.podspec

repoPath=../${repoName}

if [ ! -d "$repoPath" ]; then

mkdir -p ${repoPath} #强制创建目录，如果存在会先删除

fi

cp ./${repoName}.podspec ${repoPath}
cp ./.gitignore ${repoPath}

cd ${repoPath}

#begin 构建初始工程

podspec=$(cat podspec.txt)

#end 构建工程


token=Go2SqzjsEB76S_LcmG54

createRepoContent=$(curl -H "Content-Type:application/json" http://git.oa.com/api/v3/projects?private_token=$token -d "{ \"name\": \"$repoName\" }")

#{"id":123,"description":null,"default_branch":null,"tag_list":[],"public":false,"archived":false,"visibility_level":0,"ssh_url_to_repo":"git@git.oa.com:waynett/dtstest.git","http_url_to_repo":"http://git.oa.com/waynett/dtstest.git","web_url":"http://git.oa.com/waynett/dtstest","owner":{"name":"waynett","username":"waynett","id":12,"state":"active","avatar_url":"http://www.gravatar.com/avatar/bb2f0e3e91ca375929d955d82d2990af?s=40\u0026d=identicon"},"name":"DTSTest","name_with_namespace":"waynett / DTSTest","path":"dtstest","path_with_namespace":"waynett/dtstest","issues_enabled":true,"merge_requests_enabled":true,"wiki_enabled":true,"snippets_enabled":false,"created_at":"2017-11-06T12:04:20.606Z","last_activity_at":"2017-11-06T12:04:20.606Z","creator_id":12,"namespace":{"id":14,"name":"waynett","path":"waynett","owner_id":12,"created_at":"2015-09-14T02:40:35.523Z","updated_at":"2015-09-14T02:40:35.523Z","description":"","avatar":null},"avatar_url":null}

#curl --request DELETE --header "PRIVATE-TOKEN: Go2SqzjsEB76S_LcmG54" http://git.oa.com/api/v3/projects/123

#echo $createRepoContent

http_url_to_repo=$(echo $createRepoContent | jq -r '.http_url_to_repo') #brew install  jq

echo $http_url_to_repo

rm -rf ./.git

git init

git remote add origin $http_url_to_repo

git add *

git commit -am"init ${repoName}"

git push -u origin master

git tag 0.0.1

git push --tags
