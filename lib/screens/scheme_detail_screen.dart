import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/scheme_model.dart';

class SchemeDetailScreen extends StatelessWidget {
  final GovernmentScheme scheme;

  const SchemeDetailScreen({super.key, required this.scheme});

  Future<void> _launchURL(BuildContext context) async {
    try {
      final url = Uri.parse(scheme.url);
      final canLaunch = await canLaunchUrl(url);

      if (canLaunch) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open ${scheme.title} website')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid URL')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(scheme.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.launch),
            onPressed: () => _launchURL(context),
            tooltip: 'Open Website',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              scheme.imagePath,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[200],
                child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scheme.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(scheme.description),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _launchURL(context),
                    icon: const Icon(Icons.launch),
                    label: const Text('Visit Official Website'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
