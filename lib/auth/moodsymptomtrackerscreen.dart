import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MoodSymptomTrackerScreen extends StatefulWidget {
  const MoodSymptomTrackerScreen({Key? key}) : super(key: key);

  @override
  State<MoodSymptomTrackerScreen> createState() => _MoodSymptomTrackerScreenState();
}

class _MoodSymptomTrackerScreenState extends State<MoodSymptomTrackerScreen> {
  int? _selectedMood;
  final List<Map<String, dynamic>> _moods = [
    {'emoji': '😊', 'label': 'Great', 'color': Color(0xFF10B981)},
    {'emoji': '😌', 'label': 'Good', 'color': Color(0xFF3B82F6)},
    {'emoji': '😐', 'label': 'Okay', 'color': Color(0xFFF59E0B)},
    {'emoji': '😔', 'label': 'Low', 'color': Color(0xFFEF4444)},
    {'emoji': '😫', 'label': 'Bad', 'color': Color(0xFF991B1B)},
  ];

  final List<Map<String, dynamic>> _symptoms = [
    {'name': 'Nausea', 'icon': Icons.sick_outlined},
    {'name': 'Fatigue', 'icon': Icons.bedtime_outlined},
    {'name': 'Headache', 'icon': Icons.psychology_outlined},
    {'name': 'Back pain', 'icon': Icons.accessibility_new_outlined},
    {'name': 'Cramps', 'icon': Icons.favorite_outlined},
    {'name': 'None', 'icon': Icons.check_circle_outline},
  ];

  final Set<String> _selectedSymptoms = {};
  final TextEditingController _notesController = TextEditingController();
  final CollectionReference _healthCollection =
  FirebaseFirestore.instance.collection('health_tracker');

  void _saveHealthEntry() async {
    if (_selectedMood == null &&
        _selectedSymptoms.isEmpty &&
        _notesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one field'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    await _healthCollection.add({
      'mood': _selectedMood,
      'symptoms': _selectedSymptoms.toList(),
      'notes': _notesController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _selectedMood = null;
      _selectedSymptoms.clear();
      _notesController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Health entry saved successfully!'),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _deleteHealthEntry(String id) async {
    await _healthCollection.doc(id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Entry deleted'),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Mood & Symptoms'),
        backgroundColor: const Color(0xFFB794F4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mood Section
                  _buildSectionTitle('How are you feeling today?', Icons.mood),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        _moods.length,
                            (index) => GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMood = index;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _selectedMood == index
                                      ? _moods[index]['color'].withOpacity(0.15)
                                      : const Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: _selectedMood == index
                                        ? _moods[index]['color']
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Text(
                                  _moods[index]['emoji'],
                                  style: const TextStyle(fontSize: 32),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _moods[index]['label'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _selectedMood == index
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _selectedMood == index
                                      ? _moods[index]['color']
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Symptoms Section
                  _buildSectionTitle('Any symptoms?', Icons.health_and_safety),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _symptoms.map((symptom) {
                        final isSelected = _selectedSymptoms.contains(symptom['name']);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected)
                                _selectedSymptoms.remove(symptom['name']);
                              else
                                _selectedSymptoms.add(symptom['name']);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                colors: [Color(0xFFC239B3), Color(0xFFE91E63)],
                              )
                                  : null,
                              color: isSelected ? null : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  symptom['icon'],
                                  size: 18,
                                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  symptom['name'],
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Notes Section
                  _buildSectionTitle('Additional Notes', Icons.edit_note),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Any additional notes about how you\'re feeling...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB794F4), Color(0xFFA78BFA)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFB794F4).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _saveHealthEntry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_rounded, color: Colors.white),
                          SizedBox(width: 12),
                          Text(
                            'Save Entry',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Health History
                  _buildSectionTitle('Health History', Icons.history),
                  const SizedBox(height: 16),
                  StreamBuilder<QuerySnapshot>(
                    stream: _healthCollection
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return _buildEmptyState(
                          'No health entries yet',
                          'Start tracking your health today!',
                          Icons.favorite_border,
                        );
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final moodIndex = data['mood'] as int?;
                          final mood = moodIndex != null && moodIndex < _moods.length
                              ? _moods[moodIndex]['emoji']
                              : '🙂';
                          final symptoms = List<String>.from(data['symptoms'] ?? []);
                          final notes = data['notes'] ?? '';
                          final timestamp = data['timestamp'] as Timestamp?;
                          final date = timestamp != null
                              ? DateFormat('MMM dd, yyyy - hh:mm a')
                              .format(timestamp.toDate())
                              : 'Unknown date';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFCE7F3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(mood, style: const TextStyle(fontSize: 28)),
                              ),
                              title: Text(
                                symptoms.isNotEmpty ? symptoms.join(', ') : 'No symptoms',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  if (notes.isNotEmpty)
                                    Text(
                                      notes,
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 13,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.access_time,
                                          size: 14, color: Colors.grey[500]),
                                      const SizedBox(width: 4),
                                      Text(
                                        date,
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Color(0xFFEF4444)),
                                onPressed: () => _deleteHealthEntry(doc.id),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFB794F4), Color(0xFFB794F4)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
              color: const Color(0xFFFCE7F3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: const Color(0xFFB794F4)),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}