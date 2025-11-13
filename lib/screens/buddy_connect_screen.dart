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
      education: 'MD - Obstetrics & Gynaecology, AIIMS Delhi',
      languages: ['English', 'Hindi', 'Marathi'],
      about: 'Specialized in high-risk pregnancies and fetal medicine. Passionate about providing compassionate care to expecting mothers.',
      availability: 'Mon-Sat: 9 AM - 6 PM',
    ),
    DoctorModel(
      id: '2',
      name: 'Dr. Anjali Verma',
      specialty: 'Diet & Nutrition',
      experience: '8 years',
      rating: 4.7,
      consultations: 950,
      education: 'MSc - Clinical Nutrition, Delhi University',
      languages: ['English', 'Hindi', 'Punjabi'],
      about: 'Expert in prenatal and postnatal nutrition. Focuses on personalized diet plans for healthy pregnancy outcomes.',
      availability: 'Mon-Fri: 10 AM - 7 PM',
    ),
    DoctorModel(
      id: '3',
      name: 'Dr. Meera Patel',
      specialty: 'Physiotherapist',
      experience: '10 years',
      rating: 4.9,
      consultations: 1100,
      education: 'MPT - Women\'s Health, Christian Medical College',
      languages: ['English', 'Hindi', 'Gujarati'],
      about: 'Specialized in prenatal exercises and postpartum recovery. Helps mothers maintain fitness during pregnancy.',
      availability: 'Tue-Sun: 8 AM - 5 PM',
    ),
    DoctorModel(
      id: '4',
      name: 'Dr. Neha Gupta',
      specialty: 'Lactation Support',
      experience: '6 years',
      rating: 4.6,
      consultations: 800,
      education: 'IBCLC Certified, International Board Certified Lactation Consultant',
      languages: ['English', 'Hindi', 'Bengali'],
      about: 'Dedicated to helping new mothers with breastfeeding challenges and ensuring proper lactation.',
      availability: 'Mon-Sat: 9 AM - 4 PM',
    ),
    DoctorModel(
      id: '5',
      name: 'Dr. Sneha Singh',
      specialty: 'Emotional Wellness',
      experience: '9 years',
      rating: 4.8,
      consultations: 1050,
      education: 'PhD - Clinical Psychology, NIMHANS Bangalore',
      languages: ['English', 'Hindi', 'Tamil'],
      about: 'Specialized in perinatal mental health. Provides counseling for anxiety, depression and relationship issues during pregnancy.',
      availability: 'Mon-Fri: 11 AM - 8 PM',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buddy Connect'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: currentIndex == 0
          ? _buildDoctorCornerScreen()
          : currentIndex == 1
          ? _buildSelectSpecialtyScreen()
          : currentIndex == 2
          ? _buildSelectConsultationScreen()
          : _buildPaymentScreen(),
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
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Doctor's Corner",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Connect with certified professionals for\npersonalized pregnancy care',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = 0;
                    });
                  },
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Text(
                  'Select a ${specialties.firstWhere((s) => s.id == selectedSpecialty).name}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available ${specialties.firstWhere((s) => s.id == selectedSpecialty).name} Specialists',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                ...filteredDoctors.map((doctor) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDoctor = doctor.id;
                        currentIndex = 2;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
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
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.purple.shade100,
                                radius: 25,
                                child: const Icon(Icons.person, color: Colors.purple),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      doctor.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      doctor.specialty,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildInfoChip('${doctor.experience} Exp', Icons.work),
                              const SizedBox(width: 8),
                              _buildInfoChip('${doctor.rating} ⭐', Icons.star),
                              const SizedBox(width: 8),
                              _buildInfoChip('${doctor.consultations}+ Consults', Icons.people),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            doctor.education,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectConsultationScreen() {
    DoctorModel selectedDoctorModel = doctors.firstWhere((doc) => doc.id == selectedDoctor);
    SpecialtyModel selectedSpecialtyModel = specialties.firstWhere((s) => s.id == selectedSpecialty);

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
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = 1;
                    });
                  },
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedDoctorModel.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        selectedSpecialtyModel.name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Details Card
                Container(
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
                      const Text(
                        'About Doctor',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedDoctorModel.about,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Education',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        selectedDoctorModel.education,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Languages',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        selectedDoctorModel.languages.join(', '),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Availability',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        selectedDoctorModel.availability,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Choose Consultation Type',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...consultationTypes.map((consultation) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedConsultationType = consultation.id;
                        currentIndex = 3; // Move to payment screen
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
                // Quick Question Option
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
                          _processQuickQuestionPayment();
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

  Widget _buildPaymentScreen() {
    DoctorModel selectedDoctorModel = doctors.firstWhere((doc) => doc.id == selectedDoctor);
    ConsultationType selectedConsultation = consultationTypes.firstWhere((c) => c.id == selectedConsultationType);
    String price = selectedConsultation.price.replaceAll('₹', '');

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
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = 2;
                    });
                  },
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Payment',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Appointment Summary
                Container(
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
                      const Text(
                        'Appointment Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSummaryRow('Doctor', selectedDoctorModel.name),
                      _buildSummaryRow('Specialty', selectedDoctorModel.specialty),
                      _buildSummaryRow('Consultation Type', selectedConsultation.name),
                      _buildSummaryRow('Duration', selectedConsultation.duration),
                      _buildSummaryRow('Experience', selectedDoctorModel.experience),
                      const SizedBox(height: 12),
                      Divider(color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      _buildSummaryRow('Amount', selectedConsultation.price, isBold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Payment Methods
                Container(
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
                      const Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPaymentMethod('Credit/Debit Card', Icons.credit_card),
                      _buildPaymentMethod('UPI', Icons.payment),
                      _buildPaymentMethod('Net Banking', Icons.account_balance),
                      _buildPaymentMethod('Wallet', Icons.wallet),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Pay Now Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _processPayment(selectedDoctorModel, selectedConsultation);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Pay Now',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      currentIndex = 2;
                    });
                  },
                  child: const Text(
                    'Cancel Appointment',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Colors.purple : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  void _processPayment(DoctorModel doctor, ConsultationType consultation) {
    // Simulate payment processing
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Processing Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Booking appointment with ${doctor.name}'),
            const SizedBox(height: 8),
            Text('${consultation.name} - ${consultation.price}'),
          ],
        ),
      ),
    );

    // Simulate API call delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Payment Successful!', style: TextStyle(color: Colors.green)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 48),
              const SizedBox(height: 16),
              Text('Appointment booked with Dr. ${doctor.name}'),
              const SizedBox(height: 8),
              Text('${consultation.name} - ${consultation.price}'),
              const SizedBox(height: 16),
              const Text('You will receive a confirmation shortly.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  currentIndex = 0;
                  selectedSpecialty = null;
                  selectedConsultationType = null;
                  selectedDoctor = null;
                });
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  void _processQuickQuestionPayment() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Question'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ask your question and get a response within 24 hours.'),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Type your question here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processPayment(doctors.first, ConsultationType(
                id: '4',
                name: 'Quick Question',
                description: 'Text response within 24 hours',
                icon: '💬',
                price: '₹99',
                duration: '24 hours',
              ));
            },
            child: const Text('Pay ₹99'),
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
  final String education;
  final List<String> languages;
  final String about;
  final String availability;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.experience,
    required this.rating,
    required this.consultations,
    required this.education,
    required this.languages,
    required this.about,
    required this.availability,
  });
}



