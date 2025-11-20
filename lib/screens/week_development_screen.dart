import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PregnancyJourneyScreen extends StatefulWidget {
  @override
  _PregnancyJourneyScreenState createState() => _PregnancyJourneyScreenState();
}

class _PregnancyJourneyScreenState extends State<PregnancyJourneyScreen> {
  int _currentWeek = 1;
  final ScrollController _weekScrollController = ScrollController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _autoDetectCurrentWeek();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToCurrentWeek();
    });
  }

  void _autoDetectCurrentWeek() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final data = userDoc.data();
          final lastPeriodDate = data?['lastPeriodDate'];

          if (lastPeriodDate != null) {
            DateTime lmpDate;
            if (lastPeriodDate is Timestamp) {
              lmpDate = lastPeriodDate.toDate();
            } else if (lastPeriodDate is String) {
              lmpDate = DateTime.parse(lastPeriodDate);
            } else {
              lmpDate = DateTime.now();
            }

            final daysSinceLMP = DateTime.now().difference(lmpDate).inDays;
            final currentWeek = (daysSinceLMP / 7).floor() + 1;

            setState(() {
              _currentWeek = currentWeek.clamp(1, 40);
              _isLoading = false;
            });
            return;
          }
        }
      }
    } catch (e) {
      print('Error detecting current week: $e');
    }

    setState(() {
      _currentWeek = 1;
      _isLoading = false;
    });
  }

  void _scrollToCurrentWeek() {
    if (_weekScrollController.hasClients) {
      final double scrollPosition = (_currentWeek - 3) * 48.0;
      _weekScrollController.animateTo(
        scrollPosition.clamp(0, _weekScrollController.position.maxScrollExtent),
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _weekScrollController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> weekData = [
    {
      "week": "Week 1",
      "trimester": "First Trimester",
      "babyDevelopment": "Fertilization occurs. Egg and sperm meet. Zygote begins rapid cell division. Implantation begins.",
      "babySize": "Microscopic (Zygote)",
      "momTip": "Track your menstrual cycle. Ensure good health habits.",
      "motherSymptoms": "None yet - normal menstrual cycle",
      "nutritionFocus": "Folic acid, General health",
      "indianFoods": "Milk, eggs, leafy greens",
      "screeningTests": "None",
      "exercise": "Normal daily activities",
      "weeksRemaining": 39,
      "imageUrl": "https://via.placeholder.com/300x200/9C27B0/FFFFFF?text=Week+1"
    },
    {
      "week": "Week 2",
      "trimester": "First Trimester",
      "babyDevelopment": "Still microscopic. Zygote dividing into blastocyst. Traveling to uterus.",
      "babySize": "Microscopic",
      "momTip": "Start prenatal vitamins with folic acid",
      "motherSymptoms": "None yet",
      "nutritionFocus": "Folic acid, Iron",
      "indianFoods": "Fortified cereals, almonds, spinach",
      "screeningTests": "None",
      "exercise": "Normal activities",
      "weeksRemaining": 38,
      "imageUrl": "https://via.placeholder.com/300x200/8E24AA/FFFFFF?text=Week+2"
    },
    {
      "week": "Week 3",
      "trimester": "First Trimester",
      "babyDevelopment": "Blastocyst implanting into uterine wall. Three layers forming.",
      "babySize": "Microscopic",
      "momTip": "Continue healthy lifestyle. Avoid harmful substances.",
      "motherSymptoms": "None yet",
      "nutritionFocus": "Folic acid, Calcium",
      "indianFoods": "Paneer, milk, dal",
      "screeningTests": "None",
      "exercise": "Normal activities",
      "weeksRemaining": 37,
      "imageUrl": "https://via.placeholder.com/300x200/7B1FA2/FFFFFF?text=Week+3"
    },
    {
      "week": "Week 4",
      "trimester": "First Trimester",
      "babyDevelopment": "Blastocyst implanted. Amniotic sac begins forming. Early heart tissue developing.",
      "babySize": "Poppy seed",
      "momTip": "Confirm pregnancy with doctor. Begin prenatal appointments.",
      "motherSymptoms": "Missed period. Breast tenderness may begin. Possible positive pregnancy test.",
      "nutritionFocus": "Folic acid, Iron, Calcium",
      "indianFoods": "Milk, eggs, spinach, fortified cereals, dal",
      "screeningTests": "Blood hCG test",
      "exercise": "Light walking, normal activities",
      "weeksRemaining": 36,
      "imageUrl": "https://via.placeholder.com/300x200/6A1B9A/FFFFFF?text=Week+4"
    },
    {
      "week": "Week 5",
      "trimester": "First Trimester",
      "babyDevelopment": "Heart begins to beat. Amniotic sac visible on ultrasound. Yolk sac forms.",
      "babySize": "Apple seed",
      "momTip": "Eat small frequent meals. Stay hydrated. Rest when tired. Ginger tea helps nausea.",
      "motherSymptoms": "Nausea begins (morning sickness). Breast tenderness. Fatigue. Frequent urination.",
      "nutritionFocus": "Folic acid, Vitamin B6, Iron",
      "indianFoods": "Bananas, ginger tea, whole wheat toast, yogurt, coconut water",
      "screeningTests": "Dating ultrasound",
      "exercise": "Walking, light yoga",
      "weeksRemaining": 35,
      "imageUrl": "https://via.placeholder.com/300x200/4A148C/FFFFFF?text=Week+5"
    },
    {
      "week": "Week 6",
      "trimester": "First Trimester",
      "babyDevelopment": "Heart beating at 100-120 bpm. Brain beginning to develop. Eyes starting to form. Arm and leg buds appearing.",
      "babySize": "Lentil/Sweet pea",
      "momTip": "Keep hydrated. Eat foods you can tolerate. Rest adequately.",
      "motherSymptoms": "Morning sickness peaks. Fatigue. Mood swings. Tender breasts. Frequent urination.",
      "nutritionFocus": "Folic acid, Vitamin B6, Iron",
      "indianFoods": "Whole grain bread, eggs, bananas, dates, lentil soup",
      "screeningTests": "Ultrasound confirmation",
      "exercise": "Light walks, gentle stretching",
      "weeksRemaining": 34,
      "imageUrl": "https://via.placeholder.com/300x200/311B92/FFFFFF?text=Week+6"
    },
    {
      "week": "Week 7",
      "trimester": "First Trimester",
      "babyDevelopment": "Arms and legs look like little paddles. Eyes becoming more defined. Ears starting to form.",
      "babySize": "Blueberry",
      "momTip": "Manage nausea - eat crackers upon waking. Smaller portions. Avoid triggers.",
      "motherSymptoms": "Nausea continues. Fatigue. Food cravings/aversions. Frequent urination.",
      "nutritionFocus": "Folic acid, Calcium, Iron, Protein",
      "indianFoods": "Milk, paneer, dal, brown rice, green vegetables",
      "screeningTests": "Optional: Early NT scan",
      "exercise": "Walking, swimming, prenatal yoga",
      "weeksRemaining": 33,
      "imageUrl": "https://via.placeholder.com/300x200/1A237E/FFFFFF?text=Week+7"
    },
    {
      "week": "Week 8",
      "trimester": "First Trimester",
      "babyDevelopment": "Embryo now called fetus. Fingers and toes forming. Eyes more prominent. Ears taking shape.",
      "babySize": "Raspberry",
      "momTip": "Rest when possible. Small frequent meals. Prenatal vitamins essential.",
      "motherSymptoms": "Morning sickness may peak. Exhaustion. Mood swings. Frequent urination.",
      "nutritionFocus": "Folic acid, Iron, Calcium, Vitamin D",
      "indianFoods": "Milk with turmeric, eggs, spinach, whole grains, seasonal fruits",
      "screeningTests": "Confirm fetal heartbeat with ultrasound",
      "exercise": "Walking, gentle yoga, swimming",
      "weeksRemaining": 32,
      "imageUrl": "https://via.placeholder.com/300x200/0D47A1/FFFFFF?text=Week+8"
    },
    {
      "week": "Week 9",
      "trimester": "First Trimester",
      "babyDevelopment": "Eyes more developed, ears forming. Arms bending at elbow. Tiny muscles allowing small movements.",
      "babySize": "Grape",
      "momTip": "Eat nutritious foods despite nausea. Ginger, lemon help. Stay hydrated.",
      "motherSymptoms": "Morning sickness often at peak. Fatigue. Mood swings. Breast tenderness.",
      "nutritionFocus": "Folic acid, Iron, Protein, Omega-3",
      "indianFoods": "Walnuts, fish, eggs, milk, dates, almonds, lentils",
      "screeningTests": "Nuchal translucency scan optional",
      "exercise": "Walking, light stretching, water aerobics",
      "weeksRemaining": 31,
      "imageUrl": "https://via.placeholder.com/300x200/1565C0/FFFFFF?text=Week+9"
    },
    {
      "week": "Week 10",
      "trimester": "First Trimester",
      "babyDevelopment": "Fetus now 1.2 inches long. All major organs beginning to form. Eyebrows forming.",
      "babySize": "Kumquat/Tangerine",
      "momTip": "Some relief from nausea coming. Rest adequately. Stay active with light exercise.",
      "motherSymptoms": "Morning sickness may start improving. Still fatigued. Frequent urination.",
      "nutritionFocus": "Calcium, Iron, Protein, Folic acid",
      "indianFoods": "Milk, paneer, spinach, whole wheat, chickpeas, beans",
      "screeningTests": "Routine blood tests",
      "exercise": "Walking, prenatal yoga, swimming",
      "weeksRemaining": 30,
      "imageUrl": "https://via.placeholder.com/300x200/1976D2/FFFFFF?text=Week+10"
    },
    {
      "week": "Week 11",
      "trimester": "First Trimester",
      "babyDevelopment": "Ears more prominent. Fingers webbing beginning to disappear. Toenails starting.",
      "babySize": "Fig",
      "momTip": "Energy may be increasing. Good time to start gentle exercise.",
      "motherSymptoms": "Morning sickness improving for many. Still fatigued. Frequent urination.",
      "nutritionFocus": "Calcium, Iron, DHA, Protein",
      "indianFoods": "Salmon, sardines, walnuts, eggs, milk, green vegetables",
      "screeningTests": "Second trimester screening discussed",
      "exercise": "Walking, swimming, yoga, light dance",
      "weeksRemaining": 29,
      "imageUrl": "https://via.placeholder.com/300x200/2196F3/FFFFFF?text=Week+11"
    },
    {
      "week": "Week 12",
      "trimester": "First Trimester (End)",
      "babyDevelopment": "Baby now 2+ inches. All organs present but immature. Can make fist. Sucking reflex starting.",
      "babySize": "Lime",
      "momTip": "Celebrate end of first trimester! Energy returning.",
      "motherSymptoms": "Nausea often improving. Energy increasing. Still frequent urination.",
      "nutritionFocus": "Iron, Calcium, Protein, Vitamins",
      "indianFoods": "Iron-rich foods - spinach, pomegranate, dates; Calcium - milk, curd",
      "screeningTests": "First trimester combined screening, dating scan",
      "exercise": "Walking, swimming, prenatal yoga, strength training",
      "weeksRemaining": 28,
      "imageUrl": "https://via.placeholder.com/300x200/42A5F5/FFFFFF?text=Week+12"
    },
    {
      "week": "Week 13",
      "trimester": "Second Trimester (Start)",
      "babyDevelopment": "Tail-like structure completely gone. Fetus looks more human. Fingerprints beginning to form.",
      "babySize": "Pea pod",
      "momTip": "Energy returning! Good time to increase activity.",
      "motherSymptoms": "Energy boost for most. Morning sickness resolving. Appetite improving.",
      "nutritionFocus": "Iron, Calcium, Protein, DHA",
      "indianFoods": "Eggs, milk, spinach, lentils, fish, nuts",
      "screeningTests": "Detailed ultrasound, quad marker test",
      "exercise": "More vigorous activity - swimming, walking, yoga",
      "weeksRemaining": 27,
      "imageUrl": "https://via.placeholder.com/300x200/64B5F6/FFFFFF?text=Week+13"
    },
    {
      "week": "Week 14",
      "trimester": "Second Trimester",
      "babyDevelopment": "Chin now distinct. Eyebrows and eyelashes forming. Facial muscles exercising.",
      "babySize": "Lemon",
      "momTip": "This is the honeymoon period! Feel free to plan travel.",
      "motherSymptoms": "Feeling much better. Energy returning. Appetite increasing.",
      "nutritionFocus": "Protein, Iron, Calcium, DHA",
      "indianFoods": "Chicken, fish, paneer, dal; Fish 2-3 times weekly for DHA",
      "screeningTests": "Quad marker test if not done",
      "exercise": "Swimming, brisk walking, moderate exercise",
      "weeksRemaining": 26,
      "imageUrl": "https://via.placeholder.com/300x200/90CAF9/FFFFFF?text=Week+14"
    },
    {
      "week": "Week 15",
      "trimester": "Second Trimester",
      "babyDevelopment": "Hair beginning to grow on head. Skin very thin. Ears positioned correctly. Can hear sounds.",
      "babySize": "Apple",
      "momTip": "Baby can hear you - sing, talk to baby!",
      "motherSymptoms": "Feeling great! Energy good. Appetite strong. Possible food cravings.",
      "nutritionFocus": "Calcium, Iron, Protein",
      "indianFoods": "Calcium - milk, yogurt, paneer; Iron - dates, pomegranate",
      "screeningTests": "Routine checkup",
      "exercise": "Walking 30 minutes daily, swimming, yoga",
      "weeksRemaining": 25,
      "imageUrl": "https://via.placeholder.com/300x200/29B6F6/FFFFFF?text=Week+15"
    },
    {
      "week": "Week 16",
      "trimester": "Second Trimester",
      "babyDevelopment": "Circulatory system fully functional. Muscles developing. Possibly first movements felt.",
      "babySize": "Avocado",
      "momTip": "First movements exciting! Keep prenatal vitamins.",
      "motherSymptoms": "May start feeling quickening. Appetite good. Possible skin changes.",
      "nutritionFocus": "Iron, Calcium, Protein, Vitamin C",
      "indianFoods": "Citrus fruits for iron absorption, leafy greens, legumes",
      "screeningTests": "Anomaly detailed ultrasound around week 18-21",
      "exercise": "Walking, swimming, prenatal yoga",
      "weeksRemaining": 24,
      "imageUrl": "https://via.placeholder.com/300x200/26C6DA/FFFFFF?text=Week+16"
    },
    {
      "week": "Week 17",
      "trimester": "Second Trimester",
      "babyDevelopment": "Vernix beginning to coat baby. Swallowing amniotic fluid. Practicing breathing.",
      "babySize": "Turnip",
      "momTip": "Left side sleeping preferred. Prenatal pillows helpful.",
      "motherSymptoms": "Feeling baby movements more. Appetite good. Backache starting.",
      "nutritionFocus": "Calcium, Iron, Magnesium",
      "indianFoods": "Magnesium - almonds, pumpkin seeds, spinach",
      "screeningTests": "Routine visits every 2 weeks",
      "exercise": "Walking, swimming, yoga, pelvic floor exercises",
      "weeksRemaining": 23,
      "imageUrl": "https://via.placeholder.com/300x200/26A69A/FFFFFF?text=Week+17"
    },
    {
      "week": "Week 18",
      "trimester": "Second Trimester",
      "babyDevelopment": "Sex clearly visible on ultrasound. Fingerprints unique now. Can respond to sounds.",
      "babySize": "Sweet potato",
      "momTip": "Maternity belt for back support. Eat smaller frequent meals.",
      "motherSymptoms": "Definitely feeling movements. More energy. Backaches may occur.",
      "nutritionFocus": "Calcium, Iron, Fiber, Protein",
      "indianFoods": "High fiber - whole grains, vegetables; Calcium - milk products",
      "screeningTests": "Anomaly scan (detailed ultrasound)",
      "exercise": "Walking, swimming, prenatal yoga",
      "weeksRemaining": 22,
      "imageUrl": "https://via.placeholder.com/300x200/66BB6A/FFFFFF?text=Week+18"
    },
    {
      "week": "Week 19",
      "trimester": "Second Trimester",
      "babyDevelopment": "Legs now longer than arms. Skin becoming less transparent. Brown fat developing.",
      "babySize": "Mango",
      "momTip": "Manage weight gain - 300-400g per week normal. Magnesium for leg cramps.",
      "motherSymptoms": "Baby movements very noticeable. Appetite strong. Possible leg cramps.",
      "nutritionFocus": "Iron, Calcium, Protein, Magnesium",
      "indianFoods": "Dates for iron, milk for calcium, almonds for magnesium",
      "screeningTests": "Should complete anomaly scan",
      "exercise": "Walking, swimming, prenatal yoga",
      "weeksRemaining": 21,
      "imageUrl": "https://via.placeholder.com/300x200/9CCC65/FFFFFF?text=Week+19"
    },
    {
      "week": "Week 20",
      "trimester": "Second Trimester (Midpoint)",
      "babyDevelopment": "Hair growing on head. Eyebrows visible. Swallowing and hiccupping. Stomach producing digestive juices.",
      "babySize": "Banana",
      "momTip": "Elevate feet regularly. Compression socks helpful.",
      "motherSymptoms": "Baby movements clear. Backache common. Possible swelling in feet/ankles.",
      "nutritionFocus": "Iron, Calcium, Protein, Fiber",
      "indianFoods": "Iron-rich foods, calcium-rich foods, fiber for digestion",
      "screeningTests": "Mid-pregnancy anatomy scan",
      "exercise": "Walking 30-45 min, swimming, prenatal yoga",
      "weeksRemaining": 20,
      "imageUrl": "https://via.placeholder.com/300x200/CDDC39/FFFFFF?text=Week+20"
    },
    {
      "week": "Week 21",
      "trimester": "Second Trimester",
      "babyDevelopment": "Coordinated movements. Swallowing amniotic fluid. Practicing breathing. Buds for permanent teeth forming.",
      "babySize": "Carrot",
      "momTip": "Use maternity belt. Avoid standing long periods. Elevate feet.",
      "motherSymptoms": "Clear baby movements. Back and pelvic pain common. Possible swollen ankles.",
      "nutritionFocus": "Iron, Calcium, Protein, Fluids",
      "indianFoods": "Spinach for iron, milk for calcium, plenty of water",
      "screeningTests": "Routine visit - blood pressure, weight check",
      "exercise": "Swimming excellent, walking, yoga, pelvic floor",
      "weeksRemaining": 19,
      "imageUrl": "https://via.placeholder.com/300x200/FFEB3B/FFFFFF?text=Week+21"
    },
    {
      "week": "Week 22",
      "trimester": "Second Trimester",
      "babyDevelopment": "Lungs developing rapidly. Brain development accelerating. Senses more refined.",
      "babySize": "Papaya",
      "momTip": "Sunscreen for skin - melasma common. Back support important.",
      "motherSymptoms": "Definite movements felt. Back pain. Possible skin changes (linea nigra).",
      "nutritionFocus": "Iron, Calcium, Protein, DHA",
      "indianFoods": "Fish for DHA, greens for iron, milk for calcium",
      "screeningTests": "Routine check",
      "exercise": "Walking, swimming, yoga, modified strength training",
      "weeksRemaining": 18,
      "imageUrl": "https://via.placeholder.com/300x200/FFC107/FFFFFF?text=Week+22"
    },
    {
      "week": "Week 23",
      "trimester": "Second Trimester",
      "babyDevelopment": "Rapid brain development. Increased lung maturation. Baby can hear and respond to loud noises.",
      "babySize": "Large mango",
      "momTip": "Prenatal massage helpful. Proper posture important. Special pillow for side sleeping.",
      "motherSymptoms": "Increased discomfort. Backache. Possible leg cramps. Sleep challenging.",
      "nutritionFocus": "Iron, Calcium, Protein, Magnesium",
      "indianFoods": "Legumes, greens, milk products",
      "screeningTests": "Regular checkup every 2 weeks",
      "exercise": "Walking, swimming, prenatal yoga",
      "weeksRemaining": 17,
      "imageUrl": "https://via.placeholder.com/300x200/FF9800/FFFFFF?text=Week+23"
    },
    {
      "week": "Week 24",
      "trimester": "Second Trimester",
      "babyDevelopment": "Lungs still developing. Eyelids beginning to separate. Skin still wrinkled. Brain growth rapid.",
      "babySize": "Corn",
      "momTip": "Glucose tolerance test typically done now. Watch for diabetes symptoms.",
      "motherSymptoms": "Increased discomfort. Back pain significant. Gestational diabetes screening now.",
      "nutritionFocus": "Iron, Calcium, Protein, Reduced sugar",
      "indianFoods": "Whole grains, legumes, vegetables, lean proteins",
      "screeningTests": "Glucose tolerance test (gestational diabetes screening)",
      "exercise": "Walking, swimming, prenatal yoga",
      "weeksRemaining": 16,
      "imageUrl": "https://via.placeholder.com/300x200/FF5722/FFFFFF?text=Week+24"
    },
    {
      "week": "Week 25",
      "trimester": "Second Trimester",
      "babyDevelopment": "Nostrils opening. Ears function improving. Baby more reactive. Immune system developing.",
      "babySize": "Rutabaga",
      "momTip": "Braxton-Hicks normal. Continue exercise within comfort.",
      "motherSymptoms": "Significant discomfort. Braxton-Hicks contractions. Swelling.",
      "nutritionFocus": "Iron, Calcium, Protein, Immune support",
      "indianFoods": "Vitamin C for immune support - citrus, guava, peppers",
      "screeningTests": "Routine antenatal checkup",
      "exercise": "Walking, swimming, prenatal yoga",
      "weeksRemaining": 15,
      "imageUrl": "https://via.placeholder.com/300x200/E64A19/FFFFFF?text=Week+25"
    },
    {
      "week": "Week 26",
      "trimester": "Second Trimester (End)",
      "babyDevelopment": "Eyes open. Eyelashes fully developed. Skin pink. Practicing breathing.",
      "babySize": "Lettuce head",
      "momTip": "From 28 weeks, checkups every 2 weeks. Continue exercise.",
      "motherSymptoms": "Very uncomfortable. Weight gain. Back pain, pelvic pressure.",
      "nutritionFocus": "Iron, Calcium, Protein, DHA",
      "indianFoods": "Maintain balanced nutrition",
      "screeningTests": "Complete hemoglobin check",
      "exercise": "Walking, swimming, gentle yoga",
      "weeksRemaining": 14,
      "imageUrl": "https://via.placeholder.com/300x200/D84315/FFFFFF?text=Week+26"
    },
    {
      "week": "Week 27",
      "trimester": "Third Trimester (Start)",
      "babyDevelopment": "Brain development continuing rapidly. Lungs rapidly maturing. Strong kicks.",
      "babySize": "Head of lettuce",
      "momTip": "More frequent checkups now - every 2 weeks. Monitor blood pressure.",
      "motherSymptoms": "Severe discomfort. Back/pelvic pain. Swelling. More frequent urination.",
      "nutritionFocus": "Iron, Calcium, Protein, DHA",
      "indianFoods": "Spinach, milk, dates, fish",
      "screeningTests": "Biweekly checkups begin",
      "exercise": "Walking, swimming, modified yoga",
      "weeksRemaining": 13,
      "imageUrl": "https://via.placeholder.com/300x200/C62828/FFFFFF?text=Week+27"
    },
    {
      "week": "Week 28",
      "trimester": "Third Trimester",
      "babyDevelopment": "Eyes focusing. Hair and body lanugo present. Lungs producing surfactant.",
      "babySize": "Eggplant",
      "momTip": "Rh-negative women get anti-D injection now. Frequent checkups to monitor.",
      "motherSymptoms": "Increasingly uncomfortable. Sleep position restricted. Possible gestational hypertension.",
      "nutritionFocus": "Iron, Calcium, Protein, Blood pressure management",
      "indianFoods": "Low sodium diet, potassium-rich foods like bananas",
      "screeningTests": "Anti-D if Rh negative; biweekly checkups start",
      "exercise": "Walking, swimming, prenatal yoga",
      "weeksRemaining": 12,
      "imageUrl": "https://via.placeholder.com/300x200/B71C1C/FFFFFF?text=Week+28"
    },
    {
      "week": "Week 29",
      "trimester": "Third Trimester",
      "babyDevelopment": "Brain accelerating. Baby gaining fat. Bones hardening. Position changing.",
      "babySize": "Butternut squash",
      "momTip": "Prenatal classes important. Birth plan creation. Hospital bag preparation.",
      "motherSymptoms": "Severe discomfort. Sleep very difficult. Frequent urination at night.",
      "nutritionFocus": "Iron, Calcium, Protein, Hydration",
      "indianFoods": "Balanced nutrition; avoid excess salt",
      "screeningTests": "Biweekly antenatal care",
      "exercise": "Modified walking, swimming, prenatal yoga",
      "weeksRemaining": 11,
      "imageUrl": "https://via.placeholder.com/300x200/8D6E63/FFFFFF?text=Week+29"
    },
    {
      "week": "Week 30",
      "trimester": "Third Trimester",
      "babyDevelopment": "Brain rapid growth. Most babies head-down. Strong coordinated movements.",
      "babySize": "Large cabbage",
      "momTip": "Pain management important. Hospital bag ready. Birth plan finalized.",
      "motherSymptoms": "Very uncomfortable. Severe back and pelvic pain. Possible insomnia.",
      "nutritionFocus": "Iron, Calcium, Protein, Relaxation nutrients",
      "indianFoods": "Magnesium sources - almonds, pumpkin seeds",
      "screeningTests": "Biweekly checkups, fetal health assessments",
      "exercise": "Gentle walking, prenatal yoga, breathing exercises",
      "weeksRemaining": 10,
      "imageUrl": "https://via.placeholder.com/300x200/795548/FFFFFF?text=Week+30"
    },
    {
      "week": "Week 31",
      "trimester": "Third Trimester",
      "babyDevelopment": "Skin pink and smoother. Most lanugo disappearing. Nails reaching fingertip ends.",
      "babySize": "Coconut",
      "momTip": "Regular monitoring for preeclampsia. Rest when possible.",
      "motherSymptoms": "Increasing discomfort. Severe fatigue returning. Sleep disrupted.",
      "nutritionFocus": "Iron, Calcium, Protein, Healthy fats",
      "indianFoods": "Varied diet with all nutrients",
      "screeningTests": "Biweekly monitoring for complications",
      "exercise": "Gentle walking, light yoga, pelvic floor exercises",
      "weeksRemaining": 9,
      "imageUrl": "https://via.placeholder.com/300x200/6D4C41/FFFFFF?text=Week+31"
    },
    {
      "week": "Week 32",
      "trimester": "Third Trimester",
      "babyDevelopment": "Bones fully formed but flexible. Fingernails grown. Toenails full length. Immune system almost complete.",
      "babySize": "Jicama",
      "momTip": "Only 8 weeks remaining! Pain management important.",
      "motherSymptoms": "Very uncomfortable. Severe back pain. Pelvic pressure. Braxton-Hicks regular.",
      "nutritionFocus": "Iron, Calcium, Protein, Antioxidants",
      "indianFoods": "Colorful vegetables for antioxidants",
      "screeningTests": "Biweekly checkups; Group B Strep screening",
      "exercise": "Gentle walking, prenatal yoga for relaxation",
      "weeksRemaining": 8,
      "imageUrl": "https://via.placeholder.com/300x200/5D4037/FFFFFF?text=Week+32"
    },
    {
      "week": "Week 33",
      "trimester": "Third Trimester",
      "babyDevelopment": "Immune system nearly complete. Lungs maturing. Brain development continuing. Practicing crying.",
      "babySize": "Pineapple",
      "momTip": "7 weeks to go! Birth plan review with doctor.",
      "motherSymptoms": "Extreme discomfort. Severe fatigue. Leg cramps. Possible sciatic nerve pain.",
      "nutritionFocus": "Iron, Calcium, Protein, Fiber",
      "indianFoods": "Fiber to prevent constipation - whole grains, vegetables",
      "screeningTests": "Biweekly appointments; labor discussions",
      "exercise": "Very gentle walking, relaxation yoga",
      "weeksRemaining": 7,
      "imageUrl": "https://via.placeholder.com/300x200/4E342E/FFFFFF?text=Week+33"
    },
    {
      "week": "Week 34",
      "trimester": "Third Trimester",
      "babyDevelopment": "Position settling (most head-down). Nails fully grown. Hair thickening. Antibodies transferring.",
      "babySize": "Cantaloupe melon",
      "momTip": "6 weeks remaining! Finalize birth plans. Notify work about leave.",
      "motherSymptoms": "Extremely uncomfortable. Severe back pain. Pelvic pressure increasing.",
      "nutritionFocus": "Iron, Calcium, Protein, Hydration",
      "indianFoods": "Balanced nutrition; stay hydrated",
      "screeningTests": "Biweekly checkups; Group B Strep results",
      "exercise": "Walking, relaxation techniques, breathing exercises",
      "weeksRemaining": 6,
      "imageUrl": "https://via.placeholder.com/300x200/37474F/FFFFFF?text=Week+34"
    },
    {
      "week": "Week 35",
      "trimester": "Third Trimester",
      "babyDevelopment": "Fully capable of life outside womb. Bones hardened but flexible. Most lanugo shed.",
      "babySize": "Honeydew melon",
      "momTip": "5 weeks to go. All preparations complete. Practice breathing exercises.",
      "motherSymptoms": "Extreme discomfort. Peak fatigue. Braxton-Hicks strong and regular.",
      "nutritionFocus": "Iron, Calcium, Protein",
      "indianFoods": "Final trimester nutrition",
      "screeningTests": "Final biweekly checkups",
      "exercise": "Gentle walking, relaxation practice",
      "weeksRemaining": 5,
      "imageUrl": "https://via.placeholder.com/300x200/455A64/FFFFFF?text=Week+35"
    },
    {
      "week": "Week 36",
      "trimester": "Third Trimester",
      "babyDevelopment": "Ready for birth. Bones still flexible. Vernix coating entire body. Lungs fully mature.",
      "babySize": "Romaine lettuce head",
      "momTip": "4 weeks to go! Weekly checkups start. Watch for labor signs.",
      "motherSymptoms": "Very uncomfortable. Strong Braxton-Hicks. Baby dropping lower.",
      "nutritionFocus": "Iron, Calcium",
      "indianFoods": "Small frequent meals",
      "screeningTests": "Weekly checkups start; monitor for preeclampsia",
      "exercise": "Walking, standing, position changes",
      "weeksRemaining": 4,
      "imageUrl": "https://via.placeholder.com/300x200/546E7A/FFFFFF?text=Week+36"
    },
    {
      "week": "Week 37",
      "trimester": "Third Trimester",
      "babyDevelopment": "Now considered term. Can be born safely. Vernix coating. Lanugo mostly gone.",
      "babySize": "Stalk of swiss chard",
      "momTip": "3 weeks to go! Labor could start anytime. Know false vs real labor signs.",
      "motherSymptoms": "Extremely uncomfortable. Baby moved lower. Braxton-Hicks frequent.",
      "nutritionFocus": "Hydration, Nutrition",
      "indianFoods": "Energy-rich foods",
      "screeningTests": "Weekly checkups; Group B Strep treatment if needed",
      "exercise": "Walking, labor preparation movements",
      "weeksRemaining": 3,
      "imageUrl": "https://via.placeholder.com/300x200/607D8B/FFFFFF?text=Week+37"
    },
    {
      "week": "Week 38",
      "trimester": "Third Trimester",
      "babyDevelopment": "All systems ready. Brain continuing development. Baby fully capable of life outside.",
      "babySize": "Stalk of rhubarb",
      "momTip": "2 weeks to go! Labor could begin any day. Stay positive.",
      "motherSymptoms": "Peak discomfort. Frequent urination. Possible mucus plug loss.",
      "nutritionFocus": "Hydration, Energy",
      "indianFoods": "Light meals easily digestible",
      "screeningTests": "Weekly checkups; assess cervical changes",
      "exercise": "Walking, position changes, labor prep movements",
      "weeksRemaining": 2,
      "imageUrl": "https://via.placeholder.com/300x200/78909C/FFFFFF?text=Week+38"
    },
    {
      "week": "Week 39",
      "trimester": "Third Trimester",
      "babyDevelopment": "Fully developed. Skin smooth from vernix. All systems ready. Practicing birth.",
      "babySize": "Small pumpkin",
      "momTip": "1 week to go! Labor likely imminent. Continue walking.",
      "motherSymptoms": "Extremely uncomfortable. May lose mucus plug. Possible cervical changes.",
      "nutritionFocus": "Hydration",
      "indianFoods": "Light easily digestible foods",
      "screeningTests": "Weekly checkups; induction discussion if needed",
      "exercise": "Walking for natural labor induction, position changes",
      "weeksRemaining": 1,
      "imageUrl": "https://via.placeholder.com/300x200/90A4AE/FFFFFF?text=Week+39"
    },
    {
      "week": "Week 40",
      "trimester": "Third Trimester (Due date)",
      "babyDevelopment": "Fully term and ready! All organs functioning. Brain continuing development after birth.",
      "babySize": "Small watermelon",
      "momTip": "Your due date! Labor should begin within days. Patience important.",
      "motherSymptoms": "Due date! May have labor or still waiting. Extreme discomfort.",
      "nutritionFocus": "Hydration",
      "indianFoods": "Light meals, clear fluids",
      "screeningTests": "Labor monitoring if started; medical induction if needed",
      "exercise": "Walking if not in labor, position changes",
      "weeksRemaining": 0,
      "imageUrl": "https://via.placeholder.com/300x200/B0BEC5/FFFFFF?text=Week+40"
    },
  ];
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFB794F4)),
        ),
      );
    }

    if (_currentWeek < 1) {
      _currentWeek = 1;
    } else if (_currentWeek > weekData.length) {
      _currentWeek = weekData.length;
    }

    final currentWeekData = weekData[_currentWeek - 1];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Pregnancy Journey',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFFB794F4),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Enhanced Top Week Navigation Bar
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Current Week and Trimester Info
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentWeekData["week"]!,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB794F4),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            currentWeekData["trimester"]!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFFB794F4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${currentWeekData["weeksRemaining"]} weeks to go",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFFB794F4),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Horizontal Week Navigation (1-40)
                Container(
                  height: 110,
                  child: Column(
                    children: [
                      // Week Numbers 1-40
                      Expanded(
                        child: ListView.builder(
                          controller: _weekScrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: weekData.length,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          itemBuilder: (context, index) {
                            final weekNumber = index + 1;
                            final isSelected = weekNumber == _currentWeek;
                            final isCurrentWeek = weekNumber == _currentWeek;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentWeek = weekNumber;
                                });
                              },
                              child: Container(
                                width: 40,
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  color: isSelected ? Color(0xFFB794F4) : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: isCurrentWeek
                                      ? Border.all(color: Color(0xFFB794F4), width: 2)
                                      : null,
                                  boxShadow: isSelected ? [
                                    BoxShadow(
                                      color: Color(0xFFB794F4).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    )
                                  ] : null,
                                ),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$weekNumber',
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.grey[700],
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (isCurrentWeek) ...[
                                      SizedBox(height: 2),
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: isSelected ? Colors.white : Color(0xFFB794F4),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Navigation Arrows
                      SizedBox(height: 12),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Previous Week Button
                            ElevatedButton.icon(
                              onPressed: _currentWeek > 1 ? () {
                                setState(() {
                                  _currentWeek--;
                                });
                                _scrollToCurrentWeek();
                              } : null,
                              icon: Icon(Icons.arrow_back_ios, size: 16),
                              label: Text('Previous'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFB794F4),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),

                            // Week Indicator
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Text(
                                'Week $_currentWeek of ${weekData.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),

                            // Next Week Button
                            ElevatedButton.icon(
                              onPressed: _currentWeek < weekData.length ? () {
                                setState(() {
                                  _currentWeek++;
                                });
                                _scrollToCurrentWeek();
                              } : null,
                              label: Text('Next'),
                              icon: Icon(Icons.arrow_forward_ios, size: 16),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFB794F4),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
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

          // Content Section
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Section
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        currentWeekData["imageUrl"]!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFB794F4).withOpacity(0.3), Color(0xFF9F7AEA).withOpacity(0.3)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.pregnant_woman, size: 50, color: Color(0xFFB794F4)),
                                  SizedBox(height: 8),
                                  Text(
                                    currentWeekData["week"]!,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFB794F4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 24),

                  // Baby's Development Section
                  _buildSectionHeader("Baby's Development"),
                  SizedBox(height: 10),
                  Text(
                    currentWeekData["babyDevelopment"]!,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Baby's Size Section
                  _buildSectionHeader("Baby's Size"),
                  SizedBox(height: 10),
                  _buildInfoRow(Icons.monitor_weight, currentWeekData["babySize"]!),
                  SizedBox(height: 24),

                  // Mother's Symptoms Section
                  _buildSectionHeader("Mother's Symptoms"),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50]?.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange[100]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.health_and_safety, color: Colors.orange[600], size: 24),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            currentWeekData["motherSymptoms"]!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Mom's Tip Section
                  _buildSectionHeader("Mom's Tip"),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFB794F4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFFB794F4).withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_outline, color: Color(0xFFB794F4), size: 24),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            currentWeekData["momTip"]!,
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),

                  // Nutrition Focus Section
                  _buildSectionHeader("Nutrition Focus"),
                  SizedBox(height: 10),
                  _buildInfoRow(Icons.restaurant, currentWeekData["nutritionFocus"]!),
                  SizedBox(height: 24),

                  // Indian Foods Section
                  _buildSectionHeader("Indian Foods"),
                  SizedBox(height: 10),
                  _buildInfoRow(Icons.food_bank, currentWeekData["indianFoods"]!),
                  SizedBox(height: 24),

                  // Screening Tests Section
                  _buildSectionHeader("Screening Tests"),
                  SizedBox(height: 10),
                  _buildInfoRow(Icons.medical_services, currentWeekData["screeningTests"]!),
                  SizedBox(height: 24),

                  // Exercise Section
                  _buildSectionHeader("Exercise"),
                  SizedBox(height: 10),
                  _buildInfoRow(Icons.directions_run, currentWeekData["exercise"]!),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFFB794F4),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Color(0xFFB794F4), size: 24),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}


