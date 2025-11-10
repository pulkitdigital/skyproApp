import 'package:flutter/material.dart';
import '../main.dart'; // for colors

class SectionCheckboxList extends StatelessWidget {
  final String title;
  final String body;
  final Map<String, bool> map;
  final VoidCallback onChanged;

  const SectionCheckboxList({
    super.key,
    required this.title,
    required this.body,
    required this.map,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: kPrimaryBlue,
          fontWeight: FontWeight.w700,
        );
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.black87,
        );

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
          const SizedBox(height: 4),
          Text(body, style: bodyStyle),
          const SizedBox(height: 8),

          // Each checkbox tile without ripple/overlay
          ...map.keys.map((label) {
            final selected = map[label] == true;
            return Theme(
              // Remove ink splash, highlight & hover overlays
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
              ),
              child: CheckboxListTile(
                enableFeedback: false, // no haptic/sonic feedback
                contentPadding: EdgeInsets.zero,
                dense: false,
                controlAffinity: ListTileControlAffinity.leading,
                value: selected,
                onChanged: (v) {
                  map[label] = v ?? false;
                  onChanged();
                },
                title: Text(label),
              ),
            );
          }).toList(),

          const SizedBox(height: 6),
          const Divider(height: 20),
        ],
      ),
    );
  }
}
