importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyDAw1ePZ9eXQoG7CAnSDuh20zLQalRBV1Q",
  authDomain: "scoliocare2.firebaseapp.com",
  projectId: "scoliocare2",
  storageBucket: "scoliocare2.firebasestorage.app",
  messagingSenderId: "980034052185",
  appId: "1:980034052185:web:5b0fb1de91d33a552d1148",
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log("Received background message: ", payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/icons/Icon-192.png"
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
