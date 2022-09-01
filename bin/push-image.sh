#!/bin/bash

function usage {
cat >&2 <<EOS
dockerイメージをbuildしてpushするコマンド

[usage]
 $0 [options]

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
AWS_REGION=ap-northeast-1
args=()
while [ "$#" != 0 ]; do
  case $1 in
    -h | --help ) usage;;
    --profile   ) AWS_PROFILE="$1";;
    --region    ) AWS_REGION="$1";;
    -* | --*    ) error "$1 : 不正なオプションです" ;;
    *           ) args+=("$1");;
  esac
  shift
done

[ "${#args[@]}" != 0 ] && usage

set -e

AWS_ACCOUNT=$(aws sts get-caller-identity --output json --profile ${AWS_PROFILE} | jq -r ".Account")
info "aws ecr get-login-password --region $AWS_REGION --profile ${AWS_PROFILE} | docker login --username AWS --password-stdin ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com"
aws ecr get-login-password --region $AWS_REGION --profile ${AWS_PROFILE} | docker login --username AWS --password-stdin ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com

$SCRIPT_DIR/build.sh

invoke docker tag ${APP_NAME}/model:latest ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME}/model:latest
invoke docker push ${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME}/model:latest