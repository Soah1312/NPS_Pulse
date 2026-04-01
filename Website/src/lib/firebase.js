import { initializeApp } from "firebase/app";
import { getAuth, GoogleAuthProvider } from "firebase/auth";
import { initializeFirestore } from "firebase/firestore";

const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID,
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId: import.meta.env.VITE_FIREBASE_APP_ID
};

// Initialize Firebase only if config is somewhat populated
// (helps prevent crashes during dev if .env is not yet filled)
let app, auth, db, googleProvider;

if (firebaseConfig.apiKey && firebaseConfig.apiKey !== "AIzaSyYourApiKeyHere...") {
  app = initializeApp(firebaseConfig);
  auth = getAuth(app);
  // Auto-detect long polling for environments where WebChannel/WebSocket is blocked.
  // This commonly fixes deployed-only "client is offline" Firestore errors.
  db = initializeFirestore(app, {
    experimentalAutoDetectLongPolling: true,
    useFetchStreams: false,
  });
  googleProvider = new GoogleAuthProvider();
}

export { auth, db, googleProvider };
