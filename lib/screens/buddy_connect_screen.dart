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

  // New state for bookings
  List<BookingModel> bookings = [];

  // Color Scheme
  final Color primaryColor = const Color(0xFF8B5FBF); // Lavender Purple
  final Color secondaryColor = const Color(0xFFD8BFD8); // Light Lavender
  final Color accentColor = const Color(0xFF6A0DAD); // Deep Lavender
  final Color backgroundColor = const Color(0xFFFAF5FF); // Very Light Lavender
  final Color cardColor = Colors.white;
  final Color textPrimary = Color(0xFF333333);
  final Color textSecondary = Color(0xFF666666);
  final Color textLight = Color(0xFF999999);

  final List<SpecialtyModel> specialties = [
    SpecialtyModel(
      id: '1',
      name: 'OB-GYN Consult',
      description: 'Questions on scans, complications, due dates',
      icon: '👩‍⚕️',
      color: Color(0xFFE8DEF8),
    ),
    SpecialtyModel(
      id: '2',
      name: 'Diet & Nutrition',
      description: 'Meal plans, weight gain, supplements',
      icon: '🥗',
      color: Color(0xFFE6F4EA),
    ),
    SpecialtyModel(
      id: '3',
      name: 'Physiotherapist',
      description: 'Safe workouts, posture, back pain',
      icon: '🧘‍♀️',
      color: Color(0xFFE3F2FD),
    ),
    SpecialtyModel(
      id: '4',
      name: 'Lactation Support',
      description: 'Preparation for breastfeeding, breast care',
      icon: '🍼',
      color: Color(0xFFF3E5F5),
    ),
    SpecialtyModel(
      id: '5',
      name: 'Emotional Wellness',
      description: 'Counselling, anxiety, relationship support',
      icon: '🧠',
      color: Color(0xFFFFF8E1),
    ),
  ];

  final List<ConsultationType> consultationTypes = [
    ConsultationType(
      id: '1',
      name: 'Chat with Expert',
      description: 'Text-based consultation',
      icon: Icons.chat_bubble_outline,
      price: '₹299',
      duration: '30 mins',
    ),
    ConsultationType(
      id: '2',
      name: 'Audio Call',
      description: 'Voice consultation',
      icon: Icons.phone_in_talk_outlined,
      price: '₹499',
      duration: '30 mins',
    ),
    ConsultationType(
      id: '3',
      name: 'Video Consultation',
      description: 'Face-to-face consultation',
      icon: Icons.videocam_outlined,
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
      imageUrl: 'assets/doctor1.png',
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
      imageUrl: 'assets/doctor2.png',
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
      imageUrl: 'assets/doctor3.png',
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
      imageUrl: 'assets/doctor4.png',
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
      imageUrl: 'assets/doctor5.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Buddy Connect',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, size: 22),
            onPressed: () {
              setState(() {
                currentIndex = 4;
              });
            },
          ),
        ],
      ),
      body: _buildCurrentScreen(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (currentIndex) {
      case 0:
        return _buildDoctorCornerScreen();
      case 1:
        return _buildSelectSpecialtyScreen();
      case 2:
        return _buildSelectConsultationScreen();
      case 3:
        return _buildPaymentScreen();
      case 4:
        return _buildBookingsScreen();
      default:
        return _buildDoctorCornerScreen();
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textLight,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 22),
            activeIcon: Icon(Icons.home, size: 22),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined, size: 22),
            activeIcon: Icon(Icons.medical_services, size: 22),
            label: 'Specialties',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_call_outlined, size: 22),
            activeIcon: Icon(Icons.video_call, size: 22),
            label: 'Consult',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_outlined, size: 22),
            activeIcon: Icon(Icons.payment, size: 22),
            label: 'Payment',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online_outlined, size: 22),
            activeIcon: Icon(Icons.book_online, size: 22),
            label: 'Bookings',
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCornerScreen() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  "Expert Consultation",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Connect with certified professionals for personalized pregnancy care',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade300, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '4.8 rating from 1000+ consultations',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Specialties Grid
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose Your Specialty',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Select from our expert specialists',
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: specialties.length,
                  itemBuilder: (context, index) {
                    final specialty = specialties[index];
                    return _buildSpecialtyCard(specialty);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialtyCard(SpecialtyModel specialty) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedSpecialty = specialty.id;
            currentIndex = 1;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: cardColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: specialty.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    specialty.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                specialty.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              const SizedBox(height: 6),
              Text(
                specialty.description,
                style: TextStyle(
                  fontSize: 11,
                  color: textLight,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectSpecialtyScreen() {
    List<DoctorModel> filteredDoctors = doctors
        .where((doc) => doc.specialty == specialties
        .firstWhere((s) => s.id == selectedSpecialty)
        .name)
        .toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                setState(() {
                  currentIndex = 0;
                });
              },
            ),
            title: Text(
              'Select ${specialties.firstWhere((s) => s.id == selectedSpecialty).name}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final doctor = filteredDoctors[index];
                return _buildDoctorCard(doctor);
              },
              childCount: filteredDoctors.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            setState(() {
              selectedDoctor = doctor.id;
              currentIndex = 2;
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.person, color: primaryColor, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.specialty,
                        style: TextStyle(
                          fontSize: 13,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildDoctorInfoChip('${doctor.experience} Exp', Icons.work_history),
                          const SizedBox(width: 8),
                          _buildDoctorInfoChip('${doctor.rating} ⭐', Icons.star),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: textLight, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: primaryColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectConsultationScreen() {
    if (selectedDoctor == null) {
      return _buildErrorScreen('Please select a doctor');
    }

    DoctorModel selectedDoctorModel = doctors.firstWhere((doc) => doc.id == selectedDoctor);
    SpecialtyModel selectedSpecialtyModel = specialties.firstWhere((s) => s.id == selectedSpecialty);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 16),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedDoctorModel.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          selectedSpecialtyModel.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                setState(() {
                  currentIndex = 1;
                });
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Details Card
                  _buildDoctorDetailsCard(selectedDoctorModel),
                  const SizedBox(height: 20),
                  Text(
                    'Choose Consultation Type',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...consultationTypes.map((consultation) {
                    return _buildConsultationTypeCard(consultation);
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorDetailsCard(DoctorModel doctor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Doctor',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              doctor.about,
              style: TextStyle(
                fontSize: 13,
                color: textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Education', doctor.education),
            _buildDetailRow('Languages', doctor.languages.join(', ')),
            _buildDetailRow('Availability', doctor.availability),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationTypeCard(ConsultationType consultation) {
    bool isSelected = selectedConsultationType == consultation.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? primaryColor : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedConsultationType = consultation.id;
            currentIndex = 3;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(consultation.icon, color: primaryColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      consultation.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      consultation.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    consultation.price,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                  Text(
                    consultation.duration,
                    style: TextStyle(
                      fontSize: 11,
                      color: textLight,
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

  Widget _buildPaymentScreen() {
    if (selectedDoctor == null || selectedConsultationType == null) {
      return _buildErrorScreen('Please complete selection');
    }

    DoctorModel selectedDoctorModel = doctors.firstWhere((doc) => doc.id == selectedDoctor);
    ConsultationType selectedConsultation = consultationTypes.firstWhere((c) => c.id == selectedConsultationType);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 80,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, accentColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                setState(() {
                  currentIndex = 2;
                });
              },
            ),
            title: Text(
              'Payment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Appointment Summary
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Appointment Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSummaryRow('Doctor', selectedDoctorModel.name),
                          _buildSummaryRow('Specialty', selectedDoctorModel.specialty),
                          _buildSummaryRow('Consultation Type', selectedConsultation.name),
                          _buildSummaryRow('Duration', selectedConsultation.duration),
                          _buildSummaryRow('Experience', selectedDoctorModel.experience),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          _buildSummaryRow('Total Amount', selectedConsultation.price, isBold: true),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Payment Methods
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Method',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildPaymentMethodCard('Credit/Debit Card', Icons.credit_card, Colors.blue),
                          _buildPaymentMethodCard('UPI', Icons.payment, Colors.green),
                          _buildPaymentMethodCard('Net Banking', Icons.account_balance, Colors.orange),
                          _buildPaymentMethodCard('Wallet', Icons.wallet, primaryColor),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pay Now Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _processPayment(selectedDoctorModel, selectedConsultation);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Pay Now - ${selectedConsultation.price}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        currentIndex = 2;
                      });
                    },
                    child: Text(
                      'Cancel Appointment',
                      style: TextStyle(
                        fontSize: 14,
                        color: textLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
              color: isBold ? primaryColor : textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(String title, IconData icon, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: textLight),
      ),
    );
  }

  Widget _buildBookingsScreen() {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: bookings.isEmpty
          ? _buildEmptyBookings()
          : _buildBookingsList(),
    );
  }

  Widget _buildEmptyBookings() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: textLight,
          ),
          const SizedBox(height: 16),
          Text(
            'No Bookings Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your upcoming appointments will appear here',
            style: TextStyle(
              fontSize: 14,
              color: textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                currentIndex = 0;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Book Appointment',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 100,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, accentColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          pinned: true,
          title: Text(
            'My Bookings',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final booking = bookings[index];
              return _buildBookingCard(booking);
            },
            childCount: bookings.length,
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    booking.doctorName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      booking.status,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(booking.status),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                booking.specialty,
                style: TextStyle(
                  fontSize: 13,
                  color: textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              _buildBookingDetailRow('Type', booking.consultationType),
              _buildBookingDetailRow('Date', booking.date),
              _buildBookingDetailRow('Time', booking.time),
              _buildBookingDetailRow('Amount', booking.amount),
              const SizedBox(height: 12),
              if (booking.status == 'Upcoming')
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _cancelBooking(booking);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _joinConsultation(booking);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(
                          'Join',
                          style: TextStyle(fontSize: 13, color: Colors.white),
                        ),
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

  Widget _buildBookingDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textLight,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: textLight, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                currentIndex = 0;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _processPayment(DoctorModel doctor, ConsultationType consultation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Processing Payment', style: TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: primaryColor),
            const SizedBox(height: 16),
            Text('Booking appointment with ${doctor.name}',
                style: TextStyle(fontSize: 13)),
            const SizedBox(height: 8),
            Text('${consultation.name} - ${consultation.price}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop();

      final newBooking = BookingModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        doctorName: doctor.name,
        specialty: doctor.specialty,
        consultationType: consultation.name,
        date: '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
        time: '${DateTime.now().hour}:${DateTime.now().minute}',
        amount: consultation.price,
        status: 'Upcoming',
        doctorImage: doctor.imageUrl,
      );

      setState(() {
        bookings.add(newBooking);
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Payment Successful!',
              style: TextStyle(color: Colors.green, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 40),
              const SizedBox(height: 16),
              Text('Appointment booked with Dr. ${doctor.name}',
                  style: TextStyle(fontSize: 13)),
              const SizedBox(height: 8),
              Text('${consultation.name} - ${consultation.price}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Text('You will receive a confirmation shortly.',
                  style: TextStyle(fontSize: 12, color: textSecondary)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  currentIndex = 4;
                  selectedSpecialty = null;
                  selectedConsultationType = null;
                  selectedDoctor = null;
                });
              },
              child: Text('View Bookings', style: TextStyle(color: primaryColor)),
            ),
          ],
        ),
      );
    });
  }

  void _cancelBooking(BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Cancel Booking', style: TextStyle(fontSize: 16)),
        content: Text('Are you sure you want to cancel this appointment?',
            style: TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('No', style: TextStyle(color: textSecondary)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                booking.status = 'Cancelled';
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Appointment cancelled'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Yes', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _joinConsultation(BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Join Consultation', style: TextStyle(fontSize: 16)),
        content: Text('Connecting you with ${booking.doctorName}...',
            style: TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close', style: TextStyle(color: primaryColor)),
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
  final IconData icon;
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
  final String imageUrl;

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
    required this.imageUrl,
  });
}

class BookingModel {
  final String id;
  final String doctorName;
  final String specialty;
  final String consultationType;
  final String date;
  final String time;
  final String amount;
  String status;
  final String doctorImage;

  BookingModel({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.consultationType,
    required this.date,
    required this.time,
    required this.amount,
    required this.status,
    required this.doctorImage,
  });
}