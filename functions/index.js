/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

const admin = require("firebase-admin");
admin.initializeApp();

const db = admin.firestore();

exports.sendNotifications = async (req, res) => {
  const now = new Date();
  const promises = [];

  const medicationSnapshot = await db.collection("medications").get();

  medicationSnapshot.forEach((doc) => {
    const med = doc.data();
    const patientId = med.patientId;

    med.schedules.forEach((time) => {
      const [hours, minutes] = time.split(":");
      const isPM = time.includes("PM");
      const scheduleTime = new Date();

      scheduleTime.setHours(isPM ? parseInt(hours) + 12 : parseInt(hours));
      scheduleTime.setMinutes(parseInt(minutes));
      scheduleTime.setSeconds(0);
      scheduleTime.setMilliseconds(0);

      scheduleTime.setMinutes(scheduleTime.getMinutes() - med.reminderOffset);

      if (Math.abs(scheduleTime - now) <= 60000) {
        promises.push(
            sendNotification(
                patientId,
                "Medication Reminder: ${med.name}",
                "It's time to take " +
                "${med.dose} ${med.measurement} of ${med.name} ${med.timeRelation}.",
            ),
        );
      }
    });
  });

  const appointmentSnapshot = await db.collection("appointments").get();

  appointmentSnapshot.forEach((doc) => {
    const appointment = doc.data();
    const patientId = appointment.patientId;

    const appointmentTime = appointment.date.toDate();
    const reminderTime = new Date(appointmentTime);
    reminderTime.setMinutes(reminderTime.getMinutes() - 30);

    if (Math.abs(reminderTime - now) <= 60000) {
      promises.push(
          sendNotification(
              patientId,
              "Appointment Reminder",
              "You have an appointment at ${appointment.timeSlot}.",
          ),
      );
    }
  });

  await Promise.all(promises);

  res.status(200).send("Notifications sent successfully.");
};

/**
 * Sends a notification to the user.
 *
 * @param {string} userId - The ID of the user to notify.
 * @param {string} title - The title of the notification.
 * @param {string} body - The body of the notification.
 * @return {Promise<void>} - A promise that resolves when the notification is sent.
 */
async function sendNotification(userId, title, body) {
  const userDoc = await db.collection("users").doc(userId).get();
  const user = userDoc.data();

  if (user && user.notificationToken) {
    const message = {
      notification: {title, body},
      token: user.notificationToken,
    };

    try {
      await admin.messaging().send(message);
      console.log("Notification sent to ${user.name || userId}");
    } catch (error) {
      console.error("Failed to send notification to ${user.name || userId}:", error);
    }
  }
}
