import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrescriptionDetailScreen extends StatefulWidget {
  final String medicationName;

  const PrescriptionDetailScreen({
    Key? key,
    required this.medicationName,
  }) : super(key: key);

  @override
  State<PrescriptionDetailScreen> createState() =>
      _PrescriptionDetailScreenState();
}

class _PrescriptionDetailScreenState extends State<PrescriptionDetailScreen> {
  late Map<String, dynamic> _medication;
  bool _isLoading = true;
  List<Map<String, dynamic>> _doseHistory = [];
  bool _reminderEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadMedicationDetails();
  }

  Future<void> _loadMedicationDetails() async {
    // In a real app, this would fetch data from a database
    await Future.delayed(const Duration(seconds: 1));

    // Mock medication data
    setState(() {
      _medication = {
        'name': widget.medicationName,
        'dosage': '500mg',
        'frequency': 'Three times daily',
        'duration': '7 days',
        'startDate': DateTime.now().subtract(const Duration(days: 2)),
        'endDate': DateTime.now().add(const Duration(days: 5)),
        'instructions': 'Take with food. Avoid dairy products.',
        'sideEffects': 'May cause drowsiness, nausea, or dizziness.',
        'nextDose': DateTime.now().add(const Duration(hours: 2)),
        'remainingDoses': 15,
        'totalDoses': 21,
        'prescribedBy': 'Dr. Sarah Johnson',
        'pharmacy': 'MedPlus Pharmacy',
        'refillDate': DateTime.now().add(const Duration(days: 5)),
        'notes': 'Prescribed for bacterial infection.',
      };

      _doseHistory = [
        {
          'date': DateTime.now().subtract(const Duration(days: 2, hours: 8)),
          'taken': true,
          'onTime': true,
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 2, hours: 0)),
          'taken': true,
          'onTime': true,
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 1, hours: 16)),
          'taken': true,
          'onTime': false,
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 1, hours: 8)),
          'taken': true,
          'onTime': true,
        },
        {
          'date': DateTime.now().subtract(const Duration(days: 1, hours: 0)),
          'taken': false,
          'onTime': false,
        },
        {
          'date': DateTime.now().subtract(const Duration(hours: 16)),
          'taken': true,
          'onTime': true,
        },
      ];

      _isLoading = false;
    });
  }

  void _toggleReminder(bool value) {
    setState(() {
      _reminderEnabled = value;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? 'Reminders enabled' : 'Reminders disabled'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _markAsTaken() {
    setState(() {
      _doseHistory.insert(0, {
        'date': DateTime.now(),
        'taken': true,
        'onTime': true,
      });

      _medication['remainingDoses'] =
          (_medication['remainingDoses'] as int) - 1;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dose marked as taken'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoading ? 'Loading...' : _medication['name']),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // Edit medication details
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edit functionality coming soon'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildNextDoseCard(),
                  _buildInfoSection(),
                  _buildDoseHistorySection(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final progress =
        (_medication['totalDoses'] - _medication['remainingDoses']) /
            _medication['totalDoses'];

    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _medication['name'][0],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _medication['name'],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${_medication['dosage']} · ${_medication['frequency']}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Switch(
                value: _reminderEnabled,
                onChanged: _toggleReminder,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Progress',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_medication['remainingDoses']} doses remaining',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                '${(_medication['totalDoses'] - _medication['remainingDoses'])}/${_medication['totalDoses']} doses taken',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextDoseCard() {
    final nextDose = _medication['nextDose'] as DateTime;
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
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Next Dose',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: timeColor,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat.jm().format(nextDose),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        'in $timeText',
                        style: TextStyle(
                          color: timeColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _markAsTaken,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: const Text('Take Now'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Medication Information',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildInfoItem('Duration', _medication['duration']),
          _buildInfoItem(
            'Start Date',
            DateFormat.yMMMd().format(_medication['startDate']),
          ),
          _buildInfoItem(
            'End Date',
            DateFormat.yMMMd().format(_medication['endDate']),
          ),
          _buildInfoItem('Instructions', _medication['instructions']),
          _buildInfoItem('Side Effects', _medication['sideEffects']),
          _buildInfoItem('Prescribed By', _medication['prescribedBy']),
          _buildInfoItem('Pharmacy', _medication['pharmacy']),
          _buildInfoItem(
            'Refill Date',
            DateFormat.yMMMd().format(_medication['refillDate']),
          ),
          _buildInfoItem('Notes', _medication['notes']),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildDoseHistorySection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Dose History',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton(
                onPressed: () {
                  // View full history
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Full history view coming soon'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _doseHistory.length.clamp(0, 5),
            itemBuilder: (context, index) {
              final dose = _doseHistory[index];
              final date = dose['date'] as DateTime;

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dose['taken']
                        ? dose['onTime']
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                  ),
                  child: Center(
                    child: Icon(
                      dose['taken']
                          ? dose['onTime']
                              ? Icons.check
                              : Icons.access_time
                          : Icons.close,
                      color: dose['taken']
                          ? dose['onTime']
                              ? Colors.green
                              : Colors.orange
                          : Colors.red,
                      size: 20,
                    ),
                  ),
                ),
                title: Text(
                  dose['taken']
                      ? dose['onTime']
                          ? 'Taken on time'
                          : 'Taken late'
                      : 'Missed',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: dose['taken']
                        ? dose['onTime']
                            ? Colors.green
                            : Colors.orange
                        : Colors.red,
                  ),
                ),
                subtitle: Text(
                  DateFormat('MMM d, yyyy · h:mm a').format(date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
