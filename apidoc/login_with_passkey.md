# パスキーでログインする

```
POST /login_with_passkey
```

## Request body

- AuthenticationResponseJSON
  - https://www.w3.org/TR/webauthn-3/#dictdef-authenticationresponsejson
- AuthenticatorAssertionResponse(response)
  - https://www.w3.org/TR/webauthn-3/#dictdef-authenticatorassertionresponsejson
  - https://www.w3.org/TR/webauthn-3/#authenticatorassertionresponse

| Name                       | Type   | Description                                                    |
| -------------------------- | ------ | -------------------------------------------------------------- |
| id                         | string | 認証器の識別子                                                 |
| rawId                      | string | 生の認証器識別子                                               |
| type                       | string | キータイプ、ここでは`public-key`                               |
| response                   | object | 認証応答に関する詳細情報を含むオブジェクト                     |
| response.clientDataJSON    | string | クライアントデータの JSON 形式の base64 エンコードされた文字列 |
| response.authenticatorData | string | 認証器データの base64 エンコードされた文字列                   |
| response.signature         | string | 認証応答の署名                                                 |
| response.userHandle        | string | ユーザー識別ハンドル                                           |

### `clientDataJSON` を base64 デコードした内容

| Name        | Type    | Description                          |
| ----------- | ------- | ------------------------------------ |
| type        | string  | 処理のタイプ。ここでは`webauthn.get` |
| challenge   | string  | 認証チャレンジ                       |
| origin      | string  | リクエストのオリジン                 |
| crossOrigin | boolean | クロスオリジンリクエストかどうか     |

- sample body

```json
{
  "id": "xxx",
  "rawId": "xxx",
  "type": "public-key",
  "response": {
    "clientDataJSON": "xxx",
    "authenticatorData": "xxx",
    "signature": "xxx",
    "userHandle": "xxx"
  }
}
```

- clientDataJSON を base64 デコードした結果

```json
{
  "type": "webauthn.get",
  "challenge": "xxx",
  "origin": "https://localhost:4567",
  "crossOrigin": false
}
```

## Response

| Name        | Type   | Description    |
| ----------- | ------ | -------------- |
| id          | string | ユーザー識別子 |
| name        | string | ユーザー名     |
| displayName | string | ユーザー表示名 |

- sample body

```json
{
  "id": "xxx",
  "username": "taro",
  "displayName": "yamada taro"
}
```
