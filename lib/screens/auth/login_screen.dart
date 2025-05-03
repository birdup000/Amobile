import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:agixt/models/agixt/auth/auth.dart';
import 'package:agixt/models/agixt/auth/oauth.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _mfaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  String? _errorMessage;
  List<OAuthProvider> _oauthProviders = [];
  bool _loadingProviders = true;

  @override
  void initState() {
    super.initState();
    _loadOAuthProviders();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _mfaController.dispose();
    super.dispose();
  }

  Future<void> _loadOAuthProviders() async {
    try {
      setState(() {
        _loadingProviders = true;
      });
      
      final providers = await OAuthService.getProviders();
      
      setState(() {
        _oauthProviders = providers;
        _loadingProviders = false;
      });
    } catch (e) {
      setState(() {
        _loadingProviders = false;
      });
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final jwt = await AuthService.login(
        _emailController.text,
        _mfaController.text,
      );

      if (jwt != null) {
        // Login successful, navigate to home
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        setState(() {
          _errorMessage = 'Login failed. Please check your credentials.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _loginWithOAuth(OAuthProvider provider) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await OAuthService.authenticate(provider);
      
      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        setState(() {
          _errorMessage = 'OAuth login failed. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _openRegistrationPage() async {
    final Uri url = Uri.parse(AuthService.appUri);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appName = AuthService.appName;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Login to $appName'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            // Logo or app name
            Center(
              child: Text(
                appName,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Error message if login fails
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.red.shade100,
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ),
              
            const SizedBox(height: 20),
            
            // Email & MFA login form
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _mfaController,
                    decoration: const InputDecoration(
                      labelText: '6-Digit MFA Code',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your MFA code';
                      }
                      if (value.length != 6 || int.tryParse(value) == null) {
                        return 'Please enter a valid 6-digit code';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Login'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            const Divider(),
            
            // OAuth providers section
            Text(
              'Or continue with',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            if (_loadingProviders)
              const Center(child: CircularProgressIndicator())
            else if (_oauthProviders.isEmpty)
              const Center(child: Text('No OAuth providers available'))
            else
              ...List.generate(_oauthProviders.length, (index) {
                final provider = _oauthProviders[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: OutlinedButton(
                    onPressed: _isLoading
                        ? null
                        : () => _loginWithOAuth(provider),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('Continue with ${provider.name.toUpperCase()}'),
                  ),
                );
              }),
              
            const SizedBox(height: 30),
            
            // Registration link
            Center(
              child: RichText(
                text: TextSpan(
                  text: 'Don\'t have an account? ',
                  style: TextStyle(color: Colors.grey[700]),
                  children: [
                    TextSpan(
                      text: 'Register',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = _openRegistrationPage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}