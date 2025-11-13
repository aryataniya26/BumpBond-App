import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MedicationRemindersScreen extends StatefulWidget {
  const MedicationRemindersScreen({Key? key}) : super(key: key);

  @override
  State<MedicationRemindersScreen> createState() => _MedicationRemindersScreenState();
}

class _MedicationRemindersScreenState extends State<MedicationRemindersScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late CollectionReference _medicationCollection;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      _medicationCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('medications');
    }

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    var androidInit = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInit = const DarwinInitializationSettings();
    var initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  void _showAddMedicationScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicationScreen(
          medicationCollection: _medicationCollection,
          flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
        ),
      ),
    );
  }

  void _showHistoryScreen() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('History screen - Coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB794F4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medication Tracker',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Manage your medications',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _medicationCollection.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFB794F4)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final meds = snapshot.data?.docs ?? [];

          if (meds.isEmpty) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          'Add Medication',
                          'Log new medication',
                          Icons.add,
                          const Color(0xFF5DADE2),
                          _showAddMedicationScreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          'View History',
                          'Track your logs',
                          Icons.history,
                          const Color(0xFF10B981),
                          _showHistoryScreen,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Current Medications (${meds.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Medications List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: meds.length,
                    itemBuilder: (context, index) {
                      return _buildMedicationCard(meds[index]);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationCard(QueryDocumentSnapshot med) {
    final data = med.data() as Map<String, dynamic>;
    final name = data['name'] ?? 'Unknown';
    final dosage = data['dosage'] ?? '';
    final frequency = data['frequency'] ?? '';
    final timeSlots = List<String>.from(data['timeSlots'] ?? []);
    final purpose = data['purpose'] ?? '';
    final prescribedBy = data['prescribedBy'] ?? '';
    final instructions = data['instructions'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFB794F4).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.medication,
                  color: Color(0xFFB794F4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    if (dosage.isNotEmpty)
                      Text(
                        dosage,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                onPressed: () => _deleteMedication(med.id),
              ),
            ],
          ),

          if (frequency.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.repeat, size: 16, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 6),
                  Text(
                    frequency,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFF59E0B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (timeSlots.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: timeSlots.map((slot) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Color(0xFFB794F4)),
                      const SizedBox(width: 4),
                      Text(
                        _formatTimeSlot(slot),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF2C3E50),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          if (purpose.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    purpose,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],

          if (prescribedBy.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.medical_services_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  'Dr. $prescribedBy',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],

          if (instructions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFEF4444)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      instructions,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTimeSlot(String slot) {
    switch (slot) {
      case 'morning':
        return 'Morning';
      case 'afternoon':
        return 'Afternoon';
      case 'evening':
        return 'Evening';
      case 'night':
        return 'Night';
      case 'before_breakfast':
        return 'Before Breakfast';
      case 'after_breakfast':
        return 'After Breakfast';
      case 'before_lunch':
        return 'Before Lunch';
      case 'after_lunch':
        return 'After Lunch';
      case 'before_dinner':
        return 'Before Dinner';
      case 'after_dinner':
        return 'After Dinner';
      case 'before_sleep':
        return 'Before Sleep';
      default:
        return slot;
    }
  }

  void _deleteMedication(String id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Medication?'),
        content: const Text('Are you sure you want to delete this medication?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _medicationCollection.doc(id).delete();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Medication deleted successfully'),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Action Cards
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    'Add Medication',
                    'Log new medication',
                    Icons.add,
                    const Color(0xFF5DADE2),
                    _showAddMedicationScreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    'View History',
                    'Track your logs',
                    Icons.history,
                    const Color(0xFF10B981),
                    _showHistoryScreen,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Empty State
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.medication_outlined,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No medications added',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start tracking your medications',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _showAddMedicationScreen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB794F4),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Add Your First Medication',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add Medication Screen
class AddMedicationScreen extends StatefulWidget {
  final CollectionReference medicationCollection;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  const AddMedicationScreen({
    Key? key,
    required this.medicationCollection,
    required this.flutterLocalNotificationsPlugin,
  }) : super(key: key);

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _prescribedByController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();

  String _selectedFrequency = '';
  List<String> _selectedTimeSlots = [];
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSaving = false;

  final List<String> _frequencies = [
    'Once Daily',
    'Twice Daily',
    'Three Times Daily',
    'Four Times Daily',
    'As Needed',
    'Every 2 Hours',
    'Every 4 Hours',
    'Every 6 Hours',
    'Every 8 Hours',
    'Every 12 Hours',
  ];

  final List<Map<String, String>> _timeSlots = [
    {'label': 'Morning (6-10 AM)', 'value': 'morning'},
    {'label': 'Afternoon (12-2 PM)', 'value': 'afternoon'},
    {'label': 'Evening (6-8 PM)', 'value': 'evening'},
    {'label': 'Night (9-11 PM)', 'value': 'night'},
    {'label': 'Before Breakfast', 'value': 'before_breakfast'},
    {'label': 'After Breakfast', 'value': 'after_breakfast'},
    {'label': 'Before Lunch', 'value': 'before_lunch'},
    {'label': 'After Lunch', 'value': 'after_lunch'},
    {'label': 'Before Dinner', 'value': 'before_dinner'},
    {'label': 'After Dinner', 'value': 'after_dinner'},
    {'label': 'Before Sleep', 'value': 'before_sleep'},
  ];

  void _toggleTimeSlot(String slot) {
    setState(() {
      if (_selectedTimeSlots.contains(slot)) {
        _selectedTimeSlots.remove(slot);
      } else {
        _selectedTimeSlots.add(slot);
      }
    });
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFB794F4),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _saveMedication() async {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      _showSnackbar('Please enter medication name', isError: true);
      return;
    }

    if (_dosageController.text.trim().isEmpty) {
      _showSnackbar('Please enter dosage', isError: true);
      return;
    }

    if (_selectedFrequency.isEmpty) {
      _showSnackbar('Please select frequency', isError: true);
      return;
    }

    if (_selectedTimeSlots.isEmpty) {
      _showSnackbar('Please select at least one time of day', isError: true);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Create single medication document
      final medicationData = {
        'name': _nameController.text.trim(),
        'dosage': _dosageController.text.trim(),
        'frequency': _selectedFrequency,
        'timeSlots': _selectedTimeSlots,
        'startDate': _startDate != null ? Timestamp.fromDate(_startDate!) : Timestamp.now(),
        'endDate': _endDate != null ? Timestamp.fromDate(_endDate!) : null,
        'purpose': _purposeController.text.trim(),
        'prescribedBy': _prescribedByController.text.trim(),
        'instructions': _instructionsController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      // Add to Firestore - Single document
      final docRef = await widget.medicationCollection.add(medicationData);

      print('Medication saved with ID: ${docRef.id}');
      print('Data saved: $medicationData');

      // Schedule notifications for each time slot
      for (String slot in _selectedTimeSlots) {
        await _scheduleNotification(slot, docRef.id);
      }

      setState(() {
        _isSaving = false;
      });

      _showSnackbar('Medication added successfully!', isError: false);

      // Go back after short delay
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pop(context);

    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      print('Error saving medication: $e');
      _showSnackbar('Error adding medication: $e', isError: true);
    }
  }

  Future<void> _scheduleNotification(String timeSlot, String medicationId) async {
    TimeOfDay? notificationTime;

    switch (timeSlot) {
      case 'morning':
        notificationTime = const TimeOfDay(hour: 8, minute: 0);
        break;
      case 'afternoon':
        notificationTime = const TimeOfDay(hour: 13, minute: 0);
        break;
      case 'evening':
        notificationTime = const TimeOfDay(hour: 19, minute: 0);
        break;
      case 'night':
        notificationTime = const TimeOfDay(hour: 21, minute: 0);
        break;
      case 'before_breakfast':
        notificationTime = const TimeOfDay(hour: 7, minute: 0);
        break;
      case 'after_breakfast':
        notificationTime = const TimeOfDay(hour: 9, minute: 0);
        break;
      case 'before_lunch':
        notificationTime = const TimeOfDay(hour: 12, minute: 0);
        break;
      case 'after_lunch':
        notificationTime = const TimeOfDay(hour: 14, minute: 0);
        break;
      case 'before_dinner':
        notificationTime = const TimeOfDay(hour: 18, minute: 0);
        break;
      case 'after_dinner':
        notificationTime = const TimeOfDay(hour: 20, minute: 0);
        break;
      case 'before_sleep':
        notificationTime = const TimeOfDay(hour: 22, minute: 0);
        break;
    }

    if (notificationTime != null) {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'med_channel',
        'Medication Reminder',
        channelDescription: 'Reminder for taking medications',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

      final now = tz.TZDateTime.now(tz.local);
      tz.TZDateTime scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        notificationTime.hour,
        notificationTime.minute,
      );

      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await widget.flutterLocalNotificationsPlugin.zonedSchedule(
        '$medicationId-$timeSlot'.hashCode,
        'Medication Reminder 💊',
        'Time to take ${_nameController.text}',
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  void _showSnackbar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    _purposeController.dispose();
    _prescribedByController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB794F4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Medication',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Enter medication details',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add New Medication',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 20),

                // Medication Name
                _buildLabel('Medication Name *'),
                TextField(
                  controller: _nameController,
                  decoration: _buildInputDecoration('e.g., Folic Acid, Iron Tablet'),
                ),
                const SizedBox(height: 16),

                // Dosage
                _buildLabel('Dosage *'),
                TextField(
                  controller: _dosageController,
                  decoration: _buildInputDecoration('e.g., 5mg, 1 tablet, 2 capsules'),
                ),
                const SizedBox(height: 16),

                // Frequency
                _buildLabel('Frequency *'),
                DropdownButtonFormField<String>(
                  value: _selectedFrequency.isEmpty ? null : _selectedFrequency,
                  hint: const Text('How often?'),
                  decoration: _buildInputDecoration(''),
                  items: _frequencies.map((freq) {
                    return DropdownMenuItem(value: freq, child: Text(freq));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFrequency = value ?? '';
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Time of Day
                _buildLabel('Time of Day *'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _timeSlots.map((slot) {
                    final isSelected = _selectedTimeSlots.contains(slot['value']);
                    return FilterChip(
                      label: Text(slot['label']!),
                      selected: isSelected,
                      onSelected: (selected) => _toggleTimeSlot(slot['value']!),
                      selectedColor: const Color(0xFFB794F4).withOpacity(0.2),
                      checkmarkColor: const Color(0xFFB794F4),
                      labelStyle: TextStyle(
                        color: isSelected ? const Color(0xFFB794F4) : Colors.grey[700],
                        fontSize: 13,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Dates
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Start Date'),
                          GestureDetector(
                            onTap: () => _selectDate(true),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 18, color: Color(0xFFB794F4)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _startDate != null
                                          ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                          : 'Select date',
                                      style: TextStyle(
                                        color: _startDate != null ? Colors.black87 : Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('End Date'),
                          GestureDetector(
                            onTap: () => _selectDate(false),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFB794F4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 18, color: Color(0xFFB794F4)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _endDate != null
                                          ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                          : 'Select date',
                                      style: TextStyle(
                                        color: _endDate != null ? Colors.black87 : Colors.grey[500],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Purpose/Condition
                _buildLabel('Purpose/Condition'),
                TextField(
                  controller: _purposeController,
                  decoration: _buildInputDecoration('e.g., Prenatal vitamins, Anemia, Morning sickness'),
                ),
                const SizedBox(height: 16),

                // Prescribed By
                _buildLabel('Prescribed By'),
                TextField(
                  controller: _prescribedByController,
                  decoration: _buildInputDecoration('Doctor\'s name'),
                ),
                const SizedBox(height: 16),

                // Special Instructions
                _buildLabel('Special Instructions'),
                TextField(
                  controller: _instructionsController,
                  maxLines: 3,
                  decoration: _buildInputDecoration('e.g., Take with food, Avoid dairy, Take on empty stomach'),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveMedication,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB794F4),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                        child: _isSaving
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Save Medication',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _isSaving ? Colors.grey[300]! : Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: _isSaving ? Colors.grey[400] : Colors.grey[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2C3E50),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFB794F4), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
//
// class MedicationRemindersScreen extends StatefulWidget {
//   const MedicationRemindersScreen({Key? key}) : super(key: key);
//
//   @override
//   State<MedicationRemindersScreen> createState() => _MedicationRemindersScreenState();
// }
//
// class _MedicationRemindersScreenState extends State<MedicationRemindersScreen> {
//   final TextEditingController _medNameController = TextEditingController();
//   final TextEditingController _medTimeController = TextEditingController();
//   final CollectionReference _medicationCollection =
//   FirebaseFirestore.instance.collection('medications');
//
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   @override
//   void initState() {
//     super.initState();
//     tz.initializeTimeZones();
//     tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
//
//     var androidInit = const AndroidInitializationSettings('@mipmap/ic_launcher');
//     var iosInit = const DarwinInitializationSettings();
//     var initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
//     flutterLocalNotificationsPlugin.initialize(initSettings);
//   }
//
//   void _toggleMedication(String id, bool currentStatus) async {
//     await _medicationCollection.doc(id).update({'taken': !currentStatus});
//   }
//
//   void _deleteMedication(String id) async {
//     await _medicationCollection.doc(id).delete();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: const Text('Medication deleted'),
//         backgroundColor: const Color(0xFFEF4444),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       ),
//     );
//   }
//
//   void _addMedication() async {
//     TimeOfDay? selectedTime;
//
//     await showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           title: const Row(
//             children: [
//               Icon(Icons.medication, color: Color(0xFFB794F4)),
//               SizedBox(width: 12),
//               Text('Add Medication'),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: _medNameController,
//                 decoration: InputDecoration(
//                   labelText: 'Medication Name',
//                   prefixIcon: const Icon(Icons.local_pharmacy, color: Color(0xFFB794F4)),
//                   filled: true,
//                   fillColor: const Color(0xFFF9FAFB),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               GestureDetector(
//                 onTap: () async {
//                   final time = await showTimePicker(
//                     context: context,
//                     initialTime: TimeOfDay.now(),
//                   );
//                   if (time != null) {
//                     selectedTime = time;
//                     _medTimeController.text = time.format(context);
//                   }
//                 },
//                 child: AbsorbPointer(
//                   child: TextField(
//                     controller: _medTimeController,
//                     decoration: InputDecoration(
//                       labelText: 'Time (tap to select)',
//                       prefixIcon: const Icon(Icons.access_time, color: Color(0xFFB794F4)),
//                       filled: true,
//                       fillColor: const Color(0xFFF9FAFB),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 _medNameController.clear();
//                 _medTimeController.clear();
//                 Navigator.pop(context);
//               },
//               child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 final name = _medNameController.text.trim();
//                 if (name.isNotEmpty && selectedTime != null) {
//                   await _medicationCollection.add({
//                     'name': name,
//                     'time': _medTimeController.text,
//                     'taken': false,
//                   });
//
//                   await scheduleMedicationReminder(name, selectedTime!);
//
//                   _medNameController.clear();
//                   _medTimeController.clear();
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: const Text('Medication reminder added!'),
//                       backgroundColor: const Color(0xFF10B981),
//                       behavior: SnackBarBehavior.floating,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                     ),
//                   );
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Please fill all fields')),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFB794F4),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//               child: const Text('Add', style: TextStyle(color: Colors.white)),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> scheduleMedicationReminder(String medName, TimeOfDay time) async {
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'med_channel',
//       'Medication Reminder',
//       channelDescription: 'Reminder for taking medications',
//       importance: Importance.max,
//       priority: Priority.high,
//       playSound: true,
//       enableVibration: true,
//     );
//
//     const NotificationDetails notificationDetails =
//     NotificationDetails(android: androidDetails);
//
//     final now = tz.TZDateTime.now(tz.local);
//     tz.TZDateTime scheduledTime = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       time.hour,
//       time.minute,
//     );
//
//     if (scheduledTime.isBefore(now)) {
//       scheduledTime = scheduledTime.add(const Duration(days: 1));
//     }
//
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       medName.hashCode,
//       'Medication Reminder',
//       'Time to take $medName 💊',
//       scheduledTime,
//       notificationDetails,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//   }
//
//   @override
//   void dispose() {
//     _medNameController.dispose();
//     _medTimeController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         toolbarHeight: 80,
//         title: const Text('Medication Reminders'),
//         backgroundColor: const Color(0xFFB794F4),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.all(12),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: IconButton(
//                 icon: const Icon(Icons.add, color: Colors.white, size: 28),
//                 onPressed: _addMedication,
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _medicationCollection.snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(
//               child: CircularProgressIndicator(color: Color(0xFFB794F4)),
//             );
//           }
//
//           final meds = snapshot.data!.docs;
//
//           if (meds.isEmpty) {
//             return _buildEmptyState();
//           }
//
//           // Separate taken and not taken medications
//           final notTaken = meds
//               .where((med) => (med.data() as Map<String, dynamic>)['taken'] != true)
//               .toList();
//           final taken = meds
//               .where((med) => (med.data() as Map<String, dynamic>)['taken'] == true)
//               .toList();
//
//           return SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (notTaken.isNotEmpty) ...[
//                     _buildSectionTitle('Pending', Icons.schedule),
//                     const SizedBox(height: 12),
//                     ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: notTaken.length,
//                       itemBuilder: (context, index) {
//                         return _buildMedicationCard(notTaken[index], false);
//                       },
//                     ),
//                     const SizedBox(height: 24),
//                   ],
//                   if (taken.isNotEmpty) ...[
//                     _buildSectionTitle('Completed Today', Icons.check_circle_outline),
//                     const SizedBox(height: 12),
//                     ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: taken.length,
//                       itemBuilder: (context, index) {
//                         return _buildMedicationCard(taken[index], true);
//                       },
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildSectionTitle(String title, IconData icon) {
//     return Row(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(8),
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [Color(0xFFB794F4), Color(0xFFB794F4)],
//             ),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Icon(icon, color: Colors.white, size: 20),
//         ),
//         const SizedBox(width: 12),
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF1F2937),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildMedicationCard(QueryDocumentSnapshot med, bool isCompleted) {
//     final data = med.data() as Map<String, dynamic>;
//     final name = data['name'] ?? '';
//     final time = data['time'] ?? '';
//     final taken = data['taken'] ?? false;
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: taken ? const Color(0xFF10B981).withOpacity(0.3) : Colors.transparent,
//           width: 2,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListTile(
//         contentPadding: const EdgeInsets.all(16),
//         leading: GestureDetector(
//           onTap: () => _toggleMedication(med.id, taken),
//           child: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: taken
//                   ? const Color(0xFF10B981).withOpacity(0.1)
//                   : const Color(0xFFF3F4F6),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(
//               taken ? Icons.check_circle : Icons.radio_button_unchecked,
//               color: taken ? const Color(0xFF10B981) : Colors.grey,
//               size: 32,
//             ),
//           ),
//         ),
//         title: Text(
//           name,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.w600,
//             decoration: taken ? TextDecoration.lineThrough : null,
//             color: taken ? Colors.grey : const Color(0xFF1F2937),
//           ),
//         ),
//         subtitle: Row(
//           children: [
//             const Icon(Icons.access_time, size: 16, color: Color(0xFFB794F4)),
//             const SizedBox(width: 6),
//             Text(
//               time,
//               style: const TextStyle(
//                 color: Color(0xFFB794F4),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//         trailing: IconButton(
//           icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
//           onPressed: () => _deleteMedication(med.id),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(40),
//         child: Container(
//           padding: const EdgeInsets.all(40),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.1),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFCE7F3),
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(
//                   Icons.medication_outlined,
//                   size: 48,
//                   color: Color(0xFFB794F4),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'No medications added',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1F2937),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Add reminders for your medications',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey[600],
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 24),
//               ElevatedButton.icon(
//                 onPressed: _addMedication,
//                 icon: const Icon(Icons.add),
//                 label: const Text('Add Medication'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFFB794F4),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }