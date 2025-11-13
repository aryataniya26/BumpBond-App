import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WebinarScreen extends StatefulWidget {
  const WebinarScreen({Key? key}) : super(key: key);

  @override
  State<WebinarScreen> createState() => _WebinarScreenState();
}

class _WebinarScreenState extends State<WebinarScreen> {
  String selectedTab = 'Upcoming';

  final List<Map<String, dynamic>> webinars = [
    {
      'title': 'Prenatal Nutrition Essentials',
      'speaker': 'Dr. Sarah Johnson, MD (Obstetrics)',
      'specialization': 'Nutritionist & OB-GYN',
      'date': '18 Oct, 2025',
      'time': '3:00 PM - 4:00 PM',
      'status': 'Upcoming',
      'participants': 156,
      'registered': false,
      'description':
      'Learn about essential nutrients and meal planning during pregnancy.',
      'price': '₹499',
      'duration': '60 min',
      'image': 'Dr. Sarah J.',
    },
    {
      'title': 'Managing Pregnancy Stress & Anxiety',
      'speaker': 'Dr. Emily Chen, Ph.D (Clinical Psychology)',
      'specialization': 'Perinatal Psychologist',
      'date': '20 Oct, 2025',
      'time': '5:00 PM - 6:00 PM',
      'status': 'Upcoming',
      'participants': 203,
      'registered': true,
      'description':
      'Techniques for managing stress and anxiety during pregnancy.',
      'price': '₹549',
      'duration': '60 min',
      'image': 'Dr. Emily C.',
    },
    {
      'title': 'Safe Exercise During Pregnancy',
      'speaker': 'Dr. Michael Brown, PT (Physical Therapy)',
      'specialization': 'Sports Medicine & Pregnancy Fitness',
      'date': '22 Oct, 2025',
      'time': '2:00 PM - 3:00 PM',
      'status': 'Upcoming',
      'participants': 189,
      'registered': false,
      'description': 'Safe exercise routines for expecting mothers.',
      'price': '₹449',
      'duration': '60 min',
      'image': 'Dr. Michael B.',
    },
    {
      'title': 'Labor & Delivery: Everything You Need to Know',
      'speaker': 'Dr. Lisa Anderson, MD (Perinatology)',
      'specialization': 'High-Risk Pregnancy Specialist',
      'date': '25 Oct, 2025',
      'time': '4:00 PM - 5:30 PM',
      'status': 'Upcoming',
      'participants': 245,
      'registered': false,
      'description':
      'Everything you need to know about labor and delivery options.',
      'price': '₹599',
      'duration': '90 min',
      'image': 'Dr. Lisa A.',
    },
    {
      'title': 'Postpartum Care & Recovery',
      'speaker': 'Dr. Priya Sharma, MD (Maternal Health)',
      'specialization': 'Postpartum Recovery Expert',
      'date': '15 Oct, 2025',
      'time': '6:00 PM - 7:00 PM',
      'status': 'Past',
      'participants': 167,
      'registered': true,
      'description': 'Complete guide to postpartum recovery and self-care.',
      'price': '₹499',
      'duration': '60 min',
      'image': 'Dr. Priya S.',
      'recording': true,
    },
  ];

