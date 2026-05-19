import 'package:flutter/material.dart';
import 'package:frontend/components/glass_container.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),

          // 1. Trip Preferences Group
          _buildSettingsGroup(
            title: 'Trip preferences',
            items: [
              _buildSwitchItem(
                title: 'Trip notifications',
                subtitle: 'Updates when routes change or a trip starts.',
                value: _tripNotifications,
                onChanged: (val) => setState(() => _tripNotifications = val),
              ),
              _buildSwitchItem(
                title: 'Auto-save drafts',
                subtitle: 'Keep unfinished trips ready for later.',
                value: _autoSaveDrafts,
                onChanged: (val) => setState(() => _autoSaveDrafts = val),
              ),
              _buildDropdownItem(
                title: 'Distance unit',
                subtitle: 'Preferred units for routes and navigation.',
                value: _distanceUnit,
                items: const [
                  DropdownMenuItem(value: 'km', child: Text('Kilometers')),
                  DropdownMenuItem(value: 'mi', child: Text('Miles')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _distanceUnit = val);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 2. Map Group
          _buildSettingsGroup(
            title: 'Map',
            items: [
              _buildSwitchItem(
                title: 'My location',
                subtitle: 'Show your location on the map.',
                value: _shareLocation,
                onChanged: (val) => setState(() => _shareLocation = val),
              ),
              _buildSwitchItem(
                title: 'Traffic layer',
                subtitle: 'Overlay live traffic on the map.',
                value: _trafficLayer,
                onChanged: (val) => setState(() => _trafficLayer = val),
              ),
              _buildSwitchItem(
                title: '3D buildings',
                subtitle: 'Display building extrusions where available.',
                value: _showBuildings,
                onChanged: (val) => setState(() => _showBuildings = val),
              ),
              _buildSwitchItem(
                title: 'Compass',
                subtitle: 'Show the compass when rotating.',
                value: _showCompass,
                onChanged: (val) => setState(() => _showCompass = val),
              ),
              _buildSwitchItem(
                title: 'Rotate gestures',
                subtitle: 'Allow map rotation with two fingers.',
                value: _rotateGestures,
                onChanged: (val) => setState(() => _rotateGestures = val),
              ),
              _buildSwitchItem(
                title: 'Tilt gestures',
                subtitle: 'Allow 3D tilt with two fingers.',
                value: _tiltGestures,
                onChanged: (val) => setState(() => _tiltGestures = val),
              ),
              _buildDropdownItem(
                title: 'Map type',
                subtitle: 'Choose your preferred base map style.',
                value: _mapType,
                items: const [
                  DropdownMenuItem(value: 'standard', child: Text('Standard')),
                  DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
                  DropdownMenuItem(value: 'satellite', child: Text('Satellite')),
                  DropdownMenuItem(value: 'terrain', child: Text('Terrain')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _mapType = val);
                },
              ),
            ],
          ),

          const SizedBox(height: 32),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _resetDefaults,
              icon: const Icon(Icons.restart_alt_rounded, size: 20),
              label: const Text('RESET TO DEFAULTS'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white.withValues(alpha: 0.6),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup({required String title, required List<Widget> items}) {
    return GlassContainer(
      color: Colors.white,
      opacity: 0.05,
      blur: 12,
      borderRadius: 24,
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.15),
        width: 1,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final widget = entry.value;
              final isLast = index == items.length - 1;

              return Column(
                children: [
                  widget,
                  if (!isLast)
                    Divider(
                      color: Colors.white.withValues(alpha: 0.1),
                      height: 1,
                      indent: 24,
                      endIndent: 24,
                    ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.orange.shade600,
            activeTrackColor: Colors.orange.shade600.withValues(alpha: 0.4),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem({
    required String title,
    required String subtitle,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items: items,
              onChanged: onChanged,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
              dropdownColor: const Color(0xFF0A4275),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }
}
