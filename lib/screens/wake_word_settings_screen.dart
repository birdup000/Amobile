import 'package:flutter/material.dart';
import 'package:agixt/utils/wake_word_settings.dart';

class WakeWordSettingsScreen extends StatefulWidget {
  const WakeWordSettingsScreen({Key? key}) : super(key: key);

  @override
  State<WakeWordSettingsScreen> createState() => _WakeWordSettingsScreenState();
}

class _WakeWordSettingsScreenState extends State<WakeWordSettingsScreen> {
  final _wakeWordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _settings = WakeWordSettings.singleton;
  bool _isLoading = false;
  String _currentWakeWord = '';
  
  @override
  void initState() {
    super.initState();
    _loadCurrentWakeWord();
  }
  
  @override
  void dispose() {
    _wakeWordController.dispose();
    super.dispose();
  }
  
  Future<void> _loadCurrentWakeWord() async {
    setState(() {
      _isLoading = true;
    });
    
    // Initialize if not already done
    await _settings.initialize();
    
    setState(() {
      _currentWakeWord = _settings.wakeWord;
      _wakeWordController.text = _currentWakeWord;
      _isLoading = false;
    });
  }
  
  Future<void> _updateWakeWord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    final newWakeWord = _wakeWordController.text.trim();
    final success = await _settings.updateWakeWord(newWakeWord);
    
    setState(() {
      _isLoading = false;
    });
    
    if (success) {
      _currentWakeWord = newWakeWord;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Wake word updated to "$newWakeWord"')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update wake word')),
        );
      }
    }
  }
  
  Future<void> _resetToDefault() async {
    setState(() {
      _isLoading = true;
    });
    
    final success = await _settings.resetToDefault();
    
    setState(() {
      if (success) {
        _currentWakeWord = _settings.defaultWakeWord;
        _wakeWordController.text = _currentWakeWord;
      }
      _isLoading = false;
    });
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wake word reset to "${_settings.defaultWakeWord}"')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wake Word Settings'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Customize your wake word',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The wake word is the keyword that activates voice commands. Say this word followed by your command.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _wakeWordController,
                    decoration: InputDecoration(
                      labelText: 'Wake Word',
                      hintText: 'Enter a new wake word',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _wakeWordController.clear();
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Wake word cannot be empty';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _updateWakeWord,
                          child: const Text('Update Wake Word'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _resetToDefault,
                          child: const Text('Reset to Default'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Settings',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text('Current Wake Word: '),
                              Text(
                                _currentWakeWord,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text('Default Wake Word: '),
                              Text(
                                _settings.defaultWakeWord,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Example Usage:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"$_currentWakeWord, what\'s the weather today?"',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  Text(
                    '"$_currentWakeWord, set a reminder for tomorrow at 9 AM"',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}