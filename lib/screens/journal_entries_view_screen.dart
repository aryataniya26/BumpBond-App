import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:io';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';

class JournalEntriesViewScreen extends StatefulWidget {
  const JournalEntriesViewScreen({Key? key}) : super(key: key);

  @override
  State<JournalEntriesViewScreen> createState() => _JournalEntriesViewScreenState();
}

class _JournalEntriesViewScreenState extends State<JournalEntriesViewScreen> {
  List<JournalEntry> _entries = [];
  bool _isLoading = true;
  bool _isGeneratingPDF = false;

  // Lavender color palette
  static const Color primaryLavender = Color(0xFF7C3AED);
  static const Color lightLavender = Color(0xFFF3E8FF);
  static const Color accentLavender = Color(0xFFA78BFA);

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getString('journal_entries');

    if (entriesJson != null) {
      try {
        final List<dynamic> decoded = json.decode(entriesJson);
        setState(() {
          _entries = decoded.map((e) => JournalEntry.fromJson(e as Map<String, dynamic>)).toList();
          _entries.sort((a, b) => b.date.compareTo(a.date));
          _isLoading = false;
        });
      } catch (e) {
        print('Error loading entries: $e');
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generatePDF() async {
    if (_entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No journal entries to export'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isGeneratingPDF = true);

    try {
      final pdf = pw.Document();

      // Group entries by month
      Map<String, List<JournalEntry>> groupedEntries = {};
      for (var entry in _entries) {
        String monthYear = DateFormat('MMMM yyyy').format(entry.date);
        if (!groupedEntries.containsKey(monthYear)) {
          groupedEntries[monthYear] = [];
        }
        groupedEntries[monthYear]!.add(entry);
      }

      // Cover Page
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) => pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'My Pregnancy Journey',
                  style: pw.TextStyle(
                    fontSize: 32,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Love Journal Memories',
                  style: pw.TextStyle(fontSize: 18),
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  'Generated on ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
                ),
              ],
            ),
          ),
        ),
      );

      // Add entries by month
      for (var monthYear in groupedEntries.keys) {
        var monthEntries = groupedEntries[monthYear]!;

        // Month Header Page
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.purple100,
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        monthYear,
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.purple900,
                        ),
                      ),
                      pw.Text(
                        '${monthEntries.length} memories',
                        style: pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.purple700,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),

                // Entries for this month
                ...monthEntries.map((entry) => pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 20),
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(10),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            entry.title,
                            style: pw.TextStyle(
                              fontSize: 16,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            DateFormat('MMM dd, yyyy').format(entry.date),
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColors.grey600,
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        DateFormat('hh:mm a').format(entry.date),
                        style: pw.TextStyle(
                          fontSize: 9,
                          color: PdfColors.grey500,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        entry.note,
                        style: const pw.TextStyle(
                          fontSize: 12,
                          lineSpacing: 1.5,
                        ),
                      ),
                      if (entry.imagePath != null || entry.audioPath != null) ...[
                        pw.SizedBox(height: 10),
                        pw.Row(
                          children: [
                            if (entry.imagePath != null)
                              pw.Container(
                                padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.blue100,
                                  borderRadius: pw.BorderRadius.circular(8),
                                ),
                                child: pw.Text(
                                  '📷 Photo attached',
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    color: PdfColors.blue900,
                                  ),
                                ),
                              ),
                            if (entry.audioPath != null)
                              pw.Container(
                                margin: const pw.EdgeInsets.only(left: 8),
                                padding: const pw.EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.purple100,
                                  borderRadius: pw.BorderRadius.circular(8),
                                ),
                                child: pw.Text(
                                  '🎤 Voice note attached',
                                  style: pw.TextStyle(
                                    fontSize: 9,
                                    color: PdfColors.purple900,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                )),
              ],
            ),
          ),
        );
      }

      // Save PDF
      final output = await getTemporaryDirectory();
      final file = File('${output.path}/pregnancy_journal_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      setState(() => _isGeneratingPDF = false);

      // Share PDF
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My Pregnancy Journey - Love Journal',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('PDF generated successfully!'),
              ],
            ),
            backgroundColor: primaryLavender,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      setState(() => _isGeneratingPDF = false);
      print('Error generating PDF: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to generate PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FF),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryLavender, accentLavender],
                ),
              ),
              child: Column(
                children: [
                  Row(
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
                              'All Memories',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Your precious journal entries',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Export PDF Button
                      ElevatedButton.icon(
                        onPressed: _isGeneratingPDF ? null : _generatePDF,
                        icon: _isGeneratingPDF
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Icon(Icons.download, size: 18),
                        label: Text(_isGeneratingPDF ? 'Exporting...' : 'Export PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: primaryLavender,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Stats
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          Icons.edit_note,
                          _entries.length.toString(),
                          'Total Entries',
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        _buildStatItem(
                          Icons.photo_library,
                          _entries.where((e) => e.imagePath != null).length.toString(),
                          'Photos',
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        _buildStatItem(
                          Icons.mic,
                          _entries.where((e) => e.audioPath != null).length.toString(),
                          'Voice Notes',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Entries List
            Expanded(
              child: _isLoading
                  ? Center(
                child: CircularProgressIndicator(color: primaryLavender),
              )
                  : _entries.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_stories_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No journal entries yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start capturing your precious moments',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  return _buildEntryCard(_entries[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEntryCard(JournalEntry entry) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(entry.date);
    final formattedTime = DateFormat('hh:mm a').format(entry.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryLavender.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: lightLavender,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryLavender,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formattedTime,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.note,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6B7280),
                    height: 1.6,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),

                // Media indicators
                if (entry.imagePath != null || entry.audioPath != null) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (entry.imagePath != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.image, size: 14, color: Colors.blue),
                              SizedBox(width: 4),
                              Text(
                                'Photo',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (entry.audioPath != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primaryLavender.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.mic, size: 14, color: primaryLavender),
                              const SizedBox(width: 4),
                              Text(
                                'Voice Note',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: primaryLavender,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Journal Entry Model (same as in journal_screen.dart)
class JournalEntry {
  final String id;
  final String title;
  final String note;
  final DateTime date;
  final String? imagePath;
  final String? audioPath;

  JournalEntry({
    required this.id,
    required this.title,
    required this.note,
    required this.date,
    this.imagePath,
    this.audioPath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'note': note,
    'date': date.toIso8601String(),
    'imagePath': imagePath,
    'audioPath': audioPath,
  };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    id: json['id'] as String,
    title: json['title'] as String,
    note: json['note'] as String,
    date: DateTime.parse(json['date'] as String),
    imagePath: json['imagePath'] as String?,
    audioPath: json['audioPath'] as String?,
  );
}