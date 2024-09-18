// Import Firebase SDK scripts for compatibility
importScripts("https://www.gstatic.com/firebasejs/10.13.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.13.0/firebase-messaging-compat.js");

// Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyBUKhNpZc37vV1OBRRJ6dOMiKlL005bCEQ",
  authDomain: "project-tracker-nk.firebaseapp.com",
  projectId: "project-tracker-nk",
  storageBucket: "project-tracker-nk.appspot.com",
  messagingSenderId: "454982685223",
  appId: "1:454982685223:web:ac5a4a215961c9d4f0f402"
};

// Initialize Firebase
firebase.initializeApp(firebaseConfig);

// Retrieve Firebase Messaging object
const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);

  // Customize notification here
  const notificationTitle = payload.notification.title || 'Default Title';
  const notificationOptions = {
    body: payload.notification.body || 'Default body',
    icon: payload.notification.icon || '/firebase-logo.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
