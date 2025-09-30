// signer.js
// npm i crypto axios
const crypto = require("crypto");

/**
 * createSignedUrl
 * @param {string} baseUrl - e.g. https://mycdn.azurefd.net
 * @param {string} path - e.g. /content/image.jpg
 * @param {string} secret - the HMAC secret (from Key Vault, or from secure store)
 * @param {number} ttlSeconds - seconds from now
 */
function createSignedUrl(baseUrl, path, secret, ttlSeconds = 300) {
  const expires = Math.floor(Date.now() / 1000) + ttlSeconds;
  const payload = `${path}|${expires}`;
  const hmac = crypto.createHmac("sha256", secret).update(payload).digest();
  // base64url
  const token = hmac.toString("base64").replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
  const url = `${baseUrl}${path}?expires=${expires}&token=${token}`;
  return url;
}

// example usage:
if (require.main === module) {
  const baseUrl = process.env.BASE_URL || "https://<YOUR_FD_HOST>.azurefd.net";
  const secret = process.env.SIGNING_SECRET || "replace-with-your-secret";
  const path = process.argv[2] || "/content/example.jpg";
  const signed = createSignedUrl(baseUrl, path, secret, 600);
  console.log(signed);
}
module.exports = { createSignedUrl };
