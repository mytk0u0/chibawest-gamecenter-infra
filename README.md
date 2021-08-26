# terraform

## セットアップ

```bash:mac
brew install tfenv
tfenv install 1.0.5
```

```bash:ubuntu
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bash_profile
source .bash_profile
tfenv install 1.0.5
```

## 開発

`terrafrom plan` して問題ないか確認したら `terraform apply` でOK。

## Minecraft

### 参考資料

docker-minecraft-bedrock-server:  
<https://github.com/itzg/docker-minecraft-bedrock-server>

Java版Minecraftのterraformファイル:  
<https://github.com/futurice/terraform-examples/blob/master/google_cloud/minecraft/main.tf>
