/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");

initializeApp();

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.sendNotification = onDocumentCreated("notifications/{notificationId}", async (event) => {
  const notification = event.data.data();
  
  try {
    const userDoc = await getFirestore()
      .collection("users")
      .doc(notification.recipientId)
      .get();
    
    const userData = userDoc.data();
    const fcmToken = userData ? userData.fcmToken : null;
    
    if (fcmToken) {
      await getMessaging().send({
        token: fcmToken,
        notification: {
          title: notification.title,
          body: notification.body,
        },
      });
      console.log("Bildirim başarıyla gönderildi");
    }
  } catch (error) {
    console.error("Bildirim gönderme hatası:", error);
  }
});
