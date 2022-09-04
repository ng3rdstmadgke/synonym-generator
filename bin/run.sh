#!/bin/bash

function usage {
cat >&2 <<EOS
コンテナ起動コマンド

[usage]
 $0 <MODE> [options]

[args]
 <MODE>:
   コンテナの実行モード
   train: 学習モードで実行
   serve: 推論モードで実行

[options]
 -h | --help:
   ヘルプを表示
 -d | --daemon:
   バックグラウンドで起動

[example]
 $(dirname $0)/run.sh -e
EOS
exit 1
}

SCRIPT_DIR="$(cd $(dirname $0); pwd)"
PROJECT_ROOT="$(cd ${SCRIPT_DIR}/..; pwd)"
CONTAINER_DIR="$(cd ${PROJECT_ROOT}/docker; pwd)"
APP_NAME=$(bash $SCRIPT_DIR/lib/app_name.sh)

source "${SCRIPT_DIR}/lib/utils.sh"

OPTIONS=
args=()
while [ "$#" != 0 ]; do
  case $1 in
    -h | --help      ) usage;;
    -d | --daemon    ) shift;OPTIONS="$OPTIONS -d";;
    -* | --*         ) error "$1 : 不正なオプションです" ;;
    *                ) args+=("$1");;
  esac
  shift
done

[ "${#args[@]}" != 1 ] && usage

MODE="${args[0]}"
[ "$MODE" != "train" -a "$MODE" != "serve" ] && error "<MODE>には train , serve いずれかを指定してください (MODE=$MODE)"


docker run $OPTIONS \
  -ti \
  --rm \
  --network host \
  --name ${APP_NAME}_${MODE} \
  -v "$PROJECT_ROOT/data/tmp:/opt/tmp" \
  -v "$PROJECT_ROOT/data/ml/input/data/train:/opt/ml/input/data/train" \
  -v "$PROJECT_ROOT/data/ml/model:/opt/ml/model" \
  -v "$PROJECT_ROOT/app:/opt/app" \
  "${APP_NAME}/model:latest" \
  $MODE