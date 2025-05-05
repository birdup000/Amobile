import 'package:agixt/screens/settings/dashboard_screen.dart';
import 'package:agixt/screens/settings/debug_screen.dart';
import 'package:agixt/screens/settings/homeassistant_screen.dart';
import 'package:agixt/screens/settings/notifications_screen.dart';
import 'package:agixt/screens/settings/ui_settings.dart';
import 'package:agixt/screens/settings/whisper_screen.dart';
import 'package:agixt/screens/wake_word_settings_screen.dart';
import 'package:agixt/widgets/about_dialog.dart';
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
                Icon(Icons.home),
                SizedBox(width: 10),
                Text('HomeAssistant'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeAssistantSettingsPage()),
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
          // Add Wake Word Settings option
          ListTile(
            title: Row(
              children: [
                Icon(Icons.record_voice_over),
                SizedBox(width: 10),
                Text('Wake Word Settings'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WakeWordSettingsScreen()),
              );
            },
          ),
          ListTile(
            title: Row(
              children: [
                Icon(Icons.brush),
                SizedBox(width: 10),
                Text('UI'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UiSettingsPage()),
              );
            },
          ),
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
          ListTile(
            title: Row(
              children: [
                Icon(Icons.info),
                SizedBox(width: 10),
                Text('About'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () => showCustomAboutDialog(context),
          ),
        ],
      ),
    );
  }
}
