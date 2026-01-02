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
          body: 'Start your day with a healthy breakfast and stay hydrated! Your baby is growing every day. 💧',
          data: { screen: 'tips', feature: 'daily_tip' }
        },
        {
          title: '👶 Baby Development Update',
          body: 'Your baby is becoming more active! Try talking or singing to your baby today. 🎵',
          data: { screen: 'baby_chat', feature: 'baby_update' }
        },
        {
          title: '💖 Self-Care Reminder',
          body: 'Take some time for yourself today. Rest is important for you and your baby. 😴',
          data: { screen: 'self_care', feature: 'reminder' }
        },
        {
          title: '🍎 Nutrition Tip',
          body: 'Include fruits and vegetables in every meal for essential vitamins. 🥦',
          data: { screen: 'nutrition', feature: 'tip' }
        },
        {
          title: '🚶‍♀️ Activity Suggestion',
          body: 'A gentle walk can help with circulation and mood. Take it easy! 🌳',
          data: { screen: 'activities', feature: 'suggestion' }
        },
        {
          title: '💊 Vitamin Reminder',
          body: 'Remember to take your prenatal vitamins today! 🌟',
          data: { screen: 'medications', feature: 'reminder', channelId: 'medication_reminders' }
        },
        {
          title: '📅 Check Your Calendar',
          body: 'Review your upcoming doctor appointments and make notes. 🏥',
          data: { screen: 'appointments', feature: 'reminder' }
        }
      ];

      const randomMessage = messages[Math.floor(Math.random() * messages.length)];

      const message = {
        notification: {
          title: randomMessage.title,
          body: randomMessage.body
        },
        data: randomMessage.data,
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

// ✅ Water Reminder Every 2 Hours (8 AM to 10 PM IST)
exports.sendWaterReminder = functions.pubsub.schedule('0 8-22/2 * * *')
  .timeZone('Asia/Kolkata')
  .onRun(async (context) => {
    try {
      const messages = [
        {
          title: '💧 Water Reminder',
          body: 'Time to hydrate! Drinking water helps both you and your baby stay healthy.',
          data: {
            screen: 'baby_chat',
            feature: 'water_reminder',
            chatMessage: 'Hey mumma! 💧 It\'s time to drink water! Staying hydrated helps me grow strong and healthy. Please take a sip for both of us! 💙'
          }
        },
        {
          title: '🚰 Hydration Time',
          body: 'Your baby needs hydration too! Drink a glass of water.',
          data: {
            screen: 'baby_chat',
            feature: 'water_reminder',
            chatMessage: 'Mumma, I\'m thirsty too! 💦 Can you drink some water? It makes me feel so good when you stay hydrated! 🥰'
          }
        },
        {
          title: '💙 Drink Water',
          body: 'Staying hydrated reduces pregnancy discomfort. Drink up!',
          data: {
            screen: 'baby_chat',
            feature: 'water_reminder',
            chatMessage: 'Water time, mumma! 🌊 I need it to grow big and strong. Please drink a glass for us? Thank you! 💕'
          }
        }
      ];

      const message = messages[Math.floor(Math.random() * messages.length)];

      const notification = {
        notification: {
          title: message.title,
          body: message.body
        },
        data: message.data,
        topic: 'all_users'
      };

      await admin.messaging().send(notification);
      console.log('✅ Water reminder sent');
      return null;
    } catch (error) {
      console.error('❌ Error sending water reminder:', error);
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
        data: { screen: 'weekly_update', feature: 'weekly_update' },
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
        data: { screen: 'self_care', feature: 'evening_reminder' },
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

// ✅ Test Function
exports.sendTestToAllUsers = functions.https.onRequest(async (req, res) => {
  try {
    const message = {
      notification: {
        title: '🧪 Test Notification - Bump Bond',
        body: 'This is a test notification sent to all Bump Bond users! ✅'
      },
      data: { screen: 'home', feature: 'test', test: 'true' },
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

// ✅ Send Custom Notification
exports.sendCustomNotification = functions.https.onCall(async (data, context) => {
  try {
    const { title, body, screen, feature, userId } = data;

    const message = {
      notification: { title, body },
      data: { screen, feature },
      topic: userId ? `user_${userId}` : 'all_users'
    };

    await admin.messaging().send(message);
    console.log(`✅ Custom notification sent: ${title}`);
    return { success: true, message: 'Notification sent' };
  } catch (error) {
    console.error('❌ Error sending custom notification:', error);
    throw new functions.https.HttpsError('internal', 'Failed to send notification');
  }
});

