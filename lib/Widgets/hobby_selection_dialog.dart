import 'package:flutter/material.dart';

class HobbySelectionDialog extends StatefulWidget {
  const HobbySelectionDialog({super.key});

  @override
  State<HobbySelectionDialog> createState() => _HobbySelectionDialogState();
}

class _HobbySelectionDialogState extends State<HobbySelectionDialog> {
  final Set<String> _selectedHobbies = {};
  final List<Map<String, String>> _defaultHobbies = [
    {'id': 'football', 'name': 'Futbol'},
    {'id': 'cinema', 'name': 'Sinema'},
    {'id': 'economy', 'name': 'Ekonomi'},
    {'id': 'music', 'name': 'Müzik'},
    {'id': 'technology', 'name': 'Teknoloji'},
    {'id': 'travel', 'name': 'Seyahat'},
    {'id': 'cooking', 'name': 'Yemek Yapma'},
    {'id': 'reading', 'name': 'Kitap Okuma'},
    {'id': 'gaming', 'name': 'Oyun'},
    {'id': 'sports', 'name': 'Spor'},
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hobilerinizi Seçin'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _defaultHobbies.length,
          itemBuilder: (context, index) {
            final hobby = _defaultHobbies[index];
            return CheckboxListTile(
              title: Text(hobby['name']!),
              value: _selectedHobbies.contains(hobby['id']),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedHobbies.add(hobby['id']!);
                  } else {
                    _selectedHobbies.remove(hobby['id']);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedHobbies.toList()),
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}
