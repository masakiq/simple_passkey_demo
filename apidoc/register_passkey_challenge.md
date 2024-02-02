# パスキー登録チャレンジを作成する

```http
POST /register_passkey_challenge
```

セッションを用いてユーザーを判別するため、リクエスト時にログインセッションが必要。

## Response

- PublicKeyCredentialCreationOptions
  - https://www.w3.org/TR/webauthn-3/#dictdef-publickeycredentialcreationoptions
  - https://www.w3.org/TR/webauthn-3/#sctn-credentialcreationoptions-extension

| Name                                           | Type          | Description                                                                                        |
| ---------------------------------------------- | ------------- | -------------------------------------------------------------------------------------------------- |
| challenge                                      | string        | リプレイ攻撃を防ぐためのランダムに生成された文字列。**16 byte** 以上。Base64URL エンコードされた値 |
| rp                                             | object        | Relying Party 情報                                                                                 |
| rp.name                                        | string        | RP の名前                                                                                          |
| rp.id                                          | string        | RP のドメイン                                                                                      |
| user                                           | object        | ユーザーに関する情報                                                                               |
| user.id                                        | string        | ユーザー識別子。ランダムな文字列                                                                   |
| user.name                                      | string        | ユーザー名                                                                                         |
| user.displayName                               | string        | ユーザー表示名                                                                                     |
| pubKeyCredParams                               | array<object> | 公開キー認証パラメータ                                                                             |
| pubKeyCredParams[].type                        | string        | キータイプ                                                                                         |
| pubKeyCredParams[].alg                         | number        | アルゴリズム                                                                                       |
| timeout                                        | number        | タイムアウトの時間（ミリ秒単位）                                                                   |
| attestation                                    | string        | 証明書要件                                                                                         |
| excludeCredentials                             | array<object> | 除外する認証器のリスト                                                                             |
| excludeCredentials[].id                        | string        | 除外対象の Passkey 識別子。Base64URL エンコードされた値。                                          |
| excludeCredentials[].type                      | string        | 鍵タイプ。必ず `public-key` である                                                                 |
| excludeCredentials[].transports                | array<string> | 通信経路                                                                                           |
| authenticatorSelection                         | object        | 認証器の選択基準                                                                                   |
| authenticatorSelection.authenticatorAttachment | string        | 認証器のタイプ                                                                                     |
| authenticatorSelection.requireResidentKey      | boolean       | 後方互換のためのキー。residentKey が require に設定されている場合にのみ、このメンバを true にする  |
| authenticatorSelection.residentKey             | string        | RP ががクライアント側で発見可能なクレデンシャルの作成を望む範囲を指定する                          |
| extensions                                     | object        | 拡張機能                                                                                           |
| extensions.credProps                           | boolean       | 認証器のプロパティ拡張                                                                             |

### attestation(enum)

| Name       | Description                                                                                              |
| ---------- | -------------------------------------------------------------------------------------------------------- |
| none       | 証明書を提供する必要なし                                                                                 |
| indirect   | 認証装置は証明書を提供する必要がありますが、間接的な方法（例えば、証明書の中間機関を通じて）で提供される |
| direct     | 認証装置は直接的な方法で証明書を提供する必要がある                                                       |
| enterprise | 組織が独自の証明プロセスを実装し、認証装置からの証明書の提出を要求することができる                       |

### transports(enum)

| Name       | Description            |
| ---------- | ---------------------- |
| usb        | USB                    |
| nfc        | NFC                    |
| ble        | Bluetooth              |
| smart-card | スマートカード         |
| hybrid     | ハイブリッド           |
| internal   | デバイス固有の内部認証 |

### authenticatorAttachment(enum)

| Name           | Description                                                                                                                               |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| platform       | プラットフォーム内認証器（内蔵認証器）が使用される。例えばスマートフォン、タブレットなどの指紋センサーや顔認証システム                    |
| cross-platform | クロスプラットフォーム認証器（外部認証器）が使用される。 USB、NFC、Bluetooth を介してデバイスに接続されるハードウェアセキュリティキーなど |

- sample body

```json
{
  "challenge": "xxx",
  "rp": {
    "name": "Example app",
    "id": "localhost:4567"
  },
  "user": {
    "id": "xxx",
    "name": "taro",
    "displayName": "yamada taro"
  },
  "pubKeyCredParams": [
    { "type": "public-key", "alg": -7 },
    { "type": "public-key", "alg": -37 },
    { "type": "public-key", "alg": -257 }
  ],
  "timeout": 60000,
  "attestation": "direct",
  "excludeCredentials": [
    {
      "id": "xxx",
      "type": "public-key",
      "transports": ["hybrid", "internal"]
    },
    {
      "id": "xxx",
      "type": "public-key",
      "transports": ["internal"]
    }
  ],
  "authenticatorSelection": {
    "authenticatorAttachment": "platform",
    "requireResidentKey": true,
    "residentKey": "required"
  },
  "extensions": { "credProps": true }
}
```
