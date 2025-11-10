// // android apk
// // lib/main.dart
// import 'dart:convert';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:video_player/video_player.dart';

// /// =====================
// ///  FIREBASE INIT
// /// =====================
// Future<void> _initFirebase() async {
//   if (kIsWeb) {
//     await Firebase.initializeApp(
//       options: const FirebaseOptions(
//         apiKey: "AIzaSyDKe0kbU6Mh3gDoQpJ5yDYMcePvGm2Jpaw",
//         authDomain: "student-feedback-bc8ee.firebaseapp.com",
//         projectId: "student-feedback-bc8ee",
//         storageBucket: "student-feedback-bc8ee.firebasestorage.app",
//         messagingSenderId: "256284472835",
//         appId: "1:256284472835:web:8638c1718a38e7fc108036",
//       ),
//     );
//   } else {
//     await Firebase.initializeApp();
//   }
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await _initFirebase();
//   runApp(const MyApp());
// }

// /// =====================
// ///  BRAND + CONSTANTS
// /// =====================
// const Color kPrimaryBlue = Color(0xFF003366);
// const Color kAccentGold = Color(0xFFF4B221);
// const Color kHeaderBg = Color(0xFFF7F6F5);

// /// Apps Script Web App URL (/exec) — apna **latest** deployment URL yahan paste karein
// const String WEB_APP_URL =
//     'https://script.google.com/macros/s/AKfycbyNXqlkROXWdfqTp6q1OiySahH-SYpU1B9H1VmIqk_X14it3MJO1UViF3TWAfX-vt-c/exec';

// /// Course list
// const List<String> kCourses = [
//   'DGCA Ground Classes',
//   'ATPL Theory Training',
//   'CPL Flight Training',
//   'Type Rating',
//   'License Conversion',
//   'Mentorship Programme',
// ];

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'SkyPro Intake',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: kPrimaryBlue,
//           primary: kPrimaryBlue,
//           secondary: kAccentGold,
//         ),
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//         chipTheme: ChipThemeData.fromDefaults(
//           secondaryColor: kPrimaryBlue,
//           brightness: Brightness.light,
//           labelStyle: const TextStyle(fontWeight: FontWeight.w500),
//         ).copyWith(
//           shape: const StadiumBorder(),
//           labelStyle: const TextStyle(fontWeight: FontWeight.w500),
//           side: const BorderSide(color: Color(0x22003366)),
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         ),
//         inputDecorationTheme: const InputDecorationTheme(
//           border: OutlineInputBorder(),
//           isDense: true,
//           contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: kAccentGold,
//             foregroundColor: Colors.black,
//             shape: const StadiumBorder(),
//             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//             minimumSize: const Size.fromHeight(48),
//           ),
//         ),
//         outlinedButtonTheme: OutlinedButtonThemeData(
//           style: OutlinedButton.styleFrom(
//             side: const BorderSide(color: kPrimaryBlue),
//             foregroundColor: kPrimaryBlue,
//             shape: const StadiumBorder(),
//             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//             minimumSize: const Size(48, 48),
//           ),
//         ),
//       ),
//       home: const SplashVideoPage(),
//     );
//   }
// }

// /// ------------------------------
// /// Splash video
// /// ------------------------------
// class SplashVideoPage extends StatefulWidget {
//   const SplashVideoPage({super.key});
//   @override
//   State<SplashVideoPage> createState() => _SplashVideoPageState();
// }

// class _SplashVideoPageState extends State<SplashVideoPage> {
//   VideoPlayerController? _controller;
//   bool _readyToGo = false;

//   @override
//   void initState() {
//     super.initState();

//     // If video fails or is slow, we’ll still auto-advance quickly.
//     Future.delayed(const Duration(seconds: 3), () {
//       if (mounted && !_readyToGo) _goNext();
//     });

