import 'package:flutter/material.dart';
import 'package:agixt/models/agixt/auth/auth.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _email;
  String? _firstName;
  String? _lastName;
  bool _isLoading = true;
  UserModel? _userModel;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    // Get stored email as fallback
    final email = await AuthService.getEmail();
    
    // Try to get full user info from the server
    final userInfo = await AuthService.getUserInfo();
    
    setState(() {
      if (userInfo != null) {
        _userModel = userInfo;
        _email = userInfo.email;
        _firstName = userInfo.firstName;
        _lastName = userInfo.lastName;
      } else {
        // If server request fails, use stored email as fallback
        _email = email;
      }
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    await AuthService.logout();
    
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  Future<void> _openAGiXTWeb() async {
    final url = await AuthService.getWebUrlWithToken();
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appName = AuthService.appName;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  
                  // User avatar or icon
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // User name and email
                  if (_firstName != null && _lastName != null && _firstName!.isNotEmpty && _lastName!.isNotEmpty) ...[
                    Text(
                      '${_firstName!} ${_lastName!}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  Text(
                    _email ?? 'User',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  
                  if (_userModel != null) ...[
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    
                    // Show user timezone
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time, size: 18, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Timezone: ${_userModel!.timezone}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 10),
                    
                    // Show token usage  
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.analytics_outlined, size: 18, color: Colors.green),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Tokens: ${_userModel!.inputTokens} in / ${_userModel!.outputTokens} out',
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    if (_userModel!.companies.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      
                      // Show primary company
                      Text(
                        'Company: ${_userModel!.companies.firstWhere((c) => c.primary, orElse: () => _userModel!.companies.first).name}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                  ] else
                    const SizedBox(height: 40),
                  
                  // Go to AGiXT button
                  ElevatedButton.icon(
                    onPressed: _openAGiXTWeb,
                    icon: const Icon(Icons.open_in_browser),
                    label: Text('Go to $appName'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Logout button
                  OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}