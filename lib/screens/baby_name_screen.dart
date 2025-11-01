import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/gemini_service.dart';

class BabyNameScreen extends StatefulWidget {
  const BabyNameScreen({super.key});

  @override
  State<BabyNameScreen> createState() => _BabyNameScreenState();
}

class _BabyNameScreenState extends State<BabyNameScreen> {
  final TextEditingController _startingLetterController = TextEditingController();

  String selectedGender = '';
  String selectedReligion = '';
  List<String> generatedNames = [];
  bool loading = false;
  String errorMessage = '';

  final String apiKey = "AIzaSyCceYvJdUt2ql4tZk7Ze1DzxCE0r5azQIE";
  late GeminiService geminiService;

  final List<Map<String, dynamic>> religions = [
    {'name': 'Hindu', 'icon': Icons.self_improvement, 'color': Color(0xFFFF9800)},
    {'name': 'Muslim', 'icon': Icons.mosque, 'color': Color(0xFF4CAF50)},
    {'name': 'Christian', 'icon': Icons.church, 'color': Color(0xFF9C27B0)},
    {'name': 'Sikh', 'icon': Icons.account_balance, 'color': Color(0xFF2196F3)},
  ];

  @override
  void initState() {
    super.initState();
    geminiService = GeminiService(apiKey);
  }

  Future<void> generateNames() async {
    final gender = selectedGender.toLowerCase();
    final religion = selectedReligion;
    final letter = _startingLetterController.text.trim().toUpperCase();

    if (gender.isEmpty) {
      _showSnackbar('Please select a gender (Boy/Girl).');
      return;
    }
    if (religion.isEmpty) {
      _showSnackbar('Please select a religion.');
      return;
    }
    if (letter.isEmpty) {
      _showSnackbar('Please enter a starting letter.');
      return;
    }

    setState(() {
      loading = true;
      generatedNames = [];
      errorMessage = '';
    });

    String prompt = """Generate 8 authentic $religion baby $gender names that start with the letter '$letter'. 
These should be traditional and culturally appropriate $religion names.
Format: Only comma-separated names, no numbers, no explanations.
Example: Aarav, Arjun, Aditya, Aayush, Aryan, Arnav, Advait, Ansh

$religion $gender names starting with '$letter':""";

    try {
      String response = await geminiService.getResponse(prompt);

      List<String> names = response
          .split(RegExp(r'[,\n]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty && e.length > 1)
          .toList();

      names = names.map((name) {
        return name.replaceAll(RegExp(r'[^a-zA-Z\s]'), '').trim();
      }).where((name) =>
      name.length > 1 &&
          name[0].toUpperCase() == letter &&
          !RegExp(r'\d').hasMatch(name)
      ).take(8).toList();

      setState(() {
        generatedNames = names.isNotEmpty ? names : [];
        loading = false;
        if (names.isEmpty) {
          errorMessage = 'Unable to generate names. Please try a different letter.';
        }
      });

    } catch (e) {
      setState(() {
        loading = false;
        errorMessage = 'Error: ${e.toString()}';
        generatedNames = [];
      });
      _showSnackbar('Error generating names: ${e.toString()}');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFF2C3E50),
      ),
    );
  }

