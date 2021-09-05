# chibawest-gamecenter-infra

chibawest-gamecenterのTerraformまわり

## セットアップ

terraformのバージョン1.0.5を使ってます。

### tfenv

#### macOS

```bash
brew install tfenv
tfenv install 1.0.5
```

#### Ubuntu

```bash
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
echo 'export PATH="$HOME/.tfenv/bin:$PATH"' >> ~/.bash_profile
source .bash_profile
tfenv install 1.0.5
```

## 開発

merge前に `terrafrom plan` して問題ないか確認する。  
mainにmergeしたらCloud Buildで勝手に `terraform apply` が走る。

GCPが壊れたりしたら辛いので、mainはpushできないようにしてある。

## その他

### Minecraft

#### 設定変更

GCPの[VMインスタンス](https://console.cloud.google.com/compute/instances?project=chibawest-gamecenter)からインスタンスにsshできるので、そこで `sudo docker exec -i mc rcon-cli` すればOK。

### Valheim

#### データ移行

ゲームデータのディレクトリのworldsの中の `ChibaWest.{db,fwl}` を移せばOK。
Windowsから移すときはroot:rootの644に権限設定したほうがいいかも。