//     // On web or if asset missing, skip gracefully.
//     try {
//       _controller = VideoPlayerController.asset('assets/intro.mp4')
//         ..setLooping(false)
//         ..setVolume(0.0)
//         ..initialize().then((_) async {
//           if (!mounted) return;
//           setState(() {});
//           try {
//             await _controller?.play();
//           } catch (_) {}
//           _controller?.addListener(() {
//             final v = _controller?.value;
//             if (v != null &&
//                 v.isInitialized &&
//                 !v.isPlaying &&
//                 v.position >= v.duration &&
//                 mounted) {
//               _goNext();
//             }
//           });
//         });
//     } catch (_) {
//       // Ignore and let the 3s fallback take user forward.
//     }
//   }

//   void _goNext() {
//     if (_readyToGo) return;
//     _readyToGo = true;
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(builder: (_) => const IntakeFormPage()),
//     );
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isInit = _controller?.value.isInitialized == true;
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: isInit
//             ? FittedBox(
//                 fit: BoxFit.cover,
//                 child: SizedBox(
//                   width: _controller!.value.size.width,
//                   height: _controller!.value.size.height,
//                   child: VideoPlayer(_controller!),
//                 ),
//               )
//             : const CircularProgressIndicator(color: Colors.white),
//       ),
//     );
//   }
// }

// /// ------------------------------
// /// Intake Form Page
// /// ------------------------------
// class IntakeFormPage extends StatefulWidget {
//   const IntakeFormPage({super.key});
//   @override
//   State<IntakeFormPage> createState() => _IntakeFormPageState();
// }

// class _IntakeFormPageState extends State<IntakeFormPage> {
//   final _formKey = GlobalKey<FormState>();

//   String? _studentId;
//   String? _instructorId;
//   String _course = kCourses.first;

//   // Hidden prefill (from students/{id})
//   String? _studentEmail, _parentEmail, _phone;

//   // Questions
//   String? qExperience;
//   String? qHours;
//   String? qMedical;
//   String? qSchedule;
//   String? qFinance;

//   final Map<String, bool> qExams = {
//     'Meteorology': false,
//     'Navigation': false,
//     'Regulations/ATC (RT)': false,
//     'Technical General': false,
//   };
//   final Map<String, bool> qTarget = {
//     'CPL': false,
//     'ATPL': false,
//     'Type Rating': false,
//     'License Conversion': false,
//   };
//   final Map<String, bool> qLocation = {
//     'Delhi': false,
//     'Mumbai': false,
//     'Bengaluru': false,
//     'Other': false,
//   };

//   final _reviewCtrl = TextEditingController();
//   bool _submitting = false;

//   late final Future<List<NamedRef>> _instructorsFuture;
//   late final Future<List<NamedRef>> _studentsFuture;

//   @override
//   void initState() {
//     super.initState();
//     _instructorsFuture = _fetchNamed('instructors');
//     _studentsFuture = _fetchNamed('students');
//   }

//   @override
//   void dispose() {
//     _reviewCtrl.dispose();
//     super.dispose();
//   }

//   InputDecoration _dec(String label, IconData icon) =>
//       InputDecoration(labelText: label, prefixIcon: Icon(icon));

//   Future<Map<String, dynamic>?> _getDoc(String col, String id) async {
//     final snap = await FirebaseFirestore.instance.collection(col).doc(id).get();
//     return snap.data();
//   }

//   String _nameKeyFor(String col) {
//     switch (col) {
//       case 'students':
//         return 'student_name';
//       case 'instructors':
//         return 'instructor_name';
//       default:
//         return 'name';
//     }
//   }

//   Future<String> _getName(String col, String id) async {
//     final d = await _getDoc(col, id);
//     if (d == null) return id;
//     final key = _nameKeyFor(col);
//     final raw = d[key] ?? d['name'];
//     final n = (raw == null ? '' : raw.toString().trim());
//     return n.isNotEmpty ? n : id;
//   }

