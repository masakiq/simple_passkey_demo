# パスキーログインチャレンジを作成する

```
POST /login_with_passkey_challenge
```

## Response

- PublicKeyCredentialRequestOptions
  - https://www.w3.org/TR/webauthn-3/#dictionary-assertion-options
  - https://www.w3.org/TR/webauthn-3/#sctn-credentialrequestoptions-extension

| Name             | Type          | Description                                                                                          |
| ---------------- | ------------- | ---------------------------------------------------------------------------------------------------- |
| challenge        | string        | リプレイ攻撃を防ぐためのランダムに生成された文字列。**16 byte** 以上。Base64URL エンコードされた値。 |
| allowCredentials | array<object> | 認証に使用可能なクレデンシャルのリスト。空のリストも許容される。                                     |
| timeout          | integer       | 認証器がユーザー認証するまでの待ち時間                                                               |
| userVerification | string        | ユーザー検証の要件。例: `preferred`。                                                                |
| rpId             | string        | RP のドメイン                                                                                        |

- sample body

```json
{
  "challenge": "xxx",
  "allowCredentials": [],
  "timeout": 60000,
  "userVerification": "preferred",
  "rpId": "localhost:4567"
}
```
