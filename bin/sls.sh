#!/bin/bash

function usage {
cat >&2 <<EOS
slsコマンドを扱うラッパー

[usage]
 $0 [options]

[options]
 -h | --help:
   ヘルプを表示
 --profile <PROFILE>:
   awsのプロファイル名を指定 (default=default)
 --region <AWS_REGION>:
   awsのリージョンを指定 (default=ap-northeast-1)

[example]
 デプロイ
  $0 -- deploy --param="s3Bucket=xxxxxxxxxxxxx" --param="imageArn=xxxxxxxxxxxxx.dkr.ecr.ap-northeast-1.amazonaws.com/xxxxxxxxx:tag"
 削除
  $0 -- remove
EOS
exit 1
}

SCRIPT_DIR=$(cd $(dirname $0); pwd)
PROJECT_ROOT=$(cd $(dirname $0)/..; pwd)
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
    --          ) shift; args+=($@); break;; 
    -* | --*    ) error "$1 : 不正なオプションです" ;;
    *           ) args+=("$1");;
  esac
  shift
done

set -e

AWS_ACCESS_KEY_ID=$(aws --profile $AWS_PROFILE configure get aws_access_key_id)
AWS_SECRET_ACCESS_KEY=$(aws --profile $AWS_PROFILE configure get aws_secret_access_key)

invoke docker run \
  -ti \
  --rm \
  -e AWS_REGION=$AWS_REGION \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -v ${PROJECT_ROOT}/sls/src:/opt/sls/src \
  -v ${PROJECT_ROOT}/sls/serverless.yml:/opt/sls/serverless.yml \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ${APP_NAME}/sls:latest sls ${args[@]} --region $AWS_REGION