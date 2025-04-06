import 'package:flutter/material.dart';

class ScanResultsScreen extends StatefulWidget {
  const ScanResultsScreen({Key? key}) : super(key: key);

  @override
  State<ScanResultsScreen> createState() => _ScanResultsScreenState();
}

class _ScanResultsScreenState extends State<ScanResultsScreen> {
  late List<Map<String, dynamic>> _detectedMedications;
  final List<Map<String, dynamic>> _selectedMedications = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the detected medications from the route arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is List<Map<String, dynamic>>) {
      _detectedMedications = args;
    } else {
      // Fallback if no medications were passed
      _detectedMedications = [];
    }
  }

  void _toggleMedicationSelection(Map<String, dynamic> medication) {
    setState(() {
      if (_selectedMedications.contains(medication)) {
        _selectedMedications.remove(medication);
      } else {
        _selectedMedications.add(medication);
      }
    });
  }

  void _addSelectedMedications() {
    if (_selectedMedications.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one medication'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // In a real app, you would save these medications to a database
    // For now, we'll just show a success message and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${_selectedMedications.length} medications added to your list'),
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate back to the home screen
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Results'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _detectedMedications.isEmpty
          ? _buildEmptyState()
          : _buildMedicationList(),
      bottomNavigationBar: _detectedMedications.isEmpty
          ? null
          : BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: _selectedMedications.isEmpty
                      ? null
                      : _addSelectedMedications,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Add ${_selectedMedications.isEmpty ? 'Medications' : '${_selectedMedications.length} Medications'}',
                  ),
                ),
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
            Icons.search_off,
            size: 80,
            color: Theme.of(context).colorScheme.error.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Medications Found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'We couldn\'t detect any medications in the prescription.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Detected Medications',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'We found ${_detectedMedications.length} medications in your prescription. Select the ones you want to add to your list.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _detectedMedications.length,
            itemBuilder: (context, index) {
              final medication = _detectedMedications[index];
              final isSelected = _selectedMedications.contains(medication);

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isSelected
                      ? BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        )
                      : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () => _toggleMedicationSelection(medication),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surface,
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  size: 16,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                )
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                medication['name'],
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${medication['dosage']} · ${medication['frequency']}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Duration: ${medication['duration']}',
                                style: Theme.of(context).textTheme.bodySmall,
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
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${(medication['confidence'] * 100).toInt()}% match',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
