// Web implementation: open the Leaflet HTML asset in a new browser tab.
import 'package:flutter/material.dart';
import 'dart:html' as html;

class DataMapWidget extends StatelessWidget {
  DataMapWidget({super.key});

  String get _assetUrl => Uri.base.resolve('assets/map.html').toString();

  void _openMapInNewTab() {
    html.window.open(_assetUrl, '_blank');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map, size: 72, color: Colors.teal),
            const SizedBox(height: 12),
            const Text('Interactive Leaflet map is available'),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _openMapInNewTab,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open Map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'The map will open in a new browser tab. This provides full Leaflet functionality on web.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}