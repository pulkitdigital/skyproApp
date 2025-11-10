// // import 'package:flutter/material.dart';
// // import '../models/named_ref.dart';

// // class FirestoreDropdown extends StatelessWidget {
// //   final String label, validatorText;
// //   final IconData icon;
// //   final String? value;
// //   final ValueChanged<String?> onChanged;
// //   final Future<List<NamedRef>> future;

// //   const FirestoreDropdown({
// //     super.key,
// //     required this.label,
// //     required this.icon,
// //     required this.onChanged,
// //     required this.value,
// //     required this.validatorText,
// //     required this.future,
// //   });

// //   InputDecoration _dec(String label, IconData icon) => InputDecoration(
// //         labelText: label,
// //         prefixIcon: Icon(icon),
// //         isDense: true,
// //         contentPadding:
// //             const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
// //         // ensure tappable size on phones
// //         prefixIconConstraints:
// //             const BoxConstraints(minWidth: 44, minHeight: 44),
// //       );

// //   @override
// //   Widget build(BuildContext context) {
// //     return FutureBuilder<List<NamedRef>>(
// //       future: future,
// //       builder: (context, snap) {
// //         if (snap.connectionState == ConnectionState.waiting) {
// //           return const Padding(
// //             padding: EdgeInsets.symmetric(vertical: 8),
// //             child: LinearProgressIndicator(),
// //           );
// //         }
// //         if (snap.hasError) {
// //           return Text(
// //             'Error loading $label: ${snap.error}',
// //             style: const TextStyle(color: Colors.red),
// //           );
// //         }
// //         final list = snap.data ?? const <NamedRef>[];
// //         if (list.isEmpty) return Text('No $label found in Firestore.');

// //         final items = list
// //             .map((e) => DropdownMenuItem<String>(
// //                   value: e.id,
// //                   child: Padding(
// //                     padding: const EdgeInsets.symmetric(vertical: 6),
// //                     child: Text(
// //                       e.name,
// //                       overflow: TextOverflow.ellipsis,
// //                       maxLines: 1,
// //                     ),
// //                   ),
// //                 ))
// //             .toList();

// //         // Auto-select first value if null (one-time)
// //         if (value == null && list.isNotEmpty) {
// //           WidgetsBinding.instance.addPostFrameCallback((_) {
// //             onChanged(list.first.id);
// //           });
// //         }

// //         return DropdownButtonFormField<String>(
// //           value: value,
// //           isExpanded: true,
// //           menuMaxHeight: 320,
// //           decoration: _dec(label, icon),
// //           items: items,
// //           onChanged: onChanged,
// //           validator: (v) => v == null ? validatorText : null,
// //         );
// //       },
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import '../models/named_ref.dart';

// class FirestoreDropdown extends StatelessWidget {
//   final String label, validatorText;
//   final IconData icon;
//   final String? value; // selected id (keep null to show placeholder)
//   final ValueChanged<String?> onChanged;
//   final Future<List<NamedRef>> future; // pass a CACHED future from initState

//   const FirestoreDropdown({
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
//           return Text('Error loading $label: ${snap.error}',
//               style: const TextStyle(color: Colors.red));
//         }
//         final all = (snap.data ?? const <NamedRef>[]);
//         if (all.isEmpty) return Text('No $label found in Firestore.');

//         String displayOf(String? id) {
//           final i = all.indexWhere((e) => e.id == id);
//           return i >= 0 ? all[i].name : '';
//         }

