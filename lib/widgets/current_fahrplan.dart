import 'dart:async';

import 'package:agixt/models/agixt/agixt_dashboard.dart';
import 'package:agixt/models/g1/note.dart';
import 'package:flutter/material.dart';

class CurrentAGiXT extends StatefulWidget {
  const CurrentAGiXT({super.key});

  @override
  State<CurrentAGiXT> createState() => _CurrentAGiXTState();
}

class _CurrentAGiXTState extends State<CurrentAGiXT> {
  AGiXTDashboard agixtDashboard = AGiXTDashboard();

  List<Note> _dashboardItems = [];

  int _selectedIndex = 0;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshData();
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _refreshData();
    });
  }

  @override
  void dispose() {
    if (_refreshTimer != null) {
      _refreshTimer!.cancel();
    }
    super.dispose();
  }

  Future<void> _refreshData() async {
    _dashboardItems = await agixtDashboard.generateDashboardItems();
    _selectedIndex = 0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: const Text('Current AGiXT'),
              ),
              IconButton(onPressed: _refreshData, icon: Icon(Icons.refresh)),
            ],
          ),

          const Divider(),
          _dashboardItems.isNotEmpty
              ? Column(
                  children: [
                    Text(_dashboardItems[_selectedIndex].name),
                    Text(_dashboardItems[_selectedIndex].text),
                  ],
                )
              : Text("No items found"),
          const Divider(),
          // add next and previous buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _selectedIndex > 0
                    ? () {
                        setState(() {
                          _selectedIndex--;
                        });
                      }
                    : null,
                child: const Icon(Icons.arrow_back),
              ),
              ElevatedButton(
                onPressed: (_selectedIndex < _dashboardItems.length - 1)
                    ? () => {
                          setState(() {
                            _selectedIndex++;
                          })
                        }
                    : null,
                child: const Icon(Icons.arrow_forward),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
