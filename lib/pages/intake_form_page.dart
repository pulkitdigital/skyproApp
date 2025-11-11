import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../models/named_ref.dart';
import '../models/section_config.dart';
import '../sections/sections.dart';
import '../widgets/section_checkbox_list.dart';
import '../widgets/firestore_dropdown.dart';
import '../services/app_script_service.dart';

class IntakeFormPage extends StatefulWidget {
  const IntakeFormPage({super.key});
  @override
  State<IntakeFormPage> createState() => _IntakeFormPageState();
}

class _IntakeFormPageState extends State<IntakeFormPage> {
  final _formKey = GlobalKey<FormState>();
  String? _studentId;
  String? _instructorId;

  // Prefill from students/{id}
  String? _studentEmail, _parentEmail, _phone;

  // Section state: each section -> Map<label,bool>
  late final Map<String, Map<String, bool>> _stateBySection;

  final _reviewCtrl = TextEditingController();
  bool _submitting = false;

  // fetch ONCE and reuse
  late final Future<List<NamedRef>> _instructorsFuture;
  late final Future<List<NamedRef>> _studentsFuture;

  @override
  void initState() {
    super.initState();

    _stateBySection = {
      for (final s in sections)
        s.key: {for (final item in s.items) item: false},
    };

    _instructorsFuture = _fetchNamed('instructors');
    _studentsFuture = _fetchNamed('students');
  }

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, IconData icon) =>
      InputDecoration(labelText: label, prefixIcon: Icon(icon));

  Future<Map<String, dynamic>?> _getDoc(String col, String id) async {
    final snap = await FirebaseFirestore.instance.collection(col).doc(id).get();
    return snap.data();
  }

  String _nameKeyFor(String col) {
    switch (col) {
      case 'students':
        return 'student_name';
      case 'instructors':
        return 'instructor_name';
      default:
        return 'name';
    }
  }

  Future<String> _getName(String col, String id) async {
    final d = await _getDoc(col, id);
    if (d == null) return id;
    final key = _nameKeyFor(col);
    final raw = d[key] ?? d['name'];
    final n = (raw == null ? '' : raw.toString().trim());
    return n.isNotEmpty ? n : id;
  }

  Future<void> _prefillFromStudent(String id) async {
    final d = await _getDoc('students', id);
    if (d == null) return;
    _studentEmail = (d['student_email'] ?? d['email'] ?? d['studentEmail'])
        ?.toString();
    _parentEmail = (d['parent_e_mail'] ?? d['parent_email'] ?? d['parentEmail'])
        ?.toString();
    _phone =
        (d['student_mobile_no_'] ??
                d['mobile_no_'] ??
                d['phone'] ??
                d['student_mobile'] ??
                d['mobile'])
            ?.toString();
  }

  List<String> _selected(Map<String, bool> m) =>
      m.entries.where((e) => e.value).map((e) => e.key).toList();

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    if (_studentId == null || _instructorId == null) {
      _dialog(
        'Select required fields',
        'Please choose Student and Instructor.',
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final db = FirebaseFirestore.instance;
      final now = DateTime.now();

      final studentName = await _getName('students', _studentId!);
      final instructorName = await _getName('instructors', _instructorId!);

      // Build Firestore payload (arrays)
      final Map<String, dynamic> sectionArrays = {
        for (final s in sections) s.key: _selected(_stateBySection[s.key]!),
      };

      final data = {
        'studentId': _studentId!,
        'studentName': studentName,
        'instructorId': _instructorId!,
        'instructorName': instructorName,
        'studentEmail': _studentEmail ?? '',
        'parentEmail': _parentEmail ?? '',
        'phone': _phone ?? '',
        ...sectionArrays,
        'review': _reviewCtrl.text.trim(),
        'createdAtLocal': now.toIso8601String(),
        'timestamp': FieldValue.serverTimestamp(),
        '_source': 'app',
      };

      // 1) Firestore
      final fbRef = await db.collection('feedback').add(data);
      await db
          .collection('instructors')
          .doc(_instructorId!)
          .collection('feedback')
          .doc(fbRef.id)
          .set({...data, 'feedbackRef': fbRef});

      // 2) Apps Script Sheet — send modern section keys directly (kno, pro, com, fpa, fpm, ltw, pcd, saw, wlm)
      unawaited(
        postToAppsScript({
          'mode': 'feedback_submit',
          'sheetName': 'feedback',
          'studentId': _studentId!,
          'studentName': studentName,
          'instructorId': _instructorId!,
          'instructorName': instructorName,
          for (final e in sectionArrays.entries)
            e.key: (e.value as List).join(', '),
          'review': _reviewCtrl.text.trim(),
          'studentEmail': _studentEmail ?? '',
          'parentEmail': _parentEmail ?? '',
          'phone': _phone ?? '',
          'createdAtLocal': data['createdAtLocal'] as String,
          'sendEmails': 'false',
          'emailTargets': 'student,parent,instructor,org',
        }),
      );

      if (!mounted) return;
      _dialog('Done 🎉', 'Feedback submitted successfully.');
      _resetForm(); // clear after submit
    } catch (e) {
      if (!mounted) return;
      _dialog('Error', e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // Hard reset everything incl. dropdowns & checkboxes
  void _resetForm() {
    setState(() {
      _studentId = null;
      _instructorId = null;

      for (final k in _stateBySection.keys) {
        _stateBySection[k]!.updateAll((key, value) => false);
      }
      _reviewCtrl.clear();
      _formKey.currentState?.reset();
    });
  }

  void _dialog(String t, String m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t),
        content: Text(m),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isCompact = size.width < 480;
    final isTablet = size.width >= 768;
    final horizontalPad = isCompact ? 14.0 : 18.0;
    final maxFormWidth = isTablet ? 860.0 : 720.0;
    final double logoH = isTablet ? 56 : (isCompact ? 40 : 48);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            color: kHeaderBg,
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPad,
              vertical: 10,
            ),
            child: SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/logo.webp',
                  height: logoH,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              horizontalPad,
              16,
              horizontalPad,
              MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxFormWidth),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        'Student Intake (Aviation)',
                        style: TextStyle(
                          fontSize: isCompact ? 20 : 22,
                          fontWeight: FontWeight.w700,
                          color: kPrimaryBlue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 6,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 12 : 18,
                            vertical: isCompact ? 12 : 18,
                          ),
                          child: Column(
                            children: [
                              FirestoreDropdown(
                                label: 'Instructor name',
                                icon: Icons.verified_user,
                                validatorText: 'Select instructor',
                                value: _instructorId,
                                onChanged: (v) =>
                                    setState(() => _instructorId = v),
                                future: _instructorsFuture,
                              ),
                              const SizedBox(height: 10),
                              FirestoreDropdown(
                                label: 'Student name',
                                icon: Icons.person,
                                validatorText: 'Select student',
                                value: _studentId,
                                onChanged: (v) async {
                                  setState(() => _studentId = v);
                                  if (v != null) await _prefillFromStudent(v);
                                },
                                future: _studentsFuture,
                              ),
                              const SizedBox(height: 16),
                              for (final s in sections)
                                SectionCheckboxList(
                                  title: s.title,
                                  body: s.body,
                                  map: _stateBySection[s.key]!,
                                  onChanged: () => setState(() {}),
                                ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _reviewCtrl,
                                minLines: 2,
                                maxLines: 6,
                                textInputAction: TextInputAction.newline,
                                decoration: _dec(
                                  'Review / Notes (optional)',
                                  Icons.rate_review,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: _submitting ? null : _submit,
                                      child: _submitting
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: kPrimaryBlue,
                                              ),
                                            )
                                          : const Text('Submit'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  OutlinedButton(
                                    onPressed: _submitting ? null : _resetForm,
                                    child: const Text('Reset'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---- Firestore helpers ----
Future<List<NamedRef>> _fetchNamed(String collection) async {
  final snap = await FirebaseFirestore.instance.collection(collection).get();
  final key = _displayKeyFor(collection);
  final list = snap.docs.map((d) {
    final data = d.data();
    final raw = (data[key] ?? data['name'] ?? data['title'] ?? '')
        .toString()
        .trim();
    final display = raw.isNotEmpty ? raw : d.id;
    return NamedRef(d.id, display);
  }).toList();
  list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return list;
}

String _displayKeyFor(String collection) {
  switch (collection) {
    case 'students':
      return 'student_name';
    case 'instructors':
      return 'instructor_name';
    default:
      return 'name';
  }
}

// Small helper to silence "unawaited" warning
void unawaited(Future<dynamic> f) {}
