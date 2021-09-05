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

#### Valheimのセットアップ

SteamCMDを入れてアプリケーション用のユーザーで実行。

```bash
sudo useradd -m steam
cd /home/steam

sudo add-apt-repository multiverse
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install lib32gcc1 steamcmd

sudo mkdir -p /game/save/
sudo chown -R steam /game
sudo -u steam /usr/games/steamcmd
```

valheimをインストール。

```bash
login anonymous
force_install_dir /game/
app_update 896660 validate
```

起動スクリプトを修正。

```bash
sudo apt install vim
cd /game/
sudo -u steam vim start_server.sh
```

1行目に `#!/bin/bash` を追記 + valheim_server.x86_64を実行している行を以下のように修正。

```bash
./valheim_server.x86_64 -name "Chiba West Gamecenter" -port 2456 -world "ChibaWest" -password "chibawest" -savedir "/game/save/" -public 0
```

動作確認。

```bash
sudo -u steam ./start_server.sh
```

サーバーが問題なく起動してそうだったらsystemdに登録する。

```bash
sudo vim /etc/systemd/system/valheim-server.service
```

こんな感じ。

```bash
[Unit]
Description=Valheim Server
After=network-online.target

[Service]
User=steam
Group=steam
WorkingDirectory=/game/
ExecStart=/game/start_server.sh
Type=simple

[Install]
WantedBy=multi-user.target
```

設定できたらサービスを実行。
statusをみてfailしてないことを確認しておく。
初回起動で/game/save/worldsが生成されるので、データを移行する場合はここのファイルを置換する。

```bash
sudo systemctl enable valheim-server.service
sudo systemctl start valheim-server.service
sudo systemctl status valheim-server.service
```
