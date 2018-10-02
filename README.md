# 概要
site-builder は複数台のサーバにまたがって docker コンテナを運用するサイトを構築するためのツールです。このツールは ansible スクリプトで記述されています。サイトの構築は、以下の2つのフェーズで行われます。
1. ホスト構築フェーズ
2. コンテナ配備フェーズ

続く節でそれぞれのフェーズで提供する機能について説明します。

## ホスト構築フェーズ
ホスト構築フェーズでは、構築ツールをインストールしたVM（以降、 mother ホストと呼びます）から ansible スクリプトでホストを構築します。対象ホストは CentOS 7 がインストールされており、 ssh でパスワード無しでログインできる状態にある必要があります。

### AWS EC2環境の構築
このツールでは、条件を満たす AWS EC2 インスタンスを自動的に起動することができます。AWS EC2 インスタンスの起動を含めると、以下のステップで実行することができます。
1. Vagrant で VM を起動し、 mother ホストとしてプロビジョニングします
2. mother ホストから AWS VPC を構築し、 AWS EC2 インスタンス（以降、ターゲットホストと呼びます）を起動し、そのパブリックIPに接続できるように motherホストを設定します（AWS以外の環境に対して利用する場合は、このステップは不要です）
3. mother ホストからターゲットホストにdocker のホストシステムとなるようプロビジョニングを実行し、そのうち、1台に構成管理ツールをインストールします（構成管理ツールがインストールされたホストをマネージャホストと呼びます）

## コンテナ配備フェーズ
コンテナ配備フェーズでは、構成管理ツールで docker のコンテナをターゲットホストにデプロイします。以下のステップで実行します。
1. docker のイメージをビルドします
2. docker のコンテナをデプロイします

# 準備
Mac OS上で以下の環境を揃えます。準備段階から、mother ホストの構築ステップまでは大量にダウンロードすることになりますので、インターネットへのアクセスについて充分な速度と通信量を確保してください。

## VirtualBox+Vagrant
VirtualBox と Vagrant をインストールしてください。

参考：https://qiita.com/ats05/items/9bbd033e02323b8a68bd

## NFS
NFS をインストールしてください。

参考： http://www.1x1.jp/blog/2013/08/vagrant_synced_folder_with_nfs.html

## homebrew
homebrew をインストールしてください。

参考：https://weblabo.oscasierra.net/homebrew-1/

ここで、 xcode や xcode cli をダウンロードインストールすることになりますが、このサイズが大きく時間がかかるので注意してください。

## ansible
ansible をインストールしてください。

参考：https://weblabo.oscasierra.net/ansible-homebrew-install-1/

## Vagrant reload plugin
以下のコマンドを実行して、Vagrant reload plugin をインストールしてください。
```
vagrant plugin install vagrant-reload
```

# ファイルの配置
site-builder を clone したディレクトリに以下のように設定ファイルを配置します。
```
.
|-- config
|   |-- hosts
|   |   |-- images.yml
|   |   |-- managers.yml
|   |   `-- targets.yml
|   |-- roles
|   |   |-- (role 1)
|   |   |-- (role 2)
    ...