//   Future<void> _prefillFromStudent(String id) async {
//     final d = await _getDoc('students', id);
//     if (d == null) return;
//     _studentEmail =
//         (d['student_email'] ?? d['email'] ?? d['studentEmail'])?.toString();
//     _parentEmail = (d['parent_e_mail'] ?? d['parent_email'] ?? d['parentEmail'])
//         ?.toString();
//     _phone = (d['student_mobile_no_'] ??
//             d['mobile_no_'] ??
//             d['phone'] ??
//             d['student_mobile'] ??
//             d['mobile'])
//         ?.toString();
//   }

//   /// ---------- Apps Script: form-urlencoded POST (no CORS preflight) ----------
//   Future<bool> _postToAppsScript(Map<String, String> payload) async {
//     try {
//       final uri = Uri.parse(WEB_APP_URL);
//       final body = Uri(queryParameters: payload).query; // key=value&...
//       final res = await http
//           .post(
//             uri,
//             headers: {
//               'Content-Type':
//                   'application/x-www-form-urlencoded; charset=UTF-8',
//             },
//             body: body,
//           )
//           .timeout(const Duration(seconds: 12));
//       if (res.statusCode == 200) {
//         try {
//           final data = jsonDecode(res.body);
//           return data is Map && data['ok'] == true;
//         } catch (_) {
//           // If Apps Script returns plain text "OK" etc., still treat as success.
//           return true;
//         }
//       }
//     } catch (_) {}
//     return false;
//   }

//   Future<void> _submit() async {
//     final form = _formKey.currentState;
//     if (form == null || !form.validate()) return;

//     if (_studentId == null || _instructorId == null) {
//       _dialog(
//           'Select required fields', 'Please choose Student and Instructor.');
//       return;
//     }
//     if (qExperience == null ||
//         qHours == null ||
//         qMedical == null ||
//         qSchedule == null ||
//         qFinance == null) {
//       _dialog('Incomplete', 'Please answer all radio questions.');
//       return;
//     }

//     setState(() => _submitting = true);
//     try {
//       final db = FirebaseFirestore.instance;
//       final now = DateTime.now();

//       final studentName = await _getName('students', _studentId!);
//       final instructorName = await _getName('instructors', _instructorId!);

//       final answers = <String, dynamic>{
//         'q_experience': qExperience,
//         'q_hours': qHours,
//         'q_medical': qMedical,
//         'q_exams':
//             qExams.entries.where((e) => e.value).map((e) => e.key).toList(),
//         'q_target':
//             qTarget.entries.where((e) => e.value).map((e) => e.key).toList(),
//         'q_schedule': qSchedule,
//         'q_location':
//             qLocation.entries.where((e) => e.value).map((e) => e.key).toList(),
//         'q_finance_needed': qFinance,
//         'review': _reviewCtrl.text.trim(),
//       };

//       final data = {
//         'studentId': _studentId!,
//         'studentName': studentName,
//         'instructorId': _instructorId!,
//         'instructorName': instructorName,
//         'course': _course,
//         'studentEmail': _studentEmail ?? '',
//         'parentEmail': _parentEmail ?? '',
//         'phone': _phone ?? '',
//         ...answers,
//         'createdAtLocal': now.toIso8601String(),
//         'timestamp': FieldValue.serverTimestamp(),
//         '_source': 'app',
//       };

//       // 1) Firestore
//       final fbRef = await db.collection('feedback').add(data);
//       await db
//           .collection('instructors')
//           .doc(_instructorId!)
//           .collection('feedback')
//           .doc(fbRef.id)
//           .set({...data, 'feedbackRef': fbRef});