// import 'package:flutter/material.dart';
//
//
// class BuddyConnectHome extends StatefulWidget {
//   const BuddyConnectHome({Key? key}) : super(key: key);
//
//   @override
//   State<BuddyConnectHome> createState() => _BuddyConnectHomeState();
// }
//
// class _BuddyConnectHomeState extends State<BuddyConnectHome> {
//   int currentIndex = 0;
//   String? selectedSpecialty;
//   String? selectedConsultationType;
//   String? selectedDoctor;
//
//   final List<SpecialtyModel> specialties = [
//     SpecialtyModel(
//       id: '1',
//       name: 'OB-GYN Consult',
//       description: 'Questions on scans, complications, due dates',
//       icon: '👩‍⚕️',
//       color: Colors.red.shade100,
//     ),
//     SpecialtyModel(
//       id: '2',
//       name: 'Diet & Nutrition',
//       description: 'Meal plans, weight gain, supplements',
//       icon: '🥗',
//       color: Colors.green.shade100,
//     ),
//     SpecialtyModel(
//       id: '3',
//       name: 'Physiotherapist',
//       description: 'Safe workouts, posture, back pain',
//       icon: '🧘‍♀️',
//       color: Colors.blue.shade100,
//     ),
//     SpecialtyModel(
//       id: '4',
//       name: 'Lactation Support',
//       description: 'Preparation for breastfeeding, breast care',
//       icon: '🍼',
//       color: Colors.purple.shade100,
//     ),
//     SpecialtyModel(
//       id: '5',
//       name: 'Emotional Wellness',
//       description: 'Counselling, anxiety, relationship support',
//       icon: '🧠',
//       color: Colors.yellow.shade100,
//     ),
//   ];
//
//   final List<ConsultationType> consultationTypes = [
//     ConsultationType(
//       id: '1',
//       name: 'Chat with Expert',
//       description: 'Text-based consultation',
//       icon: '💬',
//       price: '₹299',
//       duration: '30 mins',
//     ),
//     ConsultationType(
//       id: '2',
//       name: 'Audio Call',
//       description: 'Voice consultation',
//       icon: '☎️',
//       price: '₹499',
//       duration: '30 mins',
//     ),
//     ConsultationType(
//       id: '3',
//       name: 'Video Consultation',
//       description: 'Face-to-face consultation',
//       icon: '📹',
//       price: '₹699',
//       duration: '30 mins',
//     ),
//   ];
//
//   final List<DoctorModel> doctors = [
//     DoctorModel(
//       id: '1',
//       name: 'Dr. Priya Sharma',
//       specialty: 'OB-GYN Consult',
//       experience: '12 years',
//       rating: 4.8,
//       consultations: 1200,
//     ),
//     DoctorModel(
//       id: '2',
//       name: 'Dr. Anjali Verma',
//       specialty: 'Diet & Nutrition',
//       experience: '8 years',
//       rating: 4.7,
//       consultations: 950,
//     ),
//     DoctorModel(
//       id: '3',
//       name: 'Dr. Meera Patel',
//       specialty: 'Physiotherapist',
//       experience: '10 years',
//       rating: 4.9,
//       consultations: 1100,
//     ),
//     DoctorModel(
//       id: '4',
//       name: 'Dr. Neha Gupta',
//       specialty: 'Lactation Support',
//       experience: '6 years',
//       rating: 4.6,
//       consultations: 800,
//     ),
//     DoctorModel(
//       id: '5',
//       name: 'Dr. Sneha Singh',
//       specialty: 'Emotional Wellness',
//       experience: '9 years',
//       rating: 4.8,
//       consultations: 1050,
//     ),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: currentIndex == 0
//           ? _buildDoctorCornerScreen()
//           : currentIndex == 1
//           ? _buildSelectSpecialtyScreen()
//           : _buildSelectConsultationScreen(),
//     );
//   }
//
//   Widget _buildDoctorCornerScreen() {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.purple.shade300, Colors.purple.shade200],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//
//
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const Text(
//                   "Doctor's Corner",
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 12),
//                 const Text(
//                   'Connect with certified professionals for\npersonalized pregnancy care',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 16),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.orange.shade50,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(Icons.star, color: Colors.orange, size: 20),
//                       const SizedBox(width: 8),
//                       const Text(
//                         '4.8 rating from 1000+ consultations',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 const Text(
//                   'Choose Your Specialty',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 ...specialties.map((specialty) {
//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         selectedSpecialty = specialty.id;
//                         currentIndex = 1;
//                       });
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.shade200,
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         children: [
//                           Container(
//                             width: 60,
//                             height: 60,
//                             decoration: BoxDecoration(
//                               color: specialty.color,
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 specialty.icon,
//                                 style: const TextStyle(fontSize: 32),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   specialty.name,
//                                   style: const TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 Text(
//                                   specialty.description,
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSelectSpecialtyScreen() {
//     List<DoctorModel> filteredDoctors = doctors
//         .where((doc) => doc.specialty == specialties
//         .firstWhere((s) => s.id == selectedSpecialty)
//         .name)
//         .toList();
//
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.purple.shade300, Colors.purple.shade200],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           currentIndex = 0;
//                         });
//                       },
//                       child: const Icon(Icons.arrow_back),
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Select a ${specialties.firstWhere((s) => s.id == selectedSpecialty).name}',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 ...filteredDoctors.map((doctor) {
//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         selectedDoctor = doctor.id;
//                         currentIndex = 2;
//                       });
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.shade200,
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             doctor.name,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'Experience: ${doctor.experience}',
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             children: [
//                               const Icon(Icons.star, color: Colors.orange, size: 16),
//                               const SizedBox(width: 4),
//                               Text(
//                                 '${doctor.rating} (${doctor.consultations} consultations)',
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSelectConsultationScreen() {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.purple.shade300, Colors.purple.shade200],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           currentIndex = 1;
//                         });
//                       },
//                       child: const Icon(Icons.arrow_back),
//                     ),
//                     const SizedBox(width: 8),
//                     const Text(
//                       'Choose Consultation Type',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//                 ...consultationTypes.map((consultation) {
//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         selectedConsultationType = consultation.id;
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(
//                               'Appointment booked with ${consultation.name}',
//                             ),
//                             backgroundColor: Colors.green,
//                           ),
//                         );
//                       });
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.only(bottom: 16),
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(
//                           color: selectedConsultationType == consultation.id
//                               ? Colors.purple
//                               : Colors.grey.shade200,
//                           width: 2,
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.grey.shade200,
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Row(
//                             children: [
//                               Text(
//                                 consultation.icon,
//                                 style: const TextStyle(fontSize: 32),
//                               ),
//                               const SizedBox(width: 16),
//                               Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     consultation.name,
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     consultation.description,
//                                     style: const TextStyle(
//                                       fontSize: 12,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.end,
//                             children: [
//                               Text(
//                                 consultation.price,
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.purple,
//                                 ),
//                               ),
//                               Text(
//                                 consultation.duration,
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }).toList(),
//                 const SizedBox(height: 24),
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade300),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     children: [
//                       const Text(
//                         '💬',
//                         style: TextStyle(fontSize: 32),
//                       ),
//                       const SizedBox(height: 12),
//                       const Text(
//                         'Quick Question?',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const Text(
//                         'Ask asynchronously - get response within 24 hours',
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 12),
//                       ElevatedButton(
//                         onPressed: () {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text('Quick question submitted!'),
//                               backgroundColor: Colors.green,
//                             ),
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           foregroundColor: Colors.purple,
//                           side: const BorderSide(color: Colors.purple),
//                         ),
//                         child: const Text('Ask Now - ₹99'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class SpecialtyModel {
//   final String id;
//   final String name;
//   final String description;
//   final String icon;
//   final Color color;
//
//   SpecialtyModel({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.icon,
//     required this.color,
//   });
// }
//
// class ConsultationType {
//   final String id;
//   final String name;
//   final String description;
//   final String icon;
//   final String price;
//   final String duration;
//
//   ConsultationType({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.icon,
//     required this.price,
//     required this.duration,
//   });
// }
//
// class DoctorModel {
//   final String id;
//   final String name;
//   final String specialty;
//   final String experience;
//   final double rating;
//   final int consultations;
//
//   DoctorModel({
//     required this.id,
//     required this.name,
//     required this.specialty,
//     required this.experience,
//     required this.rating,
//     required this.consultations,
//   });
// }