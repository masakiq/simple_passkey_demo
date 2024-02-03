async function registerPasskey() {
  const options = await _fetch("/register_passkey_challenge");
  const credential = await createCredential(options);
  sendPublicKeyToServer(credential);
}

async function createCredential(options) {
  options.challenge = base64url.decode(options.challenge);
  options.user.id = base64url.decode(options.user.id);
  if (options.excludeCredentials.length > 0) {
    options.excludeCredentials.forEach((credential) => {
      credential.id = base64url.decode(credential.id);
    });
  }

  const credential = await navigator.credentials.create({ publicKey: options });
  return credential;
}

async function sendPublicKeyToServer(credentials) {
  const publicKeyCredential = {
    id: credentials.id,
    type: credentials.type,
    rawId: base64url.encode(credentials.rawId),
    authenticatorAttachment: credentials.authenticatorAttachment,
    response: {
      attestationObject: base64url.encode(
        credentials.response.attestationObject
      ),
      clientDataJSON: base64url.encode(credentials.response.clientDataJSON),
      transports: credentials.response?.getTransports
        ? credentials.response.getTransports()
        : [],
    },
  };

  const response = await _fetch("/register_publick_key", publicKeyCredential);
  console.log("Server response:", response);
}
