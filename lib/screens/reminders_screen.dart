import 'package:flutter/material.dart';
import '../models/medication_reminder.dart';
import '../services/reminder_service.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({Key? key}) : super(key: key);

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final ReminderService _reminderService = ReminderService();
  List<MedicationReminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    setState(() {
      _isLoading = true;
    });

    final reminders = await _reminderService.getReminders();

    setState(() {
      _reminders = reminders;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medication Reminders')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _reminders.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                itemCount: _reminders.length,
                itemBuilder: (context, index) {
                  final reminder = _reminders[index];
                  return _buildReminderCard(reminder);
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddReminderDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No medication reminders',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              _showAddReminderDialog();
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Reminder'),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(MedicationReminder reminder) {
    final timeString =
        '${reminder.time.hour}:${reminder.time.minute.toString().padLeft(2, '0')}';
    final daysString = _getDaysString(reminder.daysOfWeek);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    reminder.medicationName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Switch(
                  value: reminder.isActive,
                  onChanged: (value) {
                    _toggleReminderActive(reminder.id, value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Dosage: ${reminder.dosage}'),
            Text('Time: $timeString'),
            Text('Days: $daysString'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    _showEditReminderDialog(reminder);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: () {
                    _deleteReminder(reminder.id);
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getDaysString(List<bool> daysOfWeek) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final selectedDays = <String>[];

    for (int i = 0; i < daysOfWeek.length; i++) {
      if (daysOfWeek[i]) {
        selectedDays.add(days[i]);
      }
    }

    if (selectedDays.isEmpty) {
      return 'No days selected';
    } else if (selectedDays.length == 7) {
      return 'Every day';
    } else {
      return selectedDays.join(', ');
    }
  }

  Future<void> _toggleReminderActive(String id, bool isActive) async {
    await _reminderService.toggleReminderActive(id, isActive);
    _loadReminders();
  }

  Future<void> _deleteReminder(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Reminder'),
            content: const Text(
              'Are you sure you want to delete this reminder?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _reminderService.deleteReminder(id);
      _loadReminders();
    }
  }

  Future<void> _showAddReminderDialog() async {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController dosageController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    List<bool> selectedDays = List.filled(7, false);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Add Medication Reminder'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Medication Name',
                          ),
                        ),
                        TextField(
                          controller: dosageController,
                          decoration: const InputDecoration(
                            labelText: 'Dosage',
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: const Text('Time'),
                          trailing: Text(
                            '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                          ),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (time != null) {
                              setState(() {
                                selectedTime = time;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        const Text('Days of Week'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (int i = 0; i < 7; i++)
                              FilterChip(
                                label: Text(
                                  [
                                    'Sun',
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                    'Sat',
                                  ][i],
                                ),
                                selected: selectedDays[i],
                                onSelected: (selected) {
                                  setState(() {
                                    selectedDays[i] = selected;
                                  });
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (nameController.text.isEmpty ||
                            dosageController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in all fields'),
                            ),
                          );
                          return;
                        }

                        if (!selectedDays.contains(true)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select at least one day'),
                            ),
                          );
                          return;
                        }

                        Navigator.pop(context, {
                          'name': nameController.text,
                          'dosage': dosageController.text,
                          'time': selectedTime,
                          'days': selectedDays,
                        });
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
          ),
    );

    if (result != null) {
      final reminder = MedicationReminder(
        id: _reminderService.generateId(),
        medicationName: result['name'],
        dosage: result['dosage'],
        time: result['time'],
        daysOfWeek: result['days'],
      );

      await _reminderService.saveReminder(reminder);
      _loadReminders();
    }
  }

  Future<void> _showEditReminderDialog(MedicationReminder reminder) async {
    final TextEditingController nameController = TextEditingController(
      text: reminder.medicationName,
    );
    final TextEditingController dosageController = TextEditingController(
      text: reminder.dosage,
    );
    TimeOfDay selectedTime = reminder.time;
    List<bool> selectedDays = List.from(reminder.daysOfWeek);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Edit Medication Reminder'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Medication Name',
                          ),
                        ),
                        TextField(
                          controller: dosageController,
                          decoration: const InputDecoration(
                            labelText: 'Dosage',
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          title: const Text('Time'),
                          trailing: Text(
                            '${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                          ),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );
                            if (time != null) {
                              setState(() {
                                selectedTime = time;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        const Text('Days of Week'),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (int i = 0; i < 7; i++)
                              FilterChip(
                                label: Text(
                                  [
                                    'Sun',
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                    'Sat',
                                  ][i],
                                ),
                                selected: selectedDays[i],
                                onSelected: (selected) {
                                  setState(() {
                                    selectedDays[i] = selected;
                                  });
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (nameController.text.isEmpty ||
                            dosageController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fill in all fields'),
                            ),
                          );
                          return;
                        }

                        if (!selectedDays.contains(true)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select at least one day'),
                            ),
                          );
                          return;
                        }

                        Navigator.pop(context, {
                          'name': nameController.text,
                          'dosage': dosageController.text,
                          'time': selectedTime,
                          'days': selectedDays,
                        });
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
          ),
    );

    if (result != null) {
      final updatedReminder = MedicationReminder(
        id: reminder.id,
        medicationName: result['name'],
        dosage: result['dosage'],
        time: result['time'],
        daysOfWeek: result['days'],
        isActive: reminder.isActive,
      );

      await _reminderService.saveReminder(updatedReminder);
      _loadReminders();
    }
  }
}
