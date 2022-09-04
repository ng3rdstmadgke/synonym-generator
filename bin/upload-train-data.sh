#!/bin/bash

function usage {
cat >&2 <<EOS
dockerイメージをbuildしてpushするコマンド

[usage]
 $0 <S3_BUCKET> <FILE_PATH> [options]

[args]
 S3_BUCKET: s3バケット名
 FILE_PATH: アップロードするファイルのパス

[options]
 -h | --help:
   ヘルプを表示
 --profile <PROFILE>:
   awsのプロファイル名を指定 (default=default)
EOS
exit 1
}

SCRIPT_DIR=$(cd $(dirname $0); pwd)
PROJECT_ROOT=$(cd $(dirname $0)/..; pwd)
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

[ "${#args[@]}" != 2 ] && usage

S3_BUCKET=${args[0]}
LOCAL_PATH=${args[1]}

[ -r "$LOCAL_PATH" -a -f "$LOCAL_PATH" ] || error "FILE_PATH: $FILE_PATH が見つかりません。"


set -e

S3_PATH="s3://${S3_BUCKET}/${APP_NAME}/data/wiki.txt"
invoke aws s3 cp $LOCAL_PATH $S3_PATH