//       // 2) Sheet append via Apps Script (fire-and-forget)
//       unawaited(_postToAppsScript({
//         'mode': 'feedback_submit',
//         'sheetName': 'feedback',
//         'studentId': _studentId!,
//         'studentName': studentName,
//         'instructorId': _instructorId!,
//         'instructorName': instructorName,
//         'course': _course,
//         'q_experience': qExperience!,
//         'q_hours': qHours!,
//         'q_medical': qMedical!,
//         'q_exams': (answers['q_exams'] as List).join(', '),
//         'q_target': (answers['q_target'] as List).join(', '),
//         'q_schedule': qSchedule!,
//         'q_location': (answers['q_location'] as List).join(', '),
//         'q_finance_needed': qFinance!,
//         'review': answers['review'],
//         'studentEmail': _studentEmail ?? '',
//         'parentEmail': _parentEmail ?? '',
//         'phone': _phone ?? '',
//         'createdAtLocal': data['createdAtLocal'] as String,
//         'sendEmails': 'false',
//         'emailTargets': 'student,parent,instructor,org',
//       }));

//       if (!mounted) return;
//       _dialog('Done 🎉', 'Feedback submitted successfully.');
//       form.reset();
//       setState(() {
//         _studentId = null;
//         _instructorId = null;
//         _course = kCourses.first;
//         qExperience = qHours = qMedical = qSchedule = qFinance = null;
//         qExams.updateAll((key, value) => false);
//         qTarget.updateAll((key, value) => false);
//         qLocation.updateAll((key, value) => false);
//         _reviewCtrl.clear();
//       });
//     } catch (e) {
//       if (!mounted) return;
//       _dialog('Error', e.toString());
//     } finally {
//       if (mounted) setState(() => _submitting = false);
//     }
//   }

//   void _dialog(String t, String m) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(t),
//         content: Text(m),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isCompact = size.width < 480; // phones
//     final isTablet = size.width >= 768; // tablets and up
//     final horizontalPad = isCompact ? 14.0 : 18.0;
//     final maxFormWidth = isTablet ? 860.0 : 720.0;

//     final double logoH = isTablet ? 56 : (isCompact ? 40 : 48);

