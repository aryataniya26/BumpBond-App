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



// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class MilestoneScreen extends StatefulWidget {
//   const MilestoneScreen({Key? key}) : super(key: key);
//
//   @override
//   State<MilestoneScreen> createState() => _MilestoneScreenState();
// }
//
// class _MilestoneScreenState extends State<MilestoneScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   late CollectionReference _milestoneCollection;
//   bool _showAddCustomDialog = false;
//
//   // Predefined milestones data
//   final List<Map<String, dynamic>> _predefinedMilestones = [
//     // First Trimester
//     {
//       'category': 'First Trimester (Weeks 1-13)',
//       'color': const Color(0xFF4CAF50),
//       'milestones': [
//         {
//           'title': 'Fertilization and implantation',
//           'description': 'The beginning of your pregnancy journey',
//           'week': 'Week 3-4',
//           'icon': Icons.calendar_today,
//         },
//         {
//           'title': 'Missed period & positive pregnancy test',
//           'description': 'The exciting moment of discovery!',
//           'week': 'Week 4-5',
//           'icon': Icons.calendar_today,
//         },
//         {
//           'title': 'First prenatal appointment',
//           'description': 'Your first meeting with your healthcare provider',
//           'week': 'Week 6-8',
//           'icon': Icons.calendar_today,
//         },
//         {
//           'title': 'Baby\'s heartbeat detectable',
//           'description': 'Hearing your little one for the first time',
//           'week': 'Week 8-10',
//           'icon': Icons.calendar_today,
//         },
//         {
//           'title': 'Morning sickness peaks',
//           'description': 'The challenging but temporary phase',
//           'week': 'Week 9',
//           'icon': Icons.calendar_today,
//         },
//         {
//           'title': 'End of first trimester',
//           'description': 'A major milestone reached!',
//           'week': 'Week 13',
//           'icon': Icons.calendar_today,
//         },
//       ],
//     },
//     // Second Trimester
//     {
//       'category': 'Second Trimester (Weeks 14-27)',
//       'color': const Color(0xFFFFA726),
//       'milestones': [
//         {
//           'title': 'Nausea subsides, energy returns',
//           'description': 'The "golden period" begins',
//           'week': 'Week 14-15',
//           'icon': Icons.calendar_today,
//         },
//         {
//           'title': 'First ultrasound / anomaly scan',
//           'description': 'Detailed look at your baby',
//           'week': 'Week 18-20',
//           'icon': Icons.calendar_today,
//         },
//         {
//           'title': 'First baby movements felt (Quickening)',
//           'description': 'Those magical first flutters',
//           'week': 'Week 18-22',
//           'icon': Icons.calendar_today,
//         },
//         {
//           'title': 'Gender reveal (optional)',
//           'description': 'Finding out if it\'s a boy or girl',
//           'week': 'Week 18-20',
//           'icon': Icons.calendar_today,
//         },
//         {
//           'title': 'Baby starts hearing sounds',
//           'description': 'Your voice becomes familiar',
//           'week': 'Week 23-25',
//           'icon': Icons.calendar_today,
//         },
//       ],
//     },
//     // Third Trimester
//     {
//       'category': 'Third Trimester (Weeks 28-40+)',
//       'color': const Color(0xFFEF5350),
//       'milestones': [
//         {
//           'title': 'Baby begins practicing breathing',
//           'description': 'Preparing for life outside the womb',
//           'week': 'Week 28-30',
//           'icon': Icons.calendar_today,
//         },
//         {
//           'title': 'Hospital bag checklist reminder',
//           'description': 'Time to start preparing',
//           'week': 'Week 32',
//           'icon': Icons.calendar_today,
//         },
//         {
//           'title': 'Baby\'s head-down position',
//           'description': 'Getting ready for delivery',
//           'week': 'Week 33-35',
//           'icon': Icons.calendar_today,
//         },
//         {
//           'title': 'Final prenatal checkups',
//           'description': 'More frequent visits begin',
//           'week': 'Week 36+',
//           'icon': Icons.calendar_today,
//         },
//         {
//           'title': 'Full term milestone',
//           'description': 'Baby is considered full term',
//           'week': 'Week 37-40',
//           'icon': Icons.calendar_today,
//         },
//         {
//           'title': 'Due date',
//           'description': 'The big day arrives!',
//           'week': 'Week 40',
//           'icon': Icons.calendar_today,
//         },
//       ],
//     },
//     // Baby Growth Milestones
//     {
//       'category': '👶 Baby Growth Milestones',
//       'color': const Color(0xFF42A5F5),
//       'milestones': [
//         {
//           'title': 'Your baby is the size of a blueberry!',
//           'description': 'Tiny but growing fast',
//           'week': 'Week 7',
//           'icon': Icons.emoji_emotions,
//         },
//         {
//           'title': 'Tiny fingernails have formed!',
//           'description': 'Amazing detail development',
//           'week': 'Week 10',
//           'icon': Icons.emoji_emotions,
//         },
//         {
//           'title': 'Baby can now hear your voice',
//           'description': 'Start talking and singing',
//           'week': 'Week 24',
//           'icon': Icons.emoji_emotions,
//         },
//         {
//           'title': 'Lungs are maturing',
//           'description': 'Preparing for first breath',
//           'week': 'Week 36',
//           'icon': Icons.emoji_emotions,
//         },
//       ],
//     },
//     // Emotional & Lifestyle Milestones
//     {
//       'category': '❤️ Emotional & Lifestyle Milestones',
//       'color': const Color(0xFFEC407A),
//       'milestones': [
//         {
//           'title': 'First time hearing the heartbeat',
//           'description': 'An unforgettable moment',
//           'week': 'Various',
//           'icon': Icons.favorite,
//         },
//         {
//           'title': 'Telling family and friends',
//           'description': 'Sharing the wonderful news',
//           'week': 'Various',
//           'icon': Icons.favorite,
//         },
//         {
//           'title': 'First kick felt',
//           'description': 'Your baby says hello!',
//           'week': 'Week 18-22',
//           'icon': Icons.favorite,
//         },
//         {
//           'title': 'First maternity clothes purchase',
//           'description': 'Embracing the bump',
//           'week': 'Various',
//           'icon': Icons.favorite,
//         },
//         {
//           'title': 'Baby shower date',
//           'description': 'Celebrating with loved ones',
//           'week': 'Week 28-32',
//           'icon': Icons.favorite,
//         },
//         {
//           'title': 'Starting maternity leave',
//           'description': 'Time to focus on baby',
//           'week': 'Various',
//           'icon': Icons.favorite,
//         },
//         {
//           'title': 'Packing hospital bag',
//           'description': 'Getting ready for the big day',
//           'week': 'Week 35-37',
//           'icon': Icons.favorite,
//         },
//         {
//           'title': 'Birth plan finalization',
//           'description': 'Preparing for delivery',
//           'week': 'Week 32-36',
//           'icon': Icons.favorite,
//         },
//       ],
//     },
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     final user = _auth.currentUser;
//     if (user != null) {
//       _milestoneCollection = FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('milestones');
//     }
//   }
//
//   Future<void> _toggleMilestone(String milestoneId, bool isCompleted) async {
//     try {
//       final doc = await _milestoneCollection.doc(milestoneId).get();
//       if (doc.exists) {
//         await _milestoneCollection.doc(milestoneId).update({
//           'completed': !isCompleted,
//         });
//       } else {
//         await _milestoneCollection.doc(milestoneId).set({
//           'completed': true,
//           'timestamp': FieldValue.serverTimestamp(),
//         });
//       }
//     } catch (e) {
//       print('Error toggling milestone: $e');
//     }
//   }
//
//   Future<void> _addNote(String milestoneId, String currentNote) async {
//     final TextEditingController noteController = TextEditingController(text: currentNote);
//
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 'Add Notes',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: noteController,
//                 maxLines: 4,
//                 decoration: InputDecoration(
//                   hintText: 'Add your notes here...',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text('Cancel'),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFB794F4),
//                       ),
//                       onPressed: () async {
//                         await _milestoneCollection.doc(milestoneId).set({
//                           'note': noteController.text,
//                           'timestamp': FieldValue.serverTimestamp(),
//                         }, SetOptions(merge: true));
//                         Navigator.pop(context);
//                       },
//                       child: const Text('Save'),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showAddCustomMilestone() {
//     final TextEditingController titleController = TextEditingController();
//     final TextEditingController descController = TextEditingController();
//
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Text(
//                 'Add Custom Milestone',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: titleController,
//                 decoration: InputDecoration(
//                   labelText: 'Milestone Title',
//                   hintText: 'e.g., First prenatal yoga class',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 controller: descController,
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                   labelText: 'Description (optional)',
//                   hintText: 'Add any details about this milestone...',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text('Cancel'),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFB794F4),
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                       ),
//                       onPressed: () async {
//                         if (titleController.text.trim().isNotEmpty) {
//                           await _milestoneCollection.add({
//                             'title': titleController.text.trim(),
//                             'description': descController.text.trim(),
//                             'isCustom': true,
//                             'completed': false,
//                             'timestamp': FieldValue.serverTimestamp(),
//                           });
//                           Navigator.pop(context);
//                         }
//                       },
//                       child: const Text('Add Milestone'),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF3E5F5),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Color(0xFFB794F4), Color(0xFF9575CD)],
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.arrow_back, color: Colors.white),
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                   const Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Milestone Tracker',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         SizedBox(height: 4),
//                         Text(
//                           'Track your pregnancy journey',
//                           style: TextStyle(
//                             color: Colors.white70,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   ElevatedButton.icon(
//                     onPressed: _showAddCustomMilestone,
//                     icon: const Icon(Icons.add, size: 18),
//                     label: const Text('Add Custom'),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.white,
//                       foregroundColor: const Color(0xFFB794F4),
//                       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Milestones List
//             Expanded(
//               child: StreamBuilder<QuerySnapshot>(
//                 stream: _milestoneCollection.snapshots(),
//                 builder: (context, snapshot) {
//                   Map<String, bool> completedMilestones = {};
//                   Map<String, String> notes = {};
//
//                   if (snapshot.hasData) {
//                     for (var doc in snapshot.data!.docs) {
//                       final data = doc.data() as Map<String, dynamic>;
//                       completedMilestones[doc.id] = data['completed'] ?? false;
//                       notes[doc.id] = data['note'] ?? '';
//                     }
//                   }
//
//                   return ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: _predefinedMilestones.length,
//                     itemBuilder: (context, categoryIndex) {
//                       final category = _predefinedMilestones[categoryIndex];
//                       return Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Category Header
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             child: Row(
//                               children: [
//                                 Container(
//                                   width: 16,
//                                   height: 16,
//                                   decoration: BoxDecoration(
//                                     color: category['color'],
//                                     borderRadius: BorderRadius.circular(4),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   category['category'],
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF1F2937),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           // Milestones
//                           ...List.generate(
//                             (category['milestones'] as List).length,
//                                 (index) {
//                               final milestone = category['milestones'][index];
//                               final milestoneId = '${categoryIndex}_$index';
//                               final isCompleted = completedMilestones[milestoneId] ?? false;
//                               final note = notes[milestoneId] ?? '';
//
//                               return Container(
//                                 margin: const EdgeInsets.only(bottom: 12),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(16),
//                                   border: isCompleted
//                                       ? Border.all(color: const Color(0xFF10B981), width: 2)
//                                       : null,
//                                 ),
//                                 child: Column(
//                                   children: [
//                                     ListTile(
//                                       leading: InkWell(
//                                         onTap: () => _toggleMilestone(milestoneId, isCompleted),
//                                         child: Container(
//                                           width: 24,
//                                           height: 24,
//                                           decoration: BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             border: Border.all(
//                                               color: isCompleted
//                                                   ? const Color(0xFF10B981)
//                                                   : const Color(0xFF9CA3AF),
//                                               width: 2,
//                                             ),
//                                             color: isCompleted
//                                                 ? const Color(0xFF10B981)
//                                                 : Colors.transparent,
//                                           ),
//                                           child: isCompleted
//                                               ? const Icon(
//                                             Icons.check,
//                                             size: 16,
//                                             color: Colors.white,
//                                           )
//                                               : null,
//                                         ),
//                                       ),
//                                       title: Row(
//                                         children: [
//                                           Expanded(
//                                             child: Text(
//                                               milestone['title'],
//                                               style: TextStyle(
//                                                 fontWeight: FontWeight.w600,
//                                                 color: isCompleted
//                                                     ? const Color(0xFF10B981)
//                                                     : const Color(0xFF1F2937),
//                                                 decoration: isCompleted
//                                                     ? TextDecoration.lineThrough
//                                                     : null,
//                                               ),
//                                             ),
//                                           ),
//                                           Container(
//                                             padding: const EdgeInsets.symmetric(
//                                               horizontal: 8,
//                                               vertical: 4,
//                                             ),
//                                             decoration: BoxDecoration(
//                                               color: category['color'].withOpacity(0.1),
//                                               borderRadius: BorderRadius.circular(8),
//                                             ),
//                                             child: Row(
//                                               mainAxisSize: MainAxisSize.min,
//                                               children: [
//                                                 Icon(
//                                                   milestone['icon'],
//                                                   size: 12,
//                                                   color: category['color'],
//                                                 ),
//                                                 const SizedBox(width: 4),
//                                                 Text(
//                                                   milestone['week'],
//                                                   style: TextStyle(
//                                                     fontSize: 12,
//                                                     color: category['color'],
//                                                     fontWeight: FontWeight.w500,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       subtitle: Text(
//                                         milestone['description'],
//                                         style: const TextStyle(
//                                           fontSize: 13,
//                                           color: Color(0xFF6B7280),
//                                         ),
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//                                       child: OutlinedButton(
//                                         onPressed: () => _addNote(milestoneId, note),
//                                         style: OutlinedButton.styleFrom(
//                                           minimumSize: const Size(double.infinity, 36),
//                                           side: const BorderSide(color: Color(0xFFE5E7EB)),
//                                         ),
//                                         child: Text(
//                                           note.isEmpty ? 'Add Notes' : 'View/Edit Notes',
//                                           style: const TextStyle(fontSize: 13),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//                             },
//                           ),
//                           const SizedBox(height: 8),
//                         ],
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// // import 'package:flutter/material.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:intl/intl.dart';
// //
// // class MilestoneScreen extends StatefulWidget {
// //   const MilestoneScreen({Key? key}) : super(key: key);
// //
// //   @override
// //   State<MilestoneScreen> createState() => _MilestoneScreenState();
// // }
// //
// // class _MilestoneScreenState extends State<MilestoneScreen> with SingleTickerProviderStateMixin {
// //   final TextEditingController _milestoneController = TextEditingController();
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   late CollectionReference _milestoneCollection;
// //   late AnimationController _animationController;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     final user = _auth.currentUser;
// //     if (user != null) {
// //       _milestoneCollection = FirebaseFirestore.instance
// //           .collection('users')
// //           .doc(user.uid)
// //           .collection('milestones');
// //     }
// //
// //     _animationController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 300),
// //     );
// //   }
// //
// //   @override
// //   void dispose() {
// //     _milestoneController.dispose();
// //     _animationController.dispose();
// //     super.dispose();
// //   }
// //
// //   void _addMilestone() async {
// //     final text = _milestoneController.text.trim();
// //     if (text.isEmpty) {
// //       _showSnackBar('Please enter a milestone', isError: true);
// //       return;
// //     }
// //
// //     await _milestoneCollection.add({
// //       'title': text,
// //       'completed': false,
// //       'timestamp': FieldValue.serverTimestamp(),
// //     });
// //
// //     _milestoneController.clear();
// //     _showSnackBar('Milestone added successfully!');
// //   }
// //
// //   void _toggleMilestone(String id, bool currentStatus) async {
// //     await _milestoneCollection.doc(id).update({'completed': !currentStatus});
// //   }
// //
// //   void _deleteMilestone(String id) async {
// //     showDialog(
// //       context: context,
// //       builder: (context) => AlertDialog(
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
// //         title: const Row(
// //           children: [
// //             Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
// //             SizedBox(width: 12),
// //             Text('Delete Milestone?'),
// //           ],
// //         ),
// //         content: const Text(
// //           'Are you sure you want to delete this milestone? This action cannot be undone.',
// //           style: TextStyle(color: Color(0xFF6B7280)),
// //         ),
// //         actions: [
// //           TextButton(
// //             onPressed: () => Navigator.pop(context),
// //             child: const Text('Cancel'),
// //           ),
// //           ElevatedButton(
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: const Color(0xFFEF4444),
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(10),
// //               ),
// //             ),
// //             onPressed: () async {
// //               await _milestoneCollection.doc(id).delete();
// //               Navigator.pop(context);
// //               _showSnackBar('Milestone deleted');
// //             },
// //             child: const Text('Delete'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   void _editMilestone(String id, String currentTitle) {
// //     final TextEditingController editController = TextEditingController(text: currentTitle);
// //
// //     showDialog(
// //       context: context,
// //       builder: (context) => Dialog(
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
// //         child: Container(
// //           padding: const EdgeInsets.all(24),
// //           decoration: BoxDecoration(
// //             gradient: const LinearGradient(
// //               begin: Alignment.topLeft,
// //               end: Alignment.bottomRight,
// //               colors: [Color(0xFFFFF5F7), Color(0xFFFFE5EC)],
// //             ),
// //             borderRadius: BorderRadius.circular(24),
// //           ),
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               Container(
// //                 width: 60,
// //                 height: 60,
// //                 decoration: BoxDecoration(
// //                   gradient: const LinearGradient(
// //                     colors: [Color(0xFFB794F4),Color(0xFFB794F4) ],
// //                   ),
// //                   borderRadius: BorderRadius.circular(30),
// //                 ),
// //                 child: const Icon(Icons.edit, color: Colors.white, size: 30),
// //               ),
// //               const SizedBox(height: 16),
// //               const Text(
// //                 'Edit Milestone',
// //                 style: TextStyle(
// //                   fontSize: 24,
// //                   fontWeight: FontWeight.bold,
// //                   color: Color(0xFF1F2937),
// //                 ),
// //               ),
// //               const SizedBox(height: 24),
// //               TextField(
// //                 controller: editController,
// //                 autofocus: true,
// //                 decoration: InputDecoration(
// //                   labelText: 'Milestone',
// //                   hintText: 'Update your milestone',
// //                   prefixIcon: const Icon(Icons.flag, color: Color(0xFFB794F4)),
// //                   filled: true,
// //                   fillColor: Colors.white,
// //                   border: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(16),
// //                     borderSide: BorderSide.none,
// //                   ),
// //                   focusedBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(16),
// //                     borderSide: const BorderSide(color: Color(0xFFB794F4), width: 2),
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 24),
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     child: OutlinedButton(
// //                       style: OutlinedButton.styleFrom(
// //                         foregroundColor: const Color(0xFF6B7280),
// //                         side: const BorderSide(color: Color(0xFFE5E7EB)),
// //                         padding: const EdgeInsets.symmetric(vertical: 14),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(12),
// //                         ),
// //                       ),
// //                       onPressed: () => Navigator.pop(context),
// //                       child: const Text('Cancel'),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   Expanded(
// //                     child: ElevatedButton(
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: const Color(0xFFB794F4),
// //                         padding: const EdgeInsets.symmetric(vertical: 14),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(12),
// //                         ),
// //                       ),
// //                       onPressed: () async {
// //                         final newTitle = editController.text.trim();
// //                         if (newTitle.isNotEmpty) {
// //                           await _milestoneCollection.doc(id).update({'title': newTitle});
// //                           Navigator.pop(context);
// //                           _showSnackBar('Milestone updated!');
// //                         }
// //                       },
// //                       child: const Text('Update'),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   void _showSnackBar(String message, {bool isError = false}) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Row(
// //           children: [
// //             Icon(
// //               isError ? Icons.error_outline : Icons.check_circle_outline,
// //               color: Colors.white,
// //             ),
// //             const SizedBox(width: 12),
// //             Expanded(child: Text(message)),
// //           ],
// //         ),
// //         backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
// //         behavior: SnackBarBehavior.floating,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       ),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFFFF5F7),
// //       body: SafeArea(
// //         child: Column(
// //           children: [
// //             // Header
// //             Container(
// //               margin: const EdgeInsets.all(20),
// //               padding: const EdgeInsets.all(28),
// //               decoration: BoxDecoration(
// //                 gradient: const LinearGradient(
// //                   begin: Alignment.topLeft,
// //                   end: Alignment.bottomRight,
// //                   colors: [Color(0xFFB794F4), Color(0xFFB794F4)],
// //                 ),
// //                 borderRadius: BorderRadius.circular(24),
// //                 boxShadow: [
// //                   BoxShadow(
// //                     color: Colors.pink.withOpacity(0.4),
// //                     blurRadius: 20,
// //                     offset: const Offset(0, 8),
// //                   ),
// //                 ],
// //               ),
// //               child: Column(
// //                 children: [
// //                   Row(
// //                     children: [
// //                       Container(
// //                         padding: const EdgeInsets.all(12),
// //                         decoration: BoxDecoration(
// //                           color: Colors.white.withOpacity(0.2),
// //                           borderRadius: BorderRadius.circular(16),
// //                         ),
// //                         child: const Icon(
// //                           Icons.emoji_events_rounded,
// //                           color: Colors.white,
// //                           size: 32,
// //                         ),
// //                       ),
// //                       const SizedBox(width: 16),
// //                       const Expanded(
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Text(
// //                               'Milestones',
// //                               style: TextStyle(
// //                                 color: Colors.white,
// //                                 fontSize: 28,
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                             SizedBox(height: 4),
// //                             Text(
// //                               'Track your pregnancy journey',
// //                               style: TextStyle(
// //                                 color: Colors.white70,
// //                                 fontSize: 14,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 20),
// //                   StreamBuilder<QuerySnapshot>(
// //                     stream: _milestoneCollection.snapshots(),
// //                     builder: (context, snapshot) {
// //                       int total = 0;
// //                       int completed = 0;
// //                       if (snapshot.hasData) {
// //                         total = snapshot.data!.docs.length;
// //                         completed = snapshot.data!.docs
// //                             .where((doc) => (doc.data() as Map)['completed'] == true)
// //                             .length;
// //                       }
// //                       return Container(
// //                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //                         decoration: BoxDecoration(
// //                           color: Colors.white.withOpacity(0.2),
// //                           borderRadius: BorderRadius.circular(16),
// //                         ),
// //                         child: Row(
// //                           mainAxisAlignment: MainAxisAlignment.spaceAround,
// //                           children: [
// //                             _buildStatItem(Icons.flag_rounded, '$total', 'Total'),
// //                             Container(
// //                               width: 1,
// //                               height: 30,
// //                               color: Colors.white.withOpacity(0.3),
// //                             ),
// //                             _buildStatItem(Icons.check_circle_rounded, '$completed', 'Completed'),
// //                             Container(
// //                               width: 1,
// //                               height: 30,
// //                               color: Colors.white.withOpacity(0.3),
// //                             ),
// //                             _buildStatItem(Icons.pending_actions_rounded, '${total - completed}', 'Pending'),
// //                           ],
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 ],
// //               ),
// //             ),
// //
// //             // Add Milestone Section
// //             Padding(
// //               padding: const EdgeInsets.symmetric(horizontal: 20),
// //               child: Container(
// //                 padding: const EdgeInsets.all(20),
// //                 decoration: BoxDecoration(
// //                   color: Colors.white,
// //                   borderRadius: BorderRadius.circular(20),
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: Colors.pink.withOpacity(0.1),
// //                       blurRadius: 15,
// //                       offset: const Offset(0, 5),
// //                     ),
// //                   ],
// //                 ),
// //                 child: Row(
// //                   children: [
// //                     Expanded(
// //                       child: TextField(
// //                         controller: _milestoneController,
// //                         decoration: InputDecoration(
// //                           hintText: 'Add new milestone...',
// //                           hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
// //                           prefixIcon: const Icon(Icons.add_task, color: Color(0xFFB794F4)),
// //                           filled: true,
// //                           fillColor: const Color(0xFFF9FAFB),
// //                           border: OutlineInputBorder(
// //                             borderRadius: BorderRadius.circular(15),
// //                             borderSide: BorderSide.none,
// //                           ),
// //                         ),
// //                         onSubmitted: (_) => _addMilestone(),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 12),
// //                     Container(
// //                       width: 56,
// //                       height: 56,
// //                       decoration: BoxDecoration(
// //                         gradient: const LinearGradient(
// //                           colors: [Color(0xFFB794F4), Color(0xFFB794F4)],
// //                         ),
// //                         borderRadius: BorderRadius.circular(15),
// //                         boxShadow: [
// //                           BoxShadow(
// //                             color: const Color(0xFFB794F4).withOpacity(0.3),
// //                             blurRadius: 10,
// //                             offset: const Offset(0, 4),
// //                           ),
// //                         ],
// //                       ),
// //                       child: Material(
// //                         color: Colors.transparent,
// //                         child: InkWell(
// //                           borderRadius: BorderRadius.circular(15),
// //                           onTap: _addMilestone,
// //                           child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //
// //             const SizedBox(height: 24),
// //
// //             // Milestones List
// //             Expanded(
// //               child: StreamBuilder<QuerySnapshot>(
// //                 stream: _milestoneCollection.orderBy('timestamp', descending: true).snapshots(),
// //                 builder: (context, snapshot) {
// //                   if (snapshot.connectionState == ConnectionState.waiting) {
// //                     return const Center(
// //                       child: CircularProgressIndicator(color: Color(0xFFB794F4)),
// //                     );
// //                   }
// //
// //                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
// //                     return Center(
// //                       child: Column(
// //                         mainAxisAlignment: MainAxisAlignment.center,
// //                         children: [
// //                           Container(
// //                             width: 120,
// //                             height: 120,
// //                             decoration: BoxDecoration(
// //                               gradient: LinearGradient(
// //                                 colors: [
// //                                   const Color(0xFFB794F4).withOpacity(0.2),
// //                                   const Color(0xFFB794F4).withOpacity(0.2),
// //                                 ],
// //                               ),
// //                               borderRadius: BorderRadius.circular(60),
// //                             ),
// //                             child: const Icon(
// //                               Icons.emoji_events_outlined,
// //                               size: 60,
// //                               color: Color(0xFFB794F4),
// //                             ),
// //                           ),
// //                           const SizedBox(height: 24),
// //                           const Text(
// //                             'No milestones yet',
// //                             style: TextStyle(
// //                               fontSize: 24,
// //                               fontWeight: FontWeight.bold,
// //                               color: Color(0xFF1F2937),
// //                             ),
// //                           ),
// //                           const SizedBox(height: 8),
// //                           const Text(
// //                             'Add your first milestone above',
// //                             style: TextStyle(
// //                               fontSize: 16,
// //                               color: Color(0xFF9CA3AF),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     );
// //                   }
// //
// //                   return ListView.builder(
// //                     padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
// //                     itemCount: snapshot.data!.docs.length,
// //                     itemBuilder: (context, index) {
// //                       final doc = snapshot.data!.docs[index];
// //                       final data = doc.data() as Map<String, dynamic>;
// //                       final title = data['title'] ?? '';
// //                       final completed = data['completed'] ?? false;
// //                       final timestamp = data['timestamp'] as Timestamp?;
// //
// //                       String formattedDate = '';
// //                       if (timestamp != null) {
// //                         formattedDate = DateFormat('MMM dd, yyyy').format(timestamp.toDate());
// //                       }
// //
// //                       return Dismissible(
// //                         key: Key(doc.id),
// //                         background: Container(
// //                           margin: const EdgeInsets.only(bottom: 12),
// //                           padding: const EdgeInsets.symmetric(horizontal: 20),
// //                           decoration: BoxDecoration(
// //                             gradient: const LinearGradient(
// //                               colors: [Color(0xFF10B981), Color(0xFF059669)],
// //                             ),
// //                             borderRadius: BorderRadius.circular(20),
// //                           ),
// //                           alignment: Alignment.centerLeft,
// //                           child: const Icon(Icons.edit, color: Colors.white, size: 28),
// //                         ),
// //                         secondaryBackground: Container(
// //                           margin: const EdgeInsets.only(bottom: 12),
// //                           padding: const EdgeInsets.symmetric(horizontal: 20),
// //                           decoration: BoxDecoration(
// //                             gradient: const LinearGradient(
// //                               colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
// //                             ),
// //                             borderRadius: BorderRadius.circular(20),
// //                           ),
// //                           alignment: Alignment.centerRight,
// //                           child: const Icon(Icons.delete, color: Colors.white, size: 28),
// //                         ),
// //                         confirmDismiss: (direction) async {
// //                           if (direction == DismissDirection.endToStart) {
// //                             _deleteMilestone(doc.id);
// //                           } else if (direction == DismissDirection.startToEnd) {
// //                             _editMilestone(doc.id, title);
// //                           }
// //                           return false;
// //                         },
// //                         child: Container(
// //                           margin: const EdgeInsets.only(bottom: 12),
// //                           decoration: BoxDecoration(
// //                             color: Colors.white,
// //                             borderRadius: BorderRadius.circular(20),
// //                             border: completed
// //                                 ? Border.all(color: const Color(0xFF10B981), width: 2)
// //                                 : null,
// //                             boxShadow: [
// //                               BoxShadow(
// //                                 color: completed
// //                                     ? const Color(0xFF10B981).withOpacity(0.1)
// //                                     : Colors.pink.withOpacity(0.08),
// //                                 blurRadius: 15,
// //                                 offset: const Offset(0, 5),
// //                               ),
// //                             ],
// //                           ),
// //                           child: Material(
// //                             color: Colors.transparent,
// //                             child: InkWell(
// //                               borderRadius: BorderRadius.circular(20),
// //                               onTap: () => _toggleMilestone(doc.id, completed),
// //                               child: Padding(
// //                                 padding: const EdgeInsets.all(16),
// //                                 child: Row(
// //                                   children: [
// //                                     Container(
// //                                       width: 50,
// //                                       height: 50,
// //                                       decoration: BoxDecoration(
// //                                         gradient: completed
// //                                             ? const LinearGradient(
// //                                           colors: [Color(0xFF10B981), Color(0xFF059669)],
// //                                         )
// //                                             : LinearGradient(
// //                                           colors: [
// //                                             const Color(0xFFFF6B9D).withOpacity(0.2),
// //                                             const Color(0xFFFE8FAB).withOpacity(0.2),
// //                                           ],
// //                                         ),
// //                                         borderRadius: BorderRadius.circular(15),
// //                                       ),
// //                                       child: Icon(
// //                                         completed ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
// //                                         color: completed ? Colors.white : const Color(0xFFFF6B9D),
// //                                         size: 28,
// //                                       ),
// //                                     ),
// //                                     const SizedBox(width: 16),
// //                                     Expanded(
// //                                       child: Column(
// //                                         crossAxisAlignment: CrossAxisAlignment.start,
// //                                         children: [
// //                                           Text(
// //                                             title,
// //                                             style: TextStyle(
// //                                               fontSize: 16,
// //                                               fontWeight: FontWeight.w600,
// //                                               color: completed ? const Color(0xFF10B981) : const Color(0xFF1F2937),
// //                                               decoration: completed ? TextDecoration.lineThrough : null,
// //                                             ),
// //                                           ),
// //                                           if (formattedDate.isNotEmpty) ...[
// //                                             const SizedBox(height: 4),
// //                                             Row(
// //                                               children: [
// //                                                 const Icon(
// //                                                   Icons.calendar_today,
// //                                                   size: 12,
// //                                                   color: Color(0xFF9CA3AF),
// //                                                 ),
// //                                                 const SizedBox(width: 6),
// //                                                 Text(
// //                                                   formattedDate,
// //                                                   style: const TextStyle(
// //                                                     fontSize: 12,
// //                                                     color: Color(0xFF9CA3AF),
// //                                                   ),
// //                                                 ),
// //                                               ],
// //                                             ),
// //                                           ],
// //                                         ],
// //                                       ),
// //                                     ),
// //                                     PopupMenuButton(
// //                                       shape: RoundedRectangleBorder(
// //                                         borderRadius: BorderRadius.circular(12),
// //                                       ),
// //                                       icon: const Icon(Icons.more_vert, color: Color(0xFF9CA3AF)),
// //                                       itemBuilder: (context) => [
// //                                         PopupMenuItem(
// //                                           child: const Row(
// //                                             children: [
// //                                               Icon(Icons.edit, color: Color(0xFF10B981), size: 20),
// //                                               SizedBox(width: 12),
// //                                               Text('Edit'),
// //                                             ],
// //                                           ),
// //                                           onTap: () {
// //                                             Future.delayed(Duration.zero, () => _editMilestone(doc.id, title));
// //                                           },
// //                                         ),
// //                                         PopupMenuItem(
// //                                           child: const Row(
// //                                             children: [
// //                                               Icon(Icons.delete, color: Color(0xFFEF4444), size: 20),
// //                                               SizedBox(width: 12),
// //                                               Text('Delete'),
// //                                             ],
// //                                           ),
// //                                           onTap: () {
// //                                             Future.delayed(Duration.zero, () => _deleteMilestone(doc.id));
// //                                           },
// //                                         ),
// //                                       ],
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       );
// //                     },
// //                   );
// //                 },
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildStatItem(IconData icon, String value, String label) {
// //     return Row(
// //       children: [
// //         Icon(icon, color: Colors.white, size: 20),
// //         const SizedBox(width: 8),
// //         Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               value,
// //               style: const TextStyle(
// //                 color: Colors.white,
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.bold,
// //               ),
// //             ),
// //             Text(
// //               label,
// //               style: const TextStyle(
// //                 color: Colors.white70,
// //                 fontSize: 12,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ],
// //     );
// //   }
// // }
