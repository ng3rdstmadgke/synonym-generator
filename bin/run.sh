#!/bin/bash

function usage {
cat >&2 <<EOS
学習タスク実行・推論サーバー起動コマンド

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

[example]
 学習モードで実行。
 $PROJECT_ROOT/data/ml/input/data/train/wiki.txt が学習対象のファイルとなります
   cp $PROJECT_ROOT/data/ml/input/data/train/wiki_100.txt $PROJECT_ROOT/data/ml/input/data/train/wiki.txt
   $0 train
 
 推論モードで実行。
   $PROJECT_ROOT/data/ml/model/model.bin がモデルとなります。
   $0 serve
EOS
exit 1
}

SCRIPT_DIR="$(cd $(dirname $0); pwd)"
PROJECT_ROOT="$(cd ${SCRIPT_DIR}/..; pwd)"
CONTAINER_DIR="$(cd ${PROJECT_ROOT}/docker; pwd)"
APP_NAME=$(bash $SCRIPT_DIR/lib/app_name.sh)

source "${SCRIPT_DIR}/lib/utils.sh"

args=()
while [ "$#" != 0 ]; do
  case $1 in
    -h | --help      ) usage;;
    -* | --*         ) error "$1 : 不正なオプションです" ;;
    *                ) args+=("$1");;
  esac
  shift
done

[ "${#args[@]}" != 1 ] && usage

MODE="${args[0]}"
[ "$MODE" != "train" -a "$MODE" != "serve" ] && error "<MODE>には train , serve いずれかを指定してください (MODE=$MODE)"


docker run \
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