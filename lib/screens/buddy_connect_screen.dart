import 'package:flutter/material.dart';


class BuddyConnectHome extends StatefulWidget {
  const BuddyConnectHome({Key? key}) : super(key: key);

  @override
  State<BuddyConnectHome> createState() => _BuddyConnectHomeState();
}

class _BuddyConnectHomeState extends State<BuddyConnectHome> {
  int currentIndex = 0;
  String? selectedSpecialty;
  String? selectedConsultationType;
  String? selectedDoctor;

  final List<SpecialtyModel> specialties = [
    SpecialtyModel(
      id: '1',
      name: 'OB-GYN Consult',
      description: 'Questions on scans, complications, due dates',
      icon: '👩‍⚕️',
      color: Colors.red.shade100,
    ),
    SpecialtyModel(
      id: '2',
      name: 'Diet & Nutrition',
      description: 'Meal plans, weight gain, supplements',
      icon: '🥗',
      color: Colors.green.shade100,
    ),
    SpecialtyModel(
      id: '3',
      name: 'Physiotherapist',
      description: 'Safe workouts, posture, back pain',
      icon: '🧘‍♀️',
      color: Colors.blue.shade100,
    ),
    SpecialtyModel(
      id: '4',
      name: 'Lactation Support',
      description: 'Preparation for breastfeeding, breast care',
      icon: '🍼',
      color: Colors.purple.shade100,
    ),
    SpecialtyModel(
      id: '5',
      name: 'Emotional Wellness',
      description: 'Counselling, anxiety, relationship support',
      icon: '🧠',
      color: Colors.yellow.shade100,
    ),
  ];

  final List<ConsultationType> consultationTypes = [
    ConsultationType(
      id: '1',
      name: 'Chat with Expert',
      description: 'Text-based consultation',
      icon: '💬',
      price: '₹299',
      duration: '30 mins',
    ),
    ConsultationType(
      id: '2',
      name: 'Audio Call',
      description: 'Voice consultation',
      icon: '☎️',
      price: '₹499',
      duration: '30 mins',
    ),
    ConsultationType(
      id: '3',
      name: 'Video Consultation',
      description: 'Face-to-face consultation',
      icon: '📹',
      price: '₹699',
      duration: '30 mins',
    ),
  ];

  final List<DoctorModel> doctors = [
    DoctorModel(
      id: '1',
      name: 'Dr. Priya Sharma',
      specialty: 'OB-GYN Consult',
      experience: '12 years',
      rating: 4.8,
      consultations: 1200,
    ),
    DoctorModel(
      id: '2',
      name: 'Dr. Anjali Verma',
      specialty: 'Diet & Nutrition',
      experience: '8 years',
      rating: 4.7,
      consultations: 950,
    ),
    DoctorModel(
      id: '3',
      name: 'Dr. Meera Patel',
      specialty: 'Physiotherapist',
      experience: '10 years',
      rating: 4.9,
      consultations: 1100,
    ),
    DoctorModel(
      id: '4',
      name: 'Dr. Neha Gupta',
      specialty: 'Lactation Support',
      experience: '6 years',
      rating: 4.6,
      consultations: 800,
    ),
    DoctorModel(
      id: '5',
      name: 'Dr. Sneha Singh',
      specialty: 'Emotional Wellness',
      experience: '9 years',
      rating: 4.8,
      consultations: 1050,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentIndex == 0
          ? _buildDoctorCornerScreen()
          : currentIndex == 1
          ? _buildSelectSpecialtyScreen()
          : _buildSelectConsultationScreen(),
    );
  }

  Widget _buildDoctorCornerScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade300, Colors.purple.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),


          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Doctor's Corner",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Connect with certified professionals for\npersonalized pregnancy care',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        '4.8 rating from 1000+ consultations',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Choose Your Specialty',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...specialties.map((specialty) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedSpecialty = specialty.id;
                        currentIndex = 1;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: specialty.color,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                specialty.icon,
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  specialty.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  specialty.description,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectSpecialtyScreen() {
    List<DoctorModel> filteredDoctors = doctors
        .where((doc) => doc.specialty == specialties
        .firstWhere((s) => s.id == selectedSpecialty)
        .name)
        .toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade300, Colors.purple.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          currentIndex = 0;
                        });
                      },
                      child: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Select a ${specialties.firstWhere((s) => s.id == selectedSpecialty).name}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...filteredDoctors.map((doctor) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDoctor = doctor.id;
                        currentIndex = 2;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Experience: ${doctor.experience}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.orange, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${doctor.rating} (${doctor.consultations} consultations)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectConsultationScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade300, Colors.purple.shade200],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          currentIndex = 1;
                        });
                      },
                      child: const Icon(Icons.arrow_back),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Choose Consultation Type',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ...consultationTypes.map((consultation) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedConsultationType = consultation.id;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Appointment booked with ${consultation.name}',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedConsultationType == consultation.id
                              ? Colors.purple
                              : Colors.grey.shade200,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                consultation.icon,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    consultation.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    consultation.description,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                consultation.price,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                              ),
                              Text(
                                consultation.duration,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '💬',
                        style: TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Quick Question?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ask asynchronously - get response within 24 hours',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Quick question submitted!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.purple,
                          side: const BorderSide(color: Colors.purple),
                        ),
                        child: const Text('Ask Now - ₹99'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SpecialtyModel {
  final String id;
  final String name;
  final String description;
  final String icon;
  final Color color;

  SpecialtyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class ConsultationType {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String price;
  final String duration;

  ConsultationType({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.price,
    required this.duration,
  });
}

class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final String experience;
  final double rating;
  final int consultations;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.experience,
    required this.rating,
    required this.consultations,
  });
}