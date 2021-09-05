# cloudbuild_terraform_builder

cloudbuildでterraformを動かすのに必要なコンテナ。↓をコピペして修正したもの。  
<https://github.com/GoogleCloudPlatform/cloud-builders-community/tree/master/terraform>

何か変更があった場合は以下のコマンドを直で叩く。

```bash
gcloud builds submit --config=cloudbuild.yaml
```
