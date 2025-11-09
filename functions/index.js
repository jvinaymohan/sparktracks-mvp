const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

// Configure your email transport (using Gmail as example)
// For production, use SendGrid, AWS SES, or similar service
const transporter = nodemailer.createTransporter({
  service: 'gmail',
  auth: {
    user: functions.config().email.user,
    pass: functions.config().email.pass,
  },
});

/**
 * Cloud Function to send class reminders
 * Runs every 5 minutes to check for pending reminders
 */
exports.sendClassReminders = functions.pubsub
  .schedule('every 5 minutes')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    
    try {
      // Get all pending reminders that should be sent now
      const reminders = await admin.firestore()
        .collection('reminders')
        .where('status', '==', 'pending')
        .where('reminderTime', '<=', now)
        .get();

      console.log(`Found ${reminders.size} reminders to send`);

      const promises = [];
      
      for (const reminderDoc of reminders.docs) {
        const reminder = reminderDoc.data();
        
        // Get class details
        const classDoc = await admin.firestore()
          .collection('classes')
          .doc(reminder.classId)
          .get();
        
        if (!classDoc.exists) {
          // Class deleted, mark reminder as cancelled
          await reminderDoc.ref.update({ status: 'cancelled' });
          continue;
        }
        
        const classData = classDoc.data();
        
        // Get coach details
        const coachDoc = await admin.firestore()
          .collection('users')
          .doc(classData.coachId)
          .get();
        
        const coachName = coachDoc.exists ? coachDoc.data().name : 'Your Coach';
        
        // Send emails to all recipients
        const emailPromises = reminder.recipientEmails.map(email => 
          sendReminderEmail({
            to: email,
            className: classData.title,
            coachName: coachName,
            classTime: classData.startTime.toDate(),
            location: classData.location || 'Online',
            meetingLink: classData.meetingLink,
            type: reminder.type,
          })
        );
        
        promises.push(...emailPromises);
        
        // Mark reminder as sent
        promises.push(
          reminderDoc.ref.update({ 
            status: 'sent',
            sentAt: admin.firestore.FieldValue.serverTimestamp(),
          })
        );
      }
      
      await Promise.all(promises);
      console.log(`Sent ${promises.length} reminder emails`);
      
    } catch (error) {
      console.error('Error sending reminders:', error);
      throw error;
    }
    
    return null;
  });

/**
 * Send a single reminder email
 */
async function sendReminderEmail({
  to,
  className,
  coachName,
  classTime,
  location,
  meetingLink,
  type,
}) {
  const timeUntilClass = type === 'twentyFourHours' ? '24 hours' : '1 hour';
  
  const formattedDate = classTime.toLocaleDateString('en-US', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });
  
  const formattedTime = classTime.toLocaleTimeString('en-US', {
    hour: 'numeric',
    minute: '2-digit',
  });
  
  const mailOptions = {
    from: {
      name: 'Sparktracks',
      address: functions.config().email.user,
    },
    to: to,
    subject: `Reminder: ${className} starts in ${timeUntilClass}`,
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: linear-gradient(135deg, #8B5CF6 0%, #EC4899 100%); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
          .content { background: white; padding: 30px; border: 1px solid #e5e7eb; }
          .class-details { background: #f3f4f6; padding: 20px; border-radius: 8px; margin: 20px 0; }
          .button { display: inline-block; background: #10B981; color: white; padding: 12px 30px; text-decoration: none; border-radius: 6px; margin-top: 20px; }
          .footer { text-align: center; padding: 20px; color: #6b7280; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>⏰ Class Reminder</h1>
            <p style="font-size: 18px; margin: 0;">Starts in ${timeUntilClass}</p>
          </div>
          <div class="content">
            <h2>${className}</h2>
            <p>Hi there! Just a friendly reminder about your upcoming class.</p>
            
            <div class="class-details">
              <p style="margin: 8px 0;"><strong>📅 Date:</strong> ${formattedDate}</p>
              <p style="margin: 8px 0;"><strong>⏰ Time:</strong> ${formattedTime}</p>
              <p style="margin: 8px 0;"><strong>👨‍🏫 Coach:</strong> ${coachName}</p>
              <p style="margin: 8px 0;"><strong>📍 Location:</strong> ${location}</p>
              ${meetingLink ? `<p style="margin: 8px 0;"><strong>🔗 Meeting Link:</strong> <a href="${meetingLink}">${meetingLink}</a></p>` : ''}
            </div>
            
            <p>We look forward to seeing you!</p>
            
            ${meetingLink ? `<a href="${meetingLink}" class="button">Join Class</a>` : ''}
          </div>
          <div class="footer">
            <p>Sparktracks - Your Child's Growth, All in One Place</p>
            <p><a href="https://sparktracks-mvp.web.app">Visit Sparktracks</a></p>
          </div>
        </div>
      </body>
      </html>
    `,
  };
  
  try {
    await transporter.sendMail(mailOptions);
    console.log(`Reminder email sent to ${to} for class ${className}`);
  } catch (error) {
    console.error(`Failed to send reminder to ${to}:`, error);
    throw error;
  }
}

/**
 * Trigger when a new enrollment is created
 * Automatically schedules reminders
 */
exports.onEnrollmentCreated = functions.firestore
  .document('enrollments/{enrollmentId}')
  .onCreate(async (snap, context) => {
    const enrollment = snap.data();
    
    try {
      // Get class details
      const classDoc = await admin.firestore()
        .collection('classes')
        .doc(enrollment.classId)
        .get();
      
      if (!classDoc.exists) return;
      
      const classData = classDoc.data();
      
      // Get parent email
      const parentDoc = await admin.firestore()
        .collection('users')
        .doc(enrollment.parentId)
        .get();
      
      if (!parentDoc.exists) return;
      
      const parentEmail = parentDoc.data().email;
      
      // Schedule reminders
      const reminderService = {
        twentyFourHours: {
          id: admin.firestore().collection('reminders').doc().id,
          classId: enrollment.classId,
          reminderTime: admin.firestore.Timestamp.fromDate(
            new Date(classData.startTime.toDate().getTime() - 24 * 60 * 60 * 1000)
          ),
          classTime: classData.startTime,
          recipientEmails: [parentEmail],
          type: 'twentyFourHours',
          status: 'pending',
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        oneHour: {
          id: admin.firestore().collection('reminders').doc().id,
          classId: enrollment.classId,
          reminderTime: admin.firestore.Timestamp.fromDate(
            new Date(classData.startTime.toDate().getTime() - 60 * 60 * 1000)
          ),
          classTime: classData.startTime,
          recipientEmails: [parentEmail],
          type: 'oneHour',
          status: 'pending',
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        },
      };
      
      const batch = admin.firestore().batch();
      
      batch.set(
        admin.firestore().collection('reminders').doc(reminderService.twentyFourHours.id),
        reminderService.twentyFourHours
      );
      
      batch.set(
        admin.firestore().collection('reminders').doc(reminderService.oneHour.id),
        reminderService.oneHour
      );
      
      await batch.commit();
      
      console.log(`Scheduled reminders for enrollment ${context.params.enrollmentId}`);
      
    } catch (error) {
      console.error('Error scheduling reminders:', error);
    }
    
    return null;
  });

