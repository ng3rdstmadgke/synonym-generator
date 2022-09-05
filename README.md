# ■ Synonym Generator
類義語っぽいものを自動生成するアプリです。

# ■ ローカルで動かしてみる

## イメージのビルド

```bash
# dockerイメージのビルド
./bin/build.sh
```

## 学習

```bash
# 学習データの準備
cp data/ml/input/data/train/wiki_100.txt data/ml/input/data/train/wiki.txt
head -n10 data/ml/input/data/train/wiki.txt

# 学習
./bin/run.sh train
# wiki.txtを形態素解析して分かち書き形式に整形した中間ファイル
head -n10 data/tmp/wakati.txt
# モデルファイルの確認
ls data/ml/model/model.bin
```

## 推論

```bash
# 推論サーバー起動
# 8080ポートをローカルにフォワードできる場合はブラウザで http://localhost:8080/api/docs にアクセス
./bin/run.sh serve

# サーバー起動確認
curl http://localhost:8080/ping

# 推論リクエスト
KEYWORD="Windows"
curl -X POST -H "Content-Type: application/json"  -d "{\"keyword\":\"$KEYWORD\"}" http://localhost:8080/invocations
```

# ■ StepFunctionsで実行する

## 前準備
```bash
APP_NAME=$(bash ./bin/lib/app_name.sh)
echo $APP_NAME

# s3バケット作成
RANDOM_ID=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 10 | head -n1)
S3_BUCKET_NAME="synonym-generator-${RANDOM_ID}"

# 控えておいてください
echo $S3_BUCKET_NAME
aws --profile default s3 mb "s3://${S3_BUCKET_NAME}"

# s3バケットに学習データをアップロード
aws --profile default s3 cp "./data/ml/input/data/train/wiki_100.txt" "s3://${S3_BUCKET_NAME}/synonym/data/wiki.txt"

# ECRリポジトリ作成
ECR_NAME="synonym/model"
aws --profile default ecr create-repository --repository-name "${ECR_NAME}"

# ECRにイメージをpush
./bin/push-image.sh "${ECR_NAME}" --profile default
```

## sls デプロイ


```bash
# デプロイ
ECR_URI=$(aws --profile default ecr describe-repositories --repository-name "${ECR_NAME}" --output text --query 'repositories[0].repositoryUri')
echo $ECR_URI
./bin/sls.sh --profile default -- deploy --param="s3Bucket=${S3_BUCKET_NAME}" --param="imageUri=${ECR_URI}"
```


## StepFunctions実行

```bash
# 実行 (ブラウザから実行しても OK)
STATE_MACHINE_ARN=$(aws --profile default stepfunctions list-state-machines --query 'stateMachines[?name==`synonym-generator-dev`].stateMachineArn' --output text)
echo $STATE_MACHINE_ARN
aws --profile default stepfunctions start-execution --state-machine-arn $STATE_MACHINE_ARN
```

## 推論

```bash
# ./bin/predict.sh synonym-05 "Windows" --profile default
ENDPOINT_NAME="..."
KEYWORD="Windows"
./bin/predict.sh "$ENDPOINT_NAME" "$KEYWORD" --profile default
```


# ■ 後片付け


```bash
# StepFunctionsを削除する
./bin/sls.sh --profile default -- remove --param="s3Bucket=${S3_BUCKET_NAME}" --param="imageUri=${ECR_REPO_ARN}"

# ECRの削除
aws --profile default ecr delete-repository --repository-name "${ECR_NAME}" --force

# s3バケットの削除
aws --profile default s3 rb "s3://${S3_BUCKET_NAME}" --force
```


# ■ TODO

- コンテナをVPC起動に
- 命名規則をAPP_NAME由来に統一
- CodePipelineでStepFunctionsを発火
- S3の学習データ更新でStepFunctionsを発火
- ALBを利用したデプロイ戦略
- Lambdaによるテスト
- 実験アーティファクト管理
- ハイパーパラメータ設定