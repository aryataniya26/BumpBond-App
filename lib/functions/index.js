const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

// ✅ Daily Morning Pregnancy Tip (9:00 AM IST)
exports.sendDailyPregnancyTip = functions.pubsub.schedule('0 9 * * *')
  .timeZone('Asia/Kolkata')
  .onRun(async (context) => {
    try {
      const messages = [
        {
          title: '🌺 Good Morning! Daily Pregnancy Tip',
          body: 'Start your day with a healthy breakfast and stay hydrated! Your baby is growing every day. 💧'
        },
        {
          title: '👶 Baby Development Update',
          body: 'Your baby is becoming more active! Try talking or singing to your baby today. 🎵'
        },
        {
          title: '💖 Self-Care Reminder',
          body: 'Take some time for yourself today. Rest is important for you and your baby. 😴'
        },
        {
          title: '🍎 Nutrition Tip',
          body: 'Include fruits and vegetables in every meal for essential vitamins. 🥦'
        },
        {
          title: '🚶‍♀️ Activity Suggestion',
          body: 'A gentle walk can help with circulation and mood. Take it easy! 🌳'
        },
        {
          title: '💊 Vitamin Reminder',
          body: 'Remember to take your prenatal vitamins today! 🌟'
        },
        {
          title: '📅 Check Your Calendar',
          body: 'Review your upcoming doctor appointments and make notes. 🏥'
        }
      ];

      const randomMessage = messages[Math.floor(Math.random() * messages.length)];

      const message = {
        notification: {
          title: randomMessage.title,
          body: randomMessage.body
        },
        topic: 'all_users'
      };

      await admin.messaging().send(message);
      console.log('✅ Daily pregnancy tip sent:', randomMessage.title);
      return null;
    } catch (error) {
      console.error('❌ Error sending daily tip:', error);
      return null;
    }
  });

// ✅ Weekly Development Update (Every Monday 10:00 AM IST)
exports.sendWeeklyUpdate = functions.pubsub.schedule('0 10 * * 1')
  .timeZone('Asia/Kolkata')
  .onRun(async (context) => {
    try {
      const message = {
        notification: {
          title: '📅 Weekly Pregnancy Update',
          body: 'Check what new developments are happening with your baby this week! 🌟'
        },
        topic: 'all_users'
      };

      await admin.messaging().send(message);
      console.log('✅ Weekly update sent successfully');
      return null;
    } catch (error) {
      console.error('❌ Error sending weekly update:', error);
      return null;
    }
  });

// ✅ Evening Relaxation Reminder (8:00 PM IST)
exports.sendEveningReminder = functions.pubsub.schedule('0 20 * * *')
  .timeZone('Asia/Kolkata')
  .onRun(async (context) => {
    try {
      const message = {
        notification: {
          title: '🌙 Evening Relaxation',
          body: 'Time to relax! Try some gentle stretching or meditation before bed. 🧘‍♀️'
        },
        topic: 'all_users'
      };

      await admin.messaging().send(message);
      console.log('✅ Evening reminder sent successfully');
      return null;
    } catch (error) {
      console.error('❌ Error sending evening reminder:', error);
      return null;
    }
  });

// ✅ Test Function - Send to all users immediately
exports.sendTestToAllUsers = functions.https.onRequest(async (req, res) => {
  try {
    const message = {
      notification: {
        title: '🧪 Test Notification - Bump Bond',
        body: 'This is a test notification sent to all Bump Bond users! ✅'
      },
      topic: 'all_users'
    };

    await admin.messaging().send(message);
    console.log('✅ Test notification sent to all users');
    res.status(200).send('Test notification sent successfully to all users!');
  } catch (error) {
    console.error('❌ Error sending test notification:', error);
    res.status(500).send('Error sending notification');
  }
});