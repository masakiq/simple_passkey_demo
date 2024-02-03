async function loginWithPasskey() {
  const options = await _fetch("/login_with_passkey_challenge");
  const credential = await getCredential(options);
  await _fetch("/login_with_passkey", credential);
  window.location.href = "/";
}

async function getCredential(options) {
  options.challenge = base64url.decode(options.challenge);
  options.allowCredentials = [];

  const cred = await navigator.credentials.get({
    publicKey: options,
    mediation: "required",
  });

  const credential = {};
  credential.id = cred.id;
  credential.rawId = base64url.encode(cred.rawId);
  credential.type = cred.type;

  // Base64URL encode some values.
  const clientDataJSON = base64url.encode(cred.response.clientDataJSON);
  const authenticatorData = base64url.encode(cred.response.authenticatorData);
  const signature = base64url.encode(cred.response.signature);
  const userHandle = base64url.encode(cred.response.userHandle);

  credential.response = {
    clientDataJSON,
    authenticatorData,
    signature,
    userHandle,
  };

  return credential;
}
