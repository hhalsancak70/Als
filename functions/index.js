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
const functions = require("firebase-functions");
const admin = require("firebase-admin");

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
    // FCM token'ı doğrudan notifications koleksiyonundan al
    if (notification.fcmToken) {
      await getMessaging().send({
        token: notification.fcmToken,
        notification: {
          title: notification.title,
          body: notification.body,
        },
        android: {
          priority: "high",
          notification: {
            channelId: "high_importance_channel",
          },
        },
      });
      console.log("Bildirim başarıyla gönderildi");
    } else {
      // FCM token yoksa kullanıcı dokümanından al
      const userDoc = await getFirestore()
        .collection("users")
        .doc(notification.recipientId)
        .get();
      
      const userData = userDoc.data();
      const fcmToken = userData?.fcmToken;
      
      if (fcmToken) {
        await getMessaging().send({
          token: fcmToken,
          notification: {
            title: notification.title,
            body: notification.body,
          },
          android: {
            priority: "high",
            notification: {
              channelId: "high_importance_channel",
            },
          },
        });
        console.log("Bildirim başarıyla gönderildi");
      }
    }
  } catch (error) {
    console.error("Bildirim gönderme hatası:", error);
  }
});

exports.migrateBlogPosts = functions.https.onRequest(async (req, res) => {
  const blogsRef = admin.firestore().collection('blogs');
  const snapshot = await blogsRef.get();
  
  const batch = admin.firestore().batch();
  
  snapshot.docs.forEach((doc) => {
    const data = doc.data();
    if (!data.postedOn || !(data.postedOn instanceof admin.firestore.Timestamp)) {
      batch.update(doc.ref, {
        postedOn: admin.firestore.Timestamp.now(),
        username: data.username || data.author || 'Anonim',
        authorPhotoURL: data.authorPhotoURL || data.photoURL || null
      });
    }
  });
  
  await batch.commit();
  res.json({success: true, message: 'Migration completed'});
});
