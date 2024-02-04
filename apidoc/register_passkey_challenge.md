# パスキー登録チャレンジを作成する

```http
POST /register_passkey_challenge
```

セッションを用いてユーザーを判別するため、リクエスト時にログインセッションが必要。

## Response

- PublicKeyCredentialCreationOptions
  - https://www.w3.org/TR/webauthn-3/#dictdef-publickeycredentialcreationoptions
  - https://www.w3.org/TR/webauthn-3/#sctn-credentialcreationoptions-extension

| Name                                                               | Type          | Description                                                                                                                            |
| ------------------------------------------------------------------ | ------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| challenge                                                          | string        | リプレイ攻撃を防ぐためのランダムに生成された文字列。**16 byte** 以上。Base64URL エンコードされた値                                     |
| rp                                                                 | object        | Relying Party(以降 RP と記載する) 情報                                                                                                 |
| rp.id(※1)                                                          | string        | RP のドメイン                                                                                                                          |
| rp.name                                                            | string        | RP の名前                                                                                                                              |
| user                                                               | object        | ユーザー情報                                                                                                                           |
| user.id(※1)                                                        | string        | ユーザー識別子。パスキー認証時に `userHandle` として返される。最大 64 byte。                                                           |
| user.name                                                          | string        | ユーザー名                                                                                                                             |
| user.displayName                                                   | string        | ユーザー表示名                                                                                                                         |
| pubKeyCredParams                                                   | array<object> | 公開キー認証パラメータ                                                                                                                 |
| pubKeyCredParams[].type                                            | string        | キータイプ                                                                                                                             |
| pubKeyCredParams[].alg                                             | number        | アルゴリズム                                                                                                                           |
| timeout(**optional**)                                              | number        | タイムアウトの時間（ミリ秒単位）                                                                                                       |
| attestation(**optional**, enum, default `none`)                    | string        | 認証器が生成した公開鍵の証明情報の取り扱いを指定する。証明情報は、認証器が信頼できることを証明するために使用する。                     |
| attestationFormats(**optional**, default `[]`)                     | array<string> | 認証器によって生成された証明（attestation）データ構造の優先順位を定義する。例 : Packed、TPM                                            |
| excludeCredentials(**optional**)                                   | array<object> | すでに登録済のクレデンシャルのリスト。重複したクレデンシャルの作成を抑制する。                                                         |
| excludeCredentials[].id                                            | string        | クレデンシャルの識別子。Base64URL エンコードされた値                                                                                   |
| excludeCredentials[].type                                          | string        | 鍵タイプ。必ず `public-key` である                                                                                                     |
| excludeCredentials[].transports(**optional**, enum)                | array<string> | クレデンシャルを取得した通信経路。認証器がクレデンシャルを生成したあとの PublicKeyCredential.resuponse.getTransports() の値            |
| authenticatorSelection(**optional**)                               | object        | 認証器の選択基準。アプリケーションのセキュリティ要件に適した認証器の選択基準を要求する。                                               |
| authenticatorSelection.authenticatorAttachment(enum)               | string        | 認証器のタイプ                                                                                                                         |
| authenticatorSelection.residentKey(enum)                           | string        | クレデンシャルを認証器内に直接保存する（常駐）タイプの認証器であるかどうか                                                             |
| authenticatorSelection.requireResidentKey(default `false`)         | boolean       | residentKey が `require` に設定されている場合にのみ、このメンバを `true` にする。WebAuthn Level 1 との後方互換のために保持されている。 |
| authenticatorSelection.userVerification(enum, default `preferred`) | string        | 認証プロセスの指定                                                                                                                     |
| extensions(**optional**)                                           | object        | 拡張機能                                                                                                                               |
| extensions.appid                                                   | string        |                                                                                                                                        |
| extensions.appidExclude                                            | string        |                                                                                                                                        |
| extensions.credProps                                               | boolean       | 認証器のプロパティ拡張                                                                                                                 |
| extensions.uvm                                                     | boolean       |                                                                                                                                        |
| extensions.largeBlob                                               | object        |                                                                                                                                        |

※1 rp.id および user.id は、認証器が持つ既存のクレデンシャルの識別に用いられる

### [attestation(enum)](https://www.w3.org/TR/webauthn-3/#attestation-conveyance)

| Name       | Description                                                                                                                |
| ---------- | -------------------------------------------------------------------------------------------------------------------------- |
| none       | デフォルト値。証明書を要求しない。プライバシーを優先し、認証器の詳細情報を隠したい場合に使用される。                       |
| indirect   | 証明情報を要求するが、間接的な方法（例えば、証明書の中間機関を通じて）で提供される                                         |
| direct     | 認証器の完全な証明情報を要求する。サーバーは認証器のモデルや製造元を確認できる。                                           |
| enterprise | 組織の独自の認証情報を要求する。組織がセキュリティ基準に準拠した認証器のみを使用することを保証したい場合などに使用される。 |

### [transports(enum)](https://www.w3.org/TR/webauthn-3/#enum-transport)

| Name       | Description            |
| ---------- | ---------------------- |
| usb        | USB                    |
| nfc        | NFC                    |
| ble        | Bluetooth              |
| smart-card | スマートカード         |
| hybrid     | ハイブリッド           |
| internal   | デバイス固有の内部認証 |

### [authenticatorAttachment(enum)](https://www.w3.org/TR/webauthn-3/#enumdef-authenticatorattachment)

| Name           | Description                                                                                                                                             |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| platform       | デバイスに組み込まれた認証機。例えば PC、スマートフォン、タブレットなど、エンドユーザーのデバイス上に物理的に存在する指紋スキャナーや顔認証システムなど |
| cross-platform | 複数のデバイス間で使用できる認証器。 USB、NFC、Bluetooth を介してデバイスに接続されるハードウェアセキュリティキーなど                                   |

### [authenticatorSelection.residentKey(enum)](https://www.w3.org/TR/webauthn-3/#enumdef-residentkeyrequirement)

| Name        | Description                                                                                                                                                            |
| ----------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| discouraged | 常駐キーである必要はない、または推奨しない。ただし、認証器が常駐キーのみしかサポートしていない場合は常駐キーが使用される可能性がある                                   |
| preferred   | 常駐キーの作成を推奨するが、必須ではない。常駐キーをサポートする認証器を優先的に使用することを示すが、常駐キーをサポートしない認証器でも登録や認証プロセスを完了できる |
| required    | 常駐キーの作成が必須である。認証プロセスは常駐キーをサポートする認証器のみを使用して行われる                                                                           |

### [authenticatorSelection.userVerification(enum)](https://www.w3.org/TR/webauthn-3/#enumdef-userverificationrequirement)

| Name        | Description                                                                                                                                                              |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| discouraged | ユーザーの本人確認を行わないことを推奨する。認証プロセスをできるだけ簡単かつ迅速にしたい場合、または本人確認の手段を持たない認証器の使用をサポートしたい場合に使用される |
| preferred   | ユーザーの本人確認を行うことを推奨するが、必須ではない。認証器がこの機能をサポートしていない場合は、ユーザーの本人確認なしで処理を進めることができる                     |
| required    | 認証プロセスでユーザーの本人確認が必須である。認証器（例えば、生体認証や PIN コードなど）による明確なユーザーの同意や身元確認が行われなければならない                    |

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
