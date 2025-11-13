import 'package:flutter/material.dart';
import '../models/pregnancy_data.dart';
import 'package:bump_bond_flutter_app/main.dart';

class BabyNicknameScreen extends StatefulWidget {
  final PregnancyData pregnancyData;

  const BabyNicknameScreen({Key? key, required this.pregnancyData}) : super(key: key);

  @override
  State<BabyNicknameScreen> createState() => _BabyNicknameScreenState();
}

class _BabyNicknameScreenState extends State<BabyNicknameScreen> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isLoading = false;

  // ✅ Popular nickname suggestions
  final List<String> _suggestions = [
    'Little One', 'Baby Bean', 'Sweetpea', 'Peanut',
    'Sunshine', 'Angel', 'Nugget', 'Bub', 'Munchkin',
    'Cupcake', 'Buttercup', 'Sprout', 'Bubba', 'Love Bug'
  ];



  @override
  void initState() {
    super.initState();

    // Pre-fill existing nickname if available
    if (widget.pregnancyData.babyNickname != null &&
        widget.pregnancyData.babyNickname!.isNotEmpty) {
      _nicknameController.text = widget.pregnancyData.babyNickname!;
    }

    print('BabyNicknameScreen - Existing nickname: ${widget.pregnancyData.babyNickname}');
  }



    Future<void> _saveAndContinue() async {
    final nickname = _nicknameController.text.trim();

    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a nickname for your baby'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // ✅ Save nickname
    widget.pregnancyData.babyNickname = nickname;
    await widget.pregnancyData.saveToPrefs();

    if (!mounted) return;

    // ✅ Navigate to home screen
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
    );
  }

  void _skipForNow() async {
    // ✅ Set default nickname if skipped
    widget.pregnancyData.babyNickname = 'Baby';
    await widget.pregnancyData.saveToPrefs();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Name Your Baby'),
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

            // ✅ Baby emoji
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFB794F4).withOpacity(0.2),
                    const Color(0xFFFCE7F3).withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Center(
                child: Text(
                  widget.pregnancyData.babyEmoji,
                  style: const TextStyle(fontSize: 60),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Give your baby a nickname! 👶',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              'This nickname will appear throughout the app.\nYou can change it anytime.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // ✅ Nickname input field
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
              child: TextField(
                controller: _nicknameController,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFB794F4),
                ),
                decoration: InputDecoration(
                  hintText: 'Enter nickname...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.normal,
                  ),
                  prefixIcon: const Icon(
                    Icons.favorite,
                    color: Color(0xFFB794F4),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ✅ Suggestions
            const Text(
              'Popular Suggestions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),

            const SizedBox(height: 16),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: _suggestions.map((name) {
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _nicknameController.text = name;
                    },
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFCE7F3),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: const Color(0xFFB794F4).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFB794F4),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 40),

            // ✅ Save button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveAndContinue,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: const Color(0xFFB794F4),
                elevation: 3,
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ✅ Skip button
            TextButton(
              onPressed: _isLoading ? null : _skipForNow,
              child: Text(
                'Skip for now',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }
}


// import 'package:flutter/material.dart';
// import '../models/pregnancy_data.dart';
// import 'package:bump_bond_flutter_app/main.dart';
//
// class BabyNicknameScreen extends StatefulWidget {
//   final PregnancyData pregnancyData;
//
//   const BabyNicknameScreen({Key? key, required this.pregnancyData}) : super(key: key);
//
//   @override
//   State<BabyNicknameScreen> createState() => _BabyNicknameScreenState();
// }
//
// class _BabyNicknameScreenState extends State<BabyNicknameScreen> {
//   final TextEditingController _nicknameController = TextEditingController();
//   bool _isLoading = false;
//
//   // ✅ Popular nickname suggestions
//   final List<String> _suggestions = [
//     'Little One', 'Baby Bean', 'Sweetpea', 'Peanut',
//     'Sunshine', 'Angel', 'Nugget', 'Bub', 'Munchkin',
//     'Cupcake', 'Buttercup', 'Sprout', 'Bubba', 'Love Bug'
//   ];
//
//   Future<void> _saveAndContinue() async {
//     final nickname = _nicknameController.text.trim();
//
//     if (nickname.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter a nickname for your baby'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     // ✅ Save nickname
//     widget.pregnancyData.babyNickname = nickname;
//     await widget.pregnancyData.saveToPrefs();
//
//     if (!mounted) return;
//
//     // ✅ Navigate to home screen
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (context) => const MainScreen()),
//           (route) => false,
//     );
//   }
//
//   void _skipForNow() async {
//     // ✅ Set default nickname if skipped
//     widget.pregnancyData.babyNickname = 'Baby';
//     await widget.pregnancyData.saveToPrefs();
//
//     if (!mounted) return;
//
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(builder: (context) => const MainScreen()),
//           (route) => false,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F7F7),
//       appBar: AppBar(
//         title: const Text('Name Your Baby'),
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
//             // ✅ Baby emoji
//             Container(
//               width: 120,
//               height: 120,
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     const Color(0xFFB794F4).withOpacity(0.2),
//                     const Color(0xFFFCE7F3).withOpacity(0.3),
//                   ],
//                 ),
//                 borderRadius: BorderRadius.circular(60),
//               ),
//               child: Center(
//                 child: Text(
//                   widget.pregnancyData.babyEmoji,
//                   style: const TextStyle(fontSize: 60),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 24),
//
//             const Text(
//               'Give your baby a nickname! 👶',
//               style: TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF1F2937),
//               ),
//               textAlign: TextAlign.center,
//             ),
//
//             const SizedBox(height: 12),
//
//             Text(
//               'This nickname will appear throughout the app.\nYou can change it anytime.',
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
//             // ✅ Nickname input field
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
//               child: TextField(
//                 controller: _nicknameController,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFFB794F4),
//                 ),
//                 decoration: InputDecoration(
//                   hintText: 'Enter nickname...',
//                   hintStyle: TextStyle(
//                     color: Colors.grey[400],
//                     fontWeight: FontWeight.normal,
//                   ),
//                   prefixIcon: const Icon(
//                     Icons.favorite,
//                     color: Color(0xFFB794F4),
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20),
//                     borderSide: BorderSide.none,
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 18,
//                   ),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 32),
//
//             // ✅ Suggestions
//             const Text(
//               'Popular Suggestions',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF1F2937),
//               ),
//             ),
//
//             const SizedBox(height: 16),
//
//             Wrap(
//               spacing: 10,
//               runSpacing: 10,
//               alignment: WrapAlignment.center,
//               children: _suggestions.map((name) {
//                 return Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     onTap: () {
//                       _nicknameController.text = name;
//                     },
//                     borderRadius: BorderRadius.circular(25),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 10,
//                       ),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFFCE7F3),
//                         borderRadius: BorderRadius.circular(25),
//                         border: Border.all(
//                           color: const Color(0xFFB794F4).withOpacity(0.3),
//                           width: 1,
//                         ),
//                       ),
//                       child: Text(
//                         name,
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w500,
//                           color: Color(0xFFB794F4),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//
//             const SizedBox(height: 40),
//
//             // ✅ Save button
//             ElevatedButton(
//               onPressed: _isLoading ? null : _saveAndContinue,
//               style: ElevatedButton.styleFrom(
//                 minimumSize: const Size.fromHeight(56),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 backgroundColor: const Color(0xFFB794F4),
//                 elevation: 3,
//               ),
//               child: _isLoading
//                   ? const SizedBox(
//                 height: 24,
//                 width: 24,
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2.5,
//                 ),
//               )
//                   : const Text(
//                 'Continue',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 12),
//
//             // ✅ Skip button
//             TextButton(
//               onPressed: _isLoading ? null : _skipForNow,
//               child: Text(
//                 'Skip for now',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey[600],
//                   decoration: TextDecoration.underline,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _nicknameController.dispose();
//     super.dispose();
//   }
// }