#!/bin/bash

function usage {
cat >&2 <<EOS
コンテナ起動コマンド

[usage]
 $0 [options]

[options]
 -h | --help:
   ヘルプを表示
 -d | --daemon:
   バックグラウンドで起動
 -e | --env <ENV_PATH>:
   環境変数ファイルを指定(default=.env)

[example]
 $(dirname $0)/run.sh -e .env
EOS
exit 1
}

SCRIPT_DIR="$(cd $(dirname $0); pwd)"
PROJECT_ROOT="$(cd ${SCRIPT_DIR}/..; pwd)"
CONTAINER_DIR="$(cd ${PROJECT_ROOT}/docker; pwd)"
APP_NAME=$(bash $SCRIPT_DIR/lib/app_name.sh)

source "${SCRIPT_DIR}/lib/utils.sh"

OPTIONS=
ENV_PATH=".env"
args=()
while [ "$#" != 0 ]; do
  case $1 in
    -h | --help      ) usage;;
    -d | --daemon    ) shift;OPTIONS="$OPTIONS -d";;
    -e | --env       ) shift;ENV_PATH="$1";;
    -* | --*         ) error "$1 : 不正なオプションです" ;;
    *                ) args+=("$1");;
  esac
  shift
done

[ "${#args[@]}" != 0 ] && usage
[ -z "$ENV_PATH" ] && error "-e | --env で環境変数ファイルを指定してください"
[ -r "$ENV_PATH" -a -f "$ENV_PATH" ] || error "環境変数ファイルを読み込めません: $ENV_PATH"

env_tmp="$(mktemp)"
cat "$ENV_PATH" > "$env_tmp"

trap "rm -f $env_tmp" EXIT

invoke docker run $OPTIONS \
  --rm \
  --network host \
  --env-file "$env_tmp" \
  "${APP_NAME}/model:latest" \
  server

rm $env_tmp