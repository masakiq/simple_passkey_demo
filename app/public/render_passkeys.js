async function renderPasskeys() {
  const passkeys = await getPasskeys();
  const passkeyList = document.getElementById("passkey_list");
  const ul = document.createElement("ul");

  if (passkeys.length === 0) {
    const li = document.createElement("li");
    li.textContent = `No Passkeys.`;
    ul.appendChild(li);
  } else {
    passkeys.forEach((passkey) => {
      const li = document.createElement("li");
      li.textContent = `Name: ${passkey.name}, WebAuthn ID: ${passkey.webauthn_id}`;
      ul.appendChild(li);
    });
  }
  passkeyList.appendChild(ul);
}

async function getPasskeys() {
  const response = await fetch("/passkeys", {
    method: "GET",
    credentials: "same-origin",
    headers: { "Content-Type": "application/json" },
  });

  if (response.status === 200) {
    return response.json();
  } else {
    const result = await response.json();
    throw new Error(result.error);
  }
}

renderPasskeys();
