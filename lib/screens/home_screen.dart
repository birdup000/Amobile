import 'package:agixt/models/agixt/auth/auth.dart';
import 'package:agixt/screens/auth/profile_screen.dart';
import 'package:agixt/screens/calendars_screen.dart';
import 'package:agixt/screens/checklist_screen.dart';
import 'package:agixt/screens/agixt_daily.dart';
import 'package:agixt/screens/agixt_stop.dart';
import 'package:agixt/screens/settings_screen.dart';
import 'package:agixt/services/ai_service.dart';
import 'package:agixt/utils/ui_perfs.dart';
import 'package:agixt/widgets/current_agixt.dart';
import 'package:agixt/widgets/gravatar_image.dart';
import 'package:flutter/material.dart';
import '../services/bluetooth_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BluetoothManager bluetoothManager = BluetoothManager();
  final AIService aiService = AIService();
  final UiPerfs _ui = UiPerfs.singleton;

  String? _userEmail;
  bool _isLoggedIn = true;
  bool _isSideButtonListenerAttached = false;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _setupBluetoothListeners();
  }

  Future<void> _loadUserDetails() async {
    final email = await AuthService.getEmail();
    final isLoggedIn = await AuthService.isLoggedIn();

    if (mounted) {
      setState(() {
        _userEmail = email;
        _isLoggedIn = isLoggedIn;
      });
      
      // For debugging
      print("User email: $_userEmail");
      print("Is logged in: $_isLoggedIn");

      // Redirect to login if not logged in
      if (!_isLoggedIn) {
        Navigator.of(context).pushReplacementNamed('/login');
      } else if (_userEmail == null || _userEmail!.isEmpty) {
        // If logged in but email is missing, try to get the user info
        final userInfo = await AuthService.getUserInfo();
        if (userInfo != null && userInfo.email.isNotEmpty) {
          setState(() {
            _userEmail = userInfo.email;
          });
          // Store the email for future use
          await AuthService.storeEmail(userInfo.email);
          print("Updated user email from user info: $_userEmail");
        }
      }
    }
  }

  void _setupBluetoothListeners() {
    // Wait until the glasses are connected to attach the listener
    Future.delayed(const Duration(seconds: 2), () {
      if (bluetoothManager.isConnected && !_isSideButtonListenerAttached) {
        _attachSideButtonListener();
      } else {
        // Try again later
        _setupBluetoothListeners();
      }
    });
  }

  void _attachSideButtonListener() {
    // Monitor for the side button press events from glasses
    if (bluetoothManager.rightGlass != null) {
      bluetoothManager.rightGlass!.onSideButtonPress = () {
        _handleSideButtonPress();
      };
      _isSideButtonListenerAttached = true;
    }
  }

  Future<void> _handleSideButtonPress() async {
    // Check if user is logged in
    if (!await AuthService.isLoggedIn()) {
      bluetoothManager.sendText('Please log in to use AI assistant');
      return;
    }

    // Handle the side button press to activate AI communications
    await aiService.handleSideButtonPress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AGiXT'),
        actions: [
          // Profile button with Gravatar
          if (_userEmail != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfileScreen()),
                  );
                },
                child: GravatarImage(
                  email: _userEmail!,
                  size: 40,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen()),
                );
              },
            ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              ).then((_) => setState(() {}));
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          CurrentAGiXT(),

          // AI Assistant Card
          Card(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.mic, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 10),
                      const Text(
                        'AI Assistant',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Press the side button on your glasses to speak with the AI assistant.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: _handleSideButtonPress,
                    icon: const Icon(Icons.record_voice_over),
                    label: const Text('Activate Assistant'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Other menu items
          ListTile(
            title: Row(
              children: [
                _ui.trainNerdMode
                    ? Image(
                        image: AssetImage('assets/icons/reference.png'),
                        height: 20,
                      )
                    : Icon(Icons.sunny),
                SizedBox(width: 10),
                Text('Daily Items'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AGiXTDailyPage()),
              );
            },
          ),
          ListTile(
            title: Row(
              children: [
                _ui.trainNerdMode
                    ? Image(
                        image: AssetImage('assets/icons/stop.png'),
                        height: 20,
                      )
                    : Icon(Icons.notifications),
                SizedBox(width: 10),
                Text('Stop Items'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AGiXTStopPage()),
              );
            },
          ),
          ListTile(
            title: Row(
              children: [
                _ui.trainNerdMode
                    ? Image(
                        image: AssetImage('assets/icons/oorsprong.png'),
                        height: 20,
                      )
                    : Icon(Icons.checklist),
                SizedBox(width: 10),
                Text('Checklists'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AGiXTChecklistPage()),
              );
            },
          ),
          ListTile(
            title: Row(
              children: [
                _ui.trainNerdMode
                    ? Image(
                        image: AssetImage('assets/icons/groen.png'),
                        height: 20,
                      )
                    : Icon(Icons.calendar_today),
                SizedBox(width: 10),
                Text('Calendar Integration'),
              ],
            ),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CalendarsPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
