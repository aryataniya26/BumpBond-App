import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class BookConsultationScreen extends StatefulWidget {
  const BookConsultationScreen({Key? key}) : super(key: key);

  @override
  State<BookConsultationScreen> createState() => _BookConsultationScreenState();
}

class _BookConsultationScreenState extends State<BookConsultationScreen> {
  DateTime? selectedDate;
  String? selectedTime;
  String? selectedDuration;
  String? consultationType;
  List<Map<String, dynamic>> savedBookings = [];

  final List<String> timeSlots = [
    '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM',
    '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM',
    '05:00 PM', '05:30 PM', '06:00 PM', '06:30 PM', '07:00 PM', '07:30 PM',
  ];

  // सिर्फ 15 mins और 30 mins के options
  final List<String> durations = ['15 mins', '30 mins'];

  final List<String> consultationTypes = [
    'General Checkup',
    'Nutrition Counseling',
    'Prenatal Exercise',
    'Mental Health Support',
    'Labor Preparation'
  ];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  // Duration के according price calculate करने का function
  int _getPrice() {
    switch (selectedDuration) {
      case '15 mins':
        return 99;
      case '30 mins':
        return 499;
      default:
        return 0;
    }
  }

  Future<void> _loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final bookingsJson = prefs.getStringList('bookings') ?? [];
    setState(() {
      savedBookings = bookingsJson.map((json) {
        final parts = json.split('|');
      return {
        'date': parts[0],
        'time': parts[1],
        'duration': parts[2],
        'type': parts[3],
        'price': parts[4],
        'doctor': parts.length > 5 ? parts[5] : 'Dr. Not Assigned', // Add this
      };
      }).toList();
    });
  }

  Future<void> _saveBooking() async {
    if (selectedDate == null || selectedTime == null || selectedDuration == null || consultationType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select all fields')),
      );
      return;
    }

    // Payment integration के लिए proceed करें
    _showPaymentConfirmation();
  }

  void _showPaymentConfirmation() {
    final price = _getPrice();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Booking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Consultation Type: $consultationType'),
              Text('Date: ${DateFormat('dd/MM/yyyy').format(selectedDate!)}'),
              Text('Time: $selectedTime'),
              Text('Duration: $selectedDuration'),
              const SizedBox(height: 10),
              Text(
                'Amount: ₹$price',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _processPayment(price),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
              ),
              child: const Text('Proceed to Pay'),
            ),
          ],
        );
      },
    );
  }

  // Future<void> _processPayment(int amount) async {
  //   // TODO: Actual payment gateway integration add in this
  //   // For now, we'll simulate successful payment
  //
  //   Navigator.of(context).pop(); // Dialog close
  //
  //   // Save booking after successful payment
  //   final prefs = await SharedPreferences.getInstance();
  //   final dateStr = DateFormat('dd/MM/yyyy').format(selectedDate!);
  //   final bookingStr = '$dateStr|$selectedTime|$selectedDuration|$consultationType|₹$amount|Dr. Not Assigned';
  //   final bookings = prefs.getStringList('bookings') ?? [];
  //   bookings.add(bookingStr);
  //   await prefs.setStringList('bookings', bookings);
  //
  //   setState(() {
  //     savedBookings.add({
  //       'date': dateStr,
  //       'time': selectedTime,
  //       'duration': selectedDuration,
  //       'type': consultationType,
  //       'price': '₹$amount',
  //     });
  //     selectedDate = null;
  //     selectedTime = null;
  //     selectedDuration = null;
  //     consultationType = null;
  //   });
  //
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Payment successful! Consultation booked.')),
  //   );
  // }
  Future<void> _processPayment(int amount) async {
    // TODO: Add Actual payment gateway integration
    // For now, we'll simulate successful payment

    Navigator.of(context).pop(); // Dialog close

    // Save booking after successful payment - FORMAT UPDATE KARO
    final prefs = await SharedPreferences.getInstance();
    final dateStr = DateFormat('dd/MM/yyyy').format(selectedDate!);
    final bookingStr = '$dateStr|$selectedTime|$selectedDuration|$consultationType|₹$amount|Dr. Not Assigned'; // Doctor add karo

    final bookings = prefs.getStringList('bookings') ?? [];
    bookings.add(bookingStr);
    await prefs.setStringList('bookings', bookings);

    setState(() {
      savedBookings.add({
        'date': dateStr,
        'time': selectedTime,
        'duration': selectedDuration,
        'type': consultationType,
        'price': '₹$amount',
        'doctor': 'Dr. Not Assigned',
      });
      selectedDate = null;
      selectedTime = null;
      selectedDuration = null;
      consultationType = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment successful! Consultation booked.')),
    );
  }

  Future<void> _deleteBooking(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final bookings = prefs.getStringList('bookings') ?? [];
    bookings.removeAt(index);
    await prefs.setStringList('bookings', bookings);

    setState(() => savedBookings.removeAt(index));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking cancelled')),
    );
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6366F1),
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Consultation'),
        backgroundColor: const Color(0xFF6366F1),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Booking Form Section
            Container(
              color: const Color(0xFFF8F9FA),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Schedule Your Consultation',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Consultation Type
                  const Text(
                    'Consultation Type',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: consultationTypes.map((type) {
                      final isSelected = consultationType == type;
                      return GestureDetector(
                        onTap: () => setState(() => consultationType = type),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF6366F1) : Colors.white,
                            border: Border.all(
                              color: isSelected ? const Color(0xFF6366F1) : Colors.grey[300]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Date Selection
                  const Text(
                    'Select Date',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Color(0xFF6366F1)),
                          const SizedBox(width: 12),
                          Text(
                            selectedDate != null
                                ? DateFormat('dd MMM yyyy').format(selectedDate!)
                                : 'Pick a date',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Time Selection
                  const Text(
                    'Select Time',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: timeSlots.length,
                    itemBuilder: (context, index) {
                      final time = timeSlots[index];
                      final isSelected = selectedTime == time;
                      return GestureDetector(
                        onTap: () => setState(() => selectedTime = time),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF6366F1) : Colors.white,
                            border: Border.all(
                              color: isSelected ? const Color(0xFF6366F1) : Colors.grey[300]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              time,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Duration Selection with Prices
                  const Text(
                    'Duration & Pricing',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: durations.map((duration) {
                      final isSelected = selectedDuration == duration;
                      final price = duration == '15 mins' ? 99 : 499;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => selectedDuration = duration),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF6366F1) : Colors.white,
                              border: Border.all(
                                color: isSelected ? const Color(0xFF6366F1) : Colors.grey[300]!,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  duration,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '₹$price',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Selected Duration Price Display
                  if (selectedDuration != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                          Text(
                            '₹${_getPrice()}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Book Consultation Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Book Consultation',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Booking Summary Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booking Summary',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (savedBookings.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text(
                          'No bookings yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: savedBookings.length,
                      itemBuilder: (context, index) {
                        final booking = savedBookings[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey[200]!),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          booking['type'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today,
                                                size: 14, color: Colors.grey[600]),
                                            const SizedBox(width: 6),
                                            Text(booking['date'],
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600])),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.access_time,
                                                size: 14, color: Colors.grey[600]),
                                            const SizedBox(width: 6),
                                            Text(
                                              '${booking['time']} • ${booking['duration']}',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600]),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.payment,
                                                size: 14, color: Colors.grey[600]),
                                            const SizedBox(width: 6),
                                            Text(
                                              booking['price'],
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => _deleteBooking(index),
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
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


// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
//
// class BookConsultationScreen extends StatefulWidget {
//   const BookConsultationScreen({Key? key}) : super(key: key);
//
//   @override
//   State<BookConsultationScreen> createState() => _BookConsultationScreenState();
// }
//
// class _BookConsultationScreenState extends State<BookConsultationScreen> {
//   DateTime? selectedDate;
//   String? selectedTime;
//   String? selectedDuration;
//   String? consultationType;
//   List<Map<String, dynamic>> savedBookings = [];
//
//   final List<String> timeSlots = [
//     '09:00 AM', '09:30 AM', '10:00 AM', '10:30 AM', '11:00 AM', '11:30 AM',
//     '02:00 PM', '02:30 PM', '03:00 PM', '03:30 PM', '04:00 PM', '04:30 PM',
//     '05:00 PM', '05:30 PM', '06:00 PM', '06:30 PM', '07:00 PM', '07:30 PM',
//   ];
//
//   final List<String> durations = ['30 mins', '45 mins', '60 mins', '90 mins'];
//
//   final List<String> consultationTypes = [
//     'General Checkup',
//     'Nutrition Counseling',
//     'Prenatal Exercise',
//     'Mental Health Support',
//     'Labor Preparation'
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadBookings();
//   }
//
//   Future<void> _loadBookings() async {
//     final prefs = await SharedPreferences.getInstance();
//     final bookingsJson = prefs.getStringList('bookings') ?? [];
//     setState(() {
//       savedBookings = bookingsJson.map((json) {
//         final parts = json.split('|');
//         return {
//           'date': parts[0],
//           'time': parts[1],
//           'duration': parts[2],
//           'type': parts[3],
//         };
//       }).toList();
//     });
//   }
//
//   Future<void> _saveBooking() async {
//     if (selectedDate == null || selectedTime == null || selectedDuration == null || consultationType == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select all fields')),
//       );
//       return;
//     }
//
//     final prefs = await SharedPreferences.getInstance();
//     final dateStr = DateFormat('dd/MM/yyyy').format(selectedDate!);
//     final bookingStr = '$dateStr|$selectedTime|$selectedDuration|$consultationType';
//
//     final bookings = prefs.getStringList('bookings') ?? [];
//     bookings.add(bookingStr);
//     await prefs.setStringList('bookings', bookings);
//
//     setState(() {
//       savedBookings.add({
//         'date': dateStr,
//         'time': selectedTime,
//         'duration': selectedDuration,
//         'type': consultationType,
//       });
//       selectedDate = null;
//       selectedTime = null;
//       selectedDuration = null;
//       consultationType = null;
//     });
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Consultation booked successfully!')),
//     );
//   }
//
//   Future<void> _deleteBooking(int index) async {
//     final prefs = await SharedPreferences.getInstance();
//     final bookings = prefs.getStringList('bookings') ?? [];
//     bookings.removeAt(index);
//     await prefs.setStringList('bookings', bookings);
//
//     setState(() => savedBookings.removeAt(index));
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Booking cancelled')),
//     );
//   }
//
//   void _pickDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime.now().add(const Duration(days: 90)),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFF6366F1),
//               surface: Colors.white,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null) {
//       setState(() => selectedDate = picked);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Book Consultation'),
//         backgroundColor: const Color(0xFF6366F1),
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Booking Form Section
//             Container(
//               color: const Color(0xFFF8F9FA),
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Schedule Your Consultation',
//                     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 20),
//
//                   // Consultation Type
//                   const Text(
//                     'Consultation Type',
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//                   ),
//                   const SizedBox(height: 10),
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: consultationTypes.map((type) {
//                       final isSelected = consultationType == type;
//                       return GestureDetector(
//                         onTap: () => setState(() => consultationType = type),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                           decoration: BoxDecoration(
//                             color: isSelected ? const Color(0xFF6366F1) : Colors.white,
//                             border: Border.all(
//                               color: isSelected ? const Color(0xFF6366F1) : Colors.grey[300]!,
//                               width: 2,
//                             ),
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Text(
//                             type,
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: isSelected ? Colors.white : Colors.black,
//                             ),
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                   const SizedBox(height: 24),
//
//                   // Date Selection
//                   const Text(
//                     'Select Date',
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//                   ),
//                   const SizedBox(height: 10),
//                   GestureDetector(
//                     onTap: _pickDate,
//                     child: Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         border: Border.all(color: Colors.grey[300]!),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Row(
//                         children: [
//                           const Icon(Icons.calendar_today, color: Color(0xFF6366F1)),
//                           const SizedBox(width: 12),
//                           Text(
//                             selectedDate != null
//                                 ? DateFormat('dd MMM yyyy').format(selectedDate!)
//                                 : 'Pick a date',
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//
//                   // Time Selection
//                   const Text(
//                     'Select Time',
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//                   ),
//                   const SizedBox(height: 10),
//                   GridView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 3,
//                       mainAxisSpacing: 8,
//                       crossAxisSpacing: 8,
//                       childAspectRatio: 2.5,
//                     ),
//                     itemCount: timeSlots.length,
//                     itemBuilder: (context, index) {
//                       final time = timeSlots[index];
//                       final isSelected = selectedTime == time;
//                       return GestureDetector(
//                         onTap: () => setState(() => selectedTime = time),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: isSelected ? const Color(0xFF6366F1) : Colors.white,
//                             border: Border.all(
//                               color: isSelected ? const Color(0xFF6366F1) : Colors.grey[300]!,
//                               width: 2,
//                             ),
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Center(
//                             child: Text(
//                               time,
//                               style: TextStyle(
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w600,
//                                 color: isSelected ? Colors.white : Colors.black,
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 24),
//
//                   // Duration Selection
//                   const Text(
//                     'Duration',
//                     style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//                   ),
//                   const SizedBox(height: 10),
//                   Row(
//                     children: durations.map((duration) {
//                       final isSelected = selectedDuration == duration;
//                       return Expanded(
//                         child: GestureDetector(
//                           onTap: () => setState(() => selectedDuration = duration),
//                           child: Container(
//                             margin: const EdgeInsets.only(right: 8),
//                             padding: const EdgeInsets.symmetric(vertical: 12),
//                             decoration: BoxDecoration(
//                               color: isSelected ? const Color(0xFF6366F1) : Colors.white,
//                               border: Border.all(
//                                 color: isSelected ? const Color(0xFF6366F1) : Colors.grey[300]!,
//                                 width: 2,
//                               ),
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 duration,
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600,
//                                   color: isSelected ? Colors.white : Colors.black,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                   const SizedBox(height: 24),
//
//                   // Save Button
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _saveBooking,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF6366F1),
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: const Text(
//                         'Book Consultation',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Booking Summary Section
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Booking Summary',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 16),
//                   if (savedBookings.isEmpty)
//                     Center(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 20),
//                         child: Text(
//                           'No bookings yet',
//                           style: TextStyle(color: Colors.grey[600]),
//                         ),
//                       ),
//                     )
//                   else
//                     ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: savedBookings.length,
//                       itemBuilder: (context, index) {
//                         final booking = savedBookings[index];
//                         return Container(
//                           margin: const EdgeInsets.only(bottom: 12),
//                           padding: const EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             border: Border.all(color: Colors.grey[200]!),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           booking['type'],
//                                           style: const TextStyle(
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Row(
//                                           children: [
//                                             Icon(Icons.calendar_today,
//                                                 size: 14, color: Colors.grey[600]),
//                                             const SizedBox(width: 6),
//                                             Text(booking['date'],
//                                                 style: TextStyle(
//                                                     fontSize: 12,
//                                                     color: Colors.grey[600])),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Row(
//                                           children: [
//                                             Icon(Icons.access_time,
//                                                 size: 14, color: Colors.grey[600]),
//                                             const SizedBox(width: 6),
//                                             Text(
//                                               '${booking['time']} • ${booking['duration']}',
//                                               style: TextStyle(
//                                                   fontSize: 12,
//                                                   color: Colors.grey[600]),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   IconButton(
//                                     onPressed: () => _deleteBooking(index),
//                                     icon: const Icon(Icons.delete_outline,
//                                         color: Colors.red),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }