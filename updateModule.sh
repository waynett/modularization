#!/bin/sh

diff=$(git status)

if [[ $diff == *"working tree clean"* ]]; then
echo "git no change!"
exit
fi

currentGitVersion=$(git describe --abbrev=0 --tags)

echo $currentGitVersion

oldBuild=$(echo $currentGitVersion | tr "." "\n" | tail -n1)

echo $oldBuild

newBuild=$(($oldBuild + 1))

echo $newBuild

newGitVersion=$(echo $currentGitVersion | sed "s/$oldBuild/$newBuild/g")

echo $newGitVersion

#exit

FILENAME=$(ls | grep podspec)

echo $FILENAME

function While_read_LINE(){
cat $FILENAME | grep s.version | cut -d \= -f 2 | awk 'NR<2' | while read LINE
do
echo $LINE
done
}

version=$(While_read_LINE)

echo "${version}"

#exit

sed -i "" "s/$version/\"$newGitVersion\"/g"  $FILENAME

git add -A && git commit -am"$newGitVersion"

git tag $newGitVersion

pod lib lint --use-libraries --allow-warnings  --verbose  --sources='https://dengtacj@bitbucket.org/dengtacj/dtspecs.git,https://github.com/CocoaPods/Specs' #测试验证组件库

if [ $? -ge 1 ]; then
git reset --mixed HEAD^1  #回滚提交代码
git tag -d $newGitVersion #删除新增加的tag
exit $?
fi

git push --tags  #上传库到github

pod repo push DTSpecs $FILENAME --use-libraries --allow-warnings  #上传podspecs到私有库，和上面的github代码库是分开的， 一个用于代码存储，一个用于cocoapods索引搜索。podspecs中的s.source指出了代码具体去哪里拉取。除了可以在github上，还可以放到文件服务器等地方。
    #s.source           = { :git => "https://github.com/dengtacj/DTSDKCoreKit.git", :tag => s.version.to_s }
