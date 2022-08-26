#!/bin/bash

# オプション: https://www.uvicorn.org/settings/
uvicorn main:app \
  --port 8080 \
  --log-config "log_config.yml" \
  --workers 2 