import 'package:agixt/widgets/glass_status.dart';
import 'package:agixt/screens/settings/dashboard_screen.dart';
import 'package:agixt/screens/settings/debug_screen.dart';
import 'package:agixt/screens/settings/notifications_screen.dart';
import 'package:agixt/screens/settings/whisper_screen.dart';
// Removed wake word settings import
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          GlassStatus(),
          ListTile(
            title: Row(
              children: [
                Icon(Icons.dashboard),
                SizedBox(width: 10),
                Text('G1 Dashboard'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DashboardSettingsPage()),
              );
            },
          ),
          ListTile(
            title: Row(
              children: [
                Icon(Icons.mic),
                SizedBox(width: 10),
                Text('Whisper'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => WhisperSettingsPage()),
              );
            },
          ),
          // Wake Word Settings option removed
          ListTile(
            title: Row(
              children: [
                Icon(Icons.notifications),
                SizedBox(width: 10),
                Text('App Notifications'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NotificationSettingsPage()),
              );
            },
          ),
          ListTile(
            title: Row(
              children: [
                Icon(Icons.bug_report),
                SizedBox(width: 10),
                Text('Debug'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DebugPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