  @override
  void dispose() {
    _startingLetterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        title: Text(
          "Baby Name Generator",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF5DADE2), Color(0xFF3498DB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.child_care_outlined,
                        size: 48,
                        color: const Color(0xFF3498DB),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Find the Perfect Name",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "AI-powered culturally authentic name suggestions",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Gender Selection
              Text(
                "Select Gender",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedGender = 'boy'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: selectedGender == 'boy'
                              ? const Color(0xFF5DADE2)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedGender == 'boy'
                                ? const Color(0xFF3498DB)
                                : Colors.grey[300]!,
                            width: 1.5,
                          ),
                          boxShadow: [
                            if (selectedGender == 'boy')
                              BoxShadow(
                                color: const Color(0xFF3498DB).withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.boy_outlined,
                              size: 36,
                              color: selectedGender == 'boy'
                                  ? Colors.white
                                  : const Color(0xFF5DADE2),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Boy",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: selectedGender == 'boy'
                                    ? Colors.white
                                    : const Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedGender = 'girl'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: selectedGender == 'girl'
                              ? const Color(0xFFF06292)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedGender == 'girl'
                                ? const Color(0xFFE91E63)
                                : Colors.grey[300]!,
                            width: 1.5,
                          ),
                          boxShadow: [
                            if (selectedGender == 'girl')
                              BoxShadow(
                                color: const Color(0xFFE91E63).withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.girl_outlined,
                              size: 36,
                              color: selectedGender == 'girl'
                                  ? Colors.white
                                  : const Color(0xFFF06292),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Girl",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: selectedGender == 'girl'
                                    ? Colors.white
                                    : const Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Religion Selection
              Text(
                "Select Religion",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                ),
                itemCount: religions.length,
                itemBuilder: (context, index) {
                  final religion = religions[index];
                  final isSelected = selectedReligion == religion['name'];

                  return GestureDetector(
                    onTap: () => setState(() => selectedReligion = religion['name']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected ? religion['color'] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? religion['color']
                              : Colors.grey[300]!,
                          width: 1.5,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: (religion['color'] as Color).withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            religion['icon'],
                            size: 32,
                            color: isSelected ? Colors.white : religion['color'],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            religion['name'],
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF2C3E50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Starting Letter Input
              Text(
                "Starting Letter",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _startingLetterController,
                maxLength: 1,
                textCapitalization: TextCapitalization.characters,
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: "e.g., A",
                  hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.abc, color: Color(0xFF5DADE2)),
                  filled: true,
                  fillColor: Colors.white,
                  counterText: "",
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Generate Button
              Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5DADE2), Color(0xFF3498DB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3498DB).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: loading ? null : generateNames,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  child: loading
                      ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Generate Names",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Error Message Display
              if (errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorMessage,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Generated Names Display
              if (generatedNames.isNotEmpty) ...[
                const SizedBox(height: 16),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.stars,
                                color: Color(0xFF3498DB),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Suggested Names",
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF2C3E50),
                                    ),
                                  ),
                                  Text(
                                    "$selectedReligion • $selectedGender",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...generatedNames.asMap().entries.map((entry) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF5DADE2), Color(0xFF3498DB)],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "${entry.key + 1}",
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF2C3E50),
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.favorite_border,
                                  color: Colors.grey[400],
                                  size: 22,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../services/gemini_service.dart';
//
// class BabyNameScreen extends StatefulWidget {
//   const BabyNameScreen({super.key});
//
//   @override
//   State<BabyNameScreen> createState() => _BabyNameScreenState();
// }
//
// class _BabyNameScreenState extends State<BabyNameScreen> {
//   final TextEditingController _startingLetterController = TextEditingController();
//
//   String selectedGender = '';
//   List<String> generatedNames = [];
//   bool loading = false;
//   String errorMessage = '';
//
//   final String apiKey = "AIzaSyCceYvJdUt2ql4tZk7Ze1DzxCE0r5azQIE";
//   late GeminiService geminiService;
//
//   @override
//   void initState() {
//     super.initState();
//     geminiService = GeminiService(apiKey);
//   }
//
//   Future<void> generateNames() async {
//     final gender = selectedGender.toLowerCase();
//     final letter = _startingLetterController.text.trim().toUpperCase();
//
//     if (gender.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a gender (Boy/Girl).')),
//       );
//       return;
//     }
//     if (letter.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter a starting letter.')),
//       );
//       return;
//     }
//
//     setState(() {
//       loading = true;
//       generatedNames = [];
//       errorMessage = '';
//     });
//
//     // Better prompt for AI
//     String prompt = """Generate 5 unique baby $gender names that start with the letter '$letter'.
// Format your response as a simple comma-separated list with only the names. No numbering, no extra text, no explanation.
// Example format: Aarav, Arjun, Aditya, Aayush, Aryan
//
// Names starting with '$letter' for $gender babies:""";
//
//     try {
//       String response = await geminiService.getResponse(prompt);
//
//       print("Raw Response: $response");
//
//       // Parse response - clean and split
//       List<String> names = response
//           .split(',')
//           .map((e) => e.trim())
//           .where((e) => e.isNotEmpty && e.length > 1)
//           .toList();
//
//       // Remove any trailing punctuation
//       names = names.map((name) {
//         return name.replaceAll(RegExp(r'[^a-zA-Z\s]'), '').trim();
//       }).toList();
//
//       // Filter out invalid entries
//       names = names.where((name) => name.length > 1 && name[0].toUpperCase() == letter).toList();
//
//       setState(() {
//         generatedNames = names.isNotEmpty ? names : ['Unable to generate names'];
//         loading = false;
//         if (names.isEmpty) {
//           errorMessage = 'No valid names generated. Please try again.';
//         }
//       });
//
//     } catch (e) {
//       print("Error: $e");
//       setState(() {
//         loading = false;
//         errorMessage = 'Error: ${e.toString()}';
//         generatedNames = [];
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error generating names: ${e.toString()}')),
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _startingLetterController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         elevation: 0,
//         title: Text(
//           "Baby Name Generator",
//           style: GoogleFonts.poppins(
//             fontWeight: FontWeight.w700,
//             fontSize: 20,
//             color: Colors.white,
//           ),
//         ),
//         centerTitle: true,
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF5DADE2), Color(0xFF3498DB)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Header Card
//               Card(
//                 elevation: 4,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     children: [
//                       Icon(
//                         Icons.child_care_outlined,
//                         size: 48,
//                         color: const Color(0xFF3498DB),
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         "Find the Perfect Name",
//                         style: GoogleFonts.poppins(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                           color: const Color(0xFF2C3E50),
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         "AI-powered name suggestions for your little one",
//                         textAlign: TextAlign.center,
//                         style: GoogleFonts.poppins(
//                           fontSize: 13,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 28),
//
//               Text(
//                 "Select Gender",
//                 style: GoogleFonts.poppins(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                   color: const Color(0xFF2C3E50),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () => setState(() => selectedGender = 'boy'),
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         decoration: BoxDecoration(
//                           color: selectedGender == 'boy'
//                               ? const Color(0xFF5DADE2)
//                               : Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(
//                             color: selectedGender == 'boy'
//                                 ? const Color(0xFF3498DB)
//                                 : Colors.grey[300]!,
//                             width: 1.5,
//                           ),
//                           boxShadow: [
//                             if (selectedGender == 'boy')
//                               BoxShadow(
//                                 color: const Color(0xFF3498DB).withOpacity(0.2),
//                                 blurRadius: 6,
//                                 offset: const Offset(0, 3),
//                               ),
//                           ],
//                         ),
//                         child: Column(
//                           children: [
//                             Icon(
//                               Icons.boy_outlined,
//                               size: 36,
//                               color: selectedGender == 'boy'
//                                   ? Colors.white
//                                   : const Color(0xFF5DADE2),
//                             ),
//                             const SizedBox(height: 6),
//                             Text(
//                               "Boy",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w600,
//                                 color: selectedGender == 'boy'
//                                     ? Colors.white
//                                     : const Color(0xFF2C3E50),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: GestureDetector(
//                       onTap: () => setState(() => selectedGender = 'girl'),
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         decoration: BoxDecoration(
//                           color: selectedGender == 'girl'
//                               ? const Color(0xFFF06292)
//                               : Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(
//                             color: selectedGender == 'girl'
//                                 ? const Color(0xFFE91E63)
//                                 : Colors.grey[300]!,
//                             width: 1.5,
//                           ),
//                           boxShadow: [
//                             if (selectedGender == 'girl')
//                               BoxShadow(
//                                 color: const Color(0xFFE91E63).withOpacity(0.2),
//                                 blurRadius: 6,
//                                 offset: const Offset(0, 3),
//                               ),
//                           ],
//                         ),
//                         child: Column(
//                           children: [
//                             Icon(
//                               Icons.girl_outlined,
//                               size: 36,
//                               color: selectedGender == 'girl'
//                                   ? Colors.white
//                                   : const Color(0xFFF06292),
//                             ),
//                             const SizedBox(height: 6),
//                             Text(
//                               "Girl",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 15,
//                                 fontWeight: FontWeight.w600,
//                                 color: selectedGender == 'girl'
//                                     ? Colors.white
//                                     : const Color(0xFF2C3E50),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 24),
//
//               // Starting Letter Input
//               Text(
//                 "Starting Letter",
//                 style: GoogleFonts.poppins(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                   color: const Color(0xFF2C3E50),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               TextField(
//                 controller: _startingLetterController,
//                 maxLength: 1,
//                 textCapitalization: TextCapitalization.characters,
//                 style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
//                 decoration: InputDecoration(
//                   hintText: "e.g., A",
//                   hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
//                   prefixIcon: const Icon(Icons.abc, color: Color(0xFF5DADE2)),
//                   filled: true,
//                   fillColor: Colors.white,
//                   counterText: "",
//                   contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 28),
//
//               // Generate Button
//               Container(
//                 height: 52,
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [Color(0xFF5DADE2), Color(0xFF3498DB)],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color(0xFF3498DB).withOpacity(0.3),
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: ElevatedButton(
//                   onPressed: loading ? null : generateNames,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.transparent,
//                     shadowColor: Colors.transparent,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: EdgeInsets.zero,
//                   ),
//                   child: loading
//                       ? const SizedBox(
//                     height: 24,
//                     width: 24,
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 2.5,
//                     ),
//                   )
//                       : Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
//                       const SizedBox(width: 8),
//                       Text(
//                         "Generate Names",
//                         style: GoogleFonts.poppins(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 28),
//
//               // Error Message Display
//               if (errorMessage.isNotEmpty)
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.red[50],
//                     borderRadius: BorderRadius.circular(12),
//                     border: Border.all(color: Colors.red[200]!),
//                   ),
//                   child: Text(
//                     errorMessage,
//                     style: GoogleFonts.poppins(
//                       fontSize: 12,
//                       color: Colors.red[700],
//                     ),
//                   ),
//                 ),
//               const SizedBox(height: 16),
//
//               // Generated Names Display
//               if (generatedNames.isNotEmpty)
//                 Card(
//                   elevation: 4,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(20),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(8),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFE3F2FD),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: const Icon(
//                                 Icons.stars,
//                                 color: Color(0xFF3498DB),
//                                 size: 22,
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Text(
//                               "Suggested Names",
//                               style: GoogleFonts.poppins(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: const Color(0xFF2C3E50),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                         ...generatedNames.asMap().entries.map((entry) {
//                           return Container(
//                             margin: const EdgeInsets.only(bottom: 10),
//                             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFF8F9FA),
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(
//                                 color: Colors.grey[200]!,
//                                 width: 1,
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 Container(
//                                   width: 32,
//                                   height: 32,
//                                   decoration: BoxDecoration(
//                                     gradient: const LinearGradient(
//                                       colors: [Color(0xFF5DADE2), Color(0xFF3498DB)],
//                                     ),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   child: Center(
//                                     child: Text(
//                                       "${entry.key + 1}",
//                                       style: GoogleFonts.poppins(
//                                         color: Colors.white,
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 14),
//                                 Expanded(
//                                   child: Text(
//                                     entry.value,
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                       color: const Color(0xFF2C3E50),
//                                     ),
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.favorite_border,
//                                   color: Colors.grey[400],
//                                   size: 22,
//                                 ),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                       ],
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