//         return FormField<String>(
//           // KEY trick: remount the FormField whenever value changes (e.g., on Reset)
//           key: ValueKey(value ?? 'none'),
//           initialValue: value,
//           validator: (v) => (v == null || v.isEmpty) ? validatorText : null,
//           builder: (state) {
//             final text = displayOf(state.value);
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 InkWell(
//                   onTap: () async {
//                     final picked = await _showSearchPicker(
//                       context: context,
//                       label: label,
//                       icon: icon,
//                       items: all,
//                       selectedId: state.value,
//                     );
//                     if (picked != null) {
//                       state.didChange(picked);
//                       onChanged(picked);
//                     }
//                   },
//                   child: InputDecorator(
//                     decoration: InputDecoration(
//                       labelText: label,
//                       prefixIcon: Icon(icon),
//                       errorText: state.errorText,
//                       suffixIcon: const Icon(Icons.arrow_drop_down),
//                       border: const OutlineInputBorder(),
//                       isDense: true,
//                       contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 12,
//                       ),
//                     ),
//                     child: Text(
//                       text.isEmpty ? 'Tap to select' : text,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color:
//                             text.isEmpty ? Theme.of(context).hintColor : null,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   /// Bottom-sheet picker with search + scroll
//   Future<String?> _showSearchPicker({
//     required BuildContext context,
//     required String label,
//     required IconData icon,
//     required List<NamedRef> items,
//     required String? selectedId,
//   }) async {
//     final controller = TextEditingController();
//     List<NamedRef> filtered = List.of(items);
//     String? current = selectedId;

//     return showModalBottomSheet<String>(
//       context: context,
//       isScrollControlled: true,
//       useSafeArea: true,
//       builder: (ctx) {
//         return StatefulBuilder(builder: (ctx, setModalState) {
//           void applyFilter(String q) {
//             final qq = q.trim().toLowerCase();
//             if (qq.isEmpty) {
//               filtered = List.of(items);
//             } else {
//               filtered = items
//                   .where((e) => e.name.toLowerCase().contains(qq))
//                   .toList();
//             }
//             setModalState(() {});
//           }

//           return Padding(
//             padding: EdgeInsets.only(
//               left: 16,
//               right: 16,
//               top: 12,
//               bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Row(
//                   children: [
//                     Icon(icon, size: 20),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Select $label',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.w700,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const Spacer(),
//                     IconButton(
//                       icon: const Icon(Icons.close),
//                       onPressed: () => Navigator.pop(ctx),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 TextField(
//                   controller: controller,
//                   onChanged: applyFilter,
//                   decoration: const InputDecoration(
//                     prefixIcon: Icon(Icons.search),
//                     hintText: 'Type to search...',
//                     border: OutlineInputBorder(),
//                     isDense: true,
//                     contentPadding:
//                         EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 ConstrainedBox(
//                   constraints: BoxConstraints(
//                     maxHeight: MediaQuery.of(ctx).size.height * 0.6,
//                   ),
//                   child: filtered.isEmpty
//                       ? const Center(
//                           child: Padding(
//                             padding: EdgeInsets.all(24.0),
//                             child: Text('No match found'),
//                           ),
//                         )
//                       : ListView.separated(
//                           itemCount: filtered.length,
//                           separatorBuilder: (_, __) => const Divider(height: 1),
//                           itemBuilder: (_, i) {
//                             final item = filtered[i];
//                             final isSel = item.id == current;
//                             return ListTile(
//                               title: Text(item.name,
//                                   overflow: TextOverflow.ellipsis),
//                               leading: isSel
//                                   ? const Icon(Icons.check_circle)
//                                   : const SizedBox(width: 24),
//                               onTap: () {
//                                 current = item.id;
//                                 Navigator.pop(ctx, item.id);
//                               },
//                             );
//                           },
//                         ),
//                 ),
//               ],
//             ),
//           );
//         });
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../models/named_ref.dart';

class FirestoreDropdown extends StatelessWidget {
  final String label, validatorText;
  final IconData icon;
  final String? value; // selected id (keep null to show placeholder)
  final ValueChanged<String?> onChanged;
  final Future<List<NamedRef>> future; // pass a CACHED future from initState

  const FirestoreDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.onChanged,
    required this.value,
    required this.validatorText,
    required this.future,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NamedRef>>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          );
        }
        if (snap.hasError) {
          return Text('Error loading $label: ${snap.error}',
              style: const TextStyle(color: Colors.red));
        }
        final all = (snap.data ?? const <NamedRef>[]);
        if (all.isEmpty) return Text('No $label found in Firestore.');

        String displayOf(String? id) {
          final i = all.indexWhere((e) => e.id == id);
          return i >= 0 ? all[i].name : '';
        }

        return FormField<String>(
          // Remount the FormField whenever value changes (helps Reset)
          key: ValueKey(value ?? 'none'),
          initialValue: value,
          validator: (v) => (v == null || v.isEmpty) ? validatorText : null,
          builder: (state) {
            final text = displayOf(state.value);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () async {
                    final picked = await _showSearchPicker(
                      context: context,
                      label: label,
                      icon: icon,
                      items: all,
                      selectedId: state.value,
                    );
                    if (picked != null) {
                      state.didChange(picked);
                      onChanged(picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: label,
                      prefixIcon: Icon(icon),
                      errorText: state.errorText,
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                      border: const OutlineInputBorder(),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      text.isEmpty ? 'Tap to select' : text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color:
                            text.isEmpty ? Theme.of(context).hintColor : null,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Bottom-sheet picker with search + scroll
  Future<String?> _showSearchPicker({
    required BuildContext context,
    required String label,
    required IconData icon,
    required List<NamedRef> items,
    required String? selectedId,
  }) async {
    final controller = TextEditingController();
    List<NamedRef> filtered = List.of(items);
    String? current = selectedId;

    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          void applyFilter(String q) {
            final qq = q.trim().toLowerCase();
            if (qq.isEmpty) {
              filtered = List.of(items);
            } else {
              filtered = items
                  .where((e) => e.name.toLowerCase().contains(qq))
                  .toList();
            }
            setModalState(() {});
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Select $label',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  onChanged: applyFilter,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Type to search...',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(ctx).size.height * 0.6,
                  ),
                  child: filtered.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text('No match found'),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final item = filtered[i];
                            final isSel = item.id == current;
                            return ListTile(
                              title: Text(item.name,
                                  overflow: TextOverflow.ellipsis),
                              leading: isSel
                                  ? const Icon(Icons.check_circle)
                                  : const SizedBox(width: 24),
                              onTap: () {
                                current = item.id;
                                Navigator.pop(ctx, item.id);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
