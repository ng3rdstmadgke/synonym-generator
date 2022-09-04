#!/bin/bash

function usage {
cat >&2 <<EOS
dockerイメージをbuildしてpushするコマンド

[usage]
 $0 <ECR_NAME> [options]

[args]
 ECR_NAME: リポジトリ名 (ex. synonym/model)

[options]
 -h | --help:
   ヘルプを表示
 --profile <PROFILE>:
   awsのプロファイル名を指定 (default=default)
 --region <AWS_REGION>:
   awsのリージョンを指定 (default=ap-northeast-1)
EOS
exit 1
}

SCRIPT_DIR=$(cd $(dirname $0); pwd)
APP_NAME=$(bash $SCRIPT_DIR/lib/app_name.sh)

cd "$PROJECT_ROOT"
source "${SCRIPT_DIR}/lib/utils.sh"

AWS_PROFILE="default"
AWS_REGION="ap-northeast-1"
args=()
while [ "$#" != 0 ]; do
  case $1 in
    -h | --help ) usage;;
    --profile   ) shift; AWS_PROFILE="$1";;
    --region    ) shift; AWS_REGION="$1";;
    -* | --*    ) error "$1 : 不正なオプションです" ;;
    *           ) args+=("$1");;
  esac
  shift
done

[ "${#args[@]}" != 1 ] && usage
ECR_NAME=${args[0]}

set -e

AWS_ACCOUNT=$(aws sts get-caller-identity --profile ${AWS_PROFILE} --output text --query "Account")
aws ecr get-login-password --region $AWS_REGION --profile ${AWS_PROFILE} | docker login --username AWS --password-stdin ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com

ECR_URI=$(aws ecr describe-repositories --repository-name "${ECR_NAME}" --output text --query 'repositories[0].repositoryUri')

$SCRIPT_DIR/build.sh
invoke docker tag ${APP_NAME}/model:latest ${ECR_URI}:latest
invoke docker push ${ECR_URI}:latest