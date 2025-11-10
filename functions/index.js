// Gen-1 Firebase Functions (Spark-friendly)
const functions = require("firebase-functions"); // v1 API
const admin = require("firebase-admin");
const sgMail = require("@sendgrid/mail");

admin.initializeApp();

// ---- Config via CLI ----
// firebase functions:config:set sendgrid.key="KEY" email.sender="Name <noreply@domain.com>" email.org="ops@domain.com"
const SENDGRID_KEY = functions.config().sendgrid.key;
const SENDER = functions.config().email.sender;
const ORG_EMAIL = functions.config().email.org;

sgMail.setApiKey(SENDGRID_KEY);

// Small helpers
const norm = (s) => (s || "").toString().trim();
const pick = (obj, keys) => {
  if (!obj) return "";
  for (const k of keys) {
    const v = norm(obj[k]);
    if (v) return v;
  }
  return "";
};

/**
 * Trigger: onCreate of feedback/{docId}
 * - Enrich missing emails (student/parent/instructor) from students/{id} & instructors/{id}
 * - De-duplicate recipients
 * - Idempotent via _mailEventLocks/{eventId}
 */
exports.sendIntakeEmails = functions.firestore
  .document("feedback/{docId}")
  .onCreate(async (snap, context) => {
    const db = admin.firestore();
    const ref = snap.ref;
    const data = snap.data() || {};
    const eventId = context.eventId;

    // -------- Idempotency guard (at-least-once semantics safe) --------
    const lockRef = db.collection("_mailEventLocks").doc(eventId);
    const lock = await lockRef.get();
    if (lock.exists) {
      console.log("Duplicate event, skipping:", eventId);
      return null;
    }
    await lockRef.set({ at: admin.firestore.FieldValue.serverTimestamp(), doc: ref.path });

    if (data.emailed === true) {
      console.log("Already emailed; skipping.");
      return null;
    }

    // -------- Read base fields --------
    const studentId = pick(data, ["studentId", "student_id"]);
    const instructorId = pick(data, ["instructorId", "instructor_id"]);

    let studentEmail = pick(data, ["studentEmail", "student_email", "email"]);
    let parentEmail = pick(data, ["parentEmail", "parent_e_mail", "parent_email"]);
    let instructorEmail = pick(data, ["instructorEmail", "instructor_email"]);

    const studentName = norm(data.studentName) || "Student";
    const instructorName = norm(data.instructorName) || "Instructor";
    const course = norm(data.course) || "Course";
    const review = norm(data.review);

    // -------- Enrich from students/{id} if needed --------
    try {
      if ((!studentEmail || !parentEmail) && studentId) {
        const sSnap = await db.collection("students").doc(studentId).get();
        if (sSnap.exists) {
          const s = sSnap.data() || {};
          studentEmail ||= pick(s, ["student_email", "studentEmail", "email"]);
          parentEmail  ||= pick(s, ["parent_e_mail", "parent_email", "parentEmail"]);
        }
      }
    } catch (e) {
      console.error("Student enrichment failed:", e);
    }

    // -------- Enrich from instructors/{id} if needed --------
    try {
      if (!instructorEmail && instructorId) {
        const iSnap = await db.collection("instructors").doc(instructorId).get();
        if (iSnap.exists) {
          const ins = iSnap.data() || {};
          instructorEmail =
            pick(ins, ["instructor_email", "instructorEmail", "email", "instructor_e_mail"]);
        }
      }
    } catch (e) {
      console.error("Instructor enrichment failed:", e);
    }

    // -------- Build messages (de-dup recipients) --------
    const messages = [];
    const seen = new Set();
    const pushIf = (msg) => {
      const to = norm(msg.to).toLowerCase();
      if (!to || seen.has(to)) return;
      seen.add(to);
      messages.push(msg);
    };

    // Student
    if (studentEmail) {
      pushIf({
        to: studentEmail,
        from: SENDER,
        subject: `Thank you, ${studentName}! Your intake for ${course} is received`,
        text:
          `Dear ${studentName},\n\n` +
          `We’ve received your intake for ${course}. Your instructor ${instructorName} will reach out soon.\n\n— SkyPro`,
      });
    }

    // Parent
    if (parentEmail) {
      pushIf({
        to: parentEmail,
        from: SENDER,
        subject: `Intake submitted for ${studentName} — ${course}`,
        text:
          `Dear Parent,\n\n` +
          `${studentName} has successfully completed intake for ${course}.\n\n— SkyPro`,
      });
    }

    // Instructor
    if (instructorEmail) {
      pushIf({
        to: instructorEmail,
        from: SENDER,
        subject: `New intake assigned: ${studentName} (${course})`,
        text:
          `Hello ${instructorName},\n\n` +
          `A new student ${studentName} has joined ${course}.` +
          (review ? `\nReview: ${review}` : "") +
          `\n\n— SkyPro`,
      });
    }

    // Org summary (always try)
    if (ORG_EMAIL) {
      pushIf({
        to: ORG_EMAIL,
        from: SENDER,
        subject: `New Intake — ${studentName} (${course})`,
        text:
          `Student: ${studentName}\n` +
          `Instructor: ${instructorName}\n` +
          `Course: ${course}\n` +
          (review ? `Review: ${review}\n` : ""),
      });
    }

    if (!messages.length) {
      console.log("No recipients found; skipping send.");
      await ref.update({ emailRecipients: [], emailed: false });
      return null;
    }

    // -------- Send & persist summary --------
    try {
      const results = await Promise.allSettled(messages.map((m) => sgMail.send(m)));
      const summary = results.map((r, i) => ({
        i,
        to: messages[i].to,
        status: r.status,
        reason: r.reason ? String(r.reason) : null,
      }));
      console.log("Recipients:", Array.from(seen));
      console.log("Send results:", JSON.stringify(summary));

      await ref.update({
        emailed: true,
        emailedAt: admin.firestore.FieldValue.serverTimestamp(),
        emailRecipients: Array.from(seen),
        emailSummary: summary,
      });
    } catch (err) {
      console.error("SendGrid error:", err);
      await ref.update({ emailError: String(err) });
    }

    return null;
  });
