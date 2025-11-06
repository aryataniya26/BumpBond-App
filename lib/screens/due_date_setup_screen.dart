import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pregnancy_data.dart';
import 'due_date_confirmation_screen.dart';

class DueDateSetupScreen extends StatefulWidget {
  const DueDateSetupScreen({Key? key}) : super(key: key);

  @override
  State<DueDateSetupScreen> createState() => _DueDateSetupScreenState();
}

class _DueDateSetupScreenState extends State<DueDateSetupScreen> {
  PregnancyData _data = PregnancyData();

  String _estimationMethod = "First day of last period";
  final List<String> _methods = [
    "First day of last period",
    "Estimated due date",
    "Date of conception"
  ];

  String _selectedDateText = "Select Date";
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _data = await PregnancyData.loadFromPrefs();
    setState(() {
      if (_data.dueDate != null) {
        _selectedDateText = DateFormat.yMd().format(_data.dueDate!);
        _selectedDate = _data.dueDate;
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    // ✅ Allow user to pick *any date* in the full calendar range
    DateTime now = DateTime.now();
    DateTime firstDate = DateTime(1900); // allows very old past dates
    DateTime lastDate = DateTime(2100); // allows far future dates

    // Suggest a meaningful initial date
    DateTime initialDate = _selectedDate ?? now;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFB794F4),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedDateText = DateFormat.yMMMd().format(picked);

        // ✅ Calculate based on selected method
        if (_estimationMethod == "First day of last period") {
          _data.lastPeriodDate = picked;
          _data.calculateDueDateFromLMP();
        } else if (_estimationMethod == "Estimated due date") {
          _data.dueDate = picked;
          _data.lastPeriodDate = picked.subtract(const Duration(days: 280));
        } else if (_estimationMethod == "Date of conception") {
          _data.conceptionDate = picked;
          _data.dueDate = picked.add(const Duration(days: 266));
          _data.lastPeriodDate = picked.subtract(const Duration(days: 14));
        }
      });
    }
  }

  void _continue() async {
    if (_data.dueDate == null || _data.lastPeriodDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a date first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    await _data.saveToPrefs();

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DueDateConfirmationScreen(pregnancyData: _data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDateSelected = _selectedDate != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Set Your Due Date'),
        backgroundColor: const Color(0xFFB794F4),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFB794F4).withOpacity(0.2),
                    const Color(0xFFFCE7F3).withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: const Center(
                child: Text('🤰', style: TextStyle(fontSize: 50)),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Set your due date 🗓️',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Choose how you want to calculate your due date.\nYou can change it anytime!',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // ✅ Method Dropdown
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Text(
                      'Based on',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: DropdownButtonFormField<String>(
                      value: _estimationMethod,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF9FAFB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      items: _methods.map((method) {
                        return DropdownMenuItem(
                          value: method,
                          child: Text(
                            method,
                            style: const TextStyle(fontSize: 15),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _estimationMethod = value!;
                          _selectedDateText = "Select Date";
                          _selectedDate = null;
                          _data.lastPeriodDate = null;
                          _data.dueDate = null;
                          _data.conceptionDate = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 18,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isDateSelected
                                ? const Color(0xFFB794F4)
                                : Colors.grey.shade300,
                            width: isDateSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  color: isDateSelected
                                      ? const Color(0xFFB794F4)
                                      : Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedDateText,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isDateSelected
                                        ? const Color(0xFF1F2937)
                                        : Colors.grey[500],
                                    fontWeight: isDateSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_estimationMethod == "First day of last period")
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE7F3).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFFB794F4),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'We calculate using a standard 28-day cycle (280 days total)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: isDateSelected ? _continue : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDateSelected
                    ? const Color(0xFFB794F4)
                    : Colors.grey[300],
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: isDateSelected ? 3 : 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDateSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  if (isDateSelected) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import '../models/pregnancy_data.dart';
// import 'due_date_confirmation_screen.dart';
//
// class DueDateSetupScreen extends StatefulWidget {
//   const DueDateSetupScreen({Key? key}) : super(key: key);
//
//   @override
//   State<DueDateSetupScreen> createState() => _DueDateSetupScreenState();
// }
//
// class _DueDateSetupScreenState extends State<DueDateSetupScreen> {
//   PregnancyData _data = PregnancyData();
//
//   String _estimationMethod = "First day of last period";
//   final List<String> _methods = [
//     "First day of last period",
//     "Estimated due date",
//     "Date of conception"
//   ];
//
//   String _selectedDateText = "Select Date";
//   DateTime? _selectedDate;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }
//
//   Future<void> _loadData() async {
//     _data = await PregnancyData.loadFromPrefs();
//     setState(() {
//       if (_data.dueDate != null) {
//         _selectedDateText = DateFormat.yMd().format(_data.dueDate!);
//         _selectedDate = _data.dueDate;
//       }
//     });
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     DateTime initialDate;
//     DateTime firstDate;
//     DateTime lastDate;
//
//     if (_estimationMethod == "First day of last period") {
//       // LMP can be up to 40 weeks ago
//       initialDate = DateTime.now().subtract(const Duration(days: 280));
//       firstDate = DateTime.now().subtract(const Duration(days: 365));
//       lastDate = DateTime.now();
//     } else if (_estimationMethod == "Estimated due date") {
//       // Due date is in the future
//       initialDate = DateTime.now().add(const Duration(days: 280));
//       firstDate = DateTime.now();
//       lastDate = DateTime.now().add(const Duration(days: 365));
//     } else {
//       // Conception date (1-2 weeks after LMP, typically)
//       initialDate = DateTime.now().subtract(const Duration(days: 266));
//       firstDate = DateTime.now().subtract(const Duration(days: 365));
//       lastDate = DateTime.now();
//     }
//
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? initialDate,
//       firstDate: firstDate,
//       lastDate: lastDate,
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFFB794F4),
//               onPrimary: Colors.white,
//               onSurface: Color(0xFF1F2937),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null) {
//       setState(() {
//         _selectedDate = picked;
//         _selectedDateText = DateFormat.yMMMd().format(picked);
//
//         // ✅ Calculate based on selected method
//         if (_estimationMethod == "First day of last period") {
//           _data.lastPeriodDate = picked;
//           _data.calculateDueDateFromLMP();
//         } else if (_estimationMethod == "Estimated due date") {
//           _data.dueDate = picked;
//           // Calculate LMP backwards (40 weeks before due date)
//           _data.lastPeriodDate = picked.subtract(const Duration(days: 280));
//         } else if (_estimationMethod == "Date of conception") {
//           _data.conceptionDate = picked;
//           // Due date is 266 days (38 weeks) after conception
//           _data.dueDate = picked.add(const Duration(days: 266));
//           // LMP is 14 days before conception
//           _data.lastPeriodDate = picked.subtract(const Duration(days: 14));
//         }
//       });
//     }
//   }
//
//   void _continue() async {
//     if (_data.dueDate == null || _data.lastPeriodDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please select a date first'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     await _data.saveToPrefs();
//
//     if (!mounted) return;
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => DueDateConfirmationScreen(pregnancyData: _data),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     bool isDateSelected = _selectedDate != null;
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F7F7),
//       appBar: AppBar(
//         title: const Text('Set Your Due Date'),
//         backgroundColor: const Color(0xFFB794F4),
//         elevation: 0,
//         automaticallyImplyLeading: false,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const SizedBox(height: 20),
//
//             // ✅ Header with emoji
//             Container(
//               width: 100,
//               height: 100,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     const Color(0xFFB794F4).withOpacity(0.2),
//                     const Color(0xFFFCE7F3).withOpacity(0.3),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(50),
//               ),
//               child: const Center(
//                 child: Text('🤰', style: TextStyle(fontSize: 50)),
//               ),
//             ),
//
//             const SizedBox(height: 24),
//
//             const Text(
//               'Set your due date 🗓️',
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF1F2937),
//               ),
//             ),
//
//             const SizedBox(height: 12),
//
//             Text(
//               'Choose how you want to calculate your due date.\nYou can change it anytime!',
//               style: TextStyle(
//                 fontSize: 15,
//                 color: Colors.grey[600],
//                 height: 1.5,
//               ),
//               textAlign: TextAlign.center,
//             ),
//
//             const SizedBox(height: 32),
//
//             // ✅ Method Selection
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.1),
//                     blurRadius: 15,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
//                     child: Text(
//                       'Based on',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 20),
//                     child: DropdownButtonFormField<String>(
//                       value: _estimationMethod,
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: const Color(0xFFF9FAFB),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(15),
//                           borderSide: BorderSide.none,
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 16,
//                         ),
//                       ),
//                       items: _methods.map((method) {
//                         return DropdownMenuItem(
//                           value: method,
//                           child: Text(
//                             method,
//                             style: const TextStyle(fontSize: 15),
//                           ),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _estimationMethod = value!;
//                           _selectedDateText = "Select Date";
//                           _selectedDate = null;
//                           _data.lastPeriodDate = null;
//                           _data.dueDate = null;
//                           _data.conceptionDate = null;
//                         });
//                       },
//                     ),
//                   ),
//
//                   const SizedBox(height: 20),
//
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
//                     child: Text(
//                       'Date',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.grey[700],
//                       ),
//                     ),
//                   ),
//
//                   // ✅ Date Picker
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//                     child: InkWell(
//                       onTap: () => _selectDate(context),
//                       borderRadius: BorderRadius.circular(15),
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 18,
//                           horizontal: 16,
//                         ),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFF9FAFB),
//                           borderRadius: BorderRadius.circular(15),
//                           border: Border.all(
//                             color: isDateSelected
//                                 ? const Color(0xFFB794F4)
//                                 : Colors.grey.shade300,
//                             width: isDateSelected ? 2 : 1,
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Row(
//                               children: [
//                                 Icon(
//                                   Icons.calendar_today_rounded,
//                                   color: isDateSelected
//                                       ? const Color(0xFFB794F4)
//                                       : Colors.grey[600],
//                                   size: 20,
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Text(
//                                   _selectedDateText,
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     color: isDateSelected
//                                         ? const Color(0xFF1F2937)
//                                         : Colors.grey[500],
//                                     fontWeight: isDateSelected
//                                         ? FontWeight.w600
//                                         : FontWeight.normal,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             Icon(
//                               Icons.arrow_drop_down,
//                               color: Colors.grey[600],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             // ✅ Info note
//             if (_estimationMethod == "First day of last period")
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFCE7F3).withOpacity(0.5),
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(
//                       Icons.info_outline,
//                       color: Color(0xFFB794F4),
//                       size: 20,
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(
//                         'We calculate using a standard 28-day cycle (280 days total)',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey[700],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//             const SizedBox(height: 40),
//
//             // ✅ Continue Button
//             ElevatedButton(
//               onPressed: isDateSelected ? _continue : null,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: isDateSelected
//                     ? const Color(0xFFB794F4)
//                     : Colors.grey[300],
//                 minimumSize: const Size(double.infinity, 56),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 elevation: isDateSelected ? 3 : 0,
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     "Continue",
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: isDateSelected ? Colors.white : Colors.grey[600],
//                     ),
//                   ),
//                   if (isDateSelected) ...[
//                     const SizedBox(width: 8),
//                     const Icon(
//                       Icons.arrow_forward_rounded,
//                       color: Colors.white,
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//           ],
//         ),
//       ),
//     );
//   }
// }
