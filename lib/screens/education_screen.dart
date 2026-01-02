import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/subscription_service.dart';
import '../screens/subscription_plan_screen.dart';

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
  String _currentUserPlan = 'free';

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
    _loadUserPlan();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ==================== SUBSCRIPTION LOGIC ====================
  Future<void> _loadUserPlan() async {
    final plan = await SubscriptionService.getCurrentPlan();
    setState(() {
      _currentUserPlan = plan;
    });
  }

  bool _hasAccess(String requiredPlan) {
    final planHierarchy = ['free', 'basic', 'premium', 'pro'];
    final userIndex = planHierarchy.indexOf(_currentUserPlan);
    final requiredIndex = planHierarchy.indexOf(requiredPlan);
    return userIndex >= requiredIndex;
  }

  Widget _buildPlanIndicator() {
    Color planColor;
    switch (_currentUserPlan) {
      case 'premium':
        planColor = const Color(0xFFD4B5E8);
        break;
      case 'pro':
        planColor = const Color(0xFFFFB800);
        break;
      default:
        planColor = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: planColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _currentUserPlan.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: planColor,
        ),
      ),
    );
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
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Learning Center',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildPlanIndicator(),
                ],
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
                      description: _hasAccess('premium')
                          ? 'Read expert articles and AI-curated content'
                          : 'Basic articles available • Upgrade for premium content',
                      icon: Icons.menu_book_rounded,
                      colors: const [Color(0xFF10B981), Color(0xFF34D399)],
                      stats: _hasAccess('premium') ? '50+ Articles' : '15 Free Articles',
                      isPremium: !_hasAccess('premium'),
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
        required bool isPremium,
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
              if (isPremium)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock, size: 12, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          'PREMIUM',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
  String _currentUserPlan = 'free';

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
      'premium': false,
      'content': 'During pregnancy, proper nutrition is crucial for both mother and baby. Key nutrients include folic acid, iron, calcium, and protein. Folic acid prevents neural tube defects, iron prevents anemia, calcium strengthens bones, and protein supports tissue growth.',
    },
    {
      'title': 'Safe Exercises During Pregnancy',
      'category': 'Exercise',
      'readTime': '7 min',
      'featured': true,
      'aiCurated': true,
      'premium': true,
      'content': 'Staying active during pregnancy has numerous benefits. Swimming, walking, and prenatal yoga are excellent choices. These low-impact exercises maintain cardiovascular health and prepare your body for labor.',
    },
    {
      'title': 'Managing Morning Sickness',
      'category': 'Health',
      'readTime': '4 min',
      'featured': false,
      'aiCurated': true,
      'premium': false,
      'content': 'Morning sickness affects many pregnant women. Try eating small, frequent meals and staying hydrated. Ginger tea and vitamin B6 supplements may help reduce symptoms.',
    },
    {
      'title': 'Preparing for Labor and Delivery',
      'category': 'Health',
      'readTime': '10 min',
      'featured': false,
      'aiCurated': false,
      'premium': true,
      'content': 'Understanding the stages of labor and delivery options can help you feel more prepared and confident. Learn about birth plans and comfort measures.',
    },
    {
      'title': 'Mental Health During Pregnancy',
      'category': 'Mental Wellness',
      'readTime': '6 min',
      'featured': true,
      'aiCurated': true,
      'premium': true,
      'content': 'Pregnancy can bring emotional changes. It\'s important to take care of your mental health through support and self-care. Hormonal changes may affect mood.',
    },
    {
      'title': 'Newborn Care Basics',
      'category': 'Baby Care',
      'readTime': '8 min',
      'featured': false,
      'aiCurated': false,
      'premium': true,
      'content': 'Learn essential skills for caring for your newborn, including feeding, diapering, and sleep routines. Establishing good habits early helps baby thrive.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserPlan();
  }

  Future<void> _loadUserPlan() async {
    final plan = await SubscriptionService.getCurrentPlan();
    setState(() {
      _currentUserPlan = plan;
    });
  }

  bool _hasAccess(String requiredPlan) {
    final planHierarchy = ['free', 'basic', 'premium', 'pro'];
    final userIndex = planHierarchy.indexOf(_currentUserPlan);
    final requiredIndex = planHierarchy.indexOf(requiredPlan);
    return userIndex >= requiredIndex;
  }

  bool _canAccessArticle(Map<String, dynamic> article) {
    if (!article['premium']) return true; // Free articles for all
    return _hasAccess('premium'); // Premium articles require premium plan
  }

  List<Map<String, dynamic>> get filteredArticles {
    var filtered = articles;

    // Filter by category
    if (selectedCategory != 'All') {
      filtered = filtered.where((a) => a['category'] == selectedCategory).toList();
    }

    return filtered;
  }

  void _showPremiumArticleLockedDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, color: const Color(0xFFD4B5E8), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Premium Article',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'This expert article is available in Premium plan\nUpgrade to access all premium content',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SubscriptionPlansScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4B5E8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Upgrade Now',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Resource Library'),
        backgroundColor: const Color(0xFF10B981),
        elevation: 0,
        actions: [
          // Plan indicator
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _hasAccess('premium')
                  ? const Color(0xFFD4B5E8).withOpacity(0.2)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _currentUserPlan.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _hasAccess('premium')
                    ? const Color(0xFFD4B5E8)
                    : Colors.grey[600],
              ),
            ),
          ),
        ],
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
          // Subscription info banner for free users
          if (!_hasAccess('premium'))
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Free plan: Basic articles • Upgrade for premium content',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SubscriptionPlansScreen()),
                      );
                    },
                    child: Text(
                      'Upgrade',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
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
    final canAccess = _canAccessArticle(article);

    // Ensure all required fields have values and handle null cases
    final String title = article['title'] ?? 'Untitled Article';
    final String category = article['category'] ?? 'General';
    final String readTime = article['readTime'] ?? '5 min';
    final String content = article['content'] ?? 'Content not available.';
    final bool isAiCurated = article['aiCurated'] ?? false;
    final bool isPremium = article['premium'] ?? false;
    final bool isFeatured = article['featured'] ?? false;

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
          onTap: canAccess ? () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ArticleDetailScreen(article: article),
              ),
            );
          } : _showPremiumArticleLockedDialog,
          borderRadius: BorderRadius.circular(20),
          child: Opacity(
            opacity: canAccess ? 1.0 : 0.6,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FIXED: Wrap badges in a Column to prevent overflow
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First row for category and AI curated badges
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF10B981),
                              ),
                            ),
                          ),
                          if (isAiCurated)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
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
                          if (isPremium && canAccess)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4B5E8).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 12,
                                    color: Color(0xFFD4B5E8),
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'PREMIUM',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFFD4B5E8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (isPremium && !canAccess)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.lock,
                                    size: 12,
                                    color: Colors.orange,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'PREMIUM',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Second row for featured icon and read time
                      Row(
                        children: [
                          if (isFeatured)
                            const Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Color(0xFFFBBF24),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Featured',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 12),
                              ],
                            ),
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
                                readTime,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Text(
                        canAccess ? 'Read more' : 'Upgrade to read',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: canAccess ? const Color(0xFF10B981) : Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        canAccess ? Icons.arrow_forward : Icons.lock_outline,
                        size: 16,
                        color: canAccess ? const Color(0xFF10B981) : Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
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
    // Ensure all required fields have values and handle null cases
    final String title = article['title'] ?? 'Untitled Article';
    final String category = article['category'] ?? 'General';
    final String readTime = article['readTime'] ?? '5 min';
    final String content = article['content'] ?? 'Content not available.';
    final bool isAiCurated = article['aiCurated'] ?? false;
    final bool isPremium = article['premium'] ?? false;

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
                const SnackBar(content: Text('Share feature coming soon!')),
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
                      category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
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
                        '$readTime read',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      if (isAiCurated) ...[
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
                      if (isPremium) ...[
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Premium',
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
                    content,
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
                  _buildBulletPoint('Maintain a balanced diet with essential nutrients'),
                  _buildBulletPoint('Stay hydrated throughout the day'),
                  _buildBulletPoint('Consult with your healthcare provider regularly'),
                  _buildBulletPoint('Get adequate rest and manage stress'),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.3),
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
// import 'package:intl/intl.dart';
// import '../services/subscription_service.dart';
// import '../screens/subscription_plan_screen.dart';
//
// // Main Education Screen
// class EducationScreen extends StatefulWidget {
//   const EducationScreen({Key? key}) : super(key: key);
//
//   @override
//   State<EducationScreen> createState() => _EducationScreenState();
// }
//
// class _EducationScreenState extends State<EducationScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   String _currentUserPlan = 'free';
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
//     _loadUserPlan();
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   // ==================== SUBSCRIPTION LOGIC ====================
//   Future<void> _loadUserPlan() async {
//     final plan = await SubscriptionService.getCurrentPlan();
//     setState(() {
//       _currentUserPlan = plan;
//     });
//   }
//
//   bool _hasAccess(String requiredPlan) {
//     final planHierarchy = ['free', 'basic', 'premium', 'pro'];
//     final userIndex = planHierarchy.indexOf(_currentUserPlan);
//     final requiredIndex = planHierarchy.indexOf(requiredPlan);
//     return userIndex >= requiredIndex;
//   }
//
//   Widget _buildPlanIndicator() {
//     Color planColor;
//     switch (_currentUserPlan) {
//       case 'premium':
//         planColor = const Color(0xFFD4B5E8);
//         break;
//       case 'pro':
//         planColor = const Color(0xFFFFB800);
//         break;
//       default:
//         planColor = Colors.orange;
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: planColor.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         _currentUserPlan.toUpperCase(),
//         style: TextStyle(
//           fontSize: 10,
//           fontWeight: FontWeight.bold,
//           color: planColor,
//         ),
//       ),
//     );
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
//               title: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     'Learning Center',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   _buildPlanIndicator(),
//                 ],
//               ),
//               background: Container(
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       Color(0xFF6366F1),
//                       Color(0xFF8B5CF6),
//                       Color(0xFFA78BFA)
//                     ],
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
//                     const SizedBox(height: 16),
//                     _buildFeatureCard(
//                       context,
//                       title: 'Resource Library',
//                       description: _hasAccess('premium')
//                           ? 'Read expert articles and AI-curated content'
//                           : 'Basic articles available • Upgrade for premium content',
//                       icon: Icons.menu_book_rounded,
//                       colors: const [Color(0xFF10B981), Color(0xFF34D399)],
//                       stats: _hasAccess('premium') ? '50+ Articles' : '15 Free Articles',
//                       isPremium: !_hasAccess('premium'),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => const ResourceLibraryScreen(),
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 32),
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
//         required bool isPremium,
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
//               if (isPremium)
//                 Positioned(
//                   top: 12,
//                   right: 12,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     decoration: BoxDecoration(
//                       color: Colors.orange.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.lock, size: 12, color: Colors.orange),
//                         const SizedBox(width: 4),
//                         Text(
//                           'PREMIUM',
//                           style: TextStyle(
//                             fontSize: 10,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.orange,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
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
//                     Icon(Icons.arrow_forward_ios_rounded,
//                         color: colors[0], size: 20),
//                   ],
//                 ),
//               ),
//             ],
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
//   String _currentUserPlan = 'free';
//
//   final List<String> categories = [
//     'All',
//     'Nutrition',
//     'Exercise',
//     'Health',
//     'Mental Wellness',
//     'Baby Care'
//   ];
//
//   final List<Map<String, dynamic>> articles = [
//     {
//       'title': 'Essential Nutrients for Pregnancy',
//       'category': 'Nutrition',
//       'readTime': '5 min',
//       'featured': true,
//       'aiCurated': true,
//       'premium': false,
//       'content': 'During pregnancy, proper nutrition is crucial for both mother and baby. Key nutrients include folic acid, iron, calcium, and protein. Folic acid prevents neural tube defects, iron prevents anemia, calcium strengthens bones, and protein supports tissue growth.',
//     },
//     {
//       'title': 'Safe Exercises During Pregnancy',
//       'category': 'Exercise',
//       'readTime': '7 min',
//       'featured': true,
//       'aiCurated': true,
//       'premium': true,
//       'content': 'Staying active during pregnancy has numerous benefits. Swimming, walking, and prenatal yoga are excellent choices. These low-impact exercises maintain cardiovascular health and prepare your body for labor.',
//     },
//     {
//       'title': 'Managing Morning Sickness',
//       'category': 'Health',
//       'readTime': '4 min',
//       'featured': false,
//       'aiCurated': true,
//       'premium': false,
//       'content': 'Morning sickness affects many pregnant women. Try eating small, frequent meals and staying hydrated. Ginger tea and vitamin B6 supplements may help reduce symptoms.',
//     },
//     {
//       'title': 'Preparing for Labor and Delivery',
//       'category': 'Health',
//       'readTime': '10 min',
//       'featured': false,
//       'aiCurated': false,
//       'premium': true,
//       'content': 'Understanding the stages of labor and delivery options can help you feel more prepared and confident. Learn about birth plans and comfort measures.',
//     },
//     {
//       'title': 'Mental Health During Pregnancy',
//       'category': 'Mental Wellness',
//       'readTime': '6 min',
//       'featured': true,
//       'aiCurated': true,
//       'premium': true,
//       'content': 'Pregnancy can bring emotional changes. It\'s important to take care of your mental health through support and self-care. Hormonal changes may affect mood.',
//     },
//     {
//       'title': 'Newborn Care Basics',
//       'category': 'Baby Care',
//       'readTime': '8 min',
//       'featured': false,
//       'aiCurated': false,
//       'premium': true,
//       'content': 'Learn essential skills for caring for your newborn, including feeding, diapering, and sleep routines. Establishing good habits early helps baby thrive.',
//     },
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserPlan();
//   }
//
//   Future<void> _loadUserPlan() async {
//     final plan = await SubscriptionService.getCurrentPlan();
//     setState(() {
//       _currentUserPlan = plan;
//     });
//   }
//
//   bool _hasAccess(String requiredPlan) {
//     final planHierarchy = ['free', 'basic', 'premium', 'pro'];
//     final userIndex = planHierarchy.indexOf(_currentUserPlan);
//     final requiredIndex = planHierarchy.indexOf(requiredPlan);
//     return userIndex >= requiredIndex;
//   }
//
//   bool _canAccessArticle(Map<String, dynamic> article) {
//     if (!article['premium']) return true; // Free articles for all
//     return _hasAccess('premium'); // Premium articles require premium plan
//   }
//
//   List<Map<String, dynamic>> get filteredArticles {
//     var filtered = articles;
//
//     // Filter by category
//     if (selectedCategory != 'All') {
//       filtered = filtered.where((a) => a['category'] == selectedCategory).toList();
//     }
//
//     return filtered;
//   }
//
//   void _showPremiumArticleLockedDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Container(
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(Icons.lock, color: const Color(0xFFD4B5E8), size: 48),
//               const SizedBox(height: 16),
//               const Text(
//                 'Premium Article',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1F2937),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'This expert article is available in Premium plan\nUpgrade to access all premium content',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: 14,
//                   height: 1.5,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () => Navigator.pop(context),
//                       style: OutlinedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       child: const Text('Cancel'),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         Navigator.pop(context);
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(builder: (_) => const SubscriptionPlansScreen()),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFFD4B5E8),
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       child: const Text(
//                         'Upgrade Now',
//                         style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
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
//         actions: [
//           // Plan indicator
//           Container(
//             margin: const EdgeInsets.only(right: 16),
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: _hasAccess('premium')
//                   ? const Color(0xFFD4B5E8).withOpacity(0.2)
//                   : Colors.grey[200],
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               _currentUserPlan.toUpperCase(),
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//                 color: _hasAccess('premium')
//                     ? const Color(0xFFD4B5E8)
//                     : Colors.grey[600],
//               ),
//             ),
//           ),
//         ],
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
//                       color: isSelected
//                           ? Colors.white
//                           : const Color(0xFF6B7280),
//                       fontWeight:
//                       isSelected ? FontWeight.w600 : FontWeight.normal,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           // Subscription info banner for free users
//           if (!_hasAccess('premium'))
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(12),
//               margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//               decoration: BoxDecoration(
//                 color: Colors.orange.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.orange.withOpacity(0.3)),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.info, color: Colors.orange, size: 16),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Free plan: Basic articles • Upgrade for premium content',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.orange,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (_) => const SubscriptionPlansScreen()),
//                       );
//                     },
//                     child: Text(
//                       'Upgrade',
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.orange,
//                         fontWeight: FontWeight.bold,
//                         decoration: TextDecoration.underline,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
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
//     final canAccess = _canAccessArticle(article);
//
//     // Ensure all required fields have values and handle null cases
//     final String title = article['title'] ?? 'Untitled Article';
//     final String category = article['category'] ?? 'General';
//     final String readTime = article['readTime'] ?? '5 min';
//     final String content = article['content'] ?? 'Content not available.';
//     final bool isAiCurated = article['aiCurated'] ?? false;
//     final bool isPremium = article['premium'] ?? false;
//     final bool isFeatured = article['featured'] ?? false;
//
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
//           onTap: canAccess ? () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => ArticleDetailScreen(article: article),
//               ),
//             );
//           } : _showPremiumArticleLockedDialog,
//           borderRadius: BorderRadius.circular(20),
//           child: Opacity(
//             opacity: canAccess ? 1.0 : 0.6,
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 10,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF10B981).withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Text(
//                           category,
//                           style: const TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF10B981),
//                           ),
//                         ),
//                       ),
//                       if (isAiCurated) ...[
//                         const SizedBox(width: 8),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 10,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF6366F1).withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Row(
//                             children: [
//                               Icon(
//                                 Icons.auto_awesome,
//                                 size: 12,
//                                 color: Color(0xFF6366F1),
//                               ),
//                               SizedBox(width: 4),
//                               Text(
//                                 'AI Curated',
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w600,
//                                   color: Color(0xFF6366F1),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                       if (isPremium && canAccess) ...[
//                         const SizedBox(width: 8),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 10,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFFD4B5E8).withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Row(
//                             children: [
//                               Icon(
//                                 Icons.star,
//                                 size: 12,
//                                 color: Color(0xFFD4B5E8),
//                               ),
//                               SizedBox(width: 4),
//                               Text(
//                                 'PREMIUM',
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w600,
//                                   color: Color(0xFFD4B5E8),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                       if (isPremium && !canAccess) ...[
//                         const SizedBox(width: 8),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 10,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.orange.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: const Row(
//                             children: [
//                               Icon(
//                                 Icons.lock,
//                                 size: 12,
//                                 color: Colors.orange,
//                               ),
//                               SizedBox(width: 4),
//                               Text(
//                                 'PREMIUM',
//                                 style: TextStyle(
//                                   fontSize: 11,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.orange,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                       if (isFeatured) ...[
//                         const SizedBox(width: 8),
//                         const Icon(
//                           Icons.star,
//                           size: 16,
//                           color: Color(0xFFFBBF24),
//                         ),
//                       ],
//                       const Spacer(),
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.access_time,
//                             size: 14,
//                             color: Color(0xFF6B7280),
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             readTime,
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: Color(0xFF6B7280),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF1F2937),
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     content,
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       color: Color(0xFF6B7280),
//                       height: 1.4,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     children: [
//                       Text(
//                         canAccess ? 'Read more' : 'Upgrade to read',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: canAccess ? const Color(0xFF10B981) : Colors.orange,
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       Icon(
//                         canAccess ? Icons.arrow_forward : Icons.lock_outline,
//                         size: 16,
//                         color: canAccess ? const Color(0xFF10B981) : Colors.orange,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
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
//   const ArticleDetailScreen({Key? key, required this.article})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // Ensure all required fields have values and handle null cases
//     final String title = article['title'] ?? 'Untitled Article';
//     final String category = article['category'] ?? 'General';
//     final String readTime = article['readTime'] ?? '5 min';
//     final String content = article['content'] ?? 'Content not available.';
//     final bool isAiCurated = article['aiCurated'] ?? false;
//     final bool isPremium = article['premium'] ?? false;
//
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
//                       category,
//                       style: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     title,
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
//                         '$readTime read',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           color: Colors.white70,
//                         ),
//                       ),
//                       if (isAiCurated) ...[
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
//                       if (isPremium) ...[
//                         const SizedBox(width: 16),
//                         const Icon(
//                           Icons.star,
//                           size: 16,
//                           color: Colors.white70,
//                         ),
//                         const SizedBox(width: 6),
//                         const Text(
//                           'Premium',
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
//                     content,
//                     style: const TextStyle(
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
//
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// //
// // // Main Education Screen
// // class EducationScreen extends StatefulWidget {
// //   const EducationScreen({Key? key}) : super(key: key);
// //
// //   @override
// //   State<EducationScreen> createState() => _EducationScreenState();
// // }
// //
// // class _EducationScreenState extends State<EducationScreen>
// //     with SingleTickerProviderStateMixin {
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
// //                     colors: [
// //                       Color(0xFF6366F1),
// //                       Color(0xFF8B5CF6),
// //                       Color(0xFFA78BFA)
// //                     ],
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
// //                     const SizedBox(height: 16),
// //                     _buildFeatureCard(
// //                       context,
// //                       title: 'Resource Library',
// //                       description:
// //                       'Read expert articles and AI-curated content',
// //                       icon: Icons.menu_book_rounded,
// //                       colors: const [Color(0xFF10B981), Color(0xFF34D399)],
// //                       stats: '50+ Articles',
// //                       onTap: () {
// //                         Navigator.push(
// //                           context,
// //                           MaterialPageRoute(
// //                             builder: (_) => const ResourceLibraryScreen(),
// //                           ),
// //                         );
// //                       },
// //                     ),
// //                     const SizedBox(height: 32),
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
// //                     Icon(Icons.arrow_forward_ios_rounded,
// //                         color: colors[0], size: 20),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
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
// //   final List<String> categories = [
// //     'All',
// //     'Nutrition',
// //     'Exercise',
// //     'Health',
// //     'Mental Wellness',
// //     'Baby Care'
// //   ];
// //
// //   final List<Map<String, dynamic>> articles = [
// //     {
// //       'title': 'Essential Nutrients for Pregnancy',
// //       'category': 'Nutrition',
// //       'readTime': '5 min',
// //       'featured': true,
// //       'aiCurated': true,
// //       'content':
// //       'During pregnancy, proper nutrition is crucial for both mother and baby. Key nutrients include folic acid, iron, calcium, and protein. Folic acid prevents neural tube defects, iron prevents anemia, calcium strengthens bones, and protein supports tissue growth.',
// //     },
// //     {
// //       'title': 'Safe Exercises During Pregnancy',
// //       'category': 'Exercise',
// //       'readTime': '7 min',
// //       'featured': true,
// //       'aiCurated': true,
// //       'content':
// //       'Staying active during pregnancy has numerous benefits. Swimming, walking, and prenatal yoga are excellent choices. These low-impact exercises maintain cardiovascular health and prepare your body for labor.',
// //     },
// //     {
// //       'title': 'Managing Morning Sickness',
// //       'category': 'Health',
// //       'readTime': '4 min',
// //       'featured': false,
// //       'aiCurated': true,
// //       'content':
// //       'Morning sickness affects many pregnant women. Try eating small, frequent meals and staying hydrated. Ginger tea and vitamin B6 supplements may help reduce symptoms.',
// //     },
// //     {
// //       'title': 'Preparing for Labor and Delivery',
// //       'category': 'Health',
// //       'readTime': '10 min',
// //       'featured': false,
// //       'aiCurated': false,
// //       'content':
// //       'Understanding the stages of labor and delivery options can help you feel more prepared and confident. Learn about birth plans and comfort measures.',
// //     },
// //     {
// //       'title': 'Mental Health During Pregnancy',
// //       'category': 'Mental Wellness',
// //       'readTime': '6 min',
// //       'featured': true,
// //       'aiCurated': true,
// //       'content':
// //       'Pregnancy can bring emotional changes. It\'s important to take care of your mental health through support and self-care. Hormonal changes may affect mood.',
// //     },
// //     {
// //       'title': 'Newborn Care Basics',
// //       'category': 'Baby Care',
// //       'readTime': '8 min',
// //       'featured': false,
// //       'aiCurated': false,
// //       'content':
// //       'Learn essential skills for caring for your newborn, including feeding, diapering, and sleep routines. Establishing good habits early helps baby thrive.',
// //     },
// //   ];
// //
// //   List<Map<String, dynamic>> get filteredArticles {
// //     if (selectedCategory == 'All') return articles;
// //     return articles
// //         .where((a) => a['category'] == selectedCategory)
// //         .toList();
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
// //                       color: isSelected
// //                           ? Colors.white
// //                           : const Color(0xFF6B7280),
// //                       fontWeight:
// //                       isSelected ? FontWeight.w600 : FontWeight.normal,
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
// //                 builder: (_) =>
// //                     ArticleDetailScreen(article: article),
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
// //                         color:
// //                         const Color(0xFF10B981).withOpacity(0.1),
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
// //                           color: const Color(0xFF6366F1)
// //                               .withOpacity(0.1),
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
// //                 const Row(
// //                   children: [
// //                     Text(
// //                       'Read more',
// //                       style: TextStyle(
// //                         fontSize: 14,
// //                         fontWeight: FontWeight.w600,
// //                         color: Color(0xFF10B981),
// //                       ),
// //                     ),
// //                     SizedBox(width: 4),
// //                     Icon(
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
// //   const ArticleDetailScreen({Key? key, required this.article})
// //       : super(key: key);
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
// //                 const SnackBar(
// //                     content: Text('Share feature coming soon!')),
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
// //                     'Key Points:',
// //                     style: TextStyle(
// //                       fontSize: 20,
// //                       fontWeight: FontWeight.bold,
// //                       color: Color(0xFF1F2937),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 12),
// //                   _buildBulletPoint(
// //                       'Maintain a balanced diet with essential nutrients'),
// //                   _buildBulletPoint('Stay hydrated throughout the day'),
// //                   _buildBulletPoint(
// //                       'Consult with your healthcare provider regularly'),
// //                   _buildBulletPoint('Get adequate rest and manage stress'),
// //                   const SizedBox(height: 24),
// //                   Container(
// //                     padding: const EdgeInsets.all(16),
// //                     decoration: BoxDecoration(
// //                       color: const Color(0xFF10B981).withOpacity(0.1),
// //                       borderRadius: BorderRadius.circular(12),
// //                       border: Border.all(
// //                         color:
// //                         const Color(0xFF10B981).withOpacity(0.3),
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