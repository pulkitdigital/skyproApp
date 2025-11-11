import 'package:firebase_core/firebase_core.dart';

/// Initialize Firebase for both Web and Mobile
Future<void> initFirebase({required bool kIsWeb}) async {
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDKe0kbU6Mh3gDoQpJ5yDYMcePvGm2Jpaw",
        authDomain: "student-feedback-bc8ee.firebaseapp.com",
        projectId: "student-feedback-bc8ee",
        storageBucket: "student-feedback-bc8ee.firebasestorage.app",
        messagingSenderId: "256284472835",
        appId: "1:256284472835:web:8638c1718a38e7fc108036",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
}