//     return GestureDetector(
//       // Tap anywhere to dismiss keyboard
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         resizeToAvoidBottomInset: true,
//         appBar: PreferredSize(
//           preferredSize: const Size.fromHeight(70),
//           child: Container(
//             color: kHeaderBg,
//             padding:
//                 EdgeInsets.symmetric(horizontal: horizontalPad, vertical: 10),
//             child: SafeArea(
//               bottom: false,
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Image.asset('assets/logo.webp',
//                     height: logoH, fit: BoxFit.contain),
//               ),
//             ),
//           ),
//         ),
//         body: SafeArea(
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               return SingleChildScrollView(
//                 keyboardDismissBehavior:
//                     ScrollViewKeyboardDismissBehavior.onDrag,
//                 padding: EdgeInsets.fromLTRB(
//                   horizontalPad,
//                   16,
//                   horizontalPad,
//                   MediaQuery.of(context).viewInsets.bottom + 16,
//                 ),
//                 child: Center(
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(maxWidth: maxFormWidth),
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const SizedBox(height: 6),
//                           Text(
//                             'Student Intake (Aviation)',
//                             style: TextStyle(
//                               fontSize: isCompact ? 20 : 22,
//                               fontWeight: FontWeight.w700,
//                               color: kPrimaryBlue,
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           Card(
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(14)),
//                             elevation: 6,
//                             child: Padding(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: isCompact ? 14 : 20,
//                                 vertical: isCompact ? 16 : 22,
//                               ),
//                               child: Column(
//                                 children: [
//                                   _FirestoreDropdown(
//                                     label: 'Instructor name',
//                                     icon: Icons.verified_user,
//                                     validatorText: 'Select instructor',
//                                     value: _instructorId,
//                                     onChanged: (v) =>
//                                         setState(() => _instructorId = v),
//                                     future: _instructorsFuture,
//                                   ),
//                                   const SizedBox(height: 12),
//                                   _FirestoreDropdown(
//                                     label: 'Student name',
//                                     icon: Icons.person,
//                                     validatorText: 'Select student',
//                                     value: _studentId,
//                                     onChanged: (v) async {
//                                       setState(() => _studentId = v);
//                                       if (v != null)
//                                         await _prefillFromStudent(v);
//                                     },
//                                     future: _studentsFuture,
//                                   ),
//                                   const SizedBox(height: 18),
//                                   _LabeledRadioChips(
//                                     label: 'Experience level',
//                                     value: qExperience,
//                                     options: const [
//                                       'No experience',
//                                       'Student Pilot',
//                                       'PPL',
//                                       'CPL'
//                                     ],
//                                     onChanged: (v) =>
//                                         setState(() => qExperience = v),
//                                   ),
//                                   _LabeledRadioChips(
//                                     label: 'Total flight hours',
//                                     value: qHours,
//                                     options: const [
//                                       '0',
//                                       '1–49',
//                                       '50–199',
//                                       '200+'
//                                     ],
//                                     onChanged: (v) =>
//                                         setState(() => qHours = v),
//                                   ),
//                                   _LabeledRadioChips(
//                                     label: 'DGCA medical status',
//                                     value: qMedical,
//                                     options: const [
//                                       'Not started',
//                                       'Class 2 done',
//                                       'Class 1 done'
//                                     ],
//                                     onChanged: (v) =>
//                                         setState(() => qMedical = v),
//                                   ),
//                                   _LabeledCheckChips(
//                                     label: 'Exams cleared',
//                                     map: qExams,
//                                     onChanged: () => setState(() {}),
//                                   ),
//                                   _LabeledCheckChips(
//                                     label: 'Target',
//                                     map: qTarget,
//                                     onChanged: () => setState(() {}),
//                                   ),
//                                   _LabeledRadioChips(
//                                     label: 'Preferred training schedule',
//                                     value: qSchedule,
//                                     options: const [
//                                       'Weekdays',
//                                       'Weekends',
//                                       'Both'
//                                     ],
//                                     onChanged: (v) =>
//                                         setState(() => qSchedule = v),
//                                   ),
//                                   _LabeledCheckChips(
//                                     label: 'Training location preference',
//                                     map: qLocation,
//                                     onChanged: () => setState(() {}),
//                                   ),
//                                   _LabeledRadioChips(
//                                     label: 'Finance/loan required?',
//                                     value: qFinance,
//                                     options: const ['No', 'Yes'],
//                                     onChanged: (v) =>
//                                         setState(() => qFinance = v),
//                                   ),
//                                   const SizedBox(height: 12),
//                                   TextFormField(
//                                     controller: _reviewCtrl,
//                                     minLines: 2,
//                                     maxLines: 6,
//                                     textInputAction: TextInputAction.newline,
//                                     decoration: _dec(
//                                         'Review / Notes (optional)',
//                                         Icons.rate_review),
//                                   ),
//                                   const SizedBox(height: 18),
//                                   Row(
//                                     children: [
//                                       Expanded(
//                                         child: ElevatedButton(
//                                           onPressed:
//                                               _submitting ? null : _submit,
//                                           child: _submitting
//                                               ? const SizedBox(
//                                                   width: 20,
//                                                   height: 20,
//                                                   child:
//                                                       CircularProgressIndicator(
//                                                     strokeWidth: 2,
//                                                     color: kPrimaryBlue,
//                                                   ),
//                                                 )
//                                               : const Text('Submit'),
//                                         ),
//                                       ),
//                                       const SizedBox(width: 12),
//                                       OutlinedButton(
//                                         onPressed: _submitting
//                                             ? null
//                                             : () =>
//                                                 _formKey.currentState?.reset(),
//                                         child: const Text('Reset'),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// ---------- Helpers: once-load Firestore ----------
// class NamedRef {
//   final String id;
//   final String name;
//   NamedRef(this.id, this.name);
// }

// String _displayKeyFor(String collection) {
//   switch (collection) {
//     case 'students':
//       return 'student_name';
//     case 'instructors':
//       return 'instructor_name';
//     default:
//       return 'name';
//   }
// }

// Future<List<NamedRef>> _fetchNamed(String collection) async {
//   final snap = await FirebaseFirestore.instance.collection(collection).get();
//   final key = _displayKeyFor(collection);
//   final list = snap.docs.map((d) {
//     final data = d.data();
//     final raw =
//         (data[key] ?? data['name'] ?? data['title'] ?? '').toString().trim();
//     final display = raw.isNotEmpty ? raw : d.id;
//     return NamedRef(d.id, display);
//   }).toList();
//   list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
//   return list;
// }

// /// ---------- UI: Left label / Right chips ----------
// class _LabeledRadioChips extends StatelessWidget {
//   final String label;
//   final String? value;
//   final List<String> options;
//   final ValueChanged<String?> onChanged;
//   const _LabeledRadioChips({
//     required this.label,
//     required this.value,
//     required this.options,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final selectedBg = kPrimaryBlue.withOpacity(0.12);
//     final isCompact = MediaQuery.of(context).size.width < 480;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.only(top: isCompact ? 8 : 10),
//               child: Text(
//                 label,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w700,
//                   color: kPrimaryBlue,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             flex: 3,
//             child: Wrap(
//               spacing: 10,
//               runSpacing: 8,
//               children: options
//                   .map(
//                     (o) => ChoiceChip(
//                       label: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 2),
//                         child: Text(o, textAlign: TextAlign.center),
//                       ),
//                       selected: value == o,
//                       selectedColor: selectedBg,
//                       showCheckmark: value == o,
//                       onSelected: (_) => onChanged(o),
//                       side: BorderSide(
//                         color:
//                             value == o ? kPrimaryBlue : const Color(0x22000000),
//                       ),
//                       materialTapTargetSize: MaterialTapTargetSize.padded,
//                     ),
//                   )
//                   .toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _LabeledCheckChips extends StatelessWidget {
//   final String label;
//   final Map<String, bool> map;
//   final VoidCallback onChanged;
//   const _LabeledCheckChips({
//     required this.label,
//     required this.map,
//     required this.onChanged,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final selectedBg = kPrimaryBlue.withOpacity(0.12);
//     final isCompact = MediaQuery.of(context).size.width < 480;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.only(top: isCompact ? 8 : 10),
//               child: Text(
//                 label,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w700,
//                   color: kPrimaryBlue,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             flex: 3,
//             child: Wrap(
//               spacing: 10,
//               runSpacing: 8,
//               children: map.keys
//                   .map(
//                     (k) => FilterChip(
//                       label: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 2),
//                         child: Text(k, textAlign: TextAlign.center),
//                       ),
//                       selected: map[k] == true,
//                       selectedColor: selectedBg,
//                       onSelected: (s) {
//                         map[k] = s;
//                         onChanged();
//                       },
//                       side: BorderSide(
//                         color: map[k] == true
//                             ? kPrimaryBlue
//                             : const Color(0x22000000),
//                       ),
//                       materialTapTargetSize: MaterialTapTargetSize.padded,
//                     ),
//                   )
//                   .toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Firestore dropdown by name (controlled; auto-init parent once)
// class _FirestoreDropdown extends StatelessWidget {
//   final String label, validatorText;
//   final IconData icon;
//   final String? value;
//   final ValueChanged<String?> onChanged;
//   final Future<List<NamedRef>> future;

//   const _FirestoreDropdown({
//     super.key,
//     required this.label,
//     required this.icon,
//     required this.onChanged,
//     required this.value,
//     required this.validatorText,
//     required this.future,
//   });

//   @override
//   Widget build(BuildContext context) {
//     InputDecoration _dec(String label, IconData icon) =>
//         InputDecoration(labelText: label, prefixIcon: Icon(icon));

//     return FutureBuilder<List<NamedRef>>(
//       future: future,
//       builder: (context, snap) {
//         if (snap.connectionState == ConnectionState.waiting) {
//           return const Padding(
//             padding: EdgeInsets.symmetric(vertical: 8),
//             child: LinearProgressIndicator(),
//           );
//         }
//         if (snap.hasError) {
//           return Text(
//             'Error loading $label: ${snap.error}',
//             style: const TextStyle(color: Colors.red),
//           );
//         }
//         final list = snap.data ?? const <NamedRef>[];
//         if (list.isEmpty) {
//           return Text('No $label found in Firestore.');
//         }

//         final items = list
//             .map((e) => DropdownMenuItem<String>(
//                   value: e.id,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 6),
//                     child: Text(
//                       e.name,
//                       overflow: TextOverflow.ellipsis,
//                       maxLines: 1,
//                     ),
//                   ),
//                 ))
//             .toList();

//         // If parent value is null, push first id into parent once (auto-select)
//         if (value == null) {
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             onChanged(list.first.id);
//           });
//         }

//         return DropdownButtonFormField<String>(
//           value: value,
//           isExpanded: true,
//           menuMaxHeight: 320,
//           decoration: _dec(label, icon),
//           items: items,
//           onChanged: onChanged,
//           validator: (v) => v == null ? validatorText : null,
//         );
//       },
//     );
//   }
// }

// // Small helper to silence "unawaited" warning
// void unawaited(Future<dynamic> f) {}

// import 'package:flutter/material.dart';
// import 'app.dart';
// import 'services/firebase_bootstrap.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await initFirebaseForAllPlatforms();
//   runApp(const SkyProApp());
// }

// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'services/firebase_init.dart';
// import 'pages/intake_form_page.dart';

// const Color kPrimaryBlue = Color(0xFF003366);
// const Color kAccentGold = Color(0xFFF4B221);
// const Color kHeaderBg = Color(0xFFF7F6F5);

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await initFirebase(kIsWeb: kIsWeb);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'SkyPro Intake',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: kPrimaryBlue,
//           primary: kPrimaryBlue,
//           secondary: kAccentGold,
//         ),
//         inputDecorationTheme: const InputDecorationTheme(
//           border: OutlineInputBorder(),
//           isDense: true,
//           contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: kAccentGold,
//             foregroundColor: Colors.black,
//             shape: const StadiumBorder(),
//             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//             minimumSize: const Size.fromHeight(48),
//           ),
//         ),
//         outlinedButtonTheme: OutlinedButtonThemeData(
//           style: OutlinedButton.styleFrom(
//             side: const BorderSide(color: kPrimaryBlue),
//             foregroundColor: kPrimaryBlue,
//             shape: const StadiumBorder(),
//             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//             minimumSize: const Size(48, 48),
//           ),
//         ),
//       ),
//       home: const IntakeFormPage(),
//     );
//   }
// }

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'services/firebase_init.dart';
import 'pages/intake_form_page.dart';
import 'pages/splash_video_page.dart'; // ⬅️ add this

const Color kPrimaryBlue = Color(0xFF003366);
const Color kAccentGold = Color(0xFFF4B221);
const Color kHeaderBg = Color(0xFFF7F6F5);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebase(kIsWeb: kIsWeb);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyPro Intake',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryBlue,
          primary: kPrimaryBlue,
          secondary: kAccentGold,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kAccentGold,
            foregroundColor: Colors.black,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            minimumSize: const Size.fromHeight(48),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: kPrimaryBlue),
            foregroundColor: kPrimaryBlue,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            minimumSize: const Size(48, 48),
          ),
        ),
      ),

      // ⬇️ start with video splash, then go to IntakeFormPage
      home: const SplashVideoPage(
        nextPage: IntakeFormPage(),
        // optional: a tiny minimum display time for smoother feel
        minShowTime: Duration(milliseconds: 600),
      ),
    );
  }
}
