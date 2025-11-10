// class SectionConfig {
//   final String key; // eg. 'kno'
//   final String title; // heading
//   final String body; // description
//   final List<String> items; // checkbox labels

//   const SectionConfig({
//     required this.key,
//     required this.title,
//     required this.body,
//     required this.items,
//   });
// }

class SectionConfig {
  final String
      key; // e.g. 'kno', 'pro', 'com', 'fpa', 'fpm', 'ltw', 'pcd', 'saw', 'wlm'
  final String title; // heading
  final String body; // description
  final List<String> items; // checkbox labels

  const SectionConfig({
    required this.key,
    required this.title,
    required this.body,
    required this.items,
  });
}