|   |   `-- (role N)
|   |-- services
|   |   |-- (service 1).yml
|   |   |-- (service 2).yml
    ...
|   |   `-- (service N).yml
|   |-- site-builder
|   |   |-- aws
|   |   |-- playbooks
|   |   |-- roles
|   |   `-- vagrant
|   `-- vars
|       `-- main.yml
|       `-- git.yml
|       `-- credentials.yml
`-- vagrant.yml
```

各ファイルの内容に関する説明は未執筆です。

# クレデンシャル情報の設定
各サービスへのアクセスのための秘密情報を credentials.yml に設定してください。
- AWS EC2 へのSSH用秘密鍵を変数 id_rsa に設定
- AWS API にアクセスするための鍵を変数 aws_access_key_id　と aws_secret_access_key　に設定

設定例：
```
aws_access_key_id: EXAMPLEOFACCESSKEYID
aws_secret_access_key: EXAMPLEOFSECRETACCESSKEY
builder_id_rsa: |
  -----BEGIN RSA PRIVATE KEY-----
  MIICXwIBAAKBgQDZBHBOzM1pIMEviVkE1EclpruTvSI29gXyIkbvefopkInovMjg
  TRE+YScYgWFq1/S6kajB4zzZFxXp7l6ml/ay0idq0Ropzxs/BeNgSbSgr8ZRoVW6
  0kxnXkE8zyuCiL9ZYxinsiVeWZpgld/+kLYNvA2WBGQOIHQWOXN5grQYZwIDAQAB
  AoGBANIcHQv992YwIzn99WTajWOjsPpR5H1n5svOafVTmGODoDHoDWg01VwavbpZ
  EVNbcILtoYDOnEvmsP3DHnqWqG4hXM60kacYIo8d0SMlUdT7JgCz4M//ozK7KEAr
  MFpdLGqy3FfYr1la9Wo4YCcHqBGiqUIBKjtZcL1c0uBsUy+xAkEA/92TeA1mKOiB
  B1uapweu/ZQt0RblijozovU3qKnBL1FzYaR4JyIcF+1LP8jSTw2L5zYvNR0oQugt
  Tf1gruj43wJBANkhotPsJVLs3qo+CBd5OzgGH3byAri1YmgWVZQd9Px17o/dAIP3
  rvCKgYqUS+zGEEMk3xmPrBAZjb1Gs5DdaXkCQQDmhBXsPwYfLPmyS1FV0pJRW0K7
  8cjzc+Q5mHuAtQ+bNeKhwa+OciilVeBJov/2wNmegS6ex5oSTWMjtHd6neI5AkEA
  mNtmHt0a9YMNyjm7RpMxDmK5GeqL4e7HpVE70/c29dgsJxlFeKIQhQRs59s4jCpv
  XmWBriQH1Jm4v+wbE7vbuQJBAN/QaPJyaD8nblu+vQ02D+nGGc0uR9av+UlgfCTe
  U517l2Pw75TaoH6/sHjOf58/n23UDBzHEtoCStMQmwIlDMU=
  -----END RSA PRIVATE KEY-----
```

## Vagrant の設定
mother ホストは NAT とホストオンリーの2つのネットワークを使用します。
mother ホストのホストオンリーの IPアドレスとネットマスクを変数 mother_ip と mother_netmask に設定してください。
また、 /vagrant ディレクトリの同期方法を変数 sync_type に設定してください。

設定例：
```
mother_ip: 192.168.56.40
mother_netmask: 255.255.255.0
sync_type: nfs
```

# mother ホスト VM の起動
以下のコマンドを実行して、Virtualbox の VM を起動してください。
```
$ cd site-builder/vagrant
$ vagrant up
```
Mac OS で vagrant.yml の中で sync_type: nfs を利用している場合は途中で root のパスワードを求めらますので、パスワードを入力してください。

## 削除方法
上記で作成したmother ホスト VM を削除する場合は、以下のコマンドを実行してください。
```
$ vagrant destroy
```
確認メッセージが出るので、yes を入力してください。

# aws 検証環境の EC2 インスタンスの起動
以下のコマンドを実行して、AWS の EC2 インスタンスを起動してください。
```
$ vagrant ssh
(ansible)[vagrant@mother ~]$ buildAws
```
ansible の AWS モジュールの動作が安定しておらず、エラーになる場合があります。エラーが出た場合は、AWSコンソールで VPC を削除して、やり直してください。
参考：https://github.com/ansible/ansible/issues/36063

このコマンドでは以下の内容が実行されます。
- VPC の作成
- サブネットの作成
- EC2インスタンスの作成と起動
- mother ホストがインターネットへ出るときのグローバルIPを取得
− 前項グローバルIPからの接続を許可する設定をセキュリティグループに追加
- EC2インスタンスの public IP を mother ホストの /etc/hosts に登録

## 削除方法
上記で作成した aws 検証環境を削除する場合は、以下のコマンドを実行してください。
```
(ansible)[vagrant@mother ~]$ destroyAws
```
## その他の alias
上記の他に以下の alias が定義されています。

|コマンド|機能|
----|----
|disconnectAws|EC2のPublic IP を /etc/hosts から削除し、セキュリティグループの設定を削除|
|stopEc2|disconnectAws実行後に EC2 インスタンスを停止|
|startEc2|EC2インスタンスを起動|
|connectAws|startEc2実行後に、EC2のPublic IP を /etc/hosts に追加し、セキュリティグループの設定を追加|

# aws 検証環境のサーバ構築
以下のコマンドを実行して、aws 検証環境のサーバを構築してください。
```
(ansible)[vagrant@mother ~]$ buildHosts
```

# マネージャホストへのログイン
以下のコマンドを実行して、マネージャホストにログインしてください。
```
(ansible)[vagrant@mother ~]$ ssh (マネージャホスト)
```

# docker イメージの構築
以下のコマンドを実行して、docker イメージを構築してください。
```
(ansible)[centos@manager ~]$ buildImages
```

# docker サービスのデプロイ
以下のコマンドを実行して、docker サービスをデプロイしてください。
```
(ansible)[centos@manager ~]$ deployServices
```