// / import 'package:flutter/material.dart';
//
// class PregnancyJourneyScreen extends StatefulWidget {
//   @override
//   _PregnancyJourneyScreenState createState() => _PregnancyJourneyScreenState();
// }
//
// class _PregnancyJourneyScreenState extends State<PregnancyJourneyScreen> {
//   int _currentWeek = 1; // Start with Week 1
//   final ScrollController _weekScrollController = ScrollController();
//
//   // Updated data structure with new content
//   // Complete data for all 40 weeks
//   final List<Map<String, dynamic>> weekData = [
//     {
//       "week": "Week 1",
//       "trimester": "First Trimester",
//       "babyDevelopment": "Fertilization occurs. Egg and sperm meet. Zygote begins rapid cell division. Implantation begins.",
//       "babySize": "Microscopic (Zygote)",
//       "momTip": "Track your menstrual cycle. Ensure good health habits.",
//       "motherSymptoms": "None yet - normal menstrual cycle",
//       "nutritionFocus": "Folic acid, General health",
//       "indianFoods": "Milk, eggs, leafy greens",
//       "screeningTests": "None",
//       "exercise": "Normal daily activities",
//       "weeksRemaining": 39,
//       "imageUrl": "https://via.placeholder.com/300x200/9C27B0/FFFFFF?text=Week+1"
//     },
//     {
//       "week": "Week 2",
//       "trimester": "First Trimester",
//       "babyDevelopment": "Still microscopic. Zygote dividing into blastocyst. Traveling to uterus.",
//       "babySize": "Microscopic",
//       "momTip": "Start prenatal vitamins with folic acid",
//       "motherSymptoms": "None yet",
//       "nutritionFocus": "Folic acid, Iron",
//       "indianFoods": "Fortified cereals, almonds, spinach",
//       "screeningTests": "None",
//       "exercise": "Normal activities",
//       "weeksRemaining": 38,
//       "imageUrl": "https://via.placeholder.com/300x200/8E24AA/FFFFFF?text=Week+2"
//     },
//     {
//       "week": "Week 3",
//       "trimester": "First Trimester",
//       "babyDevelopment": "Blastocyst implanting into uterine wall. Three layers forming.",
//       "babySize": "Microscopic",
//       "momTip": "Continue healthy lifestyle. Avoid harmful substances.",
//       "motherSymptoms": "None yet",
//       "nutritionFocus": "Folic acid, Calcium",
//       "indianFoods": "Paneer, milk, dal",
//       "screeningTests": "None",
//       "exercise": "Normal activities",
//       "weeksRemaining": 37,
//       "imageUrl": "https://via.placeholder.com/300x200/7B1FA2/FFFFFF?text=Week+3"
//     },
//     {
//       "week": "Week 4",
//       "trimester": "First Trimester",
//       "babyDevelopment": "Blastocyst implanted. Amniotic sac begins forming. Early heart tissue developing.",
//       "babySize": "Poppy seed",
//       "momTip": "Confirm pregnancy with doctor. Begin prenatal appointments.",
//       "motherSymptoms": "Missed period. Breast tenderness may begin. Possible positive pregnancy test.",
//       "nutritionFocus": "Folic acid, Iron, Calcium",
//       "indianFoods": "Milk, eggs, spinach, fortified cereals, dal",
//       "screeningTests": "Blood hCG test",
//       "exercise": "Light walking, normal activities",
//       "weeksRemaining": 36,
//       "imageUrl": "https://via.placeholder.com/300x200/6A1B9A/FFFFFF?text=Week+4"
//     },
//     {
//       "week": "Week 5",
//       "trimester": "First Trimester",
//       "babyDevelopment": "Heart begins to beat. Amniotic sac visible on ultrasound. Yolk sac forms.",
//       "babySize": "Apple seed",
//       "momTip": "Eat small frequent meals. Stay hydrated. Rest when tired. Ginger tea helps nausea.",
//       "motherSymptoms": "Nausea begins (morning sickness). Breast tenderness. Fatigue. Frequent urination.",
//       "nutritionFocus": "Folic acid, Vitamin B6, Iron",
//       "indianFoods": "Bananas, ginger tea, whole wheat toast, yogurt, coconut water",
//       "screeningTests": "Dating ultrasound",
//       "exercise": "Walking, light yoga",
//       "weeksRemaining": 35,
//       "imageUrl": "https://via.placeholder.com/300x200/4A148C/FFFFFF?text=Week+5"
//     },
//     {
//       "week": "Week 6",
//       "trimester": "First Trimester",
//       "babyDevelopment": "Heart beating at 100-120 bpm. Brain beginning to develop. Eyes starting to form. Arm and leg buds appearing.",
//       "babySize": "Lentil/Sweet pea",
//       "momTip": "Keep hydrated. Eat foods you can tolerate. Rest adequately.",
//       "motherSymptoms": "Morning sickness peaks. Fatigue. Mood swings. Tender breasts. Frequent urination.",
//       "nutritionFocus": "Folic acid, Vitamin B6, Iron",
//       "indianFoods": "Whole grain bread, eggs, bananas, dates, lentil soup",
//       "screeningTests": "Ultrasound confirmation",
//       "exercise": "Light walks, gentle stretching",
//       "weeksRemaining": 34,
//       "imageUrl": "https://via.placeholder.com/300x200/311B92/FFFFFF?text=Week+6"
//     },
//     {
//       "week": "Week 7",
//       "trimester": "First Trimester",
//       "babyDevelopment": "Arms and legs look like little paddles. Eyes becoming more defined. Ears starting to form.",
//       "babySize": "Blueberry",
//       "momTip": "Manage nausea - eat crackers upon waking. Smaller portions. Avoid triggers.",
//       "motherSymptoms": "Nausea continues. Fatigue. Food cravings/aversions. Frequent urination.",
//       "nutritionFocus": "Folic acid, Calcium, Iron, Protein",
//       "indianFoods": "Milk, paneer, dal, brown rice, green vegetables",
//       "screeningTests": "Optional: Early NT scan",
//       "exercise": "Walking, swimming, prenatal yoga",
//       "weeksRemaining": 33,
//       "imageUrl": "https://via.placeholder.com/300x200/1A237E/FFFFFF?text=Week+7"
//     },
//     {
//       "week": "Week 8",
//       "trimester": "First Trimester",
//       "babyDevelopment": "Embryo now called fetus. Fingers and toes forming. Eyes more prominent. Ears taking shape.",
//       "babySize": "Raspberry",
//       "momTip": "Rest when possible. Small frequent meals. Prenatal vitamins essential.",
//       "motherSymptoms": "Morning sickness may peak. Exhaustion. Mood swings. Frequent urination.",
//       "nutritionFocus": "Folic acid, Iron, Calcium, Vitamin D",
//       "indianFoods": "Milk with turmeric, eggs, spinach, whole grains, seasonal fruits",
//       "screeningTests": "Confirm fetal heartbeat with ultrasound",
//       "exercise": "Walking, gentle yoga, swimming",
//       "weeksRemaining": 32,
//       "imageUrl": "https://via.placeholder.com/300x200/0D47A1/FFFFFF?text=Week+8"
//     },
//     {
//       "week": "Week 9",
//       "trimester": "First Trimester",
//       "babyDevelopment": "Eyes more developed, ears forming. Arms bending at elbow. Tiny muscles allowing small movements.",
//       "babySize": "Grape",
//       "momTip": "Eat nutritious foods despite nausea. Ginger, lemon help. Stay hydrated.",
//       "motherSymptoms": "Morning sickness often at peak. Fatigue. Mood swings. Breast tenderness.",
//       "nutritionFocus": "Folic acid, Iron, Protein, Omega-3",
//       "indianFoods": "Walnuts, fish, eggs, milk, dates, almonds, lentils",
//       "screeningTests": "Nuchal translucency scan optional",
//       "exercise": "Walking, light stretching, water aerobics",
//       "weeksRemaining": 31,
//       "imageUrl": "https://via.placeholder.com/300x200/1565C0/FFFFFF?text=Week+9"
//     },
//     {
//       "week": "Week 10",
//       "trimester": "First Trimester",
//       "babyDevelopment": "Fetus now 1.2 inches long. All major organs beginning to form. Eyebrows forming.",
//       "babySize": "Kumquat/Tangerine",
//       "momTip": "Some relief from nausea coming. Rest adequately. Stay active with light exercise.",
//       "motherSymptoms": "Morning sickness may start improving. Still fatigued. Frequent urination.",
//       "nutritionFocus": "Calcium, Iron, Protein, Folic acid",
//       "indianFoods": "Milk, paneer, spinach, whole wheat, chickpeas, beans",
//       "screeningTests": "Routine blood tests",
//       "exercise": "Walking, prenatal yoga, swimming",
//       "weeksRemaining": 30,
//       "imageUrl": "https://via.placeholder.com/300x200/1976D2/FFFFFF?text=Week+10"
//     },
//     {
//       "week": "Week 11",
//       "trimester": "First Trimester",
//       "babyDevelopment": "Ears more prominent. Fingers webbing beginning to disappear. Toenails starting.",
//       "babySize": "Fig",
//       "momTip": "Energy may be increasing. Good time to start gentle exercise.",
//       "motherSymptoms": "Morning sickness improving for many. Still fatigued. Frequent urination.",
//       "nutritionFocus": "Calcium, Iron, DHA, Protein",
//       "indianFoods": "Salmon, sardines, walnuts, eggs, milk, green vegetables",
//       "screeningTests": "Second trimester screening discussed",
//       "exercise": "Walking, swimming, yoga, light dance",
//       "weeksRemaining": 29,
//       "imageUrl": "https://via.placeholder.com/300x200/2196F3/FFFFFF?text=Week+11"
//     },
//     {
//       "week": "Week 12",
//       "trimester": "First Trimester (End)",
//       "babyDevelopment": "Baby now 2+ inches. All organs present but immature. Can make fist. Sucking reflex starting.",
//       "babySize": "Lime",
//       "momTip": "Celebrate end of first trimester! Energy returning.",
//       "motherSymptoms": "Nausea often improving. Energy increasing. Still frequent urination.",
//       "nutritionFocus": "Iron, Calcium, Protein, Vitamins",
//       "indianFoods": "Iron-rich foods - spinach, pomegranate, dates; Calcium - milk, curd",
//       "screeningTests": "First trimester combined screening, dating scan",
//       "exercise": "Walking, swimming, prenatal yoga, strength training",
//       "weeksRemaining": 28,
//       "imageUrl": "https://via.placeholder.com/300x200/42A5F5/FFFFFF?text=Week+12"
//     },
//     {
//       "week": "Week 13",
//       "trimester": "Second Trimester (Start)",
//       "babyDevelopment": "Tail-like structure completely gone. Fetus looks more human. Fingerprints beginning to form.",
//       "babySize": "Pea pod",
//       "momTip": "Energy returning! Good time to increase activity.",
//       "motherSymptoms": "Energy boost for most. Morning sickness resolving. Appetite improving.",
//       "nutritionFocus": "Iron, Calcium, Protein, DHA",
//       "indianFoods": "Eggs, milk, spinach, lentils, fish, nuts",
//       "screeningTests": "Detailed ultrasound, quad marker test",
//       "exercise": "More vigorous activity - swimming, walking, yoga",
//       "weeksRemaining": 27,
//       "imageUrl": "https://via.placeholder.com/300x200/64B5F6/FFFFFF?text=Week+13"
//     },
//     {
//       "week": "Week 14",
//       "trimester": "Second Trimester",
//       "babyDevelopment": "Chin now distinct. Eyebrows and eyelashes forming. Facial muscles exercising.",
//       "babySize": "Lemon",
//       "momTip": "This is the honeymoon period! Feel free to plan travel.",
//       "motherSymptoms": "Feeling much better. Energy returning. Appetite increasing.",
//       "nutritionFocus": "Protein, Iron, Calcium, DHA",
//       "indianFoods": "Chicken, fish, paneer, dal; Fish 2-3 times weekly for DHA",
//       "screeningTests": "Quad marker test if not done",
//       "exercise": "Swimming, brisk walking, moderate exercise",
//       "weeksRemaining": 26,
//       "imageUrl": "https://via.placeholder.com/300x200/90CAF9/FFFFFF?text=Week+14"
//     },
//     {
//       "week": "Week 15",
//       "trimester": "Second Trimester",
//       "babyDevelopment": "Hair beginning to grow on head. Skin very thin. Ears positioned correctly. Can hear sounds.",
//       "babySize": "Apple",
//       "momTip": "Baby can hear you - sing, talk to baby!",
//       "motherSymptoms": "Feeling great! Energy good. Appetite strong. Possible food cravings.",
//       "nutritionFocus": "Calcium, Iron, Protein",
//       "indianFoods": "Calcium - milk, yogurt, paneer; Iron - dates, pomegranate",
//       "screeningTests": "Routine checkup",
//       "exercise": "Walking 30 minutes daily, swimming, yoga",
//       "weeksRemaining": 25,
//       "imageUrl": "https://via.placeholder.com/300x200/29B6F6/FFFFFF?text=Week+15"
//     },
//     {
//       "week": "Week 16",
//       "trimester": "Second Trimester",
//       "babyDevelopment": "Circulatory system fully functional. Muscles developing. Possibly first movements felt.",
//       "babySize": "Avocado",
//       "momTip": "First movements exciting! Keep prenatal vitamins.",
//       "motherSymptoms": "May start feeling quickening. Appetite good. Possible skin changes.",
//       "nutritionFocus": "Iron, Calcium, Protein, Vitamin C",
//       "indianFoods": "Citrus fruits for iron absorption, leafy greens, legumes",
//       "screeningTests": "Anomaly detailed ultrasound around week 18-21",
//       "exercise": "Walking, swimming, prenatal yoga",
//       "weeksRemaining": 24,
//       "imageUrl": "https://via.placeholder.com/300x200/26C6DA/FFFFFF?text=Week+16"
//     },
//     {
//       "week": "Week 17",
//       "trimester": "Second Trimester",
//       "babyDevelopment": "Vernix beginning to coat baby. Swallowing amniotic fluid. Practicing breathing.",
//       "babySize": "Turnip",
//       "momTip": "Left side sleeping preferred. Prenatal pillows helpful.",
//       "motherSymptoms": "Feeling baby movements more. Appetite good. Backache starting.",
//       "nutritionFocus": "Calcium, Iron, Magnesium",
//       "indianFoods": "Magnesium - almonds, pumpkin seeds, spinach",
//       "screeningTests": "Routine visits every 2 weeks",
//       "exercise": "Walking, swimming, yoga, pelvic floor exercises",
//       "weeksRemaining": 23,
//       "imageUrl": "https://via.placeholder.com/300x200/26A69A/FFFFFF?text=Week+17"
//     },
//     {
//       "week": "Week 18",
//       "trimester": "Second Trimester",
//       "babyDevelopment": "Sex clearly visible on ultrasound. Fingerprints unique now. Can respond to sounds.",
//       "babySize": "Sweet potato",
//       "momTip": "Maternity belt for back support. Eat smaller frequent meals.",
//       "motherSymptoms": "Definitely feeling movements. More energy. Backaches may occur.",
//       "nutritionFocus": "Calcium, Iron, Fiber, Protein",
//       "indianFoods": "High fiber - whole grains, vegetables; Calcium - milk products",
//       "screeningTests": "Anomaly scan (detailed ultrasound)",
//       "exercise": "Walking, swimming, prenatal yoga",
//       "weeksRemaining": 22,
//       "imageUrl": "https://via.placeholder.com/300x200/66BB6A/FFFFFF?text=Week+18"
//     },
//     {
//       "week": "Week 19",
//       "trimester": "Second Trimester",
//       "babyDevelopment": "Legs now longer than arms. Skin becoming less transparent. Brown fat developing.",
//       "babySize": "Mango",
//       "momTip": "Manage weight gain - 300-400g per week normal. Magnesium for leg cramps.",
//       "motherSymptoms": "Baby movements very noticeable. Appetite strong. Possible leg cramps.",
//       "nutritionFocus": "Iron, Calcium, Protein, Magnesium",
//       "indianFoods": "Dates for iron, milk for calcium, almonds for magnesium",
//       "screeningTests": "Should complete anomaly scan",
//       "exercise": "Walking, swimming, prenatal yoga",
//       "weeksRemaining": 21,
//       "imageUrl": "https://via.placeholder.com/300x200/9CCC65/FFFFFF?text=Week+19"
//     },
//     {
//       "week": "Week 20",
//       "trimester": "Second Trimester (Midpoint)",
//       "babyDevelopment": "Hair growing on head. Eyebrows visible. Swallowing and hiccupping. Stomach producing digestive juices.",
//       "babySize": "Banana",
//       "momTip": "Elevate feet regularly. Compression socks helpful.",
//       "motherSymptoms": "Baby movements clear. Backache common. Possible swelling in feet/ankles.",
//       "nutritionFocus": "Iron, Calcium, Protein, Fiber",
//       "indianFoods": "Iron-rich foods, calcium-rich foods, fiber for digestion",
//       "screeningTests": "Mid-pregnancy anatomy scan",
//       "exercise": "Walking 30-45 min, swimming, prenatal yoga",
//       "weeksRemaining": 20,
//       "imageUrl": "https://via.placeholder.com/300x200/CDDC39/FFFFFF?text=Week+20"
//     },
//     {
//       "week": "Week 21",
//       "trimester": "Second Trimester",
//       "babyDevelopment": "Coordinated movements. Swallowing amniotic fluid. Practicing breathing. Buds for permanent teeth forming.",
//       "babySize": "Carrot",
//       "momTip": "Use maternity belt. Avoid standing long periods. Elevate feet.",
//       "motherSymptoms": "Clear baby movements. Back and pelvic pain common. Possible swollen ankles.",
//       "nutritionFocus": "Iron, Calcium, Protein, Fluids",
//       "indianFoods": "Spinach for iron, milk for calcium, plenty of water",
//       "screeningTests": "Routine visit - blood pressure, weight check",
//       "exercise": "Swimming excellent, walking, yoga, pelvic floor",
//       "weeksRemaining": 19,
//       "imageUrl": "https://via.placeholder.com/300x200/FFEB3B/FFFFFF?text=Week+21"
//     },
//     {
//       "week": "Week 22",
//       "trimester": "Second Trimester",
//       "babyDevelopment": "Lungs developing rapidly. Brain development accelerating. Senses more refined.",
//       "babySize": "Papaya",
//       "momTip": "Sunscreen for skin - melasma common. Back support important.",
//       "motherSymptoms": "Definite movements felt. Back pain. Possible skin changes (linea nigra).",
//       "nutritionFocus": "Iron, Calcium, Protein, DHA",
//       "indianFoods": "Fish for DHA, greens for iron, milk for calcium",
//       "screeningTests": "Routine check",
//       "exercise": "Walking, swimming, yoga, modified strength training",
//       "weeksRemaining": 18,
//       "imageUrl": "https://via.placeholder.com/300x200/FFC107/FFFFFF?text=Week+22"
//     },
//     {
//       "week": "Week 23",
//       "trimester": "Second Trimester",
//       "babyDevelopment": "Rapid brain development. Increased lung maturation. Baby can hear and respond to loud noises.",
//       "babySize": "Large mango",
//       "momTip": "Prenatal massage helpful. Proper posture important. Special pillow for side sleeping.",
//       "motherSymptoms": "Increased discomfort. Backache. Possible leg cramps. Sleep challenging.",
//       "nutritionFocus": "Iron, Calcium, Protein, Magnesium",
//       "indianFoods": "Legumes, greens, milk products",
//       "screeningTests": "Regular checkup every 2 weeks",
//       "exercise": "Walking, swimming, prenatal yoga",
//       "weeksRemaining": 17,
//       "imageUrl": "https://via.placeholder.com/300x200/FF9800/FFFFFF?text=Week+23"
//     },
//     {
//       "week": "Week 24",
//       "trimester": "Second Trimester",
//       "babyDevelopment": "Lungs still developing. Eyelids beginning to separate. Skin still wrinkled. Brain growth rapid.",
//       "babySize": "Corn",
//       "momTip": "Glucose tolerance test typically done now. Watch for diabetes symptoms.",
//       "motherSymptoms": "Increased discomfort. Back pain significant. Gestational diabetes screening now.",
//       "nutritionFocus": "Iron, Calcium, Protein, Reduced sugar",
//       "indianFoods": "Whole grains, legumes, vegetables, lean proteins",
//       "screeningTests": "Glucose tolerance test (gestational diabetes screening)",
//       "exercise": "Walking, swimming, prenatal yoga",
//       "weeksRemaining": 16,
//       "imageUrl": "https://via.placeholder.com/300x200/FF5722/FFFFFF?text=Week+24"
//     },
//     {
//       "week": "Week 25",
//       "trimester": "Second Trimester",
//       "babyDevelopment": "Nostrils opening. Ears function improving. Baby more reactive. Immune system developing.",
//       "babySize": "Rutabaga",
//       "momTip": "Braxton-Hicks normal. Continue exercise within comfort.",
//       "motherSymptoms": "Significant discomfort. Braxton-Hicks contractions. Swelling.",
//       "nutritionFocus": "Iron, Calcium, Protein, Immune support",
//       "indianFoods": "Vitamin C for immune support - citrus, guava, peppers",
//       "screeningTests": "Routine antenatal checkup",
//       "exercise": "Walking, swimming, prenatal yoga",
//       "weeksRemaining": 15,
//       "imageUrl": "https://via.placeholder.com/300x200/E64A19/FFFFFF?text=Week+25"
//     },
//     {
//       "week": "Week 26",
//       "trimester": "Second Trimester (End)",
//       "babyDevelopment": "Eyes open. Eyelashes fully developed. Skin pink. Practicing breathing.",
//       "babySize": "Lettuce head",
//       "momTip": "From 28 weeks, checkups every 2 weeks. Continue exercise.",
//       "motherSymptoms": "Very uncomfortable. Weight gain. Back pain, pelvic pressure.",
//       "nutritionFocus": "Iron, Calcium, Protein, DHA",
//       "indianFoods": "Maintain balanced nutrition",
//       "screeningTests": "Complete hemoglobin check",
//       "exercise": "Walking, swimming, gentle yoga",
//       "weeksRemaining": 14,
//       "imageUrl": "https://via.placeholder.com/300x200/D84315/FFFFFF?text=Week+26"
//     },
//     {
//       "week": "Week 27",
//       "trimester": "Third Trimester (Start)",
//       "babyDevelopment": "Brain development continuing rapidly. Lungs rapidly maturing. Strong kicks.",
//       "babySize": "Head of lettuce",
//       "momTip": "More frequent checkups now - every 2 weeks. Monitor blood pressure.",
//       "motherSymptoms": "Severe discomfort. Back/pelvic pain. Swelling. More frequent urination.",
//       "nutritionFocus": "Iron, Calcium, Protein, DHA",
//       "indianFoods": "Spinach, milk, dates, fish",
//       "screeningTests": "Biweekly checkups begin",
//       "exercise": "Walking, swimming, modified yoga",
//       "weeksRemaining": 13,
//       "imageUrl": "https://via.placeholder.com/300x200/C62828/FFFFFF?text=Week+27"
//     },
//     {
//       "week": "Week 28",
//       "trimester": "Third Trimester",
//       "babyDevelopment": "Eyes focusing. Hair and body lanugo present. Lungs producing surfactant.",
//       "babySize": "Eggplant",
//       "momTip": "Rh-negative women get anti-D injection now. Frequent checkups to monitor.",
//       "motherSymptoms": "Increasingly uncomfortable. Sleep position restricted. Possible gestational hypertension.",
//       "nutritionFocus": "Iron, Calcium, Protein, Blood pressure management",
//       "indianFoods": "Low sodium diet, potassium-rich foods like bananas",
//       "screeningTests": "Anti-D if Rh negative; biweekly checkups start",
//       "exercise": "Walking, swimming, prenatal yoga",
//       "weeksRemaining": 12,
//       "imageUrl": "https://via.placeholder.com/300x200/B71C1C/FFFFFF?text=Week+28"
//     },
//     {
//       "week": "Week 29",
//       "trimester": "Third Trimester",
//       "babyDevelopment": "Brain accelerating. Baby gaining fat. Bones hardening. Position changing.",
//       "babySize": "Butternut squash",
//       "momTip": "Prenatal classes important. Birth plan creation. Hospital bag preparation.",
//       "motherSymptoms": "Severe discomfort. Sleep very difficult. Frequent urination at night.",
//       "nutritionFocus": "Iron, Calcium, Protein, Hydration",
//       "indianFoods": "Balanced nutrition; avoid excess salt",
//       "screeningTests": "Biweekly antenatal care",
//       "exercise": "Modified walking, swimming, prenatal yoga",
//       "weeksRemaining": 11,
//       "imageUrl": "https://via.placeholder.com/300x200/8D6E63/FFFFFF?text=Week+29"
//     },
//     {
//       "week": "Week 30",
//       "trimester": "Third Trimester",
//       "babyDevelopment": "Brain rapid growth. Most babies head-down. Strong coordinated movements.",
//       "babySize": "Large cabbage",
//       "momTip": "Pain management important. Hospital bag ready. Birth plan finalized.",
//       "motherSymptoms": "Very uncomfortable. Severe back and pelvic pain. Possible insomnia.",
//       "nutritionFocus": "Iron, Calcium, Protein, Relaxation nutrients",
//       "indianFoods": "Magnesium sources - almonds, pumpkin seeds",
//       "screeningTests": "Biweekly checkups, fetal health assessments",
//       "exercise": "Gentle walking, prenatal yoga, breathing exercises",
//       "weeksRemaining": 10,
//       "imageUrl": "https://via.placeholder.com/300x200/795548/FFFFFF?text=Week+30"
//     },
//     {
//       "week": "Week 31",
//       "trimester": "Third Trimester",
//       "babyDevelopment": "Skin pink and smoother. Most lanugo disappearing. Nails reaching fingertip ends.",
//       "babySize": "Coconut",
//       "momTip": "Regular monitoring for preeclampsia. Rest when possible.",
//       "motherSymptoms": "Increasing discomfort. Severe fatigue returning. Sleep disrupted.",
//       "nutritionFocus": "Iron, Calcium, Protein, Healthy fats",
//       "indianFoods": "Varied diet with all nutrients",
//       "screeningTests": "Biweekly monitoring for complications",
//       "exercise": "Gentle walking, light yoga, pelvic floor exercises",
//       "weeksRemaining": 9,
//       "imageUrl": "https://via.placeholder.com/300x200/6D4C41/FFFFFF?text=Week+31"
//     },
//     {
//       "week": "Week 32",
//       "trimester": "Third Trimester",
//       "babyDevelopment": "Bones fully formed but flexible. Fingernails grown. Toenails full length. Immune system almost complete.",
//       "babySize": "Jicama",
//       "momTip": "Only 8 weeks remaining! Pain management important.",
//       "motherSymptoms": "Very uncomfortable. Severe back pain. Pelvic pressure. Braxton-Hicks regular.",
//       "nutritionFocus": "Iron, Calcium, Protein, Antioxidants",
//       "indianFoods": "Colorful vegetables for antioxidants",
//       "screeningTests": "Biweekly checkups; Group B Strep screening",
//       "exercise": "Gentle walking, prenatal yoga for relaxation",
//       "weeksRemaining": 8,
//       "imageUrl": "https://via.placeholder.com/300x200/5D4037/FFFFFF?text=Week+32"
//     },
//     {
//       "week": "Week 33",
//       "trimester": "Third Trimester",
//       "babyDevelopment": "Immune system nearly complete. Lungs maturing. Brain development continuing. Practicing crying.",
//       "babySize": "Pineapple",
//       "momTip": "7 weeks to go! Birth plan review with doctor.",
//       "motherSymptoms": "Extreme discomfort. Severe fatigue. Leg cramps. Possible sciatic nerve pain.",
//       "nutritionFocus": "Iron, Calcium, Protein, Fiber",
//       "indianFoods": "Fiber to prevent constipation - whole grains, vegetables",
//       "screeningTests": "Biweekly appointments; labor discussions",
//       "exercise": "Very gentle walking, relaxation yoga",
//       "weeksRemaining": 7,
//       "imageUrl": "https://via.placeholder.com/300x200/4E342E/FFFFFF?text=Week+33"
//     },
//     {
//       "week": "Week 34",
//       "trimester": "Third Trimester",
//       "babyDevelopment": "Position settling (most head-down). Nails fully grown. Hair thickening. Antibodies transferring.",
//       "babySize": "Cantaloupe melon",
//       "momTip": "6 weeks remaining! Finalize birth plans. Notify work about leave.",
//       "motherSymptoms": "Extremely uncomfortable. Severe back pain. Pelvic pressure increasing.",
//       "nutritionFocus": "Iron, Calcium, Protein, Hydration",
//       "indianFoods": "Balanced nutrition; stay hydrated",
//       "screeningTests": "Biweekly checkups; Group B Strep results",
//       "exercise": "Walking, relaxation techniques, breathing exercises",
//       "weeksRemaining": 6,
//       "imageUrl": "https://via.placeholder.com/300x200/37474F/FFFFFF?text=Week+34"
//     },
//     {
//       "week": "Week 35",
//       "trimester": "Third Trimester",
//       "babyDevelopment": "Fully capable of life outside womb. Bones hardened but flexible. Most lanugo shed.",
//       "babySize": "Honeydew melon",
//       "momTip": "5 weeks to go. All preparations complete. Practice breathing exercises.",
//       "motherSymptoms": "Extreme discomfort. Peak fatigue. Braxton-Hicks strong and regular.",
//       "nutritionFocus": "Iron, Calcium, Protein",
//       "indianFoods": "Final trimester nutrition",
//       "screeningTests": "Final biweekly checkups",
//       "exercise": "Gentle walking, relaxation practice",
//       "weeksRemaining": 5,
//       "imageUrl": "https://via.placeholder.com/300x200/455A64/FFFFFF?text=Week+35"
//     },
//     {
//       "week": "Week 36",
//       "trimester": "Third Trimester",
//       "babyDevelopment": "Ready for birth. Bones still flexible. Vernix coating entire body. Lungs fully mature.",
//       "babySize": "Romaine lettuce head",
//       "momTip": "4 weeks to go! Weekly checkups start. Watch for labor signs.",
//       "motherSymptoms": "Very uncomfortable. Strong Braxton-Hicks. Baby dropping lower.",
//       "nutritionFocus": "Iron, Calcium",
//       "indianFoods": "Small frequent meals",
//       "screeningTests": "Weekly checkups start; monitor for preeclampsia",
//       "exercise": "Walking, standing, position changes",
//       "weeksRemaining": 4,
//       "imageUrl": "https://via.placeholder.com/300x200/546E7A/FFFFFF?text=Week+36"
//     },
//     {
//       "week": "Week 37",
//       "trimester": "Third Trimester",
//       "babyDevelopment": "Now considered term. Can be born safely. Vernix coating. Lanugo mostly gone.",
//       "babySize": "Stalk of swiss chard",
//       "momTip": "3 weeks to go! Labor could start anytime. Know false vs real labor signs.",
//       "motherSymptoms": "Extremely uncomfortable. Baby moved lower. Braxton-Hicks frequent.",
//       "nutritionFocus": "Hydration, Nutrition",
//       "indianFoods": "Energy-rich foods",
//       "screeningTests": "Weekly checkups; Group B Strep treatment if needed",
//       "exercise": "Walking, labor preparation movements",
//       "weeksRemaining": 3,
//       "imageUrl": "https://via.placeholder.com/300x200/607D8B/FFFFFF?text=Week+37"
//     },
//     {
//       "week": "Week 38",
//       "trimester": "Third Trimester",
//       "babyDevelopment": "All systems ready. Brain continuing development. Baby fully capable of life outside.",
//       "babySize": "Stalk of rhubarb",
//       "momTip": "2 weeks to go! Labor could begin any day. Stay positive.",
//       "motherSymptoms": "Peak discomfort. Frequent urination. Possible mucus plug loss.",
//       "nutritionFocus": "Hydration, Energy",
//       "indianFoods": "Light meals easily digestible",
//       "screeningTests": "Weekly checkups; assess cervical changes",
//       "exercise": "Walking, position changes, labor prep movements",
//       "weeksRemaining": 2,
//       "imageUrl": "https://via.placeholder.com/300x200/78909C/FFFFFF?text=Week+38"
//     },
//     {
//       "week": "Week 39",
//       "trimester": "Third Trimester",
//       "babyDevelopment": "Fully developed. Skin smooth from vernix. All systems ready. Practicing birth.",
//       "babySize": "Small pumpkin",
//       "momTip": "1 week to go! Labor likely imminent. Continue walking.",
//       "motherSymptoms": "Extremely uncomfortable. May lose mucus plug. Possible cervical changes.",
//       "nutritionFocus": "Hydration",
//       "indianFoods": "Light easily digestible foods",
//       "screeningTests": "Weekly checkups; induction discussion if needed",
//       "exercise": "Walking for natural labor induction, position changes",
//       "weeksRemaining": 1,
//       "imageUrl": "https://via.placeholder.com/300x200/90A4AE/FFFFFF?text=Week+39"
//     },
//     {
//       "week": "Week 40",
//       "trimester": "Third Trimester (Due date)",
//       "babyDevelopment": "Fully term and ready! All organs functioning. Brain continuing development after birth.",
//       "babySize": "Small watermelon",
//       "momTip": "Your due date! Labor should begin within days. Patience important.",
//       "motherSymptoms": "Due date! May have labor or still waiting. Extreme discomfort.",
//       "nutritionFocus": "Hydration",
//       "indianFoods": "Light meals, clear fluids",
//       "screeningTests": "Labor monitoring if started; medical induction if needed",
//       "exercise": "Walking if not in labor, position changes",
//       "weeksRemaining": 0,
//       "imageUrl": "https://via.placeholder.com/300x200/B0BEC5/FFFFFF?text=Week+40"
//     },
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     // Auto-detect current week based on pregnancy progress
//     _autoDetectCurrentWeek();
//     // Scroll to current week after build
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _scrollToCurrentWeek();
//     });
//   }
//
//   void _autoDetectCurrentWeek() {
//     // TODO: Replace with actual pregnancy date calculation
//     // For now, setting to week 10 as example
//     _currentWeek = 10; // Change this to dynamic calculation
//   }
//
//   void _scrollToCurrentWeek() {
//     final double scrollPosition = (_currentWeek - 1) * 48.0; // 48 = width + margin
//     _weekScrollController.animateTo(
//       scrollPosition,
//       duration: Duration(milliseconds: 500),
//       curve: Curves.easeInOut,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Ensure _currentWeek is within the bounds of weekData
//     if (_currentWeek < 1) {
//       _currentWeek = 1;
//     } else if (_currentWeek > weekData.length) {
//       _currentWeek = weekData.length;
//     }
//
//     // Get the data for the current week
//     final currentWeekData = weekData[_currentWeek - 1]; // -1 because list is 0-indexed
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(
//           'Pregnancy Journey',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         backgroundColor: Color(0xFFB794F4),
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Column(
//         children: [
//           // ENHANCED: Top Week Navigation Bar
//           Container(
//             padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.2),
//                   spreadRadius: 1,
//                   blurRadius: 4,
//                   offset: Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 // Current Week and Trimester Info
//                 Container(
//                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             currentWeekData["week"]!,
//                             style: TextStyle(
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFFB794F4),
//                             ),
//                           ),
//                           SizedBox(height: 4),
//                           Text(
//                             currentWeekData["trimester"]!,
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[600],
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Container(
//                         padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                         decoration: BoxDecoration(
//                           color: Color(0xFFB794F4).withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           "${currentWeekData["weeksRemaining"]} weeks to go",
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Color(0xFFB794F4),
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 SizedBox(height: 16),
//
//                 // ENHANCED: Horizontal Week Navigation (1-40)
//                 Container(
//                   height: 60,
//                   child: Column(
//                     children: [
//                       // Week Numbers 1-40
//                       Expanded(
//                         child: ListView.builder(
//                           controller: _weekScrollController,
//                           scrollDirection: Axis.horizontal,
//                           itemCount: weekData.length,
//                           padding: EdgeInsets.symmetric(horizontal: 8),
//                           itemBuilder: (context, index) {
//                             final weekNumber = index + 1;
//                             final isSelected = weekNumber == _currentWeek;
//                             final isCurrentWeek = weekNumber == _currentWeek;
//
//                             return GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   _currentWeek = weekNumber;
//                                 });
//                               },
//                               child: Container(
//                                 width: 40,
//                                 margin: EdgeInsets.symmetric(horizontal: 4),
//                                 decoration: BoxDecoration(
//                                   color: isSelected ? Color(0xFFB794F4) : Colors.grey[100],
//                                   borderRadius: BorderRadius.circular(12),
//                                   border: isCurrentWeek
//                                       ? Border.all(color: Color(0xFFB794F4), width: 2)
//                                       : null,
//                                   boxShadow: isSelected ? [
//                                     BoxShadow(
//                                       color: Color(0xFFB794F4).withOpacity(0.3),
//                                       blurRadius: 8,
//                                       offset: Offset(0, 2),
//                                     )
//                                   ] : null,
//                                 ),
//                                 alignment: Alignment.center,
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.center,
//                                   children: [
//                                     Text(
//                                       '$weekNumber',
//                                       style: TextStyle(
//                                         color: isSelected ? Colors.white : Colors.grey[700],
//                                         fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//                                         fontSize: 14,
//                                       ),
//                                     ),
//                                     if (isCurrentWeek) ...[
//                                       SizedBox(height: 2),
//                                       Container(
//                                         width: 6,
//                                         height: 6,
//                                         decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           shape: BoxShape.circle,
//                                         ),
//                                       ),
//                                     ],
//                                   ],
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//
//                       // Navigation Arrows
//                       SizedBox(height: 8),
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 16),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             // Previous Week Button
//                             ElevatedButton.icon(
//                               onPressed: _currentWeek > 1 ? () {
//                                 setState(() {
//                                   _currentWeek--;
//                                 });
//                                 _scrollToCurrentWeek();
//                               } : null,
//                               icon: Icon(Icons.arrow_back_ios, size: 16),
//                               label: Text('Previous'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Color(0xFFB794F4),
//                                 foregroundColor: Colors.white,
//                                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                               ),
//                             ),
//
//                             // Week Indicator
//                             Container(
//                               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[50],
//                                 borderRadius: BorderRadius.circular(20),
//                                 border: Border.all(color: Colors.grey[300]!),
//                               ),
//                               child: Text(
//                                 'Week $_currentWeek of 40',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.grey[700],
//                                 ),
//                               ),
//                             ),
//
//                             // Next Week Button
//                             ElevatedButton.icon(
//                               onPressed: _currentWeek < weekData.length ? () {
//                                 setState(() {
//                                   _currentWeek++;
//                                 });
//                                 _scrollToCurrentWeek();
//                               } : null,
//                               icon: Icon(Icons.arrow_forward_ios, size: 16),
//                               label: Text('Next'),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Color(0xFFB794F4),
//                                 foregroundColor: Colors.white,
//                                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Content Section
//           Expanded(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Image Section
//                   Container(
//                     height: 200,
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[100],
//                       borderRadius: BorderRadius.circular(15),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.grey.withOpacity(0.1),
//                           spreadRadius: 2,
//                           blurRadius: 5,
//                           offset: Offset(0, 3),
//                         ),
//                       ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(15),
//                       child: Image.network(
//                         currentWeekData["imageUrl"]!,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Container(
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [Color(0xFFB794F4).withOpacity(0.3), Color(0xFF9F7AEA).withOpacity(0.3)],
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                               ),
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                             child: Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(Icons.pregnant_woman, size: 50, color: Color(0xFFB794F4)),
//                                   SizedBox(height: 8),
//                                   Text(
//                                     currentWeekData["week"]!,
//                                     style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: Color(0xFFB794F4),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 24),
//
//                   // Baby's Development Section
//                   _buildSectionHeader("Baby's Development"),
//                   SizedBox(height: 10),
//                   Text(
//                     currentWeekData["babyDevelopment"]!,
//                     style: TextStyle(
//                       fontSize: 16,
//                       height: 1.5,
//                       color: Colors.grey[800],
//                     ),
//                   ),
//                   SizedBox(height: 24),
//
//                   // Baby's Size Section
//                   _buildSectionHeader("Baby's Size"),
//                   SizedBox(height: 10),
//                   _buildInfoRow(Icons.monitor_weight, currentWeekData["babySize"]!),
//                   SizedBox(height: 24),
//
//                   // Mother's Symptoms Section
//                   _buildSectionHeader("Mother's Symptoms"),
//                   SizedBox(height: 10),
//                   Container(
//                     padding: EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.orange[50]?.withOpacity(0.5),
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: Colors.orange[100]!),
//                     ),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Icon(Icons.health_and_safety, color: Colors.orange[600], size: 24),
//                         SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             currentWeekData["motherSymptoms"]!,
//                             style: TextStyle(
//                               fontSize: 16,
//                               color: Colors.grey[700],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 24),
//
//                   // Mom's Tip Section
//                   _buildSectionHeader("Mom's Tip"),
//                   SizedBox(height: 10),
//                   Container(
//                     padding: EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Color(0xFFB794F4).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: Color(0xFFB794F4).withOpacity(0.3)),
//                     ),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Icon(Icons.lightbulb_outline, color: Color(0xFFB794F4), size: 24),
//                         SizedBox(width: 10),
//                         Expanded(
//                           child: Text(
//                             currentWeekData["momTip"]!,
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontStyle: FontStyle.italic,
//                               color: Colors.grey[700],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 24),
//
//                   // Nutrition Focus Section
//                   _buildSectionHeader("Nutrition Focus"),
//                   SizedBox(height: 10),
//                   _buildInfoRow(Icons.restaurant, currentWeekData["nutritionFocus"]!),
//                   SizedBox(height: 24),
//
//                   // Indian Foods Section
//                   _buildSectionHeader("Indian Foods"),
//                   SizedBox(height: 10),
//                   _buildInfoRow(Icons.food_bank, currentWeekData["indianFoods"]!),
//                   SizedBox(height: 24),
//
//                   // Screening Tests Section
//                   _buildSectionHeader("Screening Tests"),
//                   SizedBox(height: 10),
//                   _buildInfoRow(Icons.medical_services, currentWeekData["screeningTests"]!),
//                   SizedBox(height: 24),
//
//                   // Exercise Section
//                   _buildSectionHeader("Exercise"),
//                   SizedBox(height: 10),
//                   _buildInfoRow(Icons.directions_run, currentWeekData["exercise"]!),
//                   SizedBox(height: 20),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader(String title) {
//     return Text(
//       title,
//       style: TextStyle(
//         fontSize: 20,
//         fontWeight: FontWeight.bold,
//         color: Color(0xFFB794F4),
//       ),
//     );
//   }
//
//   Widget _buildInfoRow(IconData icon, String text) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, color: Color(0xFFB794F4), size: 24),
//         SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             text,
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey[800],
//               height: 1.4,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
//
// // import 'package:flutter/material.dart';
// //
// // class PregnancyJourneyScreen extends StatefulWidget {
// //   @override
// //   _PregnancyJourneyScreenState createState() => _PregnancyJourneyScreenState();
// // }
// //
// // class _PregnancyJourneyScreenState extends State<PregnancyJourneyScreen> {
// //   int _currentWeek = 1; // Start with Week 1
// //
// //   // Updated data structure with new content
// //   // Complete data for all 40 weeks
// //   final List<Map<String, dynamic>> weekData = [
// //     {
// //       "week": "Week 1",
// //       "trimester": "First Trimester",
// //       "babyDevelopment": "Fertilization occurs. Egg and sperm meet. Zygote begins rapid cell division. Implantation begins.",
// //       "babySize": "Microscopic (Zygote)",
// //       "momTip": "Track your menstrual cycle. Ensure good health habits.",
// //       "motherSymptoms": "None yet - normal menstrual cycle",
// //       "nutritionFocus": "Folic acid, General health",
// //       "indianFoods": "Milk, eggs, leafy greens",
// //       "screeningTests": "None",
// //       "exercise": "Normal daily activities",
// //       "weeksRemaining": 39,
// //       "imageUrl": "https://via.placeholder.com/300x200/9C27B0/FFFFFF?text=Week+1"
// //     },
// //     {
// //       "week": "Week 2",
// //       "trimester": "First Trimester",
// //       "babyDevelopment": "Still microscopic. Zygote dividing into blastocyst. Traveling to uterus.",
// //       "babySize": "Microscopic",
// //       "momTip": "Start prenatal vitamins with folic acid",
// //       "motherSymptoms": "None yet",
// //       "nutritionFocus": "Folic acid, Iron",
// //       "indianFoods": "Fortified cereals, almonds, spinach",
// //       "screeningTests": "None",
// //       "exercise": "Normal activities",
// //       "weeksRemaining": 38,
// //       "imageUrl": "https://via.placeholder.com/300x200/8E24AA/FFFFFF?text=Week+2"
// //     },
// //     {
// //       "week": "Week 3",
// //       "trimester": "First Trimester",
// //       "babyDevelopment": "Blastocyst implanting into uterine wall. Three layers forming.",
// //       "babySize": "Microscopic",
// //       "momTip": "Continue healthy lifestyle. Avoid harmful substances.",
// //       "motherSymptoms": "None yet",
// //       "nutritionFocus": "Folic acid, Calcium",
// //       "indianFoods": "Paneer, milk, dal",
// //       "screeningTests": "None",
// //       "exercise": "Normal activities",
// //       "weeksRemaining": 37,
// //       "imageUrl": "https://via.placeholder.com/300x200/7B1FA2/FFFFFF?text=Week+3"
// //     },
// //     {
// //       "week": "Week 4",
// //       "trimester": "First Trimester",
// //       "babyDevelopment": "Blastocyst implanted. Amniotic sac begins forming. Early heart tissue developing.",
// //       "babySize": "Poppy seed",
// //       "momTip": "Confirm pregnancy with doctor. Begin prenatal appointments.",
// //       "motherSymptoms": "Missed period. Breast tenderness may begin. Possible positive pregnancy test.",
// //       "nutritionFocus": "Folic acid, Iron, Calcium",
// //       "indianFoods": "Milk, eggs, spinach, fortified cereals, dal",
// //       "screeningTests": "Blood hCG test",
// //       "exercise": "Light walking, normal activities",
// //       "weeksRemaining": 36,
// //       "imageUrl": "https://via.placeholder.com/300x200/6A1B9A/FFFFFF?text=Week+4"
// //     },
// //     {
// //       "week": "Week 5",
// //       "trimester": "First Trimester",
// //       "babyDevelopment": "Heart begins to beat. Amniotic sac visible on ultrasound. Yolk sac forms.",
// //       "babySize": "Apple seed",
// //       "momTip": "Eat small frequent meals. Stay hydrated. Rest when tired. Ginger tea helps nausea.",
// //       "motherSymptoms": "Nausea begins (morning sickness). Breast tenderness. Fatigue. Frequent urination.",
// //       "nutritionFocus": "Folic acid, Vitamin B6, Iron",
// //       "indianFoods": "Bananas, ginger tea, whole wheat toast, yogurt, coconut water",
// //       "screeningTests": "Dating ultrasound",
// //       "exercise": "Walking, light yoga",
// //       "weeksRemaining": 35,
// //       "imageUrl": "https://via.placeholder.com/300x200/4A148C/FFFFFF?text=Week+5"
// //     },
// //     {
// //       "week": "Week 6",
// //       "trimester": "First Trimester",
// //       "babyDevelopment": "Heart beating at 100-120 bpm. Brain beginning to develop. Eyes starting to form. Arm and leg buds appearing.",
// //       "babySize": "Lentil/Sweet pea",
// //       "momTip": "Keep hydrated. Eat foods you can tolerate. Rest adequately.",
// //       "motherSymptoms": "Morning sickness peaks. Fatigue. Mood swings. Tender breasts. Frequent urination.",
// //       "nutritionFocus": "Folic acid, Vitamin B6, Iron",
// //       "indianFoods": "Whole grain bread, eggs, bananas, dates, lentil soup",
// //       "screeningTests": "Ultrasound confirmation",
// //       "exercise": "Light walks, gentle stretching",
// //       "weeksRemaining": 34,
// //       "imageUrl": "https://via.placeholder.com/300x200/311B92/FFFFFF?text=Week+6"
// //     },
// //     {
// //       "week": "Week 7",
// //       "trimester": "First Trimester",
// //       "babyDevelopment": "Arms and legs look like little paddles. Eyes becoming more defined. Ears starting to form.",
// //       "babySize": "Blueberry",
// //       "momTip": "Manage nausea - eat crackers upon waking. Smaller portions. Avoid triggers.",
// //       "motherSymptoms": "Nausea continues. Fatigue. Food cravings/aversions. Frequent urination.",
// //       "nutritionFocus": "Folic acid, Calcium, Iron, Protein",
// //       "indianFoods": "Milk, paneer, dal, brown rice, green vegetables",
// //       "screeningTests": "Optional: Early NT scan",
// //       "exercise": "Walking, swimming, prenatal yoga",
// //       "weeksRemaining": 33,
// //       "imageUrl": "https://via.placeholder.com/300x200/1A237E/FFFFFF?text=Week+7"
// //     },
// //     {
// //       "week": "Week 8",
// //       "trimester": "First Trimester",
// //       "babyDevelopment": "Embryo now called fetus. Fingers and toes forming. Eyes more prominent. Ears taking shape.",
// //       "babySize": "Raspberry",
// //       "momTip": "Rest when possible. Small frequent meals. Prenatal vitamins essential.",
// //       "motherSymptoms": "Morning sickness may peak. Exhaustion. Mood swings. Frequent urination.",
// //       "nutritionFocus": "Folic acid, Iron, Calcium, Vitamin D",
// //       "indianFoods": "Milk with turmeric, eggs, spinach, whole grains, seasonal fruits",
// //       "screeningTests": "Confirm fetal heartbeat with ultrasound",
// //       "exercise": "Walking, gentle yoga, swimming",
// //       "weeksRemaining": 32,
// //       "imageUrl": "https://via.placeholder.com/300x200/0D47A1/FFFFFF?text=Week+8"
// //     },
// //     {
// //       "week": "Week 9",
// //       "trimester": "First Trimester",
// //       "babyDevelopment": "Eyes more developed, ears forming. Arms bending at elbow. Tiny muscles allowing small movements.",
// //       "babySize": "Grape",
// //       "momTip": "Eat nutritious foods despite nausea. Ginger, lemon help. Stay hydrated.",
// //       "motherSymptoms": "Morning sickness often at peak. Fatigue. Mood swings. Breast tenderness.",
// //       "nutritionFocus": "Folic acid, Iron, Protein, Omega-3",
// //       "indianFoods": "Walnuts, fish, eggs, milk, dates, almonds, lentils",
// //       "screeningTests": "Nuchal translucency scan optional",
// //       "exercise": "Walking, light stretching, water aerobics",
// //       "weeksRemaining": 31,
// //       "imageUrl": "https://via.placeholder.com/300x200/1565C0/FFFFFF?text=Week+9"
// //     },
// //     {
// //       "week": "Week 10",
// //       "trimester": "First Trimester",
// //       "babyDevelopment": "Fetus now 1.2 inches long. All major organs beginning to form. Eyebrows forming.",
// //       "babySize": "Kumquat/Tangerine",
// //       "momTip": "Some relief from nausea coming. Rest adequately. Stay active with light exercise.",
// //       "motherSymptoms": "Morning sickness may start improving. Still fatigued. Frequent urination.",
// //       "nutritionFocus": "Calcium, Iron, Protein, Folic acid",
// //       "indianFoods": "Milk, paneer, spinach, whole wheat, chickpeas, beans",
// //       "screeningTests": "Routine blood tests",
// //       "exercise": "Walking, prenatal yoga, swimming",
// //       "weeksRemaining": 30,
// //       "imageUrl": "https://via.placeholder.com/300x200/1976D2/FFFFFF?text=Week+10"
// //     },
// //     {
// //       "week": "Week 11",
// //       "trimester": "First Trimester",
// //       "babyDevelopment": "Ears more prominent. Fingers webbing beginning to disappear. Toenails starting.",
// //       "babySize": "Fig",
// //       "momTip": "Energy may be increasing. Good time to start gentle exercise.",
// //       "motherSymptoms": "Morning sickness improving for many. Still fatigued. Frequent urination.",
// //       "nutritionFocus": "Calcium, Iron, DHA, Protein",
// //       "indianFoods": "Salmon, sardines, walnuts, eggs, milk, green vegetables",
// //       "screeningTests": "Second trimester screening discussed",
// //       "exercise": "Walking, swimming, yoga, light dance",
// //       "weeksRemaining": 29,
// //       "imageUrl": "https://via.placeholder.com/300x200/2196F3/FFFFFF?text=Week+11"
// //     },
// //     {
// //       "week": "Week 12",
// //       "trimester": "First Trimester (End)",
// //       "babyDevelopment": "Baby now 2+ inches. All organs present but immature. Can make fist. Sucking reflex starting.",
// //       "babySize": "Lime",
// //       "momTip": "Celebrate end of first trimester! Energy returning.",
// //       "motherSymptoms": "Nausea often improving. Energy increasing. Still frequent urination.",
// //       "nutritionFocus": "Iron, Calcium, Protein, Vitamins",
// //       "indianFoods": "Iron-rich foods - spinach, pomegranate, dates; Calcium - milk, curd",
// //       "screeningTests": "First trimester combined screening, dating scan",
// //       "exercise": "Walking, swimming, prenatal yoga, strength training",
// //       "weeksRemaining": 28,
// //       "imageUrl": "https://via.placeholder.com/300x200/42A5F5/FFFFFF?text=Week+12"
// //     },
// //     {
// //       "week": "Week 13",
// //       "trimester": "Second Trimester (Start)",
// //       "babyDevelopment": "Tail-like structure completely gone. Fetus looks more human. Fingerprints beginning to form.",
// //       "babySize": "Pea pod",
// //       "momTip": "Energy returning! Good time to increase activity.",
// //       "motherSymptoms": "Energy boost for most. Morning sickness resolving. Appetite improving.",
// //       "nutritionFocus": "Iron, Calcium, Protein, DHA",
// //       "indianFoods": "Eggs, milk, spinach, lentils, fish, nuts",
// //       "screeningTests": "Detailed ultrasound, quad marker test",
// //       "exercise": "More vigorous activity - swimming, walking, yoga",
// //       "weeksRemaining": 27,
// //       "imageUrl": "https://via.placeholder.com/300x200/64B5F6/FFFFFF?text=Week+13"
// //     },
// //     {
// //       "week": "Week 14",
// //       "trimester": "Second Trimester",
// //       "babyDevelopment": "Chin now distinct. Eyebrows and eyelashes forming. Facial muscles exercising.",
// //       "babySize": "Lemon",
// //       "momTip": "This is the honeymoon period! Feel free to plan travel.",
// //       "motherSymptoms": "Feeling much better. Energy returning. Appetite increasing.",
// //       "nutritionFocus": "Protein, Iron, Calcium, DHA",
// //       "indianFoods": "Chicken, fish, paneer, dal; Fish 2-3 times weekly for DHA",
// //       "screeningTests": "Quad marker test if not done",
// //       "exercise": "Swimming, brisk walking, moderate exercise",
// //       "weeksRemaining": 26,
// //       "imageUrl": "https://via.placeholder.com/300x200/90CAF9/FFFFFF?text=Week+14"
// //     },
// //     {
// //       "week": "Week 15",
// //       "trimester": "Second Trimester",
// //       "babyDevelopment": "Hair beginning to grow on head. Skin very thin. Ears positioned correctly. Can hear sounds.",
// //       "babySize": "Apple",
// //       "momTip": "Baby can hear you - sing, talk to baby!",
// //       "motherSymptoms": "Feeling great! Energy good. Appetite strong. Possible food cravings.",
// //       "nutritionFocus": "Calcium, Iron, Protein",
// //       "indianFoods": "Calcium - milk, yogurt, paneer; Iron - dates, pomegranate",
// //       "screeningTests": "Routine checkup",
// //       "exercise": "Walking 30 minutes daily, swimming, yoga",
// //       "weeksRemaining": 25,
// //       "imageUrl": "https://via.placeholder.com/300x200/29B6F6/FFFFFF?text=Week+15"
// //     },
// //     {
// //       "week": "Week 16",
// //       "trimester": "Second Trimester",
// //       "babyDevelopment": "Circulatory system fully functional. Muscles developing. Possibly first movements felt.",
// //       "babySize": "Avocado",
// //       "momTip": "First movements exciting! Keep prenatal vitamins.",
// //       "motherSymptoms": "May start feeling quickening. Appetite good. Possible skin changes.",
// //       "nutritionFocus": "Iron, Calcium, Protein, Vitamin C",
// //       "indianFoods": "Citrus fruits for iron absorption, leafy greens, legumes",
// //       "screeningTests": "Anomaly detailed ultrasound around week 18-21",
// //       "exercise": "Walking, swimming, prenatal yoga",
// //       "weeksRemaining": 24,
// //       "imageUrl": "https://via.placeholder.com/300x200/26C6DA/FFFFFF?text=Week+16"
// //     },
// //     {
// //       "week": "Week 17",
// //       "trimester": "Second Trimester",
// //       "babyDevelopment": "Vernix beginning to coat baby. Swallowing amniotic fluid. Practicing breathing.",
// //       "babySize": "Turnip",
// //       "momTip": "Left side sleeping preferred. Prenatal pillows helpful.",
// //       "motherSymptoms": "Feeling baby movements more. Appetite good. Backache starting.",
// //       "nutritionFocus": "Calcium, Iron, Magnesium",
// //       "indianFoods": "Magnesium - almonds, pumpkin seeds, spinach",
// //       "screeningTests": "Routine visits every 2 weeks",
// //       "exercise": "Walking, swimming, yoga, pelvic floor exercises",
// //       "weeksRemaining": 23,
// //       "imageUrl": "https://via.placeholder.com/300x200/26A69A/FFFFFF?text=Week+17"
// //     },
// //     {
// //       "week": "Week 18",
// //       "trimester": "Second Trimester",
// //       "babyDevelopment": "Sex clearly visible on ultrasound. Fingerprints unique now. Can respond to sounds.",
// //       "babySize": "Sweet potato",
// //       "momTip": "Maternity belt for back support. Eat smaller frequent meals.",
// //       "motherSymptoms": "Definitely feeling movements. More energy. Backaches may occur.",
// //       "nutritionFocus": "Calcium, Iron, Fiber, Protein",
// //       "indianFoods": "High fiber - whole grains, vegetables; Calcium - milk products",
// //       "screeningTests": "Anomaly scan (detailed ultrasound)",
// //       "exercise": "Walking, swimming, prenatal yoga",
// //       "weeksRemaining": 22,
// //       "imageUrl": "https://via.placeholder.com/300x200/66BB6A/FFFFFF?text=Week+18"
// //     },
// //     {
// //       "week": "Week 19",
// //       "trimester": "Second Trimester",
// //       "babyDevelopment": "Legs now longer than arms. Skin becoming less transparent. Brown fat developing.",
// //       "babySize": "Mango",
// //       "momTip": "Manage weight gain - 300-400g per week normal. Magnesium for leg cramps.",
// //       "motherSymptoms": "Baby movements very noticeable. Appetite strong. Possible leg cramps.",
// //       "nutritionFocus": "Iron, Calcium, Protein, Magnesium",
// //       "indianFoods": "Dates for iron, milk for calcium, almonds for magnesium",
// //       "screeningTests": "Should complete anomaly scan",
// //       "exercise": "Walking, swimming, prenatal yoga",
// //       "weeksRemaining": 21,
// //       "imageUrl": "https://via.placeholder.com/300x200/9CCC65/FFFFFF?text=Week+19"
// //     },
// //     {
// //       "week": "Week 20",
// //       "trimester": "Second Trimester (Midpoint)",
// //       "babyDevelopment": "Hair growing on head. Eyebrows visible. Swallowing and hiccupping. Stomach producing digestive juices.",
// //       "babySize": "Banana",
// //       "momTip": "Elevate feet regularly. Compression socks helpful.",
// //       "motherSymptoms": "Baby movements clear. Backache common. Possible swelling in feet/ankles.",
// //       "nutritionFocus": "Iron, Calcium, Protein, Fiber",
// //       "indianFoods": "Iron-rich foods, calcium-rich foods, fiber for digestion",
// //       "screeningTests": "Mid-pregnancy anatomy scan",
// //       "exercise": "Walking 30-45 min, swimming, prenatal yoga",
// //       "weeksRemaining": 20,
// //       "imageUrl": "https://via.placeholder.com/300x200/CDDC39/FFFFFF?text=Week+20"
// //     },
// //     {
// //       "week": "Week 21",
// //       "trimester": "Second Trimester",
// //       "babyDevelopment": "Coordinated movements. Swallowing amniotic fluid. Practicing breathing. Buds for permanent teeth forming.",
// //       "babySize": "Carrot",
// //       "momTip": "Use maternity belt. Avoid standing long periods. Elevate feet.",
// //       "motherSymptoms": "Clear baby movements. Back and pelvic pain common. Possible swollen ankles.",
// //       "nutritionFocus": "Iron, Calcium, Protein, Fluids",
// //       "indianFoods": "Spinach for iron, milk for calcium, plenty of water",
// //       "screeningTests": "Routine visit - blood pressure, weight check",
// //       "exercise": "Swimming excellent, walking, yoga, pelvic floor",
// //       "weeksRemaining": 19,
// //       "imageUrl": "https://via.placeholder.com/300x200/FFEB3B/FFFFFF?text=Week+21"
// //     },
// //     {
// //       "week": "Week 22",
// //       "trimester": "Second Trimester",
// //       "babyDevelopment": "Lungs developing rapidly. Brain development accelerating. Senses more refined.",
// //       "babySize": "Papaya",
// //       "momTip": "Sunscreen for skin - melasma common. Back support important.",
// //       "motherSymptoms": "Definite movements felt. Back pain. Possible skin changes (linea nigra).",
// //       "nutritionFocus": "Iron, Calcium, Protein, DHA",
// //       "indianFoods": "Fish for DHA, greens for iron, milk for calcium",
// //       "screeningTests": "Routine check",
// //       "exercise": "Walking, swimming, yoga, modified strength training",
// //       "weeksRemaining": 18,
// //       "imageUrl": "https://via.placeholder.com/300x200/FFC107/FFFFFF?text=Week+22"
// //     },
// //     {
// //       "week": "Week 23",
// //       "trimester": "Second Trimester",
// //       "babyDevelopment": "Rapid brain development. Increased lung maturation. Baby can hear and respond to loud noises.",
// //       "babySize": "Large mango",
// //       "momTip": "Prenatal massage helpful. Proper posture important. Special pillow for side sleeping.",
// //       "motherSymptoms": "Increased discomfort. Backache. Possible leg cramps. Sleep challenging.",
// //       "nutritionFocus": "Iron, Calcium, Protein, Magnesium",
// //       "indianFoods": "Legumes, greens, milk products",
// //       "screeningTests": "Regular checkup every 2 weeks",
// //       "exercise": "Walking, swimming, prenatal yoga",
// //       "weeksRemaining": 17,
// //       "imageUrl": "https://via.placeholder.com/300x200/FF9800/FFFFFF?text=Week+23"
// //     },
// //     {
// //       "week": "Week 24",
// //       "trimester": "Second Trimester",
// //       "babyDevelopment": "Lungs still developing. Eyelids beginning to separate. Skin still wrinkled. Brain growth rapid.",
// //       "babySize": "Corn",
// //       "momTip": "Glucose tolerance test typically done now. Watch for diabetes symptoms.",
// //       "motherSymptoms": "Increased discomfort. Back pain significant. Gestational diabetes screening now.",
// //       "nutritionFocus": "Iron, Calcium, Protein, Reduced sugar",
// //       "indianFoods": "Whole grains, legumes, vegetables, lean proteins",
// //       "screeningTests": "Glucose tolerance test (gestational diabetes screening)",
// //       "exercise": "Walking, swimming, prenatal yoga",
// //       "weeksRemaining": 16,
// //       "imageUrl": "https://via.placeholder.com/300x200/FF5722/FFFFFF?text=Week+24"
// //     },
// //     {
// //       "week": "Week 25",
// //       "trimester": "Second Trimester",
// //       "babyDevelopment": "Nostrils opening. Ears function improving. Baby more reactive. Immune system developing.",
// //       "babySize": "Rutabaga",
// //       "momTip": "Braxton-Hicks normal. Continue exercise within comfort.",
// //       "motherSymptoms": "Significant discomfort. Braxton-Hicks contractions. Swelling.",
// //       "nutritionFocus": "Iron, Calcium, Protein, Immune support",
// //       "indianFoods": "Vitamin C for immune support - citrus, guava, peppers",
// //       "screeningTests": "Routine antenatal checkup",
// //       "exercise": "Walking, swimming, prenatal yoga",
// //       "weeksRemaining": 15,
// //       "imageUrl": "https://via.placeholder.com/300x200/E64A19/FFFFFF?text=Week+25"
// //     },
// //     {
// //       "week": "Week 26",
// //       "trimester": "Second Trimester (End)",
// //       "babyDevelopment": "Eyes open. Eyelashes fully developed. Skin pink. Practicing breathing.",
// //       "babySize": "Lettuce head",
// //       "momTip": "From 28 weeks, checkups every 2 weeks. Continue exercise.",
// //       "motherSymptoms": "Very uncomfortable. Weight gain. Back pain, pelvic pressure.",
// //       "nutritionFocus": "Iron, Calcium, Protein, DHA",
// //       "indianFoods": "Maintain balanced nutrition",
// //       "screeningTests": "Complete hemoglobin check",
// //       "exercise": "Walking, swimming, gentle yoga",
// //       "weeksRemaining": 14,
// //       "imageUrl": "https://via.placeholder.com/300x200/D84315/FFFFFF?text=Week+26"
// //     },
// //     {
// //       "week": "Week 27",
// //       "trimester": "Third Trimester (Start)",
// //       "babyDevelopment": "Brain development continuing rapidly. Lungs rapidly maturing. Strong kicks.",
// //       "babySize": "Head of lettuce",
// //       "momTip": "More frequent checkups now - every 2 weeks. Monitor blood pressure.",
// //       "motherSymptoms": "Severe discomfort. Back/pelvic pain. Swelling. More frequent urination.",
// //       "nutritionFocus": "Iron, Calcium, Protein, DHA",
// //       "indianFoods": "Spinach, milk, dates, fish",
// //       "screeningTests": "Biweekly checkups begin",
// //       "exercise": "Walking, swimming, modified yoga",
// //       "weeksRemaining": 13,
// //       "imageUrl": "https://via.placeholder.com/300x200/C62828/FFFFFF?text=Week+27"
// //     },
// //     {
// //       "week": "Week 28",
// //       "trimester": "Third Trimester",
// //       "babyDevelopment": "Eyes focusing. Hair and body lanugo present. Lungs producing surfactant.",
// //       "babySize": "Eggplant",
// //       "momTip": "Rh-negative women get anti-D injection now. Frequent checkups to monitor.",
// //       "motherSymptoms": "Increasingly uncomfortable. Sleep position restricted. Possible gestational hypertension.",
// //       "nutritionFocus": "Iron, Calcium, Protein, Blood pressure management",
// //       "indianFoods": "Low sodium diet, potassium-rich foods like bananas",
// //       "screeningTests": "Anti-D if Rh negative; biweekly checkups start",
// //       "exercise": "Walking, swimming, prenatal yoga",
// //       "weeksRemaining": 12,
// //       "imageUrl": "https://via.placeholder.com/300x200/B71C1C/FFFFFF?text=Week+28"
// //     },
// //     {
// //       "week": "Week 29",
// //       "trimester": "Third Trimester",
// //       "babyDevelopment": "Brain accelerating. Baby gaining fat. Bones hardening. Position changing.",
// //       "babySize": "Butternut squash",
// //       "momTip": "Prenatal classes important. Birth plan creation. Hospital bag preparation.",
// //       "motherSymptoms": "Severe discomfort. Sleep very difficult. Frequent urination at night.",
// //       "nutritionFocus": "Iron, Calcium, Protein, Hydration",
// //       "indianFoods": "Balanced nutrition; avoid excess salt",
// //       "screeningTests": "Biweekly antenatal care",
// //       "exercise": "Modified walking, swimming, prenatal yoga",
// //       "weeksRemaining": 11,
// //       "imageUrl": "https://via.placeholder.com/300x200/8D6E63/FFFFFF?text=Week+29"
// //     },
// //     {
// //       "week": "Week 30",
// //       "trimester": "Third Trimester",
// //       "babyDevelopment": "Brain rapid growth. Most babies head-down. Strong coordinated movements.",
// //       "babySize": "Large cabbage",
// //       "momTip": "Pain management important. Hospital bag ready. Birth plan finalized.",
// //       "motherSymptoms": "Very uncomfortable. Severe back and pelvic pain. Possible insomnia.",
// //       "nutritionFocus": "Iron, Calcium, Protein, Relaxation nutrients",
// //       "indianFoods": "Magnesium sources - almonds, pumpkin seeds",
// //       "screeningTests": "Biweekly checkups, fetal health assessments",
// //       "exercise": "Gentle walking, prenatal yoga, breathing exercises",
// //       "weeksRemaining": 10,
// //       "imageUrl": "https://via.placeholder.com/300x200/795548/FFFFFF?text=Week+30"
// //     },
// //     {
// //       "week": "Week 31",
// //       "trimester": "Third Trimester",
// //       "babyDevelopment": "Skin pink and smoother. Most lanugo disappearing. Nails reaching fingertip ends.",
// //       "babySize": "Coconut",
// //       "momTip": "Regular monitoring for preeclampsia. Rest when possible.",
// //       "motherSymptoms": "Increasing discomfort. Severe fatigue returning. Sleep disrupted.",
// //       "nutritionFocus": "Iron, Calcium, Protein, Healthy fats",
// //       "indianFoods": "Varied diet with all nutrients",
// //       "screeningTests": "Biweekly monitoring for complications",
// //       "exercise": "Gentle walking, light yoga, pelvic floor exercises",
// //       "weeksRemaining": 9,
// //       "imageUrl": "https://via.placeholder.com/300x200/6D4C41/FFFFFF?text=Week+31"
// //     },
// //     {
// //       "week": "Week 32",
// //       "trimester": "Third Trimester",
// //       "babyDevelopment": "Bones fully formed but flexible. Fingernails grown. Toenails full length. Immune system almost complete.",
// //       "babySize": "Jicama",
// //       "momTip": "Only 8 weeks remaining! Pain management important.",
// //       "motherSymptoms": "Very uncomfortable. Severe back pain. Pelvic pressure. Braxton-Hicks regular.",
// //       "nutritionFocus": "Iron, Calcium, Protein, Antioxidants",
// //       "indianFoods": "Colorful vegetables for antioxidants",
// //       "screeningTests": "Biweekly checkups; Group B Strep screening",
// //       "exercise": "Gentle walking, prenatal yoga for relaxation",
// //       "weeksRemaining": 8,
// //       "imageUrl": "https://via.placeholder.com/300x200/5D4037/FFFFFF?text=Week+32"
// //     },
// //     {
// //       "week": "Week 33",
// //       "trimester": "Third Trimester",
// //       "babyDevelopment": "Immune system nearly complete. Lungs maturing. Brain development continuing. Practicing crying.",
// //       "babySize": "Pineapple",
// //       "momTip": "7 weeks to go! Birth plan review with doctor.",
// //       "motherSymptoms": "Extreme discomfort. Severe fatigue. Leg cramps. Possible sciatic nerve pain.",
// //       "nutritionFocus": "Iron, Calcium, Protein, Fiber",
// //       "indianFoods": "Fiber to prevent constipation - whole grains, vegetables",
// //       "screeningTests": "Biweekly appointments; labor discussions",
// //       "exercise": "Very gentle walking, relaxation yoga",
// //       "weeksRemaining": 7,
// //       "imageUrl": "https://via.placeholder.com/300x200/4E342E/FFFFFF?text=Week+33"
// //     },
// //     {
// //       "week": "Week 34",
// //       "trimester": "Third Trimester",
// //       "babyDevelopment": "Position settling (most head-down). Nails fully grown. Hair thickening. Antibodies transferring.",
// //       "babySize": "Cantaloupe melon",
// //       "momTip": "6 weeks remaining! Finalize birth plans. Notify work about leave.",
// //       "motherSymptoms": "Extremely uncomfortable. Severe back pain. Pelvic pressure increasing.",
// //       "nutritionFocus": "Iron, Calcium, Protein, Hydration",
// //       "indianFoods": "Balanced nutrition; stay hydrated",
// //       "screeningTests": "Biweekly checkups; Group B Strep results",
// //       "exercise": "Walking, relaxation techniques, breathing exercises",
// //       "weeksRemaining": 6,
// //       "imageUrl": "https://via.placeholder.com/300x200/37474F/FFFFFF?text=Week+34"
// //     },
// //     {
// //       "week": "Week 35",
// //       "trimester": "Third Trimester",
// //       "babyDevelopment": "Fully capable of life outside womb. Bones hardened but flexible. Most lanugo shed.",
// //       "babySize": "Honeydew melon",
// //       "momTip": "5 weeks to go. All preparations complete. Practice breathing exercises.",
// //       "motherSymptoms": "Extreme discomfort. Peak fatigue. Braxton-Hicks strong and regular.",
// //       "nutritionFocus": "Iron, Calcium, Protein",
// //       "indianFoods": "Final trimester nutrition",
// //       "screeningTests": "Final biweekly checkups",
// //       "exercise": "Gentle walking, relaxation practice",
// //       "weeksRemaining": 5,
// //       "imageUrl": "https://via.placeholder.com/300x200/455A64/FFFFFF?text=Week+35"
// //     },
// //     {
// //       "week": "Week 36",
// //       "trimester": "Third Trimester",
// //       "babyDevelopment": "Ready for birth. Bones still flexible. Vernix coating entire body. Lungs fully mature.",
// //       "babySize": "Romaine lettuce head",
// //       "momTip": "4 weeks to go! Weekly checkups start. Watch for labor signs.",
// //       "motherSymptoms": "Very uncomfortable. Strong Braxton-Hicks. Baby dropping lower.",
// //       "nutritionFocus": "Iron, Calcium",
// //       "indianFoods": "Small frequent meals",
// //       "screeningTests": "Weekly checkups start; monitor for preeclampsia",
// //       "exercise": "Walking, standing, position changes",
// //       "weeksRemaining": 4,
// //       "imageUrl": "https://via.placeholder.com/300x200/546E7A/FFFFFF?text=Week+36"
// //     },
// //     {
// //       "week": "Week 37",
// //       "trimester": "Third Trimester",
// //       "babyDevelopment": "Now considered term. Can be born safely. Vernix coating. Lanugo mostly gone.",
// //       "babySize": "Stalk of swiss chard",
// //       "momTip": "3 weeks to go! Labor could start anytime. Know false vs real labor signs.",
// //       "motherSymptoms": "Extremely uncomfortable. Baby moved lower. Braxton-Hicks frequent.",
// //       "nutritionFocus": "Hydration, Nutrition",
// //       "indianFoods": "Energy-rich foods",
// //       "screeningTests": "Weekly checkups; Group B Strep treatment if needed",
// //       "exercise": "Walking, labor preparation movements",
// //       "weeksRemaining": 3,
// //       "imageUrl": "https://via.placeholder.com/300x200/607D8B/FFFFFF?text=Week+37"
// //     },
// //     {
// //       "week": "Week 38",
// //       "trimester": "Third Trimester",
// //       "babyDevelopment": "All systems ready. Brain continuing development. Baby fully capable of life outside.",
// //       "babySize": "Stalk of rhubarb",
// //       "momTip": "2 weeks to go! Labor could begin any day. Stay positive.",
// //       "motherSymptoms": "Peak discomfort. Frequent urination. Possible mucus plug loss.",
// //       "nutritionFocus": "Hydration, Energy",
// //       "indianFoods": "Light meals easily digestible",
// //       "screeningTests": "Weekly checkups; assess cervical changes",
// //       "exercise": "Walking, position changes, labor prep movements",
// //       "weeksRemaining": 2,
// //       "imageUrl": "https://via.placeholder.com/300x200/78909C/FFFFFF?text=Week+38"
// //     },
// //     {
// //       "week": "Week 39",
// //       "trimester": "Third Trimester",
// //       "babyDevelopment": "Fully developed. Skin smooth from vernix. All systems ready. Practicing birth.",
// //       "babySize": "Small pumpkin",
// //       "momTip": "1 week to go! Labor likely imminent. Continue walking.",
// //       "motherSymptoms": "Extremely uncomfortable. May lose mucus plug. Possible cervical changes.",
// //       "nutritionFocus": "Hydration",
// //       "indianFoods": "Light easily digestible foods",
// //       "screeningTests": "Weekly checkups; induction discussion if needed",
// //       "exercise": "Walking for natural labor induction, position changes",
// //       "weeksRemaining": 1,
// //       "imageUrl": "https://via.placeholder.com/300x200/90A4AE/FFFFFF?text=Week+39"
// //     },
// //     {
// //       "week": "Week 40",
// //       "trimester": "Third Trimester (Due date)",
// //       "babyDevelopment": "Fully term and ready! All organs functioning. Brain continuing development after birth.",
// //       "babySize": "Small watermelon",
// //       "momTip": "Your due date! Labor should begin within days. Patience important.",
// //       "motherSymptoms": "Due date! May have labor or still waiting. Extreme discomfort.",
// //       "nutritionFocus": "Hydration",
// //       "indianFoods": "Light meals, clear fluids",
// //       "screeningTests": "Labor monitoring if started; medical induction if needed",
// //       "exercise": "Walking if not in labor, position changes",
// //       "weeksRemaining": 0,
// //       "imageUrl": "https://via.placeholder.com/300x200/B0BEC5/FFFFFF?text=Week+40"
// //     },
// //   ];
// //   @override
// //   Widget build(BuildContext context) {
// //     // Ensure _currentWeek is within the bounds of weekData
// //     if (_currentWeek < 1) {
// //       _currentWeek = 1;
// //     } else if (_currentWeek > weekData.length) {
// //       _currentWeek = weekData.length;
// //     }
// //
// //     // Get the data for the current week
// //     final currentWeekData = weekData[_currentWeek - 1]; // -1 because list is 0-indexed
// //
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         toolbarHeight: 0,
// //         elevation: 0,
// //         backgroundColor: Colors.white,
// //       ),
// //       body: Column(
// //         children: [
// //           // Top section: Week selection and trimester
// //           Container(
// //             padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.grey.withOpacity(0.1),
// //                   spreadRadius: 1,
// //                   blurRadius: 3,
// //                   offset: Offset(0, 2),
// //                 ),
// //               ],
// //             ),
// //             child: Column(
// //               children: [
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     Text(
// //                       currentWeekData["week"]!,
// //                       style: TextStyle(
// //                         fontSize: 20,
// //                         fontWeight: FontWeight.bold,
// //                         color: Colors.black87,
// //                       ),
// //                     ),
// //                     Text(
// //                       currentWeekData["trimester"]!,
// //                       style: TextStyle(
// //                         fontSize: 16,
// //                         color: Colors.grey[700],
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 SizedBox(height: 10),
// //                 SizedBox(
// //                   height: 40,
// //                   child: ListView.builder(
// //                     scrollDirection: Axis.horizontal,
// //                     itemCount: weekData.length,
// //                     itemBuilder: (context, index) {
// //                       final weekNumber = index + 1;
// //                       final isSelected = weekNumber == _currentWeek;
// //                       return GestureDetector(
// //                         onTap: () {
// //                           setState(() {
// //                             _currentWeek = weekNumber;
// //                           });
// //                         },
// //                         child: Container(
// //                           width: 40,
// //                           margin: EdgeInsets.symmetric(horizontal: 4),
// //                           decoration: BoxDecoration(
// //                             color: isSelected ? Colors.purple[600] : Colors.grey[200],
// //                             borderRadius: BorderRadius.circular(20),
// //                           ),
// //                           alignment: Alignment.center,
// //                           child: Text(
// //                             '$weekNumber',
// //                             style: TextStyle(
// //                               color: isSelected ? Colors.white : Colors.black87,
// //                               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
// //                             ),
// //                           ),
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 ),
// //                 SizedBox(height: 10),
// //                 Row(
// //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                   children: [
// //                     IconButton(
// //                       icon: Icon(Icons.arrow_back_ios, color: Colors.grey[700]),
// //                       onPressed: () {
// //                         setState(() {
// //                           if (_currentWeek > 1) {
// //                             _currentWeek--;
// //                           }
// //                         });
// //                       },
// //                     ),
// //                     Text(
// //                       "${currentWeekData["weeksRemaining"]} weeks remaining",
// //                       style: TextStyle(
// //                         fontSize: 14,
// //                         color: Colors.grey[600],
// //                         fontWeight: FontWeight.w500,
// //                       ),
// //                     ),
// //                     IconButton(
// //                       icon: Icon(Icons.arrow_forward_ios, color: Colors.grey[700]),
// //                       onPressed: () {
// //                         setState(() {
// //                           if (_currentWeek < weekData.length) {
// //                             _currentWeek++;
// //                           }
// //                         });
// //                       },
// //                     ),
// //                   ],
// //                 ),
// //               ],
// //             ),
// //           ),
// //           Expanded(
// //             child: SingleChildScrollView(
// //               padding: EdgeInsets.all(16.0),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   // Image Section
// //                   Container(
// //                     height: 200,
// //                     width: double.infinity,
// //                     decoration: BoxDecoration(
// //                       color: Colors.grey[300],
// //                       borderRadius: BorderRadius.circular(15),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.grey.withOpacity(0.2),
// //                           spreadRadius: 2,
// //                           blurRadius: 5,
// //                           offset: Offset(0, 3),
// //                         ),
// //                       ],
// //                     ),
// //                     child: ClipRRect(
// //                       borderRadius: BorderRadius.circular(15),
// //                       child: Image.network(
// //                         currentWeekData["imageUrl"]!,
// //                         fit: BoxFit.cover,
// //                         errorBuilder: (context, error, stackTrace) {
// //                           return Center(
// //                             child: Icon(Icons.broken_image, size: 50, color: Colors.grey[600]),
// //                           );
// //                         },
// //                       ),
// //                     ),
// //                   ),
// //                   SizedBox(height: 24),
// //
// //                   // Baby's Development Section
// //                   _buildSectionHeader("Baby's Development"),
// //                   SizedBox(height: 10),
// //                   Text(
// //                     currentWeekData["babyDevelopment"]!,
// //                     style: TextStyle(
// //                       fontSize: 16,
// //                       height: 1.5,
// //                       color: Colors.grey[800],
// //                     ),
// //                   ),
// //                   SizedBox(height: 24),
// //
// //                   // Baby's Size Section
// //                   _buildSectionHeader("Baby's Size"),
// //                   SizedBox(height: 10),
// //                   _buildInfoRow(Icons.monitor_weight, currentWeekData["babySize"]!),
// //                   SizedBox(height: 24),
// //
// //                   // Mother's Symptoms Section
// //                   _buildSectionHeader("Mother's Symptoms"),
// //                   SizedBox(height: 10),
// //                   Container(
// //                     padding: EdgeInsets.all(12),
// //                     decoration: BoxDecoration(
// //                       color: Colors.orange[50]?.withOpacity(0.5),
// //                       borderRadius: BorderRadius.circular(10),
// //                       border: Border.all(color: Colors.orange[100]!),
// //                     ),
// //                     child: Row(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Icon(Icons.health_and_safety, color: Colors.orange[600], size: 24),
// //                         SizedBox(width: 10),
// //                         Expanded(
// //                           child: Text(
// //                             currentWeekData["motherSymptoms"]!,
// //                             style: TextStyle(
// //                               fontSize: 16,
// //                               color: Colors.grey[700],
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   SizedBox(height: 24),
// //
// //                   // Mom's Tip Section
// //                   _buildSectionHeader("Mom's Tip"),
// //                   SizedBox(height: 10),
// //                   Container(
// //                     padding: EdgeInsets.all(12),
// //                     decoration: BoxDecoration(
// //                       color: Colors.purple[50]?.withOpacity(0.5),
// //                       borderRadius: BorderRadius.circular(10),
// //                       border: Border.all(color: Colors.purple[100]!),
// //                     ),
// //                     child: Row(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Icon(Icons.lightbulb_outline, color: Colors.purple[600], size: 24),
// //                         SizedBox(width: 10),
// //                         Expanded(
// //                           child: Text(
// //                             currentWeekData["momTip"]!,
// //                             style: TextStyle(
// //                               fontSize: 16,
// //                               fontStyle: FontStyle.italic,
// //                               color: Colors.grey[700],
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   SizedBox(height: 24),
// //
// //                   // Nutrition Focus Section
// //                   _buildSectionHeader("Nutrition Focus"),
// //                   SizedBox(height: 10),
// //                   _buildInfoRow(Icons.restaurant, currentWeekData["nutritionFocus"]!),
// //                   SizedBox(height: 24),
// //
// //                   // Indian Foods Section
// //                   _buildSectionHeader("Indian Foods"),
// //                   SizedBox(height: 10),
// //                   _buildInfoRow(Icons.food_bank, currentWeekData["indianFoods"]!),
// //                   SizedBox(height: 24),
// //
// //                   // Screening Tests Section
// //                   _buildSectionHeader("Screening Tests"),
// //                   SizedBox(height: 10),
// //                   _buildInfoRow(Icons.medical_services, currentWeekData["screeningTests"]!),
// //                   SizedBox(height: 24),
// //
// //                   // Exercise Section
// //                   _buildSectionHeader("Exercise"),
// //                   SizedBox(height: 10),
// //                   _buildInfoRow(Icons.directions_run, currentWeekData["exercise"]!),
// //                   SizedBox(height: 20),
// //                 ],
// //               ),
// //             ),
// //           ),
// //           // Bottom Navigation Bar
// //           _buildBottomNavBar(),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildSectionHeader(String title) {
// //     return Text(
// //       title,
// //       style: TextStyle(
// //         fontSize: 22,
// //         fontWeight: FontWeight.bold,
// //         color: Colors.purple[800],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildInfoRow(IconData icon, String text) {
// //     return Row(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Icon(icon, color: Colors.purple[600], size: 24),
// //         SizedBox(width: 8),
// //         Expanded(
// //           child: Text(
// //             text,
// //             style: TextStyle(
// //               fontSize: 16,
// //               color: Colors.grey[800],
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildBottomNavBar() {
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.grey.withOpacity(0.1),
// //             spreadRadius: 2,
// //             blurRadius: 5,
// //             offset: Offset(0, -3),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
