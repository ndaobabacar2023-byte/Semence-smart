const admin = require("firebase-admin");

let initialized = false;

try {
  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey = process.env.FIREBASE_PRIVATE_KEY;

  console.log("DEBUG FIREBASE_PROJECT_ID present:", !!projectId);
  console.log("DEBUG FIREBASE_CLIENT_EMAIL present:", !!clientEmail);
  console.log("DEBUG FIREBASE_PRIVATE_KEY present:", !!privateKey);
  console.log("DEBUG FIREBASE_PRIVATE_KEY length:", privateKey ? privateKey.length : 0);
  console.log("DEBUG FIREBASE_PRIVATE_KEY starts with:", privateKey ? privateKey.substring(0, 30) : "N/A");
  console.log(admin);
  console.log(admin.credential);
  if (projectId && clientEmail && privateKey) {
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId,
        clientEmail,
        privateKey: privateKey.replace(/\\n/g, "\n"),
      }),
    });
    initialized = true;
    console.log("Firebase initialise");
  } else {
    console.warn("Variables FIREBASE manquantes - notifications push desactivees");
  }
} catch (error) {
  console.error("Erreur initialisation Firebase:", error.message);
}

module.exports = admin;