import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMedications() async {
    // Simulate loading from a database
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _medications = [
        {
          'name': 'Amoxicillin',
          'dosage': '500mg',
          'frequency': 'Three times daily',
          'duration': '7 days',
          'nextDose': DateTime.now().add(const Duration(hours: 2)),
          'remainingDoses': 15,
        },
        {
          'name': 'Paracetamol',
          'dosage': '1000mg',
          'frequency': 'Every 6 hours as needed',
          'duration': '5 days',
          'nextDose': DateTime.now().add(const Duration(hours: 4)),
          'remainingDoses': 12,
        },
        {
          'name': 'Lisinopril',
          'dosage': '10mg',
          'frequency': 'Once daily',
          'duration': '30 days',
          'nextDose': DateTime.now().add(const Duration(hours: 8)),
          'remainingDoses': 24,
        },
        {
          'name': 'Atorvastatin',
          'dosage': '20mg',
          'frequency': 'Once daily at bedtime',
          'duration': '30 days',
          'nextDose': DateTime.now().add(const Duration(hours: 12)),
          'remainingDoses': 28,
        },
      ];
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredMedications {
    if (_searchQuery.isEmpty) {
      return _medications;
    }
    return _medications.where((medication) {
      return medication['name'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Medications'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Show notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredMedications.isEmpty
                    ? _buildEmptyState()
                    : _buildMedicationList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (Platform.isIOS) {
            Navigator.pushNamed(context, '/scan');
          } else {
            Navigator.pushNamed(context, '/scan');
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Medication',
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search medications...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medication_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No medications found'
                : 'No results for "$_searchQuery"',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Tap the + button to add a medication'
                : 'Try a different search term',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredMedications.length,
      itemBuilder: (context, index) {
        final medication = _filteredMedications[index];
        return MedicationCard(
          medication: medication,
          onTap: () {
            Navigator.pushNamed(
              context,
              '/prescription_detail',
              arguments: medication['name'],
            );
          },
        );
      },
    );
  }
}

class MedicationCard extends StatelessWidget {
  final Map<String, dynamic> medication;
  final VoidCallback onTap;

  const MedicationCard({
    Key? key,
    required this.medication,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nextDose = medication['nextDose'] as DateTime;
    final now = DateTime.now();
    final difference = nextDose.difference(now);

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    String timeText;
    Color timeColor;

    if (difference.isNegative) {
      timeText = 'Overdue';
      timeColor = Theme.of(context).colorScheme.error;
    } else if (hours == 0 && minutes < 30) {
      timeText = 'Due soon';
      timeColor = Colors.orange;
    } else {
      timeText = hours > 0
          ? '$hours hr ${minutes > 0 ? '$minutes min' : ''}'
          : '$minutes min';
      timeColor = Theme.of(context).colorScheme.primary;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        medication['name'][0],
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          medication['name'],
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${medication['dosage']} · ${medication['frequency']}',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: timeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: timeColor, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, size: 12, color: timeColor),
                        const SizedBox(width: 4),
                        Text(
                          timeText,
                          style: TextStyle(
                            color: timeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: medication['remainingDoses'] /
                    (medication['remainingDoses'] +
                        5), // Assuming 5 doses taken
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.1),
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${medication['remainingDoses']} doses remaining',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    'Next: ${DateFormat.jm().format(medication['nextDose'])}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
