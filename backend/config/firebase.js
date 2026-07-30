const { initializeApp, cert, getApps } = require("firebase-admin/app");
const admin = require("firebase-admin");

try {
  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey = process.env.FIREBASE_PRIVATE_KEY;

  if (projectId && clientEmail && privateKey) {
    if (!getApps().length) {
      initializeApp({
        credential: cert({
          projectId,
          clientEmail,
          privateKey: privateKey.replace(/\\n/g, "\n"),
        }),
      });
    }

    console.log("✅ Firebase initialisé");
  } else {
    console.warn("⚠️ Variables Firebase manquantes");
  }
} catch (err) {
  console.error("Erreur Firebase :", err);
}

module.exports = admin;