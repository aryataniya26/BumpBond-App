import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MilestoneScreen extends StatefulWidget {
  const MilestoneScreen({Key? key}) : super(key: key);

  @override
  State<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends State<MilestoneScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late CollectionReference _milestoneCollection;

  // Predefined milestones data
  final List<Map<String, dynamic>> _predefinedMilestones = [
    // First Trimester
    {
      'category': 'First Trimester (Weeks 1-13)',
      'color': const Color(0xFF4CAF50),
      'milestones': [
        {
          'title': 'Fertilization and implantation',
          'description': 'The beginning of your pregnancy journey',
          'week': 'Week 3-4',
          'icon': Icons.calendar_today,
        },
        {
          'title': 'Missed period & positive pregnancy test',
          'description': 'The exciting moment of discovery!',
          'week': 'Week 4-5',
          'icon': Icons.calendar_today,
        },
        {
          'title': 'First prenatal appointment',
          'description': 'Your first meeting with your healthcare provider',
          'week': 'Week 6-8',
          'icon': Icons.calendar_today,
        },
        {
          'title': 'Baby\'s heartbeat detectable',
          'description': 'Hearing your little one for the first time',
          'week': 'Week 8-10',
          'icon': Icons.calendar_today,
        },
        {
          'title': 'Morning sickness peaks',
          'description': 'The challenging but temporary phase',
          'week': 'Week 9',
          'icon': Icons.calendar_today,
        },
        {
          'title': 'End of first trimester',
          'description': 'A major milestone reached!',
          'week': 'Week 13',
          'icon': Icons.calendar_today,
        },
      ],
    },
    // Second Trimester
    {
      'category': 'Second Trimester (Weeks 14-27)',
      'color': const Color(0xFFFFA726),
      'milestones': [
        {
          'title': 'Nausea subsides, energy returns',
          'description': 'The "golden period" begins',
          'week': 'Week 14-15',
          'icon': Icons.calendar_today,
        },
        {
          'title': 'First ultrasound / anomaly scan',
          'description': 'Detailed look at your baby',
          'week': 'Week 18-20',
          'icon': Icons.calendar_today,
        },
        {
          'title': 'First baby movements felt (Quickening)',
          'description': 'Those magical first flutters',
          'week': 'Week 18-22',
          'icon': Icons.calendar_today,
        },
        {
          'title': 'Gender reveal (optional)',
          'description': 'Finding out if it\'s a boy or girl',
          'week': 'Week 18-20',
          'icon': Icons.calendar_today,
        },
        {
          'title': 'Baby starts hearing sounds',
          'description': 'Your voice becomes familiar',
          'week': 'Week 23-25',
          'icon': Icons.calendar_today,
        },
      ],
    },
    // Third Trimester
    {
      'category': 'Third Trimester (Weeks 28-40+)',
      'color': const Color(0xFFEF5350),
      'milestones': [
        {
          'title': 'Baby begins practicing breathing',
          'description': 'Preparing for life outside the womb',
          'week': 'Week 28-30',
          'icon': Icons.calendar_today,
        },
        {
          'title': 'Hospital bag checklist reminder',
          'description': 'Time to start preparing',
          'week': 'Week 32',
          'icon': Icons.calendar_today,
        },
        {
          'title': 'Baby\'s head-down position',
          'description': 'Getting ready for delivery',
          'week': 'Week 33-35',
          'icon': Icons.calendar_today,
        },
        {
          'title': 'Final prenatal checkups',
          'description': 'More frequent visits begin',
          'week': 'Week 36+',
          'icon': Icons.calendar_today,
        },
        {
          'title': 'Full term milestone',
          'description': 'Baby is considered full term',
          'week': 'Week 37-40',
          'icon': Icons.calendar_today,
        },
        {
          'title': 'Due date',
          'description': 'The big day arrives!',
          'week': 'Week 40',
          'icon': Icons.calendar_today,
        },
      ],
    },
    // Baby Growth Milestones
    {
      'category': '👶 Baby Growth Milestones',
      'color': const Color(0xFF42A5F5),
      'milestones': [
        {
          'title': 'Your baby is the size of a blueberry!',
          'description': 'Tiny but growing fast',
          'week': 'Week 7',
          'icon': Icons.emoji_emotions,
        },
        {
          'title': 'Tiny fingernails have formed!',
          'description': 'Amazing detail development',
          'week': 'Week 10',
          'icon': Icons.emoji_emotions,
        },
        {
          'title': 'Baby can now hear your voice',
          'description': 'Start talking and singing',
          'week': 'Week 24',
          'icon': Icons.emoji_emotions,
        },
        {
          'title': 'Lungs are maturing',
          'description': 'Preparing for first breath',
          'week': 'Week 36',
          'icon': Icons.emoji_emotions,
        },
      ],
    },
    // Emotional & Lifestyle Milestones
    {
      'category': '❤️ Emotional & Lifestyle Milestones',
      'color': const Color(0xFFEC407A),
      'milestones': [
        {
          'title': 'First time hearing the heartbeat',
          'description': 'An unforgettable moment',
          'week': 'Various',
          'icon': Icons.favorite,
        },
        {
          'title': 'Telling family and friends',
          'description': 'Sharing the wonderful news',
          'week': 'Various',
          'icon': Icons.favorite,
        },
        {
          'title': 'First kick felt',
          'description': 'Your baby says hello!',
          'week': 'Week 18-22',
          'icon': Icons.favorite,
        },
        {
          'title': 'First maternity clothes purchase',
          'description': 'Embracing the bump',
          'week': 'Various',
          'icon': Icons.favorite,
        },
        {
          'title': 'Baby shower date',
          'description': 'Celebrating with loved ones',
          'week': 'Week 28-32',
          'icon': Icons.favorite,
        },
        {
          'title': 'Starting maternity leave',
          'description': 'Time to focus on baby',
          'week': 'Various',
          'icon': Icons.favorite,
        },
        {
          'title': 'Packing hospital bag',
          'description': 'Getting ready for the big day',
          'week': 'Week 35-37',
          'icon': Icons.favorite,
        },
        {
          'title': 'Birth plan finalization',
          'description': 'Preparing for delivery',
          'week': 'Week 32-36',
          'icon': Icons.favorite,
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      _milestoneCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('milestones');
    }
  }

  Future<void> _toggleMilestone(String milestoneId, bool isCompleted) async {
    try {
      final doc = await _milestoneCollection.doc(milestoneId).get();
      if (doc.exists) {
        await _milestoneCollection.doc(milestoneId).update({
          'completed': !isCompleted,
        });
      } else {
        await _milestoneCollection.doc(milestoneId).set({
          'completed': true,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error toggling milestone: $e');
    }
  }

  Future<void> _addNote(String milestoneId, String currentNote) async {
    final TextEditingController noteController = TextEditingController(text: currentNote);

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Notes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Add your notes here...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB794F4),
                      ),
                      onPressed: () async {
                        if (noteController.text.trim().isNotEmpty) {
                          await _milestoneCollection.doc(milestoneId).set({
                            'note': noteController.text.trim(),
                            'timestamp': FieldValue.serverTimestamp(),
                          }, SetOptions(merge: true));
                        }
                        Navigator.pop(context);
                      },
                      child: const Text('Save'),
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

  void _showAddCustomMilestone() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Custom Milestone',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Milestone Title',
                  hintText: 'e.g., First prenatal yoga class',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Add any details about this milestone...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB794F4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        if (titleController.text.trim().isNotEmpty) {
                          await _milestoneCollection.add({
                            'title': titleController.text.trim(),
                            'description': descController.text.trim(),
                            'isCustom': true,
                            'completed': false,
                            'timestamp': FieldValue.serverTimestamp(),
                          });
                          // Auto close dialog after adding
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: const Text('Add Milestone'),
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

  Widget _buildCustomMilestones(AsyncSnapshot<QuerySnapshot> snapshot) {
    final customMilestones = snapshot.data?.docs
        .where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['isCustom'] == true;
    })
        .toList() ?? [];

    if (customMilestones.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Custom Milestones Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: const Color(0xFFB794F4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '🌟 Custom Milestones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
        // Custom Milestones List
        ...customMilestones.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final isCompleted = data['completed'] ?? false;
          final note = data['note'] ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isCompleted
                  ? Border.all(color: const Color(0xFF10B981), width: 2)
                  : null,
            ),
            child: Column(
              children: [
                ListTile(
                  leading: InkWell(
                    onTap: () => _toggleMilestone(doc.id, isCompleted),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted
                              ? const Color(0xFF10B981)
                              : const Color(0xFF9CA3AF),
                          width: 2,
                        ),
                        color: isCompleted
                            ? const Color(0xFF10B981)
                            : Colors.transparent,
                      ),
                      child: isCompleted
                          ? const Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.white,
                      )
                          : null,
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          data['title'] ?? 'Untitled',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isCompleted
                                ? const Color(0xFF10B981)
                                : const Color(0xFF1F2937),
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB794F4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              size: 12,
                              color: Color(0xFFB794F4),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Custom',
                              style: TextStyle(
                                fontSize: 12,
                                color: const Color(0xFFB794F4),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(
                    data['description'] ?? 'Your personal milestone',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: OutlinedButton(
                    onPressed: () => _addNote(doc.id, note),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 36),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    child: Text(
                      note.isEmpty ? 'Add Notes' : 'View/Edit Notes',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFB794F4), Color(0xFF9575CD)],
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Milestone Tracker',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Track your pregnancy journey',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddCustomMilestone,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Custom'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFB794F4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),

            // Milestones List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _milestoneCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  Map<String, bool> completedMilestones = {};
                  Map<String, String> notes = {};

                  if (snapshot.hasData) {
                    for (var doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      completedMilestones[doc.id] = data['completed'] ?? false;
                      notes[doc.id] = data['note'] ?? '';
                    }
                  }

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Custom Milestones Section
                      _buildCustomMilestones(snapshot),

                      // Predefined Milestones Sections
                      ...List.generate(
                        _predefinedMilestones.length,
                            (categoryIndex) {
                          final category = _predefinedMilestones[categoryIndex];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category Header
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: category['color'],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      category['category'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Milestones
                              ...List.generate(
                                (category['milestones'] as List).length,
                                    (index) {
                                  final milestone = category['milestones'][index];
                                  final milestoneId = '${categoryIndex}_$index';
                                  final isCompleted = completedMilestones[milestoneId] ?? false;
                                  final note = notes[milestoneId] ?? '';

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: isCompleted
                                          ? Border.all(color: const Color(0xFF10B981), width: 2)
                                          : null,
                                    ),
                                    child: Column(
                                      children: [
                                        ListTile(
                                          leading: InkWell(
                                            onTap: () => _toggleMilestone(milestoneId, isCompleted),
                                            child: Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: isCompleted
                                                      ? const Color(0xFF10B981)
                                                      : const Color(0xFF9CA3AF),
                                                  width: 2,
                                                ),
                                                color: isCompleted
                                                    ? const Color(0xFF10B981)
                                                    : Colors.transparent,
                                              ),
                                              child: isCompleted
                                                  ? const Icon(
                                                Icons.check,
                                                size: 16,
                                                color: Colors.white,
                                              )
                                                  : null,
                                            ),
                                          ),
                                          title: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  milestone['title'],
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    color: isCompleted
                                                        ? const Color(0xFF10B981)
                                                        : const Color(0xFF1F2937),
                                                    decoration: isCompleted
                                                        ? TextDecoration.lineThrough
                                                        : null,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: category['color'].withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      milestone['icon'],
                                                      size: 12,
                                                      color: category['color'],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      milestone['week'],
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: category['color'],
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          subtitle: Text(
                                            milestone['description'],
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                          child: OutlinedButton(
                                            onPressed: () => _addNote(milestoneId, note),
                                            style: OutlinedButton.styleFrom(
                                              minimumSize: const Size(double.infinity, 36),
                                              side: const BorderSide(color: Color(0xFFE5E7EB)),
                                            ),
                                            child: Text(
                                              note.isEmpty ? 'Add Notes' : 'View/Edit Notes',
                                              style: const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                            ],
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}