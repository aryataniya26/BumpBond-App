import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Main Education Screen
class EducationScreen extends StatefulWidget {
  const EducationScreen({Key? key}) : super(key: key);

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF6366F1),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                'Learning Center',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6366F1),
                      Color(0xFF8B5CF6),
                      Color(0xFFA78BFA)
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: -30,
                      bottom: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Explore Resources',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose what you want to learn today',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureCard(
                      context,
                      title: 'Resource Library',
                      description:
                      'Read expert articles and AI-curated content',
                      icon: Icons.menu_book_rounded,
                      colors: const [Color(0xFF10B981), Color(0xFF34D399)],
                      stats: '50+ Articles',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ResourceLibraryScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, {
        required String title,
        required String description,
        required IconData icon,
        required List<Color> colors,
        required String stats,
        required VoidCallback onTap,
      }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: colors),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: colors),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(icon, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colors[0].withOpacity(0.1),
                                  colors[1].withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              stats,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colors[0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: colors[0], size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Resource Library Screen
class ResourceLibraryScreen extends StatefulWidget {
  const ResourceLibraryScreen({Key? key}) : super(key: key);

  @override
  State<ResourceLibraryScreen> createState() => _ResourceLibraryScreenState();
}

class _ResourceLibraryScreenState extends State<ResourceLibraryScreen> {
  String selectedCategory = 'All';
  final List<String> categories = [
    'All',
    'Nutrition',
    'Exercise',
    'Health',
    'Mental Wellness',
    'Baby Care'
  ];

  final List<Map<String, dynamic>> articles = [
    {
      'title': 'Essential Nutrients for Pregnancy',
      'category': 'Nutrition',
      'readTime': '5 min',
      'featured': true,
      'aiCurated': true,
      'content':
      'During pregnancy, proper nutrition is crucial for both mother and baby. Key nutrients include folic acid, iron, calcium, and protein. Folic acid prevents neural tube defects, iron prevents anemia, calcium strengthens bones, and protein supports tissue growth.',
    },
    {
      'title': 'Safe Exercises During Pregnancy',
      'category': 'Exercise',
      'readTime': '7 min',
      'featured': true,
      'aiCurated': true,
      'content':
      'Staying active during pregnancy has numerous benefits. Swimming, walking, and prenatal yoga are excellent choices. These low-impact exercises maintain cardiovascular health and prepare your body for labor.',
    },
    {
      'title': 'Managing Morning Sickness',
      'category': 'Health',
      'readTime': '4 min',
      'featured': false,
      'aiCurated': true,
      'content':
      'Morning sickness affects many pregnant women. Try eating small, frequent meals and staying hydrated. Ginger tea and vitamin B6 supplements may help reduce symptoms.',
    },
    {
      'title': 'Preparing for Labor and Delivery',
      'category': 'Health',
      'readTime': '10 min',
      'featured': false,
      'aiCurated': false,
      'content':
      'Understanding the stages of labor and delivery options can help you feel more prepared and confident. Learn about birth plans and comfort measures.',
    },
    {
      'title': 'Mental Health During Pregnancy',
      'category': 'Mental Wellness',
      'readTime': '6 min',
      'featured': true,
      'aiCurated': true,
      'content':
      'Pregnancy can bring emotional changes. It\'s important to take care of your mental health through support and self-care. Hormonal changes may affect mood.',
    },
    {
      'title': 'Newborn Care Basics',
      'category': 'Baby Care',
      'readTime': '8 min',
      'featured': false,
      'aiCurated': false,
      'content':
      'Learn essential skills for caring for your newborn, including feeding, diapering, and sleep routines. Establishing good habits early helps baby thrive.',
    },
  ];

  List<Map<String, dynamic>> get filteredArticles {
    if (selectedCategory == 'All') return articles;
    return articles
        .where((a) => a['category'] == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Resource Library'),
        backgroundColor: const Color(0xFF10B981),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF10B981),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF6B7280),
                      fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: filteredArticles.length,
              itemBuilder: (context, index) {
                final article = filteredArticles[index];
                return _buildArticleCard(article);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(Map<String, dynamic> article) {
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
                    ArticleDetailScreen(article: article),
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
                        color:
                        const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        article['category'],
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                    if (article['aiCurated']) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6366F1)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 12,
                              color: Color(0xFF6366F1),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'AI Curated',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (article['featured']) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: Color(0xFFFBBF24),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          article['readTime'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  article['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  article['content'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Text(
                      'Read more',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Color(0xFF10B981),
                    ),
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

// Article Detail Screen
class ArticleDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article;

  const ArticleDetailScreen({Key? key, required this.article})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Article'),
        backgroundColor: const Color(0xFF10B981),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Article saved!')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Share feature coming soon!')),
              );
            },
          ),
        ],
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
                  colors: [Color(0xFF10B981), Color(0xFF34D399)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      article['category'],
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article['title'],
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${article['readTime']} read',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      if (article['aiCurated']) ...[
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'AI Curated',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
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
                  Text(
                    article['content'],
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Key Points:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBulletPoint(
                      'Maintain a balanced diet with essential nutrients'),
                  _buildBulletPoint('Stay hydrated throughout the day'),
                  _buildBulletPoint(
                      'Consult with your healthcare provider regularly'),
                  _buildBulletPoint('Get adequate rest and manage stress'),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                        const Color(0xFF10B981).withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFF10B981),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Always consult with your healthcare provider before making any significant changes to your routine.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF10B981),
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1F2937),
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
//
// // Main Education Screen
// class EducationScreen extends StatefulWidget {
//   const EducationScreen({Key? key}) : super(key: key);
//
//   @override
//   State<EducationScreen> createState() => _EducationScreenState();
// }
//
// class _EducationScreenState extends State<EducationScreen> with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     );
//     _fadeAnimation = CurvedAnimation(
//       parent: _animationController,
//       curve: Curves.easeIn,
//     );
//     _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       body: CustomScrollView(
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           SliverAppBar(
//             expandedHeight: 200,
//             floating: false,
//             pinned: true,
//             backgroundColor: const Color(0xFF6366F1),
//             flexibleSpace: FlexibleSpaceBar(
//               centerTitle: true,
//               title: const Text(
//                 'Learning Center',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               background: Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA78BFA)],
//                   ),
//                 ),
//                 child: Stack(
//                   children: [
//                     Positioned(
//                       right: -50,
//                       top: -50,
//                       child: Container(
//                         width: 200,
//                         height: 200,
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.1),
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       left: -30,
//                       bottom: -30,
//                       child: Container(
//                         width: 150,
//                         height: 150,
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.08),
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                     ),
//                     const Positioned(
//                       bottom: 60,
//                       left: 0,
//                       right: 0,
//                       child: Column(
//                         children: [
//                           Icon(
//                             Icons.school_rounded,
//                             color: Colors.white,
//                             size: 48,
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             'Expand your knowledge',
//                             style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           SliverPadding(
//             padding: const EdgeInsets.all(20),
//             sliver: SliverToBoxAdapter(
//               child: FadeTransition(
//                 opacity: _fadeAnimation,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Explore Resources',
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF1F2937),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'Choose what you want to learn today',
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: Color(0xFF6B7280),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     _buildFeatureCard(
//                       context,
//                       title: "Weekly Quizzes",
//                       description: "Test your pregnancy knowledge with fun interactive quizzes",
//                       icon: Icons.quiz_rounded,
//                       colors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//                       stats: "15+ quizzes",
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (_) => const QuizListScreen()),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     _buildFeatureCard(
//                       context,
//                       title: "Resources & Articles",
//                       description: "Read expert articles and guides about pregnancy",
//                       icon: Icons.menu_book_rounded,
//                       colors: const [Color(0xFF10B981), Color(0xFF34D399)],
//                       stats: "50+ articles",
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (_) => const ResourceLibraryScreen()),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     _buildFeatureCard(
//                       context,
//                       title: "Live Webinars",
//                       description: "Join live sessions with healthcare professionals",
//                       icon: Icons.video_library_rounded,
//                       colors: const [Color(0xFFEC4899), Color(0xFFF472B6)],
//                       stats: "Weekly events",
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (_) => const WebinarScreen()),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     _buildFeatureCard(
//                       context,
//                       title: "Policy Information",
//                       description: "Government schemes and maternity benefits",
//                       icon: Icons.policy_rounded,
//                       colors: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
//                       stats: "AI-Curated",
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (_) => const PolicyScreen()),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 32),
//                     _buildQuickStats(),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFeatureCard(
//       BuildContext context, {
//         required String title,
//         required String description,
//         required IconData icon,
//         required List<Color> colors,
//         required String stats,
//         required VoidCallback onTap,
//       }) {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(24),
//         child: Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(24),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.08),
//                 blurRadius: 20,
//                 offset: const Offset(0, 8),
//               ),
//             ],
//           ),
//           child: Stack(
//             children: [
//               Positioned(
//                 right: -20,
//                 top: -20,
//                 child: Container(
//                   width: 100,
//                   height: 100,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(colors: colors),
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 70,
//                       height: 70,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(colors: colors),
//                         borderRadius: BorderRadius.circular(18),
//                         boxShadow: [
//                           BoxShadow(
//                             color: colors[0].withOpacity(0.3),
//                             blurRadius: 12,
//                             offset: const Offset(0, 6),
//                           ),
//                         ],
//                       ),
//                       child: Icon(icon, color: Colors.white, size: 32),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             title,
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF1F2937),
//                             ),
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             description,
//                             style: const TextStyle(
//                               fontSize: 14,
//                               color: Color(0xFF6B7280),
//                               height: 1.4,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 4,
//                             ),
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [
//                                   colors[0].withOpacity(0.1),
//                                   colors[1].withOpacity(0.1),
//                                 ],
//                               ),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: Text(
//                               stats,
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w600,
//                                 color: colors[0],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Icon(
//                       Icons.arrow_forward_ios_rounded,
//                       color: colors[0],
//                       size: 20,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildQuickStats() {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(24),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF6366F1).withOpacity(0.3),
//             blurRadius: 20,
//             offset: const Offset(0, 10),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Row(
//             children: [
//               Icon(Icons.trending_up_rounded, color: Colors.white, size: 24),
//               SizedBox(width: 12),
//               Text(
//                 'Your Progress',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: _buildStatItem(
//                   icon: Icons.check_circle_rounded,
//                   value: '12',
//                   label: 'Completed',
//                 ),
//               ),
//               Container(
//                 width: 1,
//                 height: 40,
//                 color: Colors.white.withOpacity(0.3),
//               ),
//               Expanded(
//                 child: _buildStatItem(
//                   icon: Icons.emoji_events_rounded,
//                   value: '85%',
//                   label: 'Average Score',
//                 ),
//               ),
//               Container(
//                 width: 1,
//                 height: 40,
//                 color: Colors.white.withOpacity(0.3),
//               ),
//               Expanded(
//                 child: _buildStatItem(
//                   icon: Icons.local_fire_department_rounded,
//                   value: '7',
//                   label: 'Day Streak',
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatItem({
//     required IconData icon,
//     required String value,
//     required String label,
//   }) {
//     return Column(
//       children: [
//         Icon(icon, color: Colors.white, size: 28),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Text(
//           label,
//           style: const TextStyle(
//             color: Colors.white70,
//             fontSize: 12,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // Quiz List Screen
// class QuizListScreen extends StatefulWidget {
//   const QuizListScreen({Key? key}) : super(key: key);
//
//   @override
//   State<QuizListScreen> createState() => _QuizListScreenState();
// }
//
// class _QuizListScreenState extends State<QuizListScreen> {
//   final List<Map<String, dynamic>> quizzes = [
//     {
//       'title': 'First Trimester Basics',
//       'week': 'Week 1-12',
//       'questions': 10,
//       'duration': 5,
//       'completed': true,
//       'score': 85,
//       'difficulty': 'Easy',
//       'icon': Icons.baby_changing_station,
//     },
//     {
//       'title': 'Nutrition During Pregnancy',
//       'week': 'All Trimesters',
//       'questions': 15,
//       'duration': 8,
//       'completed': true,
//       'score': 92,
//       'difficulty': 'Medium',
//       'icon': Icons.restaurant,
//     },
//     {
//       'title': 'Exercise & Fitness',
//       'week': 'Week 13-28',
//       'questions': 12,
//       'duration': 6,
//       'completed': false,
//       'difficulty': 'Medium',
//       'icon': Icons.fitness_center,
//     },
//     {
//       'title': 'Third Trimester Care',
//       'week': 'Week 29-40',
//       'questions': 10,
//       'duration': 5,
//       'completed': false,
//       'difficulty': 'Easy',
//       'icon': Icons.favorite,
//     },
//     {
//       'title': 'Labor & Delivery',
//       'week': 'Week 36+',
//       'questions': 20,
//       'duration': 10,
//       'completed': false,
//       'difficulty': 'Hard',
//       'icon': Icons.local_hospital,
//     },
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         title: const Text('Weekly Quizzes'),
//         backgroundColor: const Color(0xFF6366F1),
//         elevation: 0,
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(20),
//         itemCount: quizzes.length,
//         itemBuilder: (context, index) {
//           final quiz = quizzes[index];
//           return _buildQuizCard(quiz);
//         },
//       ),
//     );
//   }
//
//   Widget _buildQuizCard(Map<String, dynamic> quiz) {
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
//                 builder: (_) => QuizDetailScreen(quiz: quiz),
//               ),
//             );
//           },
//           borderRadius: BorderRadius.circular(20),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 Container(
//                   width: 60,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: quiz['completed']
//                           ? [const Color(0xFF10B981), const Color(0xFF34D399)]
//                           : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
//                     ),
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Icon(
//                     quiz['icon'],
//                     color: Colors.white,
//                     size: 30,
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(
//                               quiz['title'],
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF1F2937),
//                               ),
//                             ),
//                           ),
//                           if (quiz['completed'])
//                             const Icon(
//                               Icons.check_circle,
//                               color: Color(0xFF10B981),
//                               size: 20,
//                             ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         quiz['week'],
//                         style: const TextStyle(
//                           fontSize: 13,
//                           color: Color(0xFF6B7280),
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           _buildQuizInfo(
//                             Icons.help_outline,
//                             '${quiz['questions']} Q',
//                           ),
//                           const SizedBox(width: 12),
//                           _buildQuizInfo(
//                             Icons.access_time,
//                             '${quiz['duration']} min',
//                           ),
//                           const SizedBox(width: 12),
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 2,
//                             ),
//                             decoration: BoxDecoration(
//                               color: _getDifficultyColor(quiz['difficulty'])
//                                   .withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               quiz['difficulty'],
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w600,
//                                 color: _getDifficultyColor(quiz['difficulty']),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       if (quiz['completed'])
//                         Padding(
//                           padding: const EdgeInsets.only(top: 8),
//                           child: Row(
//                             children: [
//                               const Icon(
//                                 Icons.star,
//                                 color: Color(0xFFFBBF24),
//                                 size: 16,
//                               ),
//                               const SizedBox(width: 4),
//                               Text(
//                                 'Score: ${quiz['score']}%',
//                                 style: const TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600,
//                                   color: Color(0xFF10B981),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildQuizInfo(IconData icon, String text) {
//     return Row(
//       children: [
//         Icon(icon, size: 14, color: const Color(0xFF6B7280)),
//         const SizedBox(width: 4),
//         Text(
//           text,
//           style: const TextStyle(
//             fontSize: 12,
//             color: Color(0xFF6B7280),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Color _getDifficultyColor(String difficulty) {
//     switch (difficulty) {
//       case 'Easy':
//         return const Color(0xFF10B981);
//       case 'Medium':
//         return const Color(0xFFF59E0B);
//       case 'Hard':
//         return const Color(0xFFEF4444);
//       default:
//         return const Color(0xFF6B7280);
//     }
//   }
// }
//
// // Quiz Detail Screen
// class QuizDetailScreen extends StatelessWidget {
//   final Map<String, dynamic> quiz;
//
//   const QuizDetailScreen({Key? key, required this.quiz}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         title: Text(quiz['title']),
//         backgroundColor: const Color(0xFF6366F1),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//                 ),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Column(
//                 children: [
//                   Icon(
//                     quiz['icon'],
//                     color: Colors.white,
//                     size: 60,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     quiz['title'],
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     quiz['week'],
//                     style: const TextStyle(
//                       color: Colors.white70,
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//             _buildInfoRow(
//               'Questions',
//               '${quiz['questions']} questions',
//               Icons.help_outline,
//             ),
//             _buildInfoRow(
//               'Duration',
//               '${quiz['duration']} minutes',
//               Icons.access_time,
//             ),
//             _buildInfoRow(
//               'Difficulty',
//               quiz['difficulty'],
//               Icons.speed,
//             ),
//             if (quiz['completed'])
//               _buildInfoRow(
//                 'Your Score',
//                 '${quiz['score']}%',
//                 Icons.star,
//               ),
//             const SizedBox(height: 32),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => QuizTakingScreen(quiz: quiz),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF6366F1),
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                 ),
//                 child: Text(
//                   quiz['completed'] ? 'Retake Quiz' : 'Start Quiz',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value, IconData icon) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: const Color(0xFF6366F1).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               icon,
//               color: const Color(0xFF6366F1),
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
// }
//
// // Quiz Taking Screen
// class QuizTakingScreen extends StatefulWidget {
//   final Map<String, dynamic> quiz;
//
//   const QuizTakingScreen({Key? key, required this.quiz}) : super(key: key);
//
//   @override
//   State<QuizTakingScreen> createState() => _QuizTakingScreenState();
// }
//
// class _QuizTakingScreenState extends State<QuizTakingScreen> {
//   int currentQuestion = 0;
//   int? selectedAnswer;
//   int score = 0;
//   bool showResult = false;
//
//   final List<Map<String, dynamic>> questions = [
//     {
//       'question': 'What is the recommended folic acid intake during pregnancy?',
//       'options': ['200 mcg', '400 mcg', '600 mcg', '800 mcg'],
//       'correct': 1,
//     },
//     {
//       'question': 'Which trimester is considered the safest for travel?',
//       'options': ['First', 'Second', 'Third', 'None'],
//       'correct': 1,
//     },
//     {
//       'question': 'How much weight gain is typically recommended during pregnancy?',
//       'options': ['5-10 lbs', '11-20 lbs', '25-35 lbs', '40-50 lbs'],
//       'correct': 2,
//     },
//   ];
//
//   void selectAnswer(int index) {
//     setState(() {
//       selectedAnswer = index;
//     });
//   }
//
//   void nextQuestion() {
//     if (selectedAnswer == questions[currentQuestion]['correct']) {
//       score++;
//     }
//
//     if (currentQuestion < questions.length - 1) {
//       setState(() {
//         currentQuestion++;
//         selectedAnswer = null;
//       });
//     } else {
//       setState(() {
//         showResult = true;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (showResult) {
//       return Scaffold(
//         backgroundColor: const Color(0xFFF8F9FA),
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   width: 120,
//                   height: 120,
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
//                     ),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.emoji_events,
//                     color: Colors.white,
//                     size: 60,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 const Text(
//                   'Quiz Completed!',
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1F2937),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   'Your Score: ${((score / questions.length) * 100).toStringAsFixed(0)}%',
//                   style: const TextStyle(
//                     fontSize: 36,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF6366F1),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   '$score out of ${questions.length} correct',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     color: Color(0xFF6B7280),
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       Navigator.pop(context);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF6366F1),
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15),
//                       ),
//                     ),
//                     child: const Text(
//                       'Back to Quizzes',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//
//     final question = questions[currentQuestion];
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         title: Text('Question ${currentQuestion + 1}/${questions.length}'),
//         backgroundColor: const Color(0xFF6366F1),
//       ),
//       body: Column(
//         children: [
//           LinearProgressIndicator(
//             value: (currentQuestion + 1) / questions.length,
//             backgroundColor: Colors.grey[200],
//             valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     question['question'],
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1F2937),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   ...List.generate(
//                     question['options'].length,
//                         (index) => _buildOption(
//                       question['options'][index],
//                       index,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: selectedAnswer != null ? nextQuestion : null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF6366F1),
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   disabledBackgroundColor: Colors.grey[300],
//                 ),
//                 child: Text(
//                   currentQuestion < questions.length - 1 ? 'Next' : 'Finish',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOption(String option, int index) {
//     final isSelected = selectedAnswer == index;
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () => selectAnswer(index),
//           borderRadius: BorderRadius.circular(15),
//           child: Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: isSelected ? const Color(0xFF6366F1) : Colors.white,
//               borderRadius: BorderRadius.circular(15),
//               border: Border.all(
//                 color: isSelected ? const Color(0xFF6366F1) : Colors.grey[300]!,
//                 width: 2,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 24,
//                   height: 24,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: isSelected ? Colors.white : Colors.transparent,
//                     border: Border.all(
//                       color: isSelected ? Colors.white : Colors.grey[400]!,
//                       width: 2,
//                     ),
//                   ),
//                   child: isSelected
//                       ? const Icon(
//                     Icons.check,
//                     size: 16,
//                     color: Color(0xFF6366F1),
//                   )
//                       : null,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     option,
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: isSelected ? Colors.white : const Color(0xFF1F2937),
//                       fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//                     ),
//                   ),
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
// // Resource Library Screen
// class ResourceLibraryScreen extends StatefulWidget {
//   const ResourceLibraryScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ResourceLibraryScreen> createState() => _ResourceLibraryScreenState();
// }
//
// class _ResourceLibraryScreenState extends State<ResourceLibraryScreen> {
//   String selectedCategory = 'All';
//   final List<String> categories = ['All', 'Nutrition', 'Exercise', 'Health', 'Mental Wellness', 'Baby Care'];
//
//   final List<Map<String, dynamic>> articles = [
//     {
//       'title': 'Essential Nutrients for Pregnancy',
//       'category': 'Nutrition',
//       'readTime': '5 min',
//       'featured': true,
//       'aiCurated': true,
//       'content': 'During pregnancy, proper nutrition is crucial for both mother and baby. Key nutrients include folic acid, iron, calcium, and protein...',
//     },
//     {
//       'title': 'Safe Exercises During Pregnancy',
//       'category': 'Exercise',
//       'readTime': '7 min',
//       'featured': true,
//       'aiCurated': false,
//       'content': 'Staying active during pregnancy has numerous benefits. Swimming, walking, and prenatal yoga are excellent choices...',
//     },
//     {
//       'title': 'Managing Morning Sickness',
//       'category': 'Health',
//       'readTime': '4 min',
//       'featured': false,
//       'aiCurated': true,
//       'content': 'Morning sickness affects many pregnant women. Try eating small, frequent meals and staying hydrated...',
//     },
//     {
//       'title': 'Preparing for Labor and Delivery',
//       'category': 'Health',
//       'readTime': '10 min',
//       'featured': false,
//       'aiCurated': false,
//       'content': 'Understanding the stages of labor and delivery options can help you feel more prepared and confident...',
//     },
//     {
//       'title': 'Mental Health During Pregnancy',
//       'category': 'Mental Wellness',
//       'readTime': '6 min',
//       'featured': true,
//       'aiCurated': true,
//       'content': 'Pregnancy can bring emotional changes. It\'s important to take care of your mental health through support and self-care...',
//     },
//     {
//       'title': 'Newborn Care Basics',
//       'category': 'Baby Care',
//       'readTime': '8 min',
//       'featured': false,
//       'aiCurated': false,
//       'content': 'Learn essential skills for caring for your newborn, including feeding, diapering, and sleep routines...',
//     },
//   ];
//
//   List<Map<String, dynamic>> get filteredArticles {
//     if (selectedCategory == 'All') return articles;
//     return articles.where((a) => a['category'] == selectedCategory).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         title: const Text('Resource Library'),
//         backgroundColor: const Color(0xFF10B981),
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           Container(
//             height: 60,
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               itemCount: categories.length,
//               itemBuilder: (context, index) {
//                 final category = categories[index];
//                 final isSelected = selectedCategory == category;
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 4),
//                   child: FilterChip(
//                     label: Text(category),
//                     selected: isSelected,
//                     onSelected: (selected) {
//                       setState(() {
//                         selectedCategory = category;
//                       });
//                     },
//                     backgroundColor: Colors.white,
//                     selectedColor: const Color(0xFF10B981),
//                     labelStyle: TextStyle(
//                       color: isSelected ? Colors.white : const Color(0xFF6B7280),
//                       fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(20),
//               itemCount: filteredArticles.length,
//               itemBuilder: (context, index) {
//                 final article = filteredArticles[index];
//                 return _buildArticleCard(article);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildArticleCard(Map<String, dynamic> article) {
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
//                 builder: (_) => ArticleDetailScreen(article: article),
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
//                         color: const Color(0xFF10B981).withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Text(
//                         article['category'],
//                         style: const TextStyle(
//                           fontSize: 11,
//                           fontWeight: FontWeight.w600,
//                           color: Color(0xFF10B981),
//                         ),
//                       ),
//                     ),
//                     if (article['aiCurated']) ...[
//                       const SizedBox(width: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF6366F1).withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Row(
//                           children: [
//                             Icon(
//                               Icons.auto_awesome,
//                               size: 12,
//                               color: Color(0xFF6366F1),
//                             ),
//                             SizedBox(width: 4),
//                             Text(
//                               'AI Curated',
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w600,
//                                 color: Color(0xFF6366F1),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                     if (article['featured']) ...[
//                       const SizedBox(width: 8),
//                       const Icon(
//                         Icons.star,
//                         size: 16,
//                         color: Color(0xFFFBBF24),
//                       ),
//                     ],
//                     const Spacer(),
//                     Row(
//                       children: [
//                         const Icon(
//                           Icons.access_time,
//                           size: 14,
//                           color: Color(0xFF6B7280),
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           article['readTime'],
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Color(0xFF6B7280),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   article['title'],
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1F2937),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   article['content'],
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Color(0xFF6B7280),
//                     height: 1.4,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     const Text(
//                       'Read more',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFF10B981),
//                       ),
//                     ),
//                     const SizedBox(width: 4),
//                     const Icon(
//                       Icons.arrow_forward,
//                       size: 16,
//                       color: Color(0xFF10B981),
//                     ),
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
// // Article Detail Screen
// class ArticleDetailScreen extends StatelessWidget {
//   final Map<String, dynamic> article;
//
//   const ArticleDetailScreen({Key? key, required this.article}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         title: const Text('Article'),
//         backgroundColor: const Color(0xFF10B981),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.bookmark_border),
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Article saved!')),
//               );
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.share),
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Share feature coming soon!')),
//               );
//             },
//           ),
//         ],
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
//                   colors: [Color(0xFF10B981), Color(0xFF34D399)],
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       article['category'],
//                       style: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     article['title'],
//                     style: const TextStyle(
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                       height: 1.3,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.access_time,
//                         size: 16,
//                         color: Colors.white70,
//                       ),
//                       const SizedBox(width: 6),
//                       Text(
//                         '${article['readTime']} read',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.white70,
//                         ),
//                       ),
//                       if (article['aiCurated']) ...[
//                         const SizedBox(width: 16),
//                         const Icon(
//                           Icons.auto_awesome,
//                           size: 16,
//                           color: Colors.white70,
//                         ),
//                         const SizedBox(width: 6),
//                         const Text(
//                           'AI Curated',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.white70,
//                           ),
//                         ),
//                       ],
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
//                   Text(
//                     article['content'],
//                     style: const TextStyle(
//                       fontSize: 16,
//                       height: 1.6,
//                       color: Color(0xFF1F2937),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.',
//                     style: TextStyle(
//                       fontSize: 16,
//                       height: 1.6,
//                       color: Color(0xFF1F2937),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Key Points:',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1F2937),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   _buildBulletPoint('Maintain a balanced diet with essential nutrients'),
//                   _buildBulletPoint('Stay hydrated throughout the day'),
//                   _buildBulletPoint('Consult with your healthcare provider regularly'),
//                   _buildBulletPoint('Get adequate rest and manage stress'),
//                   const SizedBox(height: 24),
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF10B981).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: const Color(0xFF10B981).withOpacity(0.3),
//                       ),
//                     ),
//                     child: const Row(
//                       children: [
//                         Icon(
//                           Icons.info_outline,
//                           color: Color(0xFF10B981),
//                         ),
//                         SizedBox(width: 12),
//                         Expanded(
//                           child: Text(
//                             'Always consult with your healthcare provider before making any significant changes to your routine.',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Color(0xFF1F2937),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBulletPoint(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             '• ',
//             style: TextStyle(
//               fontSize: 20,
//               color: Color(0xFF10B981),
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               text,
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Color(0xFF1F2937),
//                 height: 1.5,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Webinar Screen
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
//       'speaker': 'Dr. Sarah Johnson',
//       'date': 'Oct 18, 2025',
//       'time': '3:00 PM - 4:00 PM',
//       'status': 'Upcoming',
//       'participants': 156,
//       'registered': false,
//       'description': 'Learn about essential nutrients and meal planning during pregnancy.',
//     },
//     {
//       'title': 'Managing Pregnancy Stress',
//       'speaker': 'Dr. Emily Chen',
//       'date': 'Oct 20, 2025',
//       'time': '5:00 PM - 6:00 PM',
//       'status': 'Upcoming',
//       'participants': 203,
//       'registered': true,
//       'description': 'Techniques for managing stress and anxiety during pregnancy.',
//     },
//     {
//       'title': 'Exercise During Pregnancy',
//       'speaker': 'Dr. Michael Brown',
//       'date': 'Oct 10, 2025',
//       'time': '2:00 PM - 3:00 PM',
//       'status': 'Past',
//       'participants': 189,
//       'registered': true,
//       'description': 'Safe exercise routines for expecting mothers.',
//       'recording': true,
//     },
//     {
//       'title': 'Labor and Delivery Preparation',
//       'speaker': 'Dr. Lisa Anderson',
//       'date': 'Oct 25, 2025',
//       'time': '4:00 PM - 5:30 PM',
//       'status': 'Upcoming',
//       'participants': 245,
//       'registered': false,
//       'description': 'Everything you need to know about labor and delivery.',
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
//         title: const Text('Live Webinars'),
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
//             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
//                 builder: (_) => WebinarDetailScreen(webinar: webinar),
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
//                     if (webinar['registered'])
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF10B981).withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: const Row(
//                           children: [
//                             Icon(
//                               Icons.check,
//                               size: 12,
//                               color: Color(0xFF10B981),
//                             ),
//                             SizedBox(width: 4),
//                             Text(
//                               'Registered',
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w600,
//                                 color: Color(0xFF10B981),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
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
//                     Text(
//                       webinar['speaker'],
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: Color(0xFF6B7280),
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
//   const WebinarDetailScreen({Key? key, required this.webinar}) : super(key: key);
//
//   @override
//   State<WebinarDetailScreen> createState() => _WebinarDetailScreenState();
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
//                       Text(
//                         widget.webinar['speaker'],
//                         style: const TextStyle(
//                           fontSize: 16,
//                           color: Colors.white70,
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
//                     Icons.people,
//                     'Participants',
//                     '${widget.webinar['participants']} registered',
//                   ),
//                   const SizedBox(height: 24),
//                   const Text(
//                     'About this Webinar',
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
//                   const SizedBox(height: 16),
//                   const Text(
//                     'What you\'ll learn:',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w600,
//                       color: Color(0xFF1F2937),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   _buildLearningPoint('Evidence-based information from experts'),
//                   _buildLearningPoint('Practical tips you can use immediately'),
//                   _buildLearningPoint('Interactive Q&A session'),
//                   _buildLearningPoint('Access to supplementary materials'),
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
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(
//                               isRegistered ? Icons.check : Icons.event_available,
//                               color: isRegistered
//                                   ? const Color(0xFF6B7280)
//                                   : Colors.white,
//                             ),
//                             const SizedBox(width: 8),
//                             Text(
//                               isRegistered ? 'Registered' : 'Register Now',
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
//                               content: Text('Playing recording...'),
//                             ),
//                           );
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFFEC4899),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                         ),
//                         child: const Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.play_circle_filled, color: Colors.white),
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
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildInfoCard(IconData icon, String label, String value) {
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
//
// // Policy Information Screen
// class PolicyScreen extends StatefulWidget {
//   const PolicyScreen({Key? key}) : super(key: key);
//
//   @override
//   State<PolicyScreen> createState() => _PolicyScreenState();
// }
//
// class _PolicyScreenState extends State<PolicyScreen> {
//   final List<Map<String, dynamic>> policies = [
//     {
//       'title': 'Pradhan Mantri Matru Vandana Yojana (PMMVY)',
//       'category': 'Financial Benefit',
//       'amount': '₹5,000',
//       'icon': Icons.account_balance_wallet,
//       'aiSummary': true,
//       'description': 'Cash incentive for pregnant and lactating mothers for their first living child.',
//       'eligibility': [
//         'All pregnant women & lactating mothers',
//         'Excluding those in regular employment',
//         'For first living child only',
//       ],
//       'benefits': [
//         '₹5,000 in three installments',
//         'Direct benefit transfer to bank account',
//         'Promotes institutional delivery',
//       ],
//     },
//     {
//       'title': 'Janani Suraksha Yojana (JSY)',
//       'category': 'Health Scheme',
//       'amount': '₹1,400-₹1,000',
//       'icon': Icons.local_hospital,
//       'aiSummary': true,
//       'description': 'Safe motherhood intervention scheme to reduce maternal and neonatal mortality.',
//       'eligibility': [
//         'All pregnant women',
//         'Institutional delivery in public facilities',
//         'BPL families get priority',
//       ],
//       'benefits': [
//         'Cash assistance for delivery',
//         'Free delivery and postnatal care',
//         'Transportation support',
//       ],
//     },
//     {
//       'title': 'Maternity Benefit Act',
//       'category': 'Employment Rights',
//       'amount': 'Paid Leave',
//       'icon': Icons.work,
//       'aiSummary': false,
//       'description': 'Provides paid maternity leave to working women in organized sector.',
//       'eligibility': [
//         'Women working in establishments',
//         'Minimum 80 days work in 12 months',
//         'Applies to first two living children',
//       ],
//       'benefits': [
//         '26 weeks paid maternity leave',
//         '12 weeks for adoption/surrogacy',
//         'Nursing breaks after return',
//       ],
//     },
//     {
//       'title': 'Free Maternal Health Services',
//       'category': 'Healthcare',
//       'amount': 'Free Services',
//       'icon': Icons.medical_services,
//       'aiSummary': true,
//       'description': 'Comprehensive free healthcare services for pregnant women.',
//       'eligibility': [
//         'All pregnant women',
//         'Available at government facilities',
//         'No income restrictions',
//       ],
//       'benefits': [
//         'Free antenatal checkups',
//         'Free delivery services',
//         'Free medicines and diagnostics',
//       ],
//     },
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         title: const Text('Policy Information'),
//         backgroundColor: const Color(0xFFF59E0B),
//         elevation: 0,
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(20),
//         itemCount: policies.length,
//         itemBuilder: (context, index) {
//           final policy = policies[index];
//           return _buildPolicyCard(policy);
//         },
//       ),
//     );
//   }
//
//   Widget _buildPolicyCard(Map<String, dynamic> policy) {
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
//                 builder: (_) => PolicyDetailScreen(policy: policy),
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
//                       width: 50,
//                       height: 50,
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(
//                           colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
//                         ),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Icon(
//                         policy['icon'],
//                         color: Colors.white,
//                         size: 26,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   policy['category'],
//                                   style: const TextStyle(
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w600,
//                                     color: Color(0xFFF59E0B),
//                                   ),
//                                 ),
//                               ),
//                               if (policy['aiSummary'])
//                                 Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 8,
//                                     vertical: 2,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: const Color(0xFF6366F1).withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(6),
//                                   ),
//                                   child: const Row(
//                                     children: [
//                                       Icon(
//                                         Icons.auto_awesome,
//                                         size: 10,
//                                         color: Color(0xFF6366F1),
//                                       ),
//                                       SizedBox(width: 4),
//                                       Text(
//                                         'AI',
//                                         style: TextStyle(
//                                           fontSize: 10,
//                                           fontWeight: FontWeight.w600,
//                                           color: Color(0xFF6366F1),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                             ],
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             policy['amount'],
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF10B981),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   policy['title'],
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF1F2937),
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   policy['description'],
//                   maxLines: 2,
//                   overflow: TextOverflow.ellipsis,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Color(0xFF6B7280),
//                     height: 1.4,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     const Text(
//                       'Learn more',
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Color(0xFFF59E0B),
//                       ),
//                     ),
//                     const SizedBox(width: 4),
//                     const Icon(
//                       Icons.arrow_forward,
//                       size: 16,
//                       color: Color(0xFFF59E0B),
//                     ),
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
// // Policy Detail Screen
// class PolicyDetailScreen extends StatelessWidget {
//   final Map<String, dynamic> policy;
//
//   const PolicyDetailScreen({Key? key, required this.policy}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         title: const Text('Policy Details'),
//         backgroundColor: const Color(0xFFF59E0B),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.share),
//             onPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Share functionality coming soon!')),
//               );
//             },
//           ),
//         ],
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
//                   colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Icon(
//                           policy['icon'],
//                           color: Colors.white,
//                           size: 32,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       if (policy['aiSummary'])
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 6,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.2),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Row(
//                             children: [
//                               Icon(
//                                 Icons.auto_awesome,
//                                 size: 14,
//                                 color: Colors.white,
//                               ),
//                               SizedBox(width: 6),
//                               Text(
//                                 'AI Generated Summary',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.white,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     policy['title'],
//                     style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                       height: 1.3,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       policy['category'],
//                       style: const TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     children: [
//                       const Text(
//                         'Benefit Amount: ',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.white70,
//                         ),
//                       ),
//                       Text(
//                         policy['amount'],
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
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
//                   const Text(
//                     'Description',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1F2937),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     policy['description'],
//                     style: const TextStyle(
//                       fontSize: 16,
//                       height: 1.6,
//                       color: Color(0xFF6B7280),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   const Text(
//                     'Eligibility Criteria',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1F2937),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   ...List.generate(
//                     policy['eligibility'].length,
//                         (index) => _buildListItem(policy['eligibility'][index]),
//                   ),
//                   const SizedBox(height: 24),
//                   const Text(
//                     'Key Benefits',
//                     style: TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1F2937),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   ...List.generate(
//                     policy['benefits'].length,
//                         (index) => _buildBenefitItem(policy['benefits'][index]),
//                   ),
//                   const SizedBox(height: 24),
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF59E0B).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: const Color(0xFFF59E0B).withOpacity(0.3),
//                       ),
//                     ),
//                     child: const Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.info_outline,
//                               color: Color(0xFFF59E0B),
//                             ),
//                             SizedBox(width: 12),
//                             Text(
//                               'How to Apply',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF1F2937),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 8),
//                         Text(
//                           'Visit your nearest Anganwadi Center or health facility with required documents. Staff will guide you through the application process.',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Color(0xFF6B7280),
//                             height: 1.5,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Opening application form...'),
//                           ),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFF59E0B),
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(15),
//                         ),
//                       ),
//                       child: const Text(
//                         'Apply Now',
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
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildListItem(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             '• ',
//             style: TextStyle(
//               fontSize: 20,
//               color: Color(0xFFF59E0B),
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               text,
//               style: const TextStyle(
//                 fontSize: 15,
//                 color: Color(0xFF6B7280),
//                 height: 1.5,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBenefitItem(String text) {
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
//                 fontSize: 15,
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
// // import 'package:flutter/material.dart';
// //
// // // Main Education Screen
// // class EducationScreen extends StatefulWidget {
// //   const EducationScreen({Key? key}) : super(key: key);
// //
// //   @override
// //   State<EducationScreen> createState() => _EducationScreenState();
// // }
// //
// // class _EducationScreenState extends State<EducationScreen> with SingleTickerProviderStateMixin {
// //   late AnimationController _animationController;
// //   late Animation<double> _fadeAnimation;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _animationController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 600),
// //     );
// //     _fadeAnimation = CurvedAnimation(
// //       parent: _animationController,
// //       curve: Curves.easeIn,
// //     );
// //     _animationController.forward();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _animationController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF8F9FA),
// //       body: CustomScrollView(
// //         physics: const BouncingScrollPhysics(),
// //         slivers: [
// //           SliverAppBar(
// //             expandedHeight: 200,
// //             floating: false,
// //             pinned: true,
// //             backgroundColor: const Color(0xFF6366F1),
// //             flexibleSpace: FlexibleSpaceBar(
// //               centerTitle: true,
// //               title: const Text(
// //                 'Learning Center',
// //                 style: TextStyle(
// //                   color: Colors.white,
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //               background: Container(
// //                 decoration: const BoxDecoration(
// //                   gradient: LinearGradient(
// //                     begin: Alignment.topLeft,
// //                     end: Alignment.bottomRight,
// //                     colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFA78BFA)],
// //                   ),
// //                 ),
// //                 child: Stack(
// //                   children: [
// //                     Positioned(
// //                       right: -50,
// //                       top: -50,
// //                       child: Container(
// //                         width: 200,
// //                         height: 200,
// //                         decoration: BoxDecoration(
// //                           color: Colors.white.withOpacity(0.1),
// //                           shape: BoxShape.circle,
// //                         ),
// //                       ),
// //                     ),
// //                     Positioned(
// //                       left: -30,
// //                       bottom: -30,
// //                       child: Container(
// //                         width: 150,
// //                         height: 150,
// //                         decoration: BoxDecoration(
// //                           color: Colors.white.withOpacity(0.08),
// //                           shape: BoxShape.circle,
// //                         ),
// //                       ),
// //                     ),
// //                     const Positioned(
// //                       bottom: 60,
// //                       left: 0,
// //                       right: 0,
// //                       child: Column(
// //                         children: [
// //                           Icon(
// //                             Icons.school_rounded,
// //                             color: Colors.white,
// //                             size: 48,
// //                           ),
// //                           SizedBox(height: 8),
// //                           Text(
// //                             'Expand your knowledge',
// //                             style: TextStyle(
// //                               color: Colors.white70,
// //                               fontSize: 14,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //           SliverPadding(
// //             padding: const EdgeInsets.all(20),
// //             sliver: SliverToBoxAdapter(
// //               child: FadeTransition(
// //                 opacity: _fadeAnimation,
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     const Text(
// //                       'Explore Resources',
// //                       style: TextStyle(
// //                         fontSize: 24,
// //                         fontWeight: FontWeight.bold,
// //                         color: Color(0xFF1F2937),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 8),
// //                     const Text(
// //                       'Choose what you want to learn today',
// //                       style: TextStyle(
// //                         fontSize: 15,
// //                         color: Color(0xFF6B7280),
// //                       ),
// //                     ),
// //                     const SizedBox(height: 24),
// //                     _buildFeatureCard(
// //                       context,
// //                       title: "Weekly Quizzes",
// //                       description: "Test your pregnancy knowledge with fun interactive quizzes",
// //                       icon: Icons.quiz_rounded,
// //                       colors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
// //                       stats: "15+ quizzes",
// //                       onTap: () {
// //                         Navigator.push(
// //                           context,
// //                           MaterialPageRoute(builder: (_) => const QuizListScreen()),
// //                         );
// //                       },
// //                     ),
// //                     const SizedBox(height: 16),
// //                     _buildFeatureCard(
// //                       context,
// //                       title: "Resources & Articles",
// //                       description: "Read expert articles and guides about pregnancy",
// //                       icon: Icons.menu_book_rounded,
// //                       colors: const [Color(0xFF10B981), Color(0xFF34D399)],
// //                       stats: "50+ articles",
// //                       onTap: () {
// //                         Navigator.push(
// //                           context,
// //                           MaterialPageRoute(builder: (_) => const ResourceLibraryScreen()),
// //                         );
// //                       },
// //                     ),
// //                     const SizedBox(height: 16),
// //                     _buildFeatureCard(
// //                       context,
// //                       title: "Live Webinars",
// //                       description: "Join live sessions with healthcare professionals",
// //                       icon: Icons.video_library_rounded,
// //                       colors: const [Color(0xFFEC4899), Color(0xFFF472B6)],
// //                       stats: "Weekly events",
// //                       onTap: () {
// //                         Navigator.push(
// //                           context,
// //                           MaterialPageRoute(builder: (_) => const WebinarScreen()),
// //                         );
// //                       },
// //                     ),
// //                     const SizedBox(height: 16),
// //                     _buildFeatureCard(
// //                       context,
// //                       title: "Policy Information",
// //                       description: "Government schemes and maternity benefits",
// //                       icon: Icons.policy_rounded,
// //                       colors: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
// //                       stats: "AI-Curated",
// //                       onTap: () {
// //                         Navigator.push(
// //                           context,
// //                           MaterialPageRoute(builder: (_) => const PolicyScreen()),
// //                         );
// //                       },
// //                     ),
// //                     const SizedBox(height: 32),
// //                     _buildQuickStats(),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildFeatureCard(
// //       BuildContext context, {
// //         required String title,
// //         required String description,
// //         required IconData icon,
// //         required List<Color> colors,
// //         required String stats,
// //         required VoidCallback onTap,
// //       }) {
// //     return Material(
// //       color: Colors.transparent,
// //       child: InkWell(
// //         onTap: onTap,
// //         borderRadius: BorderRadius.circular(24),
// //         child: Container(
// //           decoration: BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.circular(24),
// //             boxShadow: [
// //               BoxShadow(
// //                 color: Colors.grey.withOpacity(0.08),
// //                 blurRadius: 20,
// //                 offset: const Offset(0, 8),
// //               ),
// //             ],
// //           ),
// //           child: Stack(
// //             children: [
// //               Positioned(
// //                 right: -20,
// //                 top: -20,
// //                 child: Container(
// //                   width: 100,
// //                   height: 100,
// //                   decoration: BoxDecoration(
// //                     gradient: LinearGradient(colors: colors),
// //                     shape: BoxShape.circle,
// //                   ),
// //                 ),
// //               ),
// //               Padding(
// //                 padding: const EdgeInsets.all(20),
// //                 child: Row(
// //                   children: [
// //                     Container(
// //                       width: 70,
// //                       height: 70,
// //                       decoration: BoxDecoration(
// //                         gradient: LinearGradient(colors: colors),
// //                         borderRadius: BorderRadius.circular(18),
// //                         boxShadow: [
// //                           BoxShadow(
// //                             color: colors[0].withOpacity(0.3),
// //                             blurRadius: 12,
// //                             offset: const Offset(0, 6),
// //                           ),
// //                         ],
// //                       ),
// //                       child: Icon(icon, color: Colors.white, size: 32),
// //                     ),
// //                     const SizedBox(width: 16),
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             title,
// //                             style: const TextStyle(
// //                               fontSize: 18,
// //                               fontWeight: FontWeight.bold,
// //                               color: Color(0xFF1F2937),
// //                             ),
// //                           ),
// //                           const SizedBox(height: 6),
// //                           Text(
// //                             description,
// //                             style: const TextStyle(
// //                               fontSize: 14,
// //                               color: Color(0xFF6B7280),
// //                               height: 1.4,
// //                             ),
// //                           ),
// //                           const SizedBox(height: 8),
// //                           Container(
// //                             padding: const EdgeInsets.symmetric(
// //                               horizontal: 12,
// //                               vertical: 4,
// //                             ),
// //                             decoration: BoxDecoration(
// //                               gradient: LinearGradient(
// //                                 colors: [
// //                                   colors[0].withOpacity(0.1),
// //                                   colors[1].withOpacity(0.1),
// //                                 ],
// //                               ),
// //                               borderRadius: BorderRadius.circular(12),
// //                             ),
// //                             child: Text(
// //                               stats,
// //                               style: TextStyle(
// //                                 fontSize: 12,
// //                                 fontWeight: FontWeight.w600,
// //                                 color: colors[0],
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                     Icon(
// //                       Icons.arrow_forward_ios_rounded,
// //                       color: colors[0],
// //                       size: 20,
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildQuickStats() {
// //     return Container(
// //       padding: const EdgeInsets.all(24),
// //       decoration: BoxDecoration(
// //         gradient: const LinearGradient(
// //           colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //         ),
// //         borderRadius: BorderRadius.circular(24),
// //         boxShadow: [
// //           BoxShadow(
// //             color: const Color(0xFF6366F1).withOpacity(0.3),
// //             blurRadius: 20,
// //             offset: const Offset(0, 10),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const Row(
// //             children: [
// //               Icon(Icons.trending_up_rounded, color: Colors.white, size: 24),
// //               SizedBox(width: 12),
// //               Text(
// //                 'Your Progress',
// //                 style: TextStyle(
// //                   color: Colors.white,
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 20),
// //           Row(
// //             children: [
// //               Expanded(
// //                 child: _buildStatItem(
// //                   icon: Icons.check_circle_rounded,
// //                   value: '12',
// //                   label: 'Completed',
// //                 ),
// //               ),
// //               Container(
// //                 width: 1,
// //                 height: 40,
// //                 color: Colors.white.withOpacity(0.3),
// //               ),
// //               Expanded(
// //                 child: _buildStatItem(
// //                   icon: Icons.emoji_events_rounded,
// //                   value: '85%',
// //                   label: 'Average Score',
// //                 ),
// //               ),
// //               Container(
// //                 width: 1,
// //                 height: 40,
// //                 color: Colors.white.withOpacity(0.3),
// //               ),
// //               Expanded(
// //                 child: _buildStatItem(
// //                   icon: Icons.local_fire_department_rounded,
// //                   value: '7',
// //                   label: 'Day Streak',
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildStatItem({
// //     required IconData icon,
// //     required String value,
// //     required String label,
// //   }) {
// //     return Column(
// //       children: [
// //         Icon(icon, color: Colors.white, size: 28),
// //         const SizedBox(height: 8),
// //         Text(
// //           value,
// //           style: const TextStyle(
// //             color: Colors.white,
// //             fontSize: 24,
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),
// //         Text(
// //           label,
// //           style: const TextStyle(
// //             color: Colors.white70,
// //             fontSize: 12,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
// //
// // // Quiz List Screen
// // class QuizListScreen extends StatefulWidget {
// //   const QuizListScreen({Key? key}) : super(key: key);
// //
// //   @override
// //   State<QuizListScreen> createState() => _QuizListScreenState();
// // }
// //
// // class _QuizListScreenState extends State<QuizListScreen> {
// //   final List<Map<String, dynamic>> quizzes = [
// //     {
// //       'title': 'First Trimester Basics',
// //       'week': 'Week 1-12',
// //       'questions': 10,
// //       'duration': 5,
// //       'completed': true,
// //       'score': 85,
// //       'difficulty': 'Easy',
// //       'icon': Icons.baby_changing_station,
// //     },
// //     {
// //       'title': 'Nutrition During Pregnancy',
// //       'week': 'All Trimesters',
// //       'questions': 15,
// //       'duration': 8,
// //       'completed': true,
// //       'score': 92,
// //       'difficulty': 'Medium',
// //       'icon': Icons.restaurant,
// //     },
// //     {
// //       'title': 'Exercise & Fitness',
// //       'week': 'Week 13-28',
// //       'questions': 12,
// //       'duration': 6,
// //       'completed': false,
// //       'difficulty': 'Medium',
// //       'icon': Icons.fitness_center,
// //     },
// //     {
// //       'title': 'Third Trimester Care',
// //       'week': 'Week 29-40',
// //       'questions': 10,
// //       'duration': 5,
// //       'completed': false,
// //       'difficulty': 'Easy',
// //       'icon': Icons.favorite,
// //     },
// //     {
// //       'title': 'Labor & Delivery',
// //       'week': 'Week 36+',
// //       'questions': 20,
// //       'duration': 10,
// //       'completed': false,
// //       'difficulty': 'Hard',
// //       'icon': Icons.local_hospital,
// //     },
// //   ];
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF8F9FA),
// //       appBar: AppBar(
// //         title: const Text('Weekly Quizzes'),
// //         backgroundColor: const Color(0xFF6366F1),
// //         elevation: 0,
// //       ),
// //       body: ListView.builder(
// //         padding: const EdgeInsets.all(20),
// //         itemCount: quizzes.length,
// //         itemBuilder: (context, index) {
// //           final quiz = quizzes[index];
// //           return _buildQuizCard(quiz);
// //         },
// //       ),
// //     );
// //   }
// //
// //   Widget _buildQuizCard(Map<String, dynamic> quiz) {
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(20),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.grey.withOpacity(0.1),
// //             blurRadius: 10,
// //             offset: const Offset(0, 4),
// //           ),
// //         ],
// //       ),
// //       child: Material(
// //         color: Colors.transparent,
// //         child: InkWell(
// //           onTap: () {
// //             Navigator.push(
// //               context,
// //               MaterialPageRoute(
// //                 builder: (_) => QuizDetailScreen(quiz: quiz),
// //               ),
// //             );
// //           },
// //           borderRadius: BorderRadius.circular(20),
// //           child: Padding(
// //             padding: const EdgeInsets.all(16),
// //             child: Row(
// //               children: [
// //                 Container(
// //                   width: 60,
// //                   height: 60,
// //                   decoration: BoxDecoration(
// //                     gradient: LinearGradient(
// //                       colors: quiz['completed']
// //                           ? [const Color(0xFF10B981), const Color(0xFF34D399)]
// //                           : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
// //                     ),
// //                     borderRadius: BorderRadius.circular(15),
// //                   ),
// //                   child: Icon(
// //                     quiz['icon'],
// //                     color: Colors.white,
// //                     size: 30,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 16),
// //                 Expanded(
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Row(
// //                         children: [
// //                           Expanded(
// //                             child: Text(
// //                               quiz['title'],
// //                               style: const TextStyle(
// //                                 fontSize: 16,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Color(0xFF1F2937),
// //                               ),
// //                             ),
// //                           ),
// //                           if (quiz['completed'])
// //                             const Icon(
// //                               Icons.check_circle,
// //                               color: Color(0xFF10B981),
// //                               size: 20,
// //                             ),
// //                         ],
// //                       ),
// //                       const SizedBox(height: 4),
// //                       Text(
// //                         quiz['week'],
// //                         style: const TextStyle(
// //                           fontSize: 13,
// //                           color: Color(0xFF6B7280),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 8),
// //                       Row(
// //                         children: [
// //                           _buildQuizInfo(
// //                             Icons.help_outline,
// //                             '${quiz['questions']} Q',
// //                           ),
// //                           const SizedBox(width: 12),
// //                           _buildQuizInfo(
// //                             Icons.access_time,
// //                             '${quiz['duration']} min',
// //                           ),
// //                           const SizedBox(width: 12),
// //                           Container(
// //                             padding: const EdgeInsets.symmetric(
// //                               horizontal: 8,
// //                               vertical: 2,
// //                             ),
// //                             decoration: BoxDecoration(
// //                               color: _getDifficultyColor(quiz['difficulty'])
// //                                   .withOpacity(0.1),
// //                               borderRadius: BorderRadius.circular(8),
// //                             ),
// //                             child: Text(
// //                               quiz['difficulty'],
// //                               style: TextStyle(
// //                                 fontSize: 11,
// //                                 fontWeight: FontWeight.w600,
// //                                 color: _getDifficultyColor(quiz['difficulty']),
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                       if (quiz['completed'])
// //                         Padding(
// //                           padding: const EdgeInsets.only(top: 8),
// //                           child: Row(
// //                             children: [
// //                               const Icon(
// //                                 Icons.star,
// //                                 color: Color(0xFFFBBF24),
// //                                 size: 16,
// //                               ),
// //                               const SizedBox(width: 4),
// //                               Text(
// //                                 'Score: ${quiz['score']}%',
// //                                 style: const TextStyle(
// //                                   fontSize: 12,
// //                                   fontWeight: FontWeight.w600,
// //                                   color: Color(0xFF10B981),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildQuizInfo(IconData icon, String text) {
// //     return Row(
// //       children: [
// //         Icon(icon, size: 14, color: const Color(0xFF6B7280)),
// //         const SizedBox(width: 4),
// //         Text(
// //           text,
// //           style: const TextStyle(
// //             fontSize: 12,
// //             color: Color(0xFF6B7280),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Color _getDifficultyColor(String difficulty) {
// //     switch (difficulty) {
// //       case 'Easy':
// //         return const Color(0xFF10B981);
// //       case 'Medium':
// //         return const Color(0xFFF59E0B);
// //       case 'Hard':
// //         return const Color(0xFFEF4444);
// //       default:
// //         return const Color(0xFF6B7280);
// //     }
// //   }
// // }
// //
// // // Quiz Detail Screen
// // class QuizDetailScreen extends StatelessWidget {
// //   final Map<String, dynamic> quiz;
// //
// //   const QuizDetailScreen({Key? key, required this.quiz}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF8F9FA),
// //       appBar: AppBar(
// //         title: Text(quiz['title']),
// //         backgroundColor: const Color(0xFF6366F1),
// //       ),
// //       body: SingleChildScrollView(
// //         padding: const EdgeInsets.all(20),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Container(
// //               width: double.infinity,
// //               padding: const EdgeInsets.all(24),
// //               decoration: BoxDecoration(
// //                 gradient: const LinearGradient(
// //                   colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
// //                 ),
// //                 borderRadius: BorderRadius.circular(20),
// //               ),
// //               child: Column(
// //                 children: [
// //                   Icon(
// //                     quiz['icon'],
// //                     color: Colors.white,
// //                     size: 60,
// //                   ),
// //                   const SizedBox(height: 16),
// //                   Text(
// //                     quiz['title'],
// //                     textAlign: TextAlign.center,
// //                     style: const TextStyle(
// //                       color: Colors.white,
// //                       fontSize: 22,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 8),
// //                   Text(
// //                     quiz['week'],
// //                     style: const TextStyle(
// //                       color: Colors.white70,
// //                       fontSize: 14,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             const SizedBox(height: 24),
// //             _buildInfoRow(
// //               'Questions',
// //               '${quiz['questions']} questions',
// //               Icons.help_outline,
// //             ),
// //             _buildInfoRow(
// //               'Duration',
// //               '${quiz['duration']} minutes',
// //               Icons.access_time,
// //             ),
// //             _buildInfoRow(
// //               'Difficulty',
// //               quiz['difficulty'],
// //               Icons.speed,
// //             ),
// //             if (quiz['completed'])
// //               _buildInfoRow(
// //                 'Your Score',
// //                 '${quiz['score']}%',
// //                 Icons.star,
// //               ),
// //             const SizedBox(height: 32),
// //             SizedBox(
// //               width: double.infinity,
// //               child: ElevatedButton(
// //                 onPressed: () {
// //                   Navigator.push(
// //                     context,
// //                     MaterialPageRoute(
// //                       builder: (_) => QuizTakingScreen(quiz: quiz),
// //                     ),
// //                   );
// //                 },
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: const Color(0xFF6366F1),
// //                   padding: const EdgeInsets.symmetric(vertical: 16),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(15),
// //                   ),
// //                 ),
// //                 child: Text(
// //                   quiz['completed'] ? 'Retake Quiz' : 'Start Quiz',
// //                   style: const TextStyle(
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.white,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildInfoRow(String label, String value, IconData icon) {
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 12),
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //       ),
// //       child: Row(
// //         children: [
// //           Container(
// //             padding: const EdgeInsets.all(8),
// //             decoration: BoxDecoration(
// //               color: const Color(0xFF6366F1).withOpacity(0.1),
// //               borderRadius: BorderRadius.circular(8),
// //             ),
// //             child: Icon(
// //               icon,
// //               color: const Color(0xFF6366F1),
// //               size: 20,
// //             ),
// //           ),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   label,
// //                   style: const TextStyle(
// //                     fontSize: 12,
// //                     color: Color(0xFF6B7280),
// //                   ),
// //                 ),
// //                 Text(
// //                   value,
// //                   style: const TextStyle(
// //                     fontSize: 14,
// //                     fontWeight: FontWeight.w600,
// //                     color: Color(0xFF1F2937),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // // Quiz Taking Screen
// // class QuizTakingScreen extends StatefulWidget {
// //   final Map<String, dynamic> quiz;
// //
// //   const QuizTakingScreen({Key? key, required this.quiz}) : super(key: key);
// //
// //   @override
// //   State<QuizTakingScreen> createState() => _QuizTakingScreenState();
// // }
// //
// // class _QuizTakingScreenState extends State<QuizTakingScreen> {
// //   int currentQuestion = 0;
// //   int? selectedAnswer;
// //   int score = 0;
// //   bool showResult = false;
// //
// //   final List<Map<String, dynamic>> questions = [
// //     {
// //       'question': 'What is the recommended folic acid intake during pregnancy?',
// //       'options': ['200 mcg', '400 mcg', '600 mcg', '800 mcg'],
// //       'correct': 1,
// //     },
// //     {
// //       'question': 'Which trimester is considered the safest for travel?',
// //       'options': ['First', 'Second', 'Third', 'None'],
// //       'correct': 1,
// //     },
// //     {
// //       'question': 'How much weight gain is typically recommended during pregnancy?',
// //       'options': ['5-10 lbs', '11-20 lbs', '25-35 lbs', '40-50 lbs'],
// //       'correct': 2,
// //     },
// //   ];
// //
// //   void selectAnswer(int index) {
// //     setState(() {
// //       selectedAnswer = index;
// //     });
// //   }
// //
// //   void nextQuestion() {
// //     if (selectedAnswer == questions[currentQuestion]['correct']) {
// //       score++;
// //     }
// //
// //     if (currentQuestion < questions.length - 1) {
// //       setState(() {
// //         currentQuestion++;
// //         selectedAnswer = null;
// //       });
// //     } else {
// //       setState(() {
// //         showResult = true;
// //       });
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     if (showResult) {
// //       return Scaffold(
// //         backgroundColor: const Color(0xFFF8F9FA),
// //         body: Center(
// //           child: Padding(
// //             padding: const EdgeInsets.all(20),
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Container(
// //                   width: 120,
// //                   height: 120,
// //                   decoration: BoxDecoration(
// //                     gradient: const LinearGradient(
// //                       colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
// //                     ),
// //                     shape: BoxShape.circle,
// //                   ),
// //                   child: const Icon(
// //                     Icons.emoji_events,
// //                     color: Colors.white,
// //                     size: 60,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 24),
// //                 const Text(
// //                   'Quiz Completed!',
// //                   style: TextStyle(
// //                     fontSize: 28,
// //                     fontWeight: FontWeight.bold,
// //                     color: Color(0xFF1F2937),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),
// //                 Text(
// //                   'Your Score: ${((score / questions.length) * 100).toStringAsFixed(0)}%',
// //                   style: const TextStyle(
// //                     fontSize: 36,
// //                     fontWeight: FontWeight.bold,
// //                     color: Color(0xFF6366F1),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 8),
// //                 Text(
// //                   '$score out of ${questions.length} correct',
// //                   style: const TextStyle(
// //                     fontSize: 16,
// //                     color: Color(0xFF6B7280),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 32),
// //                 SizedBox(
// //                   width: double.infinity,
// //                   child: ElevatedButton(
// //                     onPressed: () {
// //                       Navigator.pop(context);
// //                       Navigator.pop(context);
// //                     },
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: const Color(0xFF6366F1),
// //                       padding: const EdgeInsets.symmetric(vertical: 16),
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(15),
// //                       ),
// //                     ),
// //                     child: const Text(
// //                       'Back to Quizzes',
// //                       style: TextStyle(
// //                         fontSize: 16,
// //                         fontWeight: FontWeight.bold,
// //                         color: Colors.white,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       );
// //     }
// //
// //     final question = questions[currentQuestion];
// //
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF8F9FA),
// //       appBar: AppBar(
// //         title: Text('Question ${currentQuestion + 1}/${questions.length}'),
// //         backgroundColor: const Color(0xFF6366F1),
// //       ),
// //       body: Column(
// //         children: [
// //           LinearProgressIndicator(
// //             value: (currentQuestion + 1) / questions.length,
// //             backgroundColor: Colors.grey[200],
// //             valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
// //           ),
// //           Expanded(
// //             child: SingleChildScrollView(
// //               padding: const EdgeInsets.all(20),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     question['question'],
// //                     style: const TextStyle(
// //                       fontSize: 20,
// //                       fontWeight: FontWeight.bold,
// //                       color: Color(0xFF1F2937),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 24),
// //                   ...List.generate(
// //                     question['options'].length,
// //                         (index) => _buildOption(
// //                       question['options'][index],
// //                       index,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //           Padding(
// //             padding: const EdgeInsets.all(20),
// //             child: SizedBox(
// //               width: double.infinity,
// //               child: ElevatedButton(
// //                 onPressed: selectedAnswer != null ? nextQuestion : null,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: const Color(0xFF6366F1),
// //                   padding: const EdgeInsets.symmetric(vertical: 16),
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(15),
// //                   ),
// //                   disabledBackgroundColor: Colors.grey[300],
// //                 ),
// //                 child: Text(
// //                   currentQuestion < questions.length - 1 ? 'Next' : 'Finish',
// //                   style: const TextStyle(
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.white,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildOption(String option, int index) {
// //     final isSelected = selectedAnswer == index;
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 12),
// //       child: Material(
// //         color: Colors.transparent,
// //         child: InkWell(
// //           onTap: () => selectAnswer(index),
// //           borderRadius: BorderRadius.circular(15),
// //           child: Container(
// //             padding: const EdgeInsets.all(16),
// //             decoration: BoxDecoration(
// //               color: isSelected ? const Color(0xFF6366F1) : Colors.white,
// //               borderRadius: BorderRadius.circular(15),
// //               border: Border.all(
// //                 color: isSelected ? const Color(0xFF6366F1) : Colors.grey[300]!,
// //                 width: 2,
// //               ),
// //             ),
// //             child: Row(
// //               children: [
// //                 Container(
// //                   width: 24,
// //                   height: 24,
// //                   decoration: BoxDecoration(
// //                     shape: BoxShape.circle,
// //                     color: isSelected ? Colors.white : Colors.transparent,
// //                     border: Border.all(
// //                       color: isSelected ? Colors.white : Colors.grey[400]!,
// //                       width: 2,
// //                     ),
// //                   ),
// //                   child: isSelected
// //                       ? const Icon(
// //                     Icons.check,
// //                     size: 16,
// //                     color: Color(0xFF6366F1),
// //                   )
// //                       : null,
// //                 ),
// //                 const SizedBox(width: 12),
// //                 Expanded(
// //                   child: Text(
// //                     option,
// //                     style: TextStyle(
// //                       fontSize: 16,
// //                       color: isSelected ? Colors.white : const Color(0xFF1F2937),
// //                       fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // Resource Library Screen
// // class ResourceLibraryScreen extends StatefulWidget {
// //   const ResourceLibraryScreen({Key? key}) : super(key: key);
// //
// //   @override
// //   State<ResourceLibraryScreen> createState() => _ResourceLibraryScreenState();
// // }
// //
// // class _ResourceLibraryScreenState extends State<ResourceLibraryScreen> {
// //   String selectedCategory = 'All';
// //   final List<String> categories = ['All', 'Nutrition', 'Exercise', 'Health', 'Mental Wellness', 'Baby Care'];
// //
// //   final List<Map<String, dynamic>> articles = [
// //     {
// //       'title': 'Essential Nutrients for Pregnancy',
// //       'category': 'Nutrition',
// //       'readTime': '5 min',
// //       'featured': true,
// //       'aiCurated': true,
// //       'content': 'During pregnancy, proper nutrition is crucial for both mother and baby. Key nutrients include folic acid, iron, calcium, and protein...',
// //     },
// //     {
// //       'title': 'Safe Exercises During Pregnancy',
// //       'category': 'Exercise',
// //       'readTime': '7 min',
// //       'featured': true,
// //       'aiCurated': false,
// //       'content': 'Staying active during pregnancy has numerous benefits. Swimming, walking, and prenatal yoga are excellent choices...',
// //     },
// //     {
// //       'title': 'Managing Morning Sickness',
// //       'category': 'Health',
// //       'readTime': '4 min',
// //       'featured': false,
// //       'aiCurated': true,
// //       'content': 'Morning sickness affects many pregnant women. Try eating small, frequent meals and staying hydrated...',
// //     },
// //     {
// //       'title': 'Preparing for Labor and Delivery',
// //       'category': 'Health',
// //       'readTime': '10 min',
// //       'featured': false,
// //       'aiCurated': false,
// //       'content': 'Understanding the stages of labor and delivery options can help you feel more prepared and confident...',
// //     },
// //     {
// //       'title': 'Mental Health During Pregnancy',
// //       'category': 'Mental Wellness',
// //       'readTime': '6 min',
// //       'featured': true,
// //       'aiCurated': true,
// //       'content': 'Pregnancy can bring emotional changes. It\'s important to take care of your mental health through support and self-care...',
// //     },
// //     {
// //       'title': 'Newborn Care Basics',
// //       'category': 'Baby Care',
// //       'readTime': '8 min',
// //       'featured': false,
// //       'aiCurated': false,
// //       'content': 'Learn essential skills for caring for your newborn, including feeding, diapering, and sleep routines...',
// //     },
// //   ];
// //
// //   List<Map<String, dynamic>> get filteredArticles {
// //     if (selectedCategory == 'All') return articles;
// //     return articles.where((a) => a['category'] == selectedCategory).toList();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF8F9FA),
// //       appBar: AppBar(
// //         title: const Text('Resource Library'),
// //         backgroundColor: const Color(0xFF10B981),
// //         elevation: 0,
// //       ),
// //       body: Column(
// //         children: [
// //           Container(
// //             height: 60,
// //             padding: const EdgeInsets.symmetric(vertical: 8),
// //             child: ListView.builder(
// //               scrollDirection: Axis.horizontal,
// //               padding: const EdgeInsets.symmetric(horizontal: 12),
// //               itemCount: categories.length,
// //               itemBuilder: (context, index) {
// //                 final category = categories[index];
// //                 final isSelected = selectedCategory == category;
// //                 return Padding(
// //                   padding: const EdgeInsets.symmetric(horizontal: 4),
// //                   child: FilterChip(
// //                     label: Text(category),
// //                     selected: isSelected,
// //                     onSelected: (selected) {
// //                       setState(() {
// //                         selectedCategory = category;
// //                       });
// //                     },
// //                     backgroundColor: Colors.white,
// //                     selectedColor: const Color(0xFF10B981),
// //                     labelStyle: TextStyle(
// //                       color: isSelected ? Colors.white : const Color(0xFF6B7280),
// //                       fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
// //                     ),
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),
// //           Expanded(
// //             child: ListView.builder(
// //               padding: const EdgeInsets.all(20),
// //               itemCount: filteredArticles.length,
// //               itemBuilder: (context, index) {
// //                 final article = filteredArticles[index];
// //                 return _buildArticleCard(article);
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildArticleCard(Map<String, dynamic> article) {
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(20),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.grey.withOpacity(0.1),
// //             blurRadius: 10,
// //             offset: const Offset(0, 4),
// //           ),
// //         ],
// //       ),
// //       child: Material(
// //         color: Colors.transparent,
// //         child: InkWell(
// //           onTap: () {
// //             Navigator.push(
// //               context,
// //               MaterialPageRoute(
// //                 builder: (_) => ArticleDetailScreen(article: article),
// //               ),
// //             );
// //           },
// //           borderRadius: BorderRadius.circular(20),
// //           child: Padding(
// //             padding: const EdgeInsets.all(16),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   children: [
// //                     Container(
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 10,
// //                         vertical: 4,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: const Color(0xFF10B981).withOpacity(0.1),
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                       child: Text(
// //                         article['category'],
// //                         style: const TextStyle(
// //                           fontSize: 11,
// //                           fontWeight: FontWeight.w600,
// //                           color: Color(0xFF10B981),
// //                         ),
// //                       ),
// //                     ),
// //                     if (article['aiCurated']) ...[
// //                       const SizedBox(width: 8),
// //                       Container(
// //                         padding: const EdgeInsets.symmetric(
// //                           horizontal: 10,
// //                           vertical: 4,
// //                         ),
// //                         decoration: BoxDecoration(
// //                           color: const Color(0xFF6366F1).withOpacity(0.1),
// //                           borderRadius: BorderRadius.circular(8),
// //                         ),
// //                         child: const Row(
// //                           children: [
// //                             Icon(
// //                               Icons.auto_awesome,
// //                               size: 12,
// //                               color: Color(0xFF6366F1),
// //                             ),
// //                             SizedBox(width: 4),
// //                             Text(
// //                               'AI Curated',
// //                               style: TextStyle(
// //                                 fontSize: 11,
// //                                 fontWeight: FontWeight.w600,
// //                                 color: Color(0xFF6366F1),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                     if (article['featured']) ...[
// //                       const SizedBox(width: 8),
// //                       const Icon(
// //                         Icons.star,
// //                         size: 16,
// //                         color: Color(0xFFFBBF24),
// //                       ),
// //                     ],
// //                     const Spacer(),
// //                     Row(
// //                       children: [
// //                         const Icon(
// //                           Icons.access_time,
// //                           size: 14,
// //                           color: Color(0xFF6B7280),
// //                         ),
// //                         const SizedBox(width: 4),
// //                         Text(
// //                           article['readTime'],
// //                           style: const TextStyle(
// //                             fontSize: 12,
// //                             color: Color(0xFF6B7280),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 12),
// //                 Text(
// //                   article['title'],
// //                   style: const TextStyle(
// //                     fontSize: 18,
// //                     fontWeight: FontWeight.bold,
// //                     color: Color(0xFF1F2937),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 8),
// //                 Text(
// //                   article['content'],
// //                   maxLines: 2,
// //                   overflow: TextOverflow.ellipsis,
// //                   style: const TextStyle(
// //                     fontSize: 14,
// //                     color: Color(0xFF6B7280),
// //                     height: 1.4,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 12),
// //                 Row(
// //                   children: [
// //                     const Text(
// //                       'Read more',
// //                       style: TextStyle(
// //                         fontSize: 14,
// //                         fontWeight: FontWeight.w600,
// //                         color: Color(0xFF10B981),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 4),
// //                     const Icon(
// //                       Icons.arrow_forward,
// //                       size: 16,
// //                       color: Color(0xFF10B981),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // Article Detail Screen
// // class ArticleDetailScreen extends StatelessWidget {
// //   final Map<String, dynamic> article;
// //
// //   const ArticleDetailScreen({Key? key, required this.article}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF8F9FA),
// //       appBar: AppBar(
// //         title: const Text('Article'),
// //         backgroundColor: const Color(0xFF10B981),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.bookmark_border),
// //             onPressed: () {
// //               ScaffoldMessenger.of(context).showSnackBar(
// //                 const SnackBar(content: Text('Article saved!')),
// //               );
// //             },
// //           ),
// //           IconButton(
// //             icon: const Icon(Icons.share),
// //             onPressed: () {
// //               ScaffoldMessenger.of(context).showSnackBar(
// //                 const SnackBar(content: Text('Share feature coming soon!')),
// //               );
// //             },
// //           ),
// //         ],
// //       ),
// //       body: SingleChildScrollView(
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Container(
// //               width: double.infinity,
// //               padding: const EdgeInsets.all(24),
// //               decoration: const BoxDecoration(
// //                 gradient: LinearGradient(
// //                   colors: [Color(0xFF10B981), Color(0xFF34D399)],
// //                 ),
// //               ),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 12,
// //                       vertical: 6,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white.withOpacity(0.2),
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: Text(
// //                       article['category'],
// //                       style: const TextStyle(
// //                         fontSize: 12,
// //                         fontWeight: FontWeight.w600,
// //                         color: Colors.white,
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 16),
// //                   Text(
// //                     article['title'],
// //                     style: const TextStyle(
// //                       fontSize: 26,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.white,
// //                       height: 1.3,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 12),
// //                   Row(
// //                     children: [
// //                       const Icon(
// //                         Icons.access_time,
// //                         size: 16,
// //                         color: Colors.white70,
// //                       ),
// //                       const SizedBox(width: 6),
// //                       Text(
// //                         '${article['readTime']} read',
// //                         style: const TextStyle(
// //                           fontSize: 14,
// //                           color: Colors.white70,
// //                         ),
// //                       ),
// //                       if (article['aiCurated']) ...[
// //                         const SizedBox(width: 16),
// //                         const Icon(
// //                           Icons.auto_awesome,
// //                           size: 16,
// //                           color: Colors.white70,
// //                         ),
// //                         const SizedBox(width: 6),
// //                         const Text(
// //                           'AI Curated',
// //                           style: TextStyle(
// //                             fontSize: 14,
// //                             color: Colors.white70,
// //                           ),
// //                         ),
// //                       ],
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             Padding(
// //               padding: const EdgeInsets.all(20),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     article['content'],
// //                     style: const TextStyle(
// //                       fontSize: 16,
// //                       height: 1.6,
// //                       color: Color(0xFF1F2937),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 20),
// //                   const Text(
// //                     'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.',
// //                     style: TextStyle(
// //                       fontSize: 16,
// //                       height: 1.6,
// //                       color: Color(0xFF1F2937),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 20),
// //                   const Text(
// //                     'Key Points:',
// //                     style: TextStyle(
// //                       fontSize: 20,
// //                       fontWeight: FontWeight.bold,
// //                       color: Color(0xFF1F2937),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 12),
// //                   _buildBulletPoint('Maintain a balanced diet with essential nutrients'),
// //                   _buildBulletPoint('Stay hydrated throughout the day'),
// //                   _buildBulletPoint('Consult with your healthcare provider regularly'),
// //                   _buildBulletPoint('Get adequate rest and manage stress'),
// //                   const SizedBox(height: 24),
// //                   Container(
// //                     padding: const EdgeInsets.all(16),
// //                     decoration: BoxDecoration(
// //                       color: const Color(0xFF10B981).withOpacity(0.1),
// //                       borderRadius: BorderRadius.circular(12),
// //                       border: Border.all(
// //                         color: const Color(0xFF10B981).withOpacity(0.3),
// //                       ),
// //                     ),
// //                     child: const Row(
// //                       children: [
// //                         Icon(
// //                           Icons.info_outline,
// //                           color: Color(0xFF10B981),
// //                         ),
// //                         SizedBox(width: 12),
// //                         Expanded(
// //                           child: Text(
// //                             'Always consult with your healthcare provider before making any significant changes to your routine.',
// //                             style: TextStyle(
// //                               fontSize: 14,
// //                               color: Color(0xFF1F2937),
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildBulletPoint(String text) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 8),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const Text(
// //             '• ',
// //             style: TextStyle(
// //               fontSize: 20,
// //               color: Color(0xFF10B981),
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //           Expanded(
// //             child: Text(
// //               text,
// //               style: const TextStyle(
// //                 fontSize: 16,
// //                 color: Color(0xFF1F2937),
// //                 height: 1.5,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // // Webinar Screen
// // class WebinarScreen extends StatefulWidget {
// //   const WebinarScreen({Key? key}) : super(key: key);
// //
// //   @override
// //   State<WebinarScreen> createState() => _WebinarScreenState();
// // }
// //
// // class _WebinarScreenState extends State<WebinarScreen> {
// //   String selectedTab = 'Upcoming';
// //
// //   final List<Map<String, dynamic>> webinars = [
// //     {
// //       'title': 'Prenatal Nutrition Essentials',
// //       'speaker': 'Dr. Sarah Johnson',
// //       'date': 'Oct 18, 2025',
// //       'time': '3:00 PM - 4:00 PM',
// //       'status': 'Upcoming',
// //       'participants': 156,
// //       'registered': false,
// //       'description': 'Learn about essential nutrients and meal planning during pregnancy.',
// //     },
// //     {
// //       'title': 'Managing Pregnancy Stress',
// //       'speaker': 'Dr. Emily Chen',
// //       'date': 'Oct 20, 2025',
// //       'time': '5:00 PM - 6:00 PM',
// //       'status': 'Upcoming',
// //       'participants': 203,
// //       'registered': true,
// //       'description': 'Techniques for managing stress and anxiety during pregnancy.',
// //     },
// //     {
// //       'title': 'Exercise During Pregnancy',
// //       'speaker': 'Dr. Michael Brown',
// //       'date': 'Oct 10, 2025',
// //       'time': '2:00 PM - 3:00 PM',
// //       'status': 'Past',
// //       'participants': 189,
// //       'registered': true,
// //       'description': 'Safe exercise routines for expecting mothers.',
// //       'recording': true,
// //     },
// //     {
// //       'title': 'Labor and Delivery Preparation',
// //       'speaker': 'Dr. Lisa Anderson',
// //       'date': 'Oct 25, 2025',
// //       'time': '4:00 PM - 5:30 PM',
// //       'status': 'Upcoming',
// //       'participants': 245,
// //       'registered': false,
// //       'description': 'Everything you need to know about labor and delivery.',
// //     },
// //   ];
// //
// //   List<Map<String, dynamic>> get filteredWebinars {
// //     return webinars.where((w) => w['status'] == selectedTab).toList();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF8F9FA),
// //       appBar: AppBar(
// //         title: const Text('Live Webinars'),
// //         backgroundColor: const Color(0xFFEC4899),
// //         elevation: 0,
// //       ),
// //       body: Column(
// //         children: [
// //           Container(
// //             color: const Color(0xFFEC4899),
// //             child: Row(
// //               children: [
// //                 Expanded(
// //                   child: _buildTabButton('Upcoming'),
// //                 ),
// //                 Expanded(
// //                   child: _buildTabButton('Past'),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           Expanded(
// //             child: ListView.builder(
// //               padding: const EdgeInsets.all(20),
// //               itemCount: filteredWebinars.length,
// //               itemBuilder: (context, index) {
// //                 final webinar = filteredWebinars[index];
// //                 return _buildWebinarCard(webinar);
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildTabButton(String tab) {
// //     final isSelected = selectedTab == tab;
// //     return InkWell(
// //       onTap: () {
// //         setState(() {
// //           selectedTab = tab;
// //         });
// //       },
// //       child: Container(
// //         padding: const EdgeInsets.symmetric(vertical: 16),
// //         decoration: BoxDecoration(
// //           border: Border(
// //             bottom: BorderSide(
// //               color: isSelected ? Colors.white : Colors.transparent,
// //               width: 3,
// //             ),
// //           ),
// //         ),
// //         child: Text(
// //           tab,
// //           textAlign: TextAlign.center,
// //           style: TextStyle(
// //             fontSize: 16,
// //             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
// //             color: isSelected ? Colors.white : Colors.white70,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildWebinarCard(Map<String, dynamic> webinar) {
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(20),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.grey.withOpacity(0.1),
// //             blurRadius: 10,
// //             offset: const Offset(0, 4),
// //           ),
// //         ],
// //       ),
// //       child: Material(
// //         color: Colors.transparent,
// //         child: InkWell(
// //           onTap: () {
// //             Navigator.push(
// //               context,
// //               MaterialPageRoute(
// //                 builder: (_) => WebinarDetailScreen(webinar: webinar),
// //               ),
// //             );
// //           },
// //           borderRadius: BorderRadius.circular(20),
// //           child: Padding(
// //             padding: const EdgeInsets.all(16),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   children: [
// //                     Container(
// //                       padding: const EdgeInsets.symmetric(
// //                         horizontal: 10,
// //                         vertical: 4,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: webinar['status'] == 'Upcoming'
// //                             ? const Color(0xFFEC4899).withOpacity(0.1)
// //                             : Colors.grey.withOpacity(0.1),
// //                         borderRadius: BorderRadius.circular(8),
// //                       ),
// //                       child: Row(
// //                         children: [
// //                           Icon(
// //                             webinar['status'] == 'Upcoming'
// //                                 ? Icons.circle
// //                                 : Icons.check_circle,
// //                             size: 12,
// //                             color: webinar['status'] == 'Upcoming'
// //                                 ? const Color(0xFFEC4899)
// //                                 : Colors.grey,
// //                           ),
// //                           const SizedBox(width: 4),
// //                           Text(
// //                             webinar['status'],
// //                             style: TextStyle(
// //                               fontSize: 11,
// //                               fontWeight: FontWeight.w600,
// //                               color: webinar['status'] == 'Upcoming'
// //                                   ? const Color(0xFFEC4899)
// //                                   : Colors.grey,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                     const Spacer(),
// //                     if (webinar['registered'])
// //                       Container(
// //                         padding: const EdgeInsets.symmetric(
// //                           horizontal: 10,
// //                           vertical: 4,
// //                         ),
// //                         decoration: BoxDecoration(
// //                           color: const Color(0xFF10B981).withOpacity(0.1),
// //                           borderRadius: BorderRadius.circular(8),
// //                         ),
// //                         child: const Row(
// //                           children: [
// //                             Icon(
// //                               Icons.check,
// //                               size: 12,
// //                               color: Color(0xFF10B981),
// //                             ),
// //                             SizedBox(width: 4),
// //                             Text(
// //                               'Registered',
// //                               style: TextStyle(
// //                                 fontSize: 11,
// //                                 fontWeight: FontWeight.w600,
// //                                 color: Color(0xFF10B981),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 12),
// //                 Text(
// //                   webinar['title'],
// //                   style: const TextStyle(
// //                     fontSize: 18,
// //                     fontWeight: FontWeight.bold,
// //                     color: Color(0xFF1F2937),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 8),
// //                 Row(
// //                   children: [
// //                     const Icon(
// //                       Icons.person_outline,
// //                       size: 16,
// //                       color: Color(0xFF6B7280),
// //                     ),
// //                     const SizedBox(width: 6),
// //                     Text(
// //                       webinar['speaker'],
// //                       style: const TextStyle(
// //                         fontSize: 14,
// //                         color: Color(0xFF6B7280),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 8),
// //                 Row(
// //                   children: [
// //                     const Icon(
// //                       Icons.calendar_today,
// //                       size: 14,
// //                       color: Color(0xFF6B7280),
// //                     ),
// //                     const SizedBox(width: 6),
// //                     Text(
// //                       webinar['date'],
// //                       style: const TextStyle(
// //                         fontSize: 13,
// //                         color: Color(0xFF6B7280),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 16),
// //                     const Icon(
// //                       Icons.access_time,
// //                       size: 14,
// //                       color: Color(0xFF6B7280),
// //                     ),
// //                     const SizedBox(width: 6),
// //                     Text(
// //                       webinar['time'],
// //                       style: const TextStyle(
// //                         fontSize: 13,
// //                         color: Color(0xFF6B7280),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 12),
// //                 Row(
// //                   children: [
// //                     const Icon(
// //                       Icons.people_outline,
// //                       size: 16,
// //                       color: Color(0xFF6B7280),
// //                     ),
// //                     const SizedBox(width: 6),
// //                     Text(
// //                       '${webinar['participants']} participants',
// //                       style: const TextStyle(
// //                         fontSize: 13,
// //                         color: Color(0xFF6B7280),
// //                       ),
// //                     ),
// //                     if (webinar['recording'] == true) ...[
// //                       const Spacer(),
// //                       const Icon(
// //                         Icons.play_circle_outline,
// //                         size: 16,
// //                         color: Color(0xFFEC4899),
// //                       ),
// //                       const SizedBox(width: 6),
// //                       const Text(
// //                         'Recording Available',
// //                         style: TextStyle(
// //                           fontSize: 13,
// //                           fontWeight: FontWeight.w600,
// //                           color: Color(0xFFEC4899),
// //                         ),
// //                       ),
// //                     ],
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // Webinar Detail Screen
// // class WebinarDetailScreen extends StatefulWidget {
// //   final Map<String, dynamic> webinar;
// //
// //   const WebinarDetailScreen({Key? key, required this.webinar}) : super(key: key);
// //
// //   @override
// //   State<WebinarDetailScreen> createState() => _WebinarDetailScreenState();
// // }
// //
// // class _WebinarDetailScreenState extends State<WebinarDetailScreen> {
// //   late bool isRegistered;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     isRegistered = widget.webinar['registered'];
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF8F9FA),
// //       appBar: AppBar(
// //         title: const Text('Webinar Details'),
// //         backgroundColor: const Color(0xFFEC4899),
// //       ),
// //       body: SingleChildScrollView(
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Container(
// //               width: double.infinity,
// //               padding: const EdgeInsets.all(24),
// //               decoration: const BoxDecoration(
// //                 gradient: LinearGradient(
// //                   colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
// //                 ),
// //               ),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Container(
// //                     width: 80,
// //                     height: 80,
// //                     decoration: BoxDecoration(
// //                       color: Colors.white.withOpacity(0.2),
// //                       shape: BoxShape.circle,
// //                     ),
// //                     child: const Icon(
// //                       Icons.videocam,
// //                       size: 40,
// //                       color: Colors.white,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 16),
// //                   Text(
// //                     widget.webinar['title'],
// //                     style: const TextStyle(
// //                       fontSize: 24,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.white,
// //                       height: 1.3,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 12),
// //                   Row(
// //                     children: [
// //                       const Icon(
// //                         Icons.person,
// //                         size: 18,
// //                         color: Colors.white70,
// //                       ),
// //                       const SizedBox(width: 6),
// //                       Text(
// //                         widget.webinar['speaker'],
// //                         style: const TextStyle(
// //                           fontSize: 16,
// //                           color: Colors.white70,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             Padding(
// //               padding: const EdgeInsets.all(20),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   _buildInfoCard(
// //                     Icons.calendar_today,
// //                     'Date',
// //                     widget.webinar['date'],
// //                   ),
// //                   const SizedBox(height: 12),
// //                   _buildInfoCard(
// //                     Icons.access_time,
// //                     'Time',
// //                     widget.webinar['time'],
// //                   ),
// //                   const SizedBox(height: 12),
// //                   _buildInfoCard(
// //                     Icons.people,
// //                     'Participants',
// //                     '${widget.webinar['participants']} registered',
// //                   ),
// //                   const SizedBox(height: 24),
// //                   const Text(
// //                     'About this Webinar',
// //                     style: TextStyle(
// //                       fontSize: 20,
// //                       fontWeight: FontWeight.bold,
// //                       color: Color(0xFF1F2937),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 12),
// //                   Text(
// //                     widget.webinar['description'],
// //                     style: const TextStyle(
// //                       fontSize: 16,
// //                       height: 1.6,
// //                       color: Color(0xFF6B7280),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 16),
// //                   const Text(
// //                     'What you\'ll learn:',
// //                     style: TextStyle(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.w600,
// //                       color: Color(0xFF1F2937),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 8),
// //                   _buildLearningPoint('Evidence-based information from experts'),
// //                   _buildLearningPoint('Practical tips you can use immediately'),
// //                   _buildLearningPoint('Interactive Q&A session'),
// //                   _buildLearningPoint('Access to supplementary materials'),
// //                   const SizedBox(height: 24),
// //                   if (widget.webinar['status'] == 'Upcoming')
// //                     SizedBox(
// //                       width: double.infinity,
// //                       child: ElevatedButton(
// //                         onPressed: () {
// //                           setState(() {
// //                             isRegistered = !isRegistered;
// //                           });
// //                           ScaffoldMessenger.of(context).showSnackBar(
// //                             SnackBar(
// //                               content: Text(
// //                                 isRegistered
// //                                     ? 'Successfully registered! Reminder will be sent.'
// //                                     : 'Registration cancelled.',
// //                               ),
// //                               backgroundColor: isRegistered
// //                                   ? const Color(0xFF10B981)
// //                                   : Colors.grey,
// //                             ),
// //                           );
// //                         },
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: isRegistered
// //                               ? Colors.grey[300]
// //                               : const Color(0xFFEC4899),
// //                           padding: const EdgeInsets.symmetric(vertical: 16),
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(15),
// //                           ),
// //                         ),
// //                         child: Row(
// //                           mainAxisAlignment: MainAxisAlignment.center,
// //                           children: [
// //                             Icon(
// //                               isRegistered ? Icons.check : Icons.event_available,
// //                               color: isRegistered
// //                                   ? const Color(0xFF6B7280)
// //                                   : Colors.white,
// //                             ),
// //                             const SizedBox(width: 8),
// //                             Text(
// //                               isRegistered ? 'Registered' : 'Register Now',
// //                               style: TextStyle(
// //                                 fontSize: 16,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: isRegistered
// //                                     ? const Color(0xFF6B7280)
// //                                     : Colors.white,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   if (widget.webinar['recording'] == true)
// //                     SizedBox(
// //                       width: double.infinity,
// //                       child: ElevatedButton(
// //                         onPressed: () {
// //                           ScaffoldMessenger.of(context).showSnackBar(
// //                             const SnackBar(
// //                               content: Text('Playing recording...'),
// //                             ),
// //                           );
// //                         },
// //                         style: ElevatedButton.styleFrom(
// //                           backgroundColor: const Color(0xFFEC4899),
// //                           padding: const EdgeInsets.symmetric(vertical: 16),
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(15),
// //                           ),
// //                         ),
// //                         child: const Row(
// //                           mainAxisAlignment: MainAxisAlignment.center,
// //                           children: [
// //                             Icon(Icons.play_circle_filled, color: Colors.white),
// //                             SizedBox(width: 8),
// //                             Text(
// //                               'Watch Recording',
// //                               style: TextStyle(
// //                                 fontSize: 16,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Colors.white,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildInfoCard(IconData icon, String label, String value) {
// //     return Container(
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.grey.withOpacity(0.1),
// //             blurRadius: 5,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         children: [
// //           Container(
// //             padding: const EdgeInsets.all(8),
// //             decoration: BoxDecoration(
// //               color: const Color(0xFFEC4899).withOpacity(0.1),
// //               borderRadius: BorderRadius.circular(8),
// //             ),
// //             child: Icon(
// //               icon,
// //               color: const Color(0xFFEC4899),
// //               size: 20,
// //             ),
// //           ),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   label,
// //                   style: const TextStyle(
// //                     fontSize: 12,
// //                     color: Color(0xFF6B7280),
// //                   ),
// //                 ),
// //                 Text(
// //                   value,
// //                   style: const TextStyle(
// //                     fontSize: 14,
// //                     fontWeight: FontWeight.w600,
// //                     color: Color(0xFF1F2937),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildLearningPoint(String text) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 8),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const Icon(
// //             Icons.check_circle,
// //             size: 20,
// //             color: Color(0xFF10B981),
// //           ),
// //           const SizedBox(width: 8),
// //           Expanded(
// //             child: Text(
// //               text,
// //               style: const TextStyle(
// //                 fontSize: 14,
// //                 color: Color(0xFF6B7280),
// //                 height: 1.5,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // // Policy Information Screen
// // class PolicyScreen extends StatefulWidget {
// //   const PolicyScreen({Key? key}) : super(key: key);
// //
// //   @override
// //   State<PolicyScreen> createState() => _PolicyScreenState();
// // }
// //
// // class _PolicyScreenState extends State<PolicyScreen> {
// //   final List<Map<String, dynamic>> policies = [
// //     {
// //       'title': 'Pradhan Mantri Matru Vandana Yojana (PMMVY)',
// //       'category': 'Financial Benefit',
// //       'amount': '₹5,000',
// //       'icon': Icons.account_balance_wallet,
// //       'aiSummary': true,
// //       'description': 'Cash incentive for pregnant and lactating mothers for their first living child.',
// //       'eligibility': [
// //         'All pregnant women & lactating mothers',
// //         'Excluding those in regular employment',
// //         'For first living child only',
// //       ],
// //       'benefits': [
// //         '₹5,000 in three installments',
// //         'Direct benefit transfer to bank account',
// //         'Promotes institutional delivery',
// //       ],
// //     },
// //     {
// //       'title': 'Janani Suraksha Yojana (JSY)',
// //       'category': 'Health Scheme',
// //       'amount': '₹1,400-₹1,000',
// //       'icon': Icons.local_hospital,
// //       'aiSummary': true,
// //       'description': 'Safe motherhood intervention scheme to reduce maternal and neonatal mortality.',
// //       'eligibility': [
// //         'All pregnant women',
// //         'Institutional delivery in public facilities',
// //         'BPL families get priority',
// //       ],
// //       'benefits': [
// //         'Cash assistance for delivery',
// //         'Free delivery and postnatal care',
// //         'Transportation support',
// //       ],
// //     },
// //     {
// //       'title': 'Maternity Benefit Act',
// //       'category': 'Employment Rights',
// //       'amount': 'Paid Leave',
// //       'icon': Icons.work,
// //       'aiSummary': false,
// //       'description': 'Provides paid maternity leave to working women in organized sector.',
// //       'eligibility': [
// //         'Women working in establishments',
// //         'Minimum 80 days work in 12 months',
// //         'Applies to first two living children',
// //       ],
// //       'benefits': [
// //         '26 weeks paid maternity leave',
// //         '12 weeks for adoption/surrogacy',
// //         'Nursing breaks after return',
// //       ],
// //     },
// //     {
// //       'title': 'Free Maternal Health Services',
// //       'category': 'Healthcare',
// //       'amount': 'Free Services',
// //       'icon': Icons.medical_services,
// //       'aiSummary': true,
// //       'description': 'Comprehensive free healthcare services for pregnant women.',
// //       'eligibility': [
// //         'All pregnant women',
// //         'Available at government facilities',
// //         'No income restrictions',
// //       ],
// //       'benefits': [
// //         'Free antenatal checkups',
// //         'Free delivery services',
// //         'Free medicines and diagnostics',
// //       ],
// //     },
// //   ];
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF8F9FA),
// //       appBar: AppBar(
// //         title: const Text('Policy Information'),
// //         backgroundColor: const Color(0xFFF59E0B),
// //         elevation: 0,
// //       ),
// //       body: ListView.builder(
// //         padding: const EdgeInsets.all(20),
// //         itemCount: policies.length,
// //         itemBuilder: (context, index) {
// //           final policy = policies[index];
// //           return _buildPolicyCard(policy);
// //         },
// //       ),
// //     );
// //   }
// //
// //   Widget _buildPolicyCard(Map<String, dynamic> policy) {
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(20),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.grey.withOpacity(0.1),
// //             blurRadius: 10,
// //             offset: const Offset(0, 4),
// //           ),
// //         ],
// //       ),
// //       child: Material(
// //         color: Colors.transparent,
// //         child: InkWell(
// //           onTap: () {
// //             Navigator.push(
// //               context,
// //               MaterialPageRoute(
// //                 builder: (_) => PolicyDetailScreen(policy: policy),
// //               ),
// //             );
// //           },
// //           borderRadius: BorderRadius.circular(20),
// //           child: Padding(
// //             padding: const EdgeInsets.all(16),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   children: [
// //                     Container(
// //                       width: 50,
// //                       height: 50,
// //                       decoration: BoxDecoration(
// //                         gradient: const LinearGradient(
// //                           colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
// //                         ),
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       child: Icon(
// //                         policy['icon'],
// //                         color: Colors.white,
// //                         size: 26,
// //                       ),
// //                     ),
// //                     const SizedBox(width: 12),
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Row(
// //                             children: [
// //                               Expanded(
// //                                 child: Text(
// //                                   policy['category'],
// //                                   style: const TextStyle(
// //                                     fontSize: 12,
// //                                     fontWeight: FontWeight.w600,
// //                                     color: Color(0xFFF59E0B),
// //                                   ),
// //                                 ),
// //                               ),
// //                               if (policy['aiSummary'])
// //                                 Container(
// //                                   padding: const EdgeInsets.symmetric(
// //                                     horizontal: 8,
// //                                     vertical: 2,
// //                                   ),
// //                                   decoration: BoxDecoration(
// //                                     color: const Color(0xFF6366F1).withOpacity(0.1),
// //                                     borderRadius: BorderRadius.circular(6),
// //                                   ),
// //                                   child: const Row(
// //                                     children: [
// //                                       Icon(
// //                                         Icons.auto_awesome,
// //                                         size: 10,
// //                                         color: Color(0xFF6366F1),
// //                                       ),
// //                                       SizedBox(width: 4),
// //                                       Text(
// //                                         'AI',
// //                                         style: TextStyle(
// //                                           fontSize: 10,
// //                                           fontWeight: FontWeight.w600,
// //                                           color: Color(0xFF6366F1),
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ),
// //                             ],
// //                           ),
// //                           const SizedBox(height: 4),
// //                           Text(
// //                             policy['amount'],
// //                             style: const TextStyle(
// //                               fontSize: 16,
// //                               fontWeight: FontWeight.bold,
// //                               color: Color(0xFF10B981),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 const SizedBox(height: 12),
// //                 Text(
// //                   policy['title'],
// //                   style: const TextStyle(
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.bold,
// //                     color: Color(0xFF1F2937),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 6),
// //                 Text(
// //                   policy['description'],
// //                   maxLines: 2,
// //                   overflow: TextOverflow.ellipsis,
// //                   style: const TextStyle(
// //                     fontSize: 14,
// //                     color: Color(0xFF6B7280),
// //                     height: 1.4,
// //                   ),
// //                 ),
// //                 const SizedBox(height: 12),
// //                 Row(
// //                   children: [
// //                     const Text(
// //                       'Learn more',
// //                       style: TextStyle(
// //                         fontSize: 14,
// //                         fontWeight: FontWeight.w600,
// //                         color: Color(0xFFF59E0B),
// //                       ),
// //                     ),
// //                     const SizedBox(width: 4),
// //                     const Icon(
// //                       Icons.arrow_forward,
// //                       size: 16,
// //                       color: Color(0xFFF59E0B),
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // Policy Detail Screen
// // class PolicyDetailScreen extends StatelessWidget {
// //   final Map<String, dynamic> policy;
// //
// //   const PolicyDetailScreen({Key? key, required this.policy}) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF8F9FA),
// //       appBar: AppBar(
// //         title: const Text('Policy Details'),
// //         backgroundColor: const Color(0xFFF59E0B),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.share),
// //             onPressed: () {
// //               ScaffoldMessenger.of(context).showSnackBar(
// //                 const SnackBar(content: Text('Share functionality coming soon!')),
// //               );
// //             },
// //           ),
// //         ],
// //       ),
// //       body: SingleChildScrollView(
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Container(
// //               width: double.infinity,
// //               padding: const EdgeInsets.all(24),
// //               decoration: const BoxDecoration(
// //                 gradient: LinearGradient(
// //                   colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
// //                 ),
// //               ),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Row(
// //                     children: [
// //                       Container(
// //                         padding: const EdgeInsets.all(12),
// //                         decoration: BoxDecoration(
// //                           color: Colors.white.withOpacity(0.2),
// //                           borderRadius: BorderRadius.circular(12),
// //                         ),
// //                         child: Icon(
// //                           policy['icon'],
// //                           color: Colors.white,
// //                           size: 32,
// //                         ),
// //                       ),
// //                       const SizedBox(width: 12),
// //                       if (policy['aiSummary'])
// //                         Container(
// //                           padding: const EdgeInsets.symmetric(
// //                             horizontal: 12,
// //                             vertical: 6,
// //                           ),
// //                           decoration: BoxDecoration(
// //                             color: Colors.white.withOpacity(0.2),
// //                             borderRadius: BorderRadius.circular(8),
// //                           ),
// //                           child: const Row(
// //                             children: [
// //                               Icon(
// //                                 Icons.auto_awesome,
// //                                 size: 14,
// //                                 color: Colors.white,
// //                               ),
// //                               SizedBox(width: 6),
// //                               Text(
// //                                 'AI Generated Summary',
// //                                 style: TextStyle(
// //                                   fontSize: 12,
// //                                   fontWeight: FontWeight.w600,
// //                                   color: Colors.white,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 16),
// //                   Text(
// //                     policy['title'],
// //                     style: const TextStyle(
// //                       fontSize: 24,
// //                       fontWeight: FontWeight.bold,
// //                       color: Colors.white,
// //                       height: 1.3,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 8),
// //                   Container(
// //                     padding: const EdgeInsets.symmetric(
// //                       horizontal: 12,
// //                       vertical: 6,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       color: Colors.white.withOpacity(0.2),
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: Text(
// //                       policy['category'],
// //                       style: const TextStyle(
// //                         fontSize: 14,
// //                         fontWeight: FontWeight.w600,
// //                         color: Colors.white,
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 16),
// //                   Row(
// //                     children: [
// //                       const Text(
// //                         'Benefit Amount: ',
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           color: Colors.white70,
// //                         ),
// //                       ),
// //                       Text(
// //                         policy['amount'],
// //                         style: const TextStyle(
// //                           fontSize: 20,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.white,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //             Padding(
// //               padding: const EdgeInsets.all(20),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   const Text(
// //                     'Description',
// //                     style: TextStyle(
// //                       fontSize: 20,
// //                       fontWeight: FontWeight.bold,
// //                       color: Color(0xFF1F2937),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 12),
// //                   Text(
// //                     policy['description'],
// //                     style: const TextStyle(
// //                       fontSize: 16,
// //                       height: 1.6,
// //                       color: Color(0xFF6B7280),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 24),
// //                   const Text(
// //                     'Eligibility Criteria',
// //                     style: TextStyle(
// //                       fontSize: 20,
// //                       fontWeight: FontWeight.bold,
// //                       color: Color(0xFF1F2937),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 12),
// //                   ...List.generate(
// //                     policy['eligibility'].length,
// //                         (index) => _buildListItem(policy['eligibility'][index]),
// //                   ),
// //                   const SizedBox(height: 24),
// //                   const Text(
// //                     'Key Benefits',
// //                     style: TextStyle(
// //                       fontSize: 20,
// //                       fontWeight: FontWeight.bold,
// //                       color: Color(0xFF1F2937),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 12),
// //                   ...List.generate(
// //                     policy['benefits'].length,
// //                         (index) => _buildBenefitItem(policy['benefits'][index]),
// //                   ),
// //                   const SizedBox(height: 24),
// //                   Container(
// //                     padding: const EdgeInsets.all(16),
// //                     decoration: BoxDecoration(
// //                       color: const Color(0xFFF59E0B).withOpacity(0.1),
// //                       borderRadius: BorderRadius.circular(12),
// //                       border: Border.all(
// //                         color: const Color(0xFFF59E0B).withOpacity(0.3),
// //                       ),
// //                     ),
// //                     child: const Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Row(
// //                           children: [
// //                             Icon(
// //                               Icons.info_outline,
// //                               color: Color(0xFFF59E0B),
// //                             ),
// //                             SizedBox(width: 12),
// //                             Text(
// //                               'How to Apply',
// //                               style: TextStyle(
// //                                 fontSize: 16,
// //                                 fontWeight: FontWeight.bold,
// //                                 color: Color(0xFF1F2937),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                         SizedBox(height: 8),
// //                         Text(
// //                           'Visit your nearest Anganwadi Center or health facility with required documents. Staff will guide you through the application process.',
// //                           style: TextStyle(
// //                             fontSize: 14,
// //                             color: Color(0xFF6B7280),
// //                             height: 1.5,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   const SizedBox(height: 16),
// //                   SizedBox(
// //                     width: double.infinity,
// //                     child: ElevatedButton(
// //                       onPressed: () {
// //                         ScaffoldMessenger.of(context).showSnackBar(
// //                           const SnackBar(
// //                             content: Text('Opening application form...'),
// //                           ),
// //                         );
// //                       },
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: const Color(0xFFF59E0B),
// //                         padding: const EdgeInsets.symmetric(vertical: 16),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(15),
// //                         ),
// //                       ),
// //                       child: const Text(
// //                         'Apply Now',
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.white,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildListItem(String text) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 8),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const Text(
// //             '• ',
// //             style: TextStyle(
// //               fontSize: 20,
// //               color: Color(0xFFF59E0B),
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //           Expanded(
// //             child: Text(
// //               text,
// //               style: const TextStyle(
// //                 fontSize: 15,
// //                 color: Color(0xFF6B7280),
// //                 height: 1.5,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildBenefitItem(String text) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 8),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const Icon(
// //             Icons.check_circle,
// //             size: 20,
// //             color: Color(0xFF10B981),
// //           ),
// //           const SizedBox(width: 8),
// //           Expanded(
// //             child: Text(
// //               text,
// //               style: const TextStyle(
// //                 fontSize: 15,
// //                 color: Color(0xFF6B7280),
// //                 height: 1.5,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }