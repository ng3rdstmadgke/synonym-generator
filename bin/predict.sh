#!/bin/bash

function usage {
cat >&2 <<EOS
類義語の推論を行うコマンド

[usage]
 $0 <ENDPOINT_NAME> <KEYWORD> [options]

[args]
 ENDPOINT_NAME:
   SageMakerエンドポイント名を指定します。
 KEYWORD:
   類義語推論したい単語を指定します。

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
    -* | --*    ) error "$1 : 不正なオプションです" ;;
    *           ) args+=("$1");;
  esac
  shift
done

[ "${#args[@]}" != 2 ] && usage
ENDPOINT_NAME=${args[0]}
KEYWORD=${args[1]}

set -e


AWS_ACCESS_KEY_ID=$(aws --profile $AWS_PROFILE configure get aws_access_key_id)
AWS_SECRET_ACCESS_KEY=$(aws --profile $AWS_PROFILE configure get aws_secret_access_key)

invoke docker run \
  --rm \
  -e AWS_REGION=$AWS_REGION \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  --name ${APP_NAME}_predict \
  -v "$PROJECT_ROOT/app:/opt/app" \
  "${APP_NAME}/tool:latest" \
  python /opt/app/predict.py "$ENDPOINT_NAME" "$KEYWORD"