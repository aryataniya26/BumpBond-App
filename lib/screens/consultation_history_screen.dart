import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ConsultationHistoryScreen extends StatefulWidget {
  const ConsultationHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ConsultationHistoryScreen> createState() =>
      _ConsultationHistoryScreenState();
}

class _ConsultationHistoryScreenState
    extends State<ConsultationHistoryScreen> {
  List<Map<String, dynamic>> consultationHistory = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();

    // Load booked consultations
    final bookingsJson = prefs.getStringList('bookings') ?? [];

    List<Map<String, dynamic>> history = [];

    // Convert bookings to history format
    for (String booking in bookingsJson) {
      try {
        final parts = booking.split('|');
        if (parts.length >= 4) {
          history.add({
            'type': parts[3], // consultation type
            'doctor': parts.length > 5 ? parts[5] : 'Dr. Not Assigned', // Updated
            'date': parts[0], // dd/MM/yyyy
            'time': parts[1],
            'duration': parts[2],
            'rating': 0,
            'notes': '',
            'status': 'booked',
            'icon': _getIconForType(parts[3]),
          });
        }      } catch (e) {
        print('Error parsing booking: $e');
      }
    }

    // Load completed consultations (if any saved separately)
    final completedJson = prefs.getStringList('consultation_history') ?? [];
    for (String completed in completedJson) {
      try {
        final parts = completed.split('|||');
        if (parts.length >= 7) {
          history.add({
            'type': parts[0],
            'doctor': parts[1],
            'date': parts[2],
            'time': parts[3],
            'duration': parts[4],
            'rating': int.tryParse(parts[5]) ?? 0,
            'notes': parts[6],
            'status': 'completed',
            'icon': _getIconForType(parts[0]),
          });
        }
      } catch (e) {
        print('Error parsing completed consultation: $e');
      }
    }

    // Sort by date (newest first)
    history.sort((a, b) {
      try {
        final dateA = DateFormat('dd/MM/yyyy').parse(a['date']);
        final dateB = DateFormat('dd/MM/yyyy').parse(b['date']);
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    setState(() {
      consultationHistory = history;
      loading = false;
    });
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'general checkup':
      case 'ob-gyn':
        return Icons.videocam_outlined;
      case 'nutrition counseling':
      case 'nutrition':
        return Icons.chat_bubble_outline;
      case 'lactation support':
        return Icons.phone_outlined;
      case 'prenatal exercise':
        return Icons.fitness_center;
      case 'mental health support':
        return Icons.favorite_outline;
      case 'labor preparation':
        return Icons.local_hospital;
      default:
        return Icons.calendar_today;
    }
  }

  Widget _buildStarRating(int rating) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_outline,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  Future<void> _deleteConsultation(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final consultation = consultationHistory[index];

    // Delete from appropriate storage
    if (consultation['status'] == 'booked') {
      final bookingsJson = prefs.getStringList('bookings') ?? [];
// _deleteConsultation function mein:
      bookingsJson.removeWhere((booking) {
        try {
          final parts = booking.split('|');
          return parts.length >= 4 &&
              parts[0] == consultation['date'] &&
              parts[1] == consultation['time'] &&
              parts[3] == consultation['type'];
        } catch (e) {
          return false;
        }
      });      await prefs.setStringList('bookings', bookingsJson);
    } else {
      final historyJson = prefs.getStringList('consultation_history') ?? [];
      historyJson.removeAt(index);
      await prefs.setStringList('consultation_history', historyJson);
    }

    setState(() => consultationHistory.removeAt(index));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Consultation removed')),
    );
  }

  Future<void> _markAsCompleted(int index) async {
    final consultation = consultationHistory[index];

    // Show dialog to add rating and notes
    showDialog(
      context: context,
      builder: (context) => _CompletionDialog(
        consultation: consultation,
        onSave: (rating, notes, doctor) async {
          // Move from booked to completed
          final prefs = await SharedPreferences.getInstance();

          // Remove from bookings
          final bookingsJson = prefs.getStringList('bookings') ?? [];
          bookingsJson.removeWhere((booking) {
            try {
              final parts = booking.split('|');
              return parts.length >= 4 &&
                  parts[0] == consultation['date'] &&
                  parts[1] == consultation['time'] &&
                  parts[3] == consultation['type'];
            } catch (e) {
              return false;
            }
          });
          await prefs.setStringList('bookings', bookingsJson);

          // Add to completed
          final completedStr =
              '${consultation['type']}|||$doctor|||${consultation['date']}|||${consultation['time']}|||${consultation['duration']}|||$rating|||$notes';
          final history = prefs.getStringList('consultation_history') ?? [];
          history.add(completedStr);
          await prefs.setStringList('consultation_history', history);

          Navigator.pop(context);
          _loadHistory();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Consultation marked as completed')),
          );
        },
      ),
    );
  }

  void _viewDetails(Map<String, dynamic> consultation) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Consultation Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _detailRow('Type', consultation['type']),
            _detailRow('Doctor', consultation['doctor']),
            _detailRow('Date', consultation['date']),
            _detailRow('Time', consultation['time']),
            _detailRow('Duration', consultation['duration']),
            _detailRow('Status', consultation['status']),
            const SizedBox(height: 16),
            if (consultation['notes'].isNotEmpty) ...[
              const Text(
                'Notes',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                consultation['notes'],
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 20),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Consultation History'),
          backgroundColor: const Color(0xFF6366F1),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation History'),
        backgroundColor: const Color(0xFF6366F1),
        elevation: 0,
      ),
      body: consultationHistory.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No consultation bookings yet',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: consultationHistory.length,
        itemBuilder: (context, index) {
          final consultation = consultationHistory[index];
          final isBooked = consultation['status'] == 'booked';
          final isCompleted = consultation['status'] == 'completed';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          consultation['icon'],
                          color: const Color(0xFF6366F1),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              consultation['type'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              consultation['doctor'],
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? const Color(0xFF10B981).withOpacity(0.15)
                              : const Color(0xFFF59E0B).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isCompleted ? 'completed' : 'booked',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isCompleted
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Date and Time
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Text(
                              'Date: ${consultation['date']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 6),
                            Text(
                              'Time: ${consultation['time']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Duration and Rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Duration: ${consultation['duration']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      if (isCompleted)
                        Expanded(
                          child: Row(
                            children: [
                              const Text(
                                'Rating: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              _buildStarRating(consultation['rating']),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (consultation['notes'].isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Notes: ${consultation['notes']}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              _viewDetails(consultation),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF6366F1),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'View Details',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        ),
                      ),
                      if (isBooked) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                _markAsCompleted(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color(0xFF6366F1),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Complete',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () =>
                            _deleteConsultation(index),
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Completion Dialog
class _CompletionDialog extends StatefulWidget {
  final Map<String, dynamic> consultation;
  final Function(int, String, String) onSave;

  const _CompletionDialog({
    required this.consultation,
    required this.onSave,
  });

  @override
  State<_CompletionDialog> createState() => _CompletionDialogState();
}

class _CompletionDialogState extends State<_CompletionDialog> {
  int selectedRating = 0;
  String doctorName = '';
  String notes = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Mark as Completed'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Doctor Name:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              onChanged: (value) => doctorName = value,
              decoration: InputDecoration(
                hintText: 'Enter doctor name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Rating:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () => setState(() => selectedRating = index + 1),
                  icon: Icon(
                    index < selectedRating ? Icons.star : Icons.star_outline,
                    color: Colors.amber,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              onChanged: (value) => notes = value,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add notes about consultation',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (doctorName.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter doctor name')),
              );
              return;
            }
            widget.onSave(selectedRating, notes, doctorName);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}