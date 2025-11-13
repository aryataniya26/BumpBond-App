// import 'package:bump_bond_flutter_app/widgets/medication_reminder_dialog.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//
//   void _showAddMedicationDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => const MedicationReminderDialog(),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFFF5F7),
//       body: Column(
//         children: [
//           // ... existing home screen content ...
//
//           // Add Reminder Button
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: ElevatedButton.icon(
//               onPressed: _showAddMedicationDialog,
//               icon: const Icon(Icons.medical_services),
//               label: const Text('Add Medication Reminder'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFB794F4),
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }