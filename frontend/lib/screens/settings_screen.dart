import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _tripNotifications = true;
  bool _autoSaveDrafts = false;
  bool _shareLocation = true;
  bool _trafficLayer = true;
  bool _showBuildings = true;
  bool _showCompass = true;
  bool _rotateGestures = true;
  bool _tiltGestures = true;
  String _distanceUnit = 'km';
  String _mapType = 'standard';

  void _resetDefaults() {
    setState(() {
      _tripNotifications = true;
      _autoSaveDrafts = false;
      _shareLocation = true;
      _trafficLayer = true;
      _showBuildings = true;
      _showCompass = true;
      _rotateGestures = true;
      _tiltGestures = true;
      _distanceUnit = 'km';
      _mapType = 'standard';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings reset to defaults.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Trip preferences', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SwitchListTile.adaptive(
                    value: _tripNotifications,
                    onChanged: (value) {
                      setState(() => _tripNotifications = value);
                    },
                    title: const Text('Trip notifications'),
                    subtitle: const Text('Updates when routes change or a trip starts.'),
                  ),
                  SwitchListTile.adaptive(
                    value: _autoSaveDrafts,
                    onChanged: (value) {
                      setState(() => _autoSaveDrafts = value);
                    },
                    title: const Text('Auto-save drafts'),
                    subtitle: const Text('Keep unfinished trips ready for later.'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _distanceUnit,
                    items: const [
                      DropdownMenuItem(value: 'km', child: Text('Kilometers')),
                      DropdownMenuItem(value: 'mi', child: Text('Miles')),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() => _distanceUnit = value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Distance unit',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Map', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SwitchListTile.adaptive(
                    value: _shareLocation,
                    onChanged: (value) {
                      setState(() => _shareLocation = value);
                    },
                    title: const Text('My location'),
                    subtitle: const Text('Show your location on the map.'),
                  ),
                  SwitchListTile.adaptive(
                    value: _trafficLayer,
                    onChanged: (value) {
                      setState(() => _trafficLayer = value);
                    },
                    title: const Text('Traffic layer'),
                    subtitle: const Text('Overlay live traffic on the map.'),
                  ),
                  SwitchListTile.adaptive(
                    value: _showBuildings,
                    onChanged: (value) {
                      setState(() => _showBuildings = value);
                    },
                    title: const Text('3D buildings'),
                    subtitle: const Text('Display building extrusions where available.'),
                  ),
                  SwitchListTile.adaptive(
                    value: _showCompass,
                    onChanged: (value) {
                      setState(() => _showCompass = value);
                    },
                    title: const Text('Compass'),
                    subtitle: const Text('Show the compass when rotating.'),
                  ),
                  SwitchListTile.adaptive(
                    value: _rotateGestures,
                    onChanged: (value) {
                      setState(() => _rotateGestures = value);
                    },
                    title: const Text('Rotate gestures'),
                    subtitle: const Text('Allow map rotation with two fingers.'),
                  ),
                  SwitchListTile.adaptive(
                    value: _tiltGestures,
                    onChanged: (value) {
                      setState(() => _tiltGestures = value);
                    },
                    title: const Text('Tilt gestures'),
                    subtitle: const Text('Allow 3D tilt with two fingers.'),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _mapType,
                    items: const [
                      DropdownMenuItem(
                        value: 'standard',
                        child: Text('Standard'),
                      ),
                      DropdownMenuItem(
                        value: 'hybrid',
                        child: Text('Hybrid'),
                      ),
                      DropdownMenuItem(
                        value: 'satellite',
                        child: Text('Satellite'),
                      ),
                      DropdownMenuItem(
                        value: 'terrain',
                        child: Text('Terrain'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() => _mapType = value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Map type',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: _resetDefaults,
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Reset to defaults'),
            ),
          ),
        ],
      ),
    );
  }
}
