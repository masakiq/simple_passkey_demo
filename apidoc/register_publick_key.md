# 公開鍵を登録する

```
POST /register_publick_key
```

## Request body

- RegistrationResponseJSON
  - https://www.w3.org/TR/webauthn-3/#dictdef-registrationresponsejson
- AuthenticatorAttestationResponse(response)
  - https://www.w3.org/TR/webauthn-3/#dictdef-authenticatorattestationresponsejson
  - https://www.w3.org/TR/webauthn-3/#iface-authenticatorattestationresponse

| Name                       | Type          | Description                                                        |
| -------------------------- | ------------- | ------------------------------------------------------------------ |
| id                         | string        | 識別子                                                             |
| rawId                      | string        | 生の識別子                                                         |
| type                       | string        | キータイプ、ここでは`public-key`                                   |
| authenticatorAttachment    | string        | 認証器の取り付け方法。例: `platform`                               |
| response                   | object        | 認証応答に関する詳細情報を含むオブジェクト                         |
| response.clientDataJSON    | string        | クライアントデータの JSON 形式の base64 エンコードされた文字列     |
| response.attestationObject | string        | 認証オブジェクトの base64 エンコードされた文字列                   |
| response.transports        | array<string> | 使用可能なトランスポート方法のリスト。例: `["internal", "hybrid"]` |

### `clientDataJSON` を base64 デコードした内容

| Name        | Type    | Description                             |
| ----------- | ------- | --------------------------------------- |
| type        | string  | 処理のタイプ。ここでは`webauthn.create` |
| challenge   | string  | 認証チャレンジ                          |
| origin      | string  | リクエストのオリジン                    |
| crossOrigin | boolean | クロスオリジンリクエストかどうか        |

これらのテーブルは、提供された JSON データに基づいています。

- sample body

```json
{
  "id": "xxx",
  "rawId": "xxx",
  "type": "public-key",
  "authenticatorAttachment": "platform",
  "response": {
    "clientDataJSON": "xxx",
    "attestationObject": "xxx",
    "transports": ["internal", "hybrid"]
  }
}
```

## Response

| Name        | Type   | Description    |
| ----------- | ------ | -------------- |
| id          | string | ユーザー識別子 |
| name        | string | ユーザー名     |
| displayName | string | ユーザー表示名 |

```json
{
  "id": "xxx",
  "username": "taro",
  "displayName": "yamada taro"
}
```
