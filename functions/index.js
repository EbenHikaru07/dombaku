// const functions = require("firebase-functions");
// const admin = require("firebase-admin");
// admin.initializeApp();

// exports.sendHealthNotification = funcstions.firestore
//     .document("catatan_kesehatan/{docId}")
//     .onWrite((change, context) => {s
//         const data = change.after.exists ? change.after.data() : null;
//         if (!data || !data.timestamp) return null;

//         const timestamp = data.timestamp.toDate();
//         const now = new Date();

//         // ✅ Kirim hanya jika timestamp >= sekarang
//         if (timestamp < now) {
//             console.log("Lewat waktu, tidak dikirim notifikasi.");
//             return null;
//         }

//         const payload = {
//             notification: {
//                 title: "Perubahan Kesehatan Domba",
//                 body: `Eartag: ${data.eartag}, Status: ${data.kesehatan}`
//             },
//             data: {
//                 eartag: data.eartag,
//                 kesehatan: data.kesehatan || "",
//                 keterangan: data.keterangan || "",
//             }
//         };

//         return admin.messaging().sendToTopic("notifikasi_domba", payload);
//     });

// // /**
// //  * Import function triggers from their respective submodules:
// //  *
// //  * const {onCall} = require("firebase-functions/v2/https");
// //  * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
// //  *
// //  * See a full list of supported triggers at https://firebase.google.com/docs/functions
// //  */

// // const {onRequest} = require("firebase-functions/v2/https");
// // const logger = require("firebase-functions/logger");

// // // Create and deploy your first functions
// // // https://firebase.google.com/docs/functions/get-started

// // // exports.helloWorld = onRequest((request, response) => {
// // //   logger.info("Hello logs!", {structuredData: true});
// // //   response.send("Hello from Firebase!");
// // // });