  List<Map<String, dynamic>> get filteredWebinars {
    return webinars.where((w) => w['status'] == selectedTab).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Premium Webinars'),
        backgroundColor: const Color(0xFFEC4899),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFEC4899),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton('Upcoming'),
                ),
                Expanded(
                  child: _buildTabButton('Past'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: filteredWebinars.length,
              itemBuilder: (context, index) {
                final webinar = filteredWebinars[index];
                return _buildWebinarCard(webinar);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tab) {
    final isSelected = selectedTab == tab;
    return InkWell(
      onTap: () {
        setState(() {
          selectedTab = tab;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.white : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          tab,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight:
            isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildWebinarCard(Map<String, dynamic> webinar) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    WebinarDetailScreen(webinar: webinar),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: webinar['status'] == 'Upcoming'
                            ? const Color(0xFFEC4899).withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            webinar['status'] == 'Upcoming'
                                ? Icons.circle
                                : Icons.check_circle,
                            size: 12,
                            color: webinar['status'] == 'Upcoming'
                                ? const Color(0xFFEC4899)
                                : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            webinar['status'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: webinar['status'] == 'Upcoming'
                                  ? const Color(0xFFEC4899)
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        webinar['price'],
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  webinar['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        webinar['speaker'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      webinar['date'],
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      webinar['time'],
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${webinar['participants']} participants',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    if (webinar['recording'] == true) ...[
                      const Spacer(),
                      const Icon(
                        Icons.play_circle_outline,
                        size: 16,
                        color: Color(0xFFEC4899),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Recording Available',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEC4899),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Webinar Detail Screen
class WebinarDetailScreen extends StatefulWidget {
  final Map<String, dynamic> webinar;

  const WebinarDetailScreen({Key? key, required this.webinar})
      : super(key: key);

  @override
  State<WebinarDetailScreen> createState() =>
      _WebinarDetailScreenState();
}

class _WebinarDetailScreenState extends State<WebinarDetailScreen> {
  late bool isRegistered;

  @override
  void initState() {
    super.initState();
    isRegistered = widget.webinar['registered'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Webinar Details'),
        backgroundColor: const Color(0xFFEC4899),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.videocam,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.webinar['title'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 18,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          widget.webinar['speaker'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(
                    Icons.calendar_today,
                    'Date',
                    widget.webinar['date'],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    Icons.access_time,
                    'Time',
                    widget.webinar['time'],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    Icons.timer,
                    'Duration',
                    widget.webinar['duration'],
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    Icons.people,
                    'Participants',
                    '${widget.webinar['participants']} registered',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    Icons.currency_rupee,
                    'Price',
                    widget.webinar['price'],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'About Webinar',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.webinar['description'],
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'About the Speaker',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEC4899).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFEC4899).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.webinar['speaker'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.verified,
                              size: 16,
                              color: Color(0xFFEC4899),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.webinar['specialization'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.orange[700],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Coming soon...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange[700],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'What You\'ll Learn',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLearningPoint(
                      'Expert insights from certified professionals'),
                  _buildLearningPoint(
                      'Practical tips and evidence-based advice'),
                  _buildLearningPoint('Interactive Q&A session'),
                  _buildLearningPoint('Access to webinar recording'),
                  _buildLearningPoint('Certificate of attendance'),
                  const SizedBox(height: 24),
                  if (widget.webinar['status'] == 'Upcoming')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isRegistered = !isRegistered;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                isRegistered
                                    ? 'Successfully registered! Reminder will be sent.'
                                    : 'Registration cancelled.',
                              ),
                              backgroundColor: isRegistered
                                  ? const Color(0xFF10B981)
                                  : Colors.grey,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRegistered
                              ? Colors.grey[300]
                              : const Color(0xFFEC4899),
                          padding:
                          const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Icon(
                              isRegistered
                                  ? Icons.check
                                  : Icons.event_available,
                              color: isRegistered
                                  ? const Color(0xFF6B7280)
                                  : Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isRegistered
                                  ? 'Registered'
                                  : 'Register Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isRegistered
                                    ? const Color(0xFF6B7280)
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (widget.webinar['recording'] == true)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Opening recording player...'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEC4899),
                          padding:
                          const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_circle_filled,
                                color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Watch Recording',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
      IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEC4899).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFEC4899),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            size: 20,
            color: Color(0xFF10B981),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// class WebinarScreen extends StatefulWidget {
//   const WebinarScreen({Key? key}) : super(key: key);
//
//   @override
//   State<WebinarScreen> createState() => _WebinarScreenState();
// }
//
// class _WebinarScreenState extends State<WebinarScreen> {
//   String selectedTab = 'Upcoming';
//
//   final List<Map<String, dynamic>> webinars = [
//     {
//       'title': 'Prenatal Nutrition Essentials',
//       'speaker': 'Dr. Sarah Johnson, MD (Obstetrics)',
//       'specialization': 'Nutritionist & OB-GYN',
//       'date': '18 Oct, 2025',
//       'time': '3:00 PM - 4:00 PM',
//       'status': 'Upcoming',
//       'participants': 156,
//       'registered': false,
//       'description':
//       'Learn about essential nutrients and meal planning during pregnancy.',
//       'price': '₹499',
//       'duration': '60 min',
//       'image': 'Dr. Sarah J.',
//     },
//     {
//       'title': 'Managing Pregnancy Stress & Anxiety',
//       'speaker': 'Dr. Emily Chen, Ph.D (Clinical Psychology)',
//       'specialization': 'Perinatal Psychologist',
//       'date': '20 Oct, 2025',
//       'time': '5:00 PM - 6:00 PM',
//       'status': 'Upcoming',
//       'participants': 203,
//       'registered': true,
//       'description':
//       'Techniques for managing stress and anxiety during pregnancy.',
//       'price': '₹549',
//       'duration': '60 min',
//       'image': 'Dr. Emily C.',
//     },
//     {
//       'title': 'Safe Exercise During Pregnancy',
//       'speaker': 'Dr. Michael Brown, PT (Physical Therapy)',
//       'specialization': 'Sports Medicine & Pregnancy Fitness',
//       'date': '22 Oct, 2025',
//       'time': '2:00 PM - 3:00 PM',
//       'status': 'Upcoming',
//       'participants': 189,
//       'registered': false,
//       'description': 'Safe exercise routines for expecting mothers.',
//       'price': '₹449',
//       'duration': '60 min',
//       'image': 'Dr. Michael B.',
//     },
//     {
//       'title': 'Labor & Delivery: Everything You Need to Know',
//       'speaker': 'Dr. Lisa Anderson, MD (Perinatology)',
//       'specialization': 'High-Risk Pregnancy Specialist',
//       'date': '25 Oct, 2025',
//       'time': '4:00 PM - 5:30 PM',
//       'status': 'Upcoming',
//       'participants': 245,
//       'registered': false,
//       'description':
//       'Everything you need to know about labor and delivery options.',
//       'price': '₹599',
//       'duration': '90 min',
//       'image': 'Dr. Lisa A.',
//     },
//     {
//       'title': 'Postpartum Care & Recovery',
//       'speaker': 'Dr. Priya Sharma, MD (Maternal Health)',
//       'specialization': 'Postpartum Recovery Expert',
//       'date': '15 Oct, 2025',
//       'time': '6:00 PM - 7:00 PM',
//       'status': 'Past',
//       'participants': 167,
//       'registered': true,
//       'description': 'Complete guide to postpartum recovery and self-care.',
//       'price': '₹499',
//       'duration': '60 min',
//       'image': 'Dr. Priya S.',
//       'recording': true,
//     },
//   ];
//
//   List<Map<String, dynamic>> get filteredWebinars {
//     return webinars.where((w) => w['status'] == selectedTab).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         title: const Text('Premium Webinars'),
//         backgroundColor: const Color(0xFFEC4899),
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           Container(
//             color: const Color(0xFFEC4899),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: _buildTabButton('Upcoming'),
//                 ),
//                 Expanded(
//                   child: _buildTabButton('Past'),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(20),
//               itemCount: filteredWebinars.length,
//               itemBuilder: (context, index) {
//                 final webinar = filteredWebinars[index];
//                 return _buildWebinarCard(webinar);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTabButton(String tab) {
//     final isSelected = selectedTab == tab;
//     return InkWell(
//       onTap: () {
//         setState(() {
//           selectedTab = tab;
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         decoration: BoxDecoration(
//           border: Border(
//             bottom: BorderSide(
//               color: isSelected ? Colors.white : Colors.transparent,
//               width: 3,
//             ),
//           ),
//         ),
//         child: Text(
//           tab,
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight:
//             isSelected ? FontWeight.bold : FontWeight.normal,
//             color: isSelected ? Colors.white : Colors.white70,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildWebinarCard(Map<String, dynamic> webinar) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) =>
//                     WebinarDetailScreen(webinar: webinar),
//               ),
//             );
//           },
//           borderRadius: BorderRadius.circular(20),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: webinar['status'] == 'Upcoming'
//                             ? const Color(0xFFEC4899).withOpacity(0.1)
//                             : Colors.grey.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             webinar['status'] == 'Upcoming'
//                                 ? Icons.circle
//                                 : Icons.check_circle,
//                             size: 12,
//                             color: webinar['status'] == 'Upcoming'
//                                 ? const Color(0xFFEC4899)
//                                 : Colors.grey,
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             webinar['status'],
//                             style: TextStyle(
//                               fontSize: 11,
//                               fontWeight: FontWeight.w600,
//                               color: webinar['status'] == 'Upcoming'
//                                   ? const Color(0xFFEC4899)
//                                   : Colors.grey,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const Spacer(),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 10,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF10B981).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         webinar['price'],
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF10B981),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   webinar['title'],
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1F2937),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     const Icon(
//                       Icons.person_outline,
//                       size: 16,
//                       color: Color(0xFF6B7280),
//                     ),
//                     const SizedBox(width: 6),
//                     Expanded(
//                       child: Text(
//                         webinar['speaker'],
//                         style: const TextStyle(
//                           fontSize: 13,
//                           color: Color(0xFF6B7280),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     const Icon(
//                       Icons.calendar_today,
//                       size: 14,
//                       color: Color(0xFF6B7280),
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       webinar['date'],
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Color(0xFF6B7280),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     const Icon(
//                       Icons.access_time,
//                       size: 14,
//                       color: Color(0xFF6B7280),
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       webinar['time'],
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Color(0xFF6B7280),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     const Icon(
//                       Icons.people_outline,
//                       size: 16,
//                       color: Color(0xFF6B7280),
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       '${webinar['participants']} participants',
//                       style: const TextStyle(
//                         fontSize: 13,
//                         color: Color(0xFF6B7280),
//                       ),
//                     ),
//                     if (webinar['recording'] == true) ...[
//                       const Spacer(),
//                       const Icon(
//                         Icons.play_circle_outline,
//                         size: 16,
//                         color: Color(0xFFEC4899),
//                       ),
//                       const SizedBox(width: 6),
//                       const Text(
//                         'Recording Available',
//                         style: TextStyle(
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFFEC4899),
//                         ),
//                       ),
//                     ],
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Webinar Detail Screen
// class WebinarDetailScreen extends StatefulWidget {
//   final Map<String, dynamic> webinar;
//
//   const WebinarDetailScreen({Key? key, required this.webinar})
//       : super(key: key);
//
//   @override
//   State<WebinarDetailScreen> createState() =>
//       _WebinarDetailScreenState();
// }
//
// class _WebinarDetailScreenState extends State<WebinarDetailScreen> {
//   late bool isRegistered;
//
//   @override
//   void initState() {
//     super.initState();
//     isRegistered = widget.webinar['registered'];
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         title: const Text('Webinar Details'),
//         backgroundColor: const Color(0xFFEC4899),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(24),
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     width: 80,
//                     height: 80,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.videocam,
//                       size: 40,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     widget.webinar['title'],
//                     style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                       height: 1.3,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.person,
//                         size: 18,
//                         color: Colors.white70,
//                       ),
//                       const SizedBox(width: 6),
//                       Expanded(
//                         child: Text(
//                           widget.webinar['speaker'],
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Colors.white70,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildInfoCard(
//                     Icons.calendar_today,
//                     'Date',
//                     widget.webinar['date'],
//                   ),
//                   const SizedBox(height: 12),
//                   _buildInfoCard(
//                     Icons.access_time,
//                     'Time',
//                     widget.webinar['time'],
//                   ),
//                   const SizedBox(height: 12),
//                   _buildInfoCard(
//                     Icons.timer,
//                     'Duration',
//                     widget.webinar['duration'],
//                   ),
//                   const SizedBox(height: 12),
//                   _buildInfoCard(
//                     Icons.people,
//                     'Participants',
//                     '${widget.webinar['participants']} registered',
//                   ),
//                   const SizedBox(height: 12),
//                   _buildInfoCard(
//                     Icons.currency_rupee,
//                     'Price',
//                     widget.webinar['price'],
//                   ),
//                   const SizedBox(height: 24),
//                   const Text(
//                     'About Webinar',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1F2937),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     widget.webinar['description'],
//                     style: const TextStyle(
//                       fontSize: 16,
//                       height: 1.6,
//                       color: Color(0xFF6B7280),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   const Text(
//                     'About the Speaker',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1F2937),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFEC4899).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: const Color(0xFFEC4899).withOpacity(0.3),
//                       ),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.webinar['speaker'],
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF1F2937),
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Row(
//                           children: [
//                             const Icon(
//                               Icons.verified,
//                               size: 16,
//                               color: Color(0xFFEC4899),
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 widget.webinar['specialization'],
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                   color: Color(0xFF6B7280),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   const Text(
//                     'What You\'ll Learn',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1F2937),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   _buildLearningPoint(
//                       'Expert insights from certified professionals'),
//                   _buildLearningPoint(
//                       'Practical tips and evidence-based advice'),
//                   _buildLearningPoint('Interactive Q&A session'),
//                   _buildLearningPoint('Access to webinar recording'),
//                   _buildLearningPoint('Certificate of attendance'),
//                   const SizedBox(height: 24),
//                   if (widget.webinar['status'] == 'Upcoming')
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           setState(() {
//                             isRegistered = !isRegistered;
//                           });
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(
//                               content: Text(
//                                 isRegistered
//                                     ? 'Successfully registered! Reminder will be sent.'
//                                     : 'Registration cancelled.',
//                               ),
//                               backgroundColor: isRegistered
//                                   ? const Color(0xFF10B981)
//                                   : Colors.grey,
//                             ),
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: isRegistered
//                               ? Colors.grey[300]
//                               : const Color(0xFFEC4899),
//                           padding:
//                           const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisAlignment:
//                           MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               isRegistered
//                                   ? Icons.check
//                                   : Icons.event_available,
//                               color: isRegistered
//                                   ? const Color(0xFF6B7280)
//                                   : Colors.white,
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               isRegistered
//                                   ? 'Registered'
//                                   : 'Register Now',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: isRegistered
//                                     ? const Color(0xFF6B7280)
//                                     : Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   if (widget.webinar['recording'] == true)
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text(
//                                   'Opening recording player...'),
//                             ),
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFEC4899),
//                           padding:
//                           const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                         ),
//                         child: const Row(
//                           mainAxisAlignment:
//                           MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.play_circle_filled,
//                                 color: Colors.white),
//                             SizedBox(width: 8),
//                             Text(
//                               'Watch Recording',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   const SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoCard(
//       IconData icon, String label, String value) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 5,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: const Color(0xFFEC4899).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               icon,
//               color: const Color(0xFFEC4899),
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: Color(0xFF6B7280),
//                   ),
//                 ),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF1F2937),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLearningPoint(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Icon(
//             Icons.check_circle,
//             size: 20,
//             color: Color(0xFF10B981),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               text,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Color(0xFF6B7280),
//                 height: 1.5,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
