import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language),
      onSelected: (String value) {
        switch (value) {
          case 'en':
            context.setLocale(const Locale('en'));
            break;
          case 'ta':
            context.setLocale(const Locale('ta'));
            break;
          case 'hi':
            context.setLocale(const Locale('hi'));
            break;
          case 'ml':
            context.setLocale(const Locale('ml'));
            break;
          case 'kn':
            context.setLocale(const Locale('kn'));
            break;
          case 'te':
            context.setLocale(const Locale('te'));
            break;
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'en',
          child: Text('English'),
        ),
        const PopupMenuItem<String>(
          value: 'ta',
          child: Text('தமிழ்'),
        ),
        const PopupMenuItem<String>(
          value: 'hi',
          child: Text('हिंदी'),
        ),
        const PopupMenuItem<String>(
          value: 'ml',
          child: Text('മലയാളം'),
        ),
        const PopupMenuItem<String>(
          value: 'kn',
          child: Text('ಕನ್ನಡ'),
        ),
        const PopupMenuItem<String>(
          value: 'te',
          child: Text('తెలుగు'),
        ),
      ],
    );
  }
}