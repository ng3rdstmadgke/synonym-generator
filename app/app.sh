#!/bin/bash

SCRIPT_DIR="$(cd $(dirname $0); pwd)"
MODE="$1"

if [ "$MODE" = "train" ]; then
  python "$SCRIPT_DIR/main.py" $MODE
elif [ "$MODE" = "serve" ]; then
  # オプション: https://www.uvicorn.org/settings/
  uvicorn main:serve.app \
    --port 8080 \
    --log-config "log_config.yml" \
    --workers 2 
fi