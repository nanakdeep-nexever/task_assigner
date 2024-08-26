// Import Firebase SDK scripts for compatibility
importScripts("https://www.gstatic.com/firebasejs/9.6.10/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.6.10/firebase-messaging-compat.js");

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
//
//// Background message handler
//messaging.onBackgroundMessage((payload) => {
//    console.log('[firebase-messaging-sw.js] Received background message ', payload);
//
//
//    // Customize notification here
//    const notificationTitle = ;
//    const notificationOptions = {
//        body: payload,
//        icon: '/firebase-logo.png'
//    };
//
//    self.registration.showNotification(notificationTitle, notificationOptions);
});


