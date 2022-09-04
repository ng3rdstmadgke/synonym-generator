#!/bin/bash
shopt -s expand_aliases
[ -f "$HOME/.bashrc" ] && source $HOME/.bashrc

function usage {
cat >&2 <<EOS
dockerイメージビルドコマンド

[usage]
 $0 [options]

[options]
 -h | --help:
   ヘルプを表示
 --no-cache:
   キャッシュを使わないでビルド
EOS
exit 1
}

SCRIPT_DIR=$(cd $(dirname $0); pwd)
PROJECT_ROOT=$(cd $(dirname $0)/..; pwd)
APP_NAME=$(bash $SCRIPT_DIR/lib/app_name.sh)


cd "$PROJECT_ROOT"
source "${SCRIPT_DIR}/lib/utils.sh"

OPTIONS=
args=()
while [ "$#" != 0 ]; do
  case $1 in
    -h | --help ) usage;;
    --no-cache  ) OPTIONS="$OPTIONS --no-cache";;
    -* | --*    ) error "$1 : 不正なオプションです" ;;
    *           ) args+=("$1");;
  esac
  shift
done

[ "${#args[@]}" != 0 ] && usage

set -e
invoke docker build $OPTIONS --rm -f docker/model/Dockerfile -t "${APP_NAME}/model:latest" .
invoke docker build $OPTIONS --rm -f docker/tool/Dockerfile -t "${APP_NAME}/tool:latest" .
invoke docker build $OPTIONS --rm -f docker/sls/Dockerfile -t "${APP_NAME}/sls:latest" .