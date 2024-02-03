# Simple Passkey Demo

This is the Simple Passkey Demo App.

# How to Start

## Install Ruby gems

```
$ bundle install
```

## Start server

```
$ bundle exec ruby app/main.rb
```

The default is to start up `http://localhost:4567`.

- Specify the URI of the Relying party

```
$ bundle exec ruby app/main.rb https://example.ngrok-free.app
```

Then You can create the Passkey in the domain of the relying party.

# Sequence diagram

## Register Passkey

```mermaid
sequenceDiagram
    participant Auth as 認証器
    participant User as ユーザー
    participant UA as ブラウザ
    participant RP as Relying Party

    User->>UA: パスキー登録ボタンを押下
    UA->>RP: チャレンジ要求
    RP->>+RP: チャレンジ生成・保存
    RP->>UA: チャレンジやユーザー情報などを返却
    UA->>Auth: チャレンジ + キーペア作成要求
    Auth->>User: 認証
    User->>Auth: 認証完了
    Auth->>+Auth: 公開鍵 + 秘密鍵生成
    Auth->>+Auth: チャレンジやその他データを秘密鍵で署名
    Auth->>UA: 署名したチャレンジと公開鍵を返却
    UA->>RP: 署名したチャレンジと公開鍵を送信
    RP->>+RP: 公開鍵でチャレンジやその他データを検証
    RP->>+RP: 公開鍵、ユーザーデータなどを保存
    RP->>UA: 登録完了
    UA->>User: 登録完了
```

## Authenticate with Passkey

```mermaid
sequenceDiagram
    participant Auth as 認証器
    participant User as ユーザー
    participant UA as ブラウザ
    participant RP as Relying Party

    User->>UA: パスキーでログインするボタンを押下
    UA->>RP: チャレンジ要求
    RP->>+RP: チャレンジ生成・保存
    RP->>UA: チャレンジや RP データなど返却
    UA->>Auth: チャレンジやその他データの署名を要求
    Auth->>User: 認証
    User->>Auth: 認証完了
    Auth->>+Auth: RP に紐づく秘密鍵でチャレンジやその他データを署名
    Auth->>UA: 署名したデータを返却
    UA->>RP: 署名したデータを送信
    RP->>+RP: 公開鍵を DB から検索して取得
    RP->>+RP: 取得した公開鍵でチャレンジやその他データを検証
    RP->>UA: ログインさせる
    UA->>User: ログイン完了
```

# URLs used as references when creating this app

- [はじめての WebAuthn](https://developers.google.com/codelabs/webauthn-reauth?hl=ja#0)
- [Web Authentication: An API for accessing Public Key Credentials - Level 2 Recommendation](https://www.w3.org/TR/webauthn-2/)
- [Web Authentication: An API for accessing Public Key Credentials - Level 3 Working Draft](https://www.w3.org/TR/webauthn-3/)
- [Web Authentication: An API for accessing Public Key Credentials - Level 3 Editor’s Draft](https://w3c.github.io/webauthn/)
- [Web Authentication API \- Web API \| MDN](https://developer.mozilla.org/ja/docs/Web/API/Web_Authentication_API)
- [Sequence diagrams · line/line-fido2-server Wiki](https://github.com/line/line-fido2-server/wiki/Sequence-diagrams)
- [パスワードの不要な世界はいかにして実現されるのか \- FIDO2 と WebAuthn の基本を知る](https://blog.agektmr.com/2019/03/fido-webauthn)
