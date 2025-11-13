import 'package:shared_preferences/shared_preferences.dart';

class PregnancyData {
  DateTime? lastPeriodDate;
  DateTime? dueDate;
  DateTime? conceptionDate;
  String? babyNickname;

  PregnancyData({
    this.lastPeriodDate,
    this.dueDate,
    this.conceptionDate,
    this.babyNickname,
  });

  // ✅ Calculate due date from LMP (280 days / 40 weeks)
  void calculateDueDateFromLMP() {
    if (lastPeriodDate != null) {
      dueDate = lastPeriodDate!.add(const Duration(days: 280));
    }
  }

  // ✅ Total days pregnant
  int get daysPregnant {
    if (lastPeriodDate == null) return 0;
    return DateTime.now().difference(lastPeriodDate!).inDays;
  }

  // ✅ Current week number (1-40)
  int get currentWeekNumber {
    if (lastPeriodDate == null) return 0;
    int week = (daysPregnant ~/ 7) + 1;
    return week.clamp(1, 40);
  }

  // ✅ Current day in the week (0-6)
  int get currentDayNumber {
    if (lastPeriodDate == null) return 0;
    return daysPregnant % 7;
  }

  // ✅ Weeks pregnant as string (e.g., "5 weeks and 3 days")
  String get weeksPregnant {
    if (lastPeriodDate == null) return "0 weeks and 0 days";
    final weeks = currentWeekNumber;
    final days = currentDayNumber;
    return "$weeks weeks and $days days";
  }

  // ✅ Current month of pregnancy (1-9)
  String get currentMonth {
    int week = currentWeekNumber;
    if (week <= 4) return "1st month";
    if (week <= 8) return "2nd month";
    if (week <= 13) return "3rd month";
    if (week <= 17) return "4th month";
    if (week <= 21) return "5th month";
    if (week <= 26) return "6th month";
    if (week <= 30) return "7th month";
    if (week <= 35) return "8th month";
    return "9th month";
  }

  // ✅ Current trimester
  String get trimester {
    int week = currentWeekNumber;
    if (week <= 13) return "First Trimester";
    if (week <= 26) return "Second Trimester";
    return "Third Trimester";
  }

  // ✅ Weeks remaining
  String get weeksRemaining {
    if (dueDate == null) return "N/A";
    final daysLeft = dueDate!.difference(DateTime.now()).inDays;
    if (daysLeft <= 0) return "Baby is here!";
    final weeks = daysLeft ~/ 7;
    final days = daysLeft % 7;
    return "$weeks weeks and $days days";
  }

  // ✅ Baby size with accurate emoji based on week
  String get babySize {
    int week = currentWeekNumber;
    Map<int, String> sizes = {
      1: "Poppy Seed", 2: "Sesame Seed", 3: "Poppy Seed", 4: "Poppyseed",
      5: "Apple Seed", 6: "Sweet Pea", 7: "Blueberry", 8: "Kidney Bean",
      9: "Grape", 10: "Kumquat", 11: "Fig", 12: "Lime",
      13: "Peapod", 14: "Lemon", 15: "Apple", 16: "Avocado",
      17: "Turnip", 18: "Bell Pepper", 19: "Heirloom Tomato", 20: "Banana",
      21: "Carrot", 22: "Spaghetti Squash", 23: "Large Mango", 24: "Ear of Corn",
      25: "Rutabaga", 26: "Scallion", 27: "Cauliflower", 28: "Large Eggplant",
      29: "Butternut Squash", 30: "Large Cabbage", 31: "Coconut", 32: "Jicama",
      33: "Pineapple", 34: "Cantaloupe", 35: "Honeydew Melon", 36: "Romaine Lettuce",
      37: "Swiss Chard", 38: "Leek", 39: "Mini Watermelon", 40: "Small Pumpkin"
    };
    return sizes[week.clamp(1, 40)] ?? "N/A";
  }

  // ✅ Baby emoji based on size
  String get babyEmoji {
    int week = currentWeekNumber;
    if (week <= 6) return "🌱"; // Seed stage
    if (week <= 12) return "🫐"; // Berry stage
    if (week <= 16) return "🍋"; // Lemon/lime
    if (week <= 20) return "🥑"; // Avocado
    if (week <= 24) return "🌽"; // Corn
    if (week <= 28) return "🍆"; // Eggplant
    if (week <= 32) return "🥥"; // Coconut
    if (week <= 36) return "🍉"; // Melon
    return "🎃"; // Pumpkin (full term)
  }

  // ✅ Development stage description
  String get stageDescription {
    int week = currentWeekNumber;
    if (week <= 8) return "Embryo: Major organs beginning to form";
    if (week <= 12) return "Fetus: All organs present, rapid growth";
    if (week <= 20) return "Fetus: Movements felt, hair growing";
    if (week <= 28) return "Fetus: Eyes open, brain developing";
    if (week <= 36) return "Fetus: Lungs maturing, gaining weight";
    return "Full term: Baby ready for birth";
  }

  // ✅ Progress percentage (0-100%)
  double get progress {
    return (currentWeekNumber / 40).clamp(0.0, 1.0);
  }

  String get progressPercentage {
    return "${(progress * 100).toStringAsFixed(1)}%";
  }

  // ✅ Days remaining
  int get daysRemaining {
    if (dueDate == null) return 0;
    final days = dueDate!.difference(DateTime.now()).inDays;
    return days > 0 ? days : 0;
  }

  // // ✅ Save to SharedPreferences
  // Future<void> saveToPrefs() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   if (lastPeriodDate != null) {
  //     prefs.setString('lastPeriodDate', lastPeriodDate!.toIso8601String());
  //   }
  //   if (dueDate != null) {
  //     prefs.setString('dueDate', dueDate!.toIso8601String());
  //   }
  //   if (conceptionDate != null) {
  //     prefs.setString('conceptionDate', conceptionDate!.toIso8601String());
  //   }
  //   if (babyNickname != null) {
  //     prefs.setString('babyNickname', babyNickname!);
  //   }
  // }
  //
  // // ✅ Load from SharedPreferences
  // static Future<PregnancyData> loadFromPrefs() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   PregnancyData data = PregnancyData();
  //
  //   if (prefs.containsKey('lastPeriodDate')) {
  //     data.lastPeriodDate = DateTime.parse(prefs.getString('lastPeriodDate')!);
  //   }
  //   if (prefs.containsKey('dueDate')) {
  //     data.dueDate = DateTime.parse(prefs.getString('dueDate')!);
  //   }
  //   if (prefs.containsKey('conceptionDate')) {
  //     data.conceptionDate = DateTime.parse(prefs.getString('conceptionDate')!);
  //   }
  //   if (prefs.containsKey('babyNickname')) {
  //     data.babyNickname = prefs.getString('babyNickname');
  //   }
  //
  //   return data;
  // }


  // ✅ Enhanced Save to SharedPreferences
  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    print('Saving Pregnancy Data:');
    print('Last Period: $lastPeriodDate');
    print('Due Date: $dueDate');
    print('Baby Nickname: $babyNickname');

    if (lastPeriodDate != null) {
      await prefs.setString('lastPeriodDate', lastPeriodDate!.toIso8601String());
    } else {
      await prefs.remove('lastPeriodDate');
    }

    if (dueDate != null) {
      await prefs.setString('dueDate', dueDate!.toIso8601String());
    } else {
      await prefs.remove('dueDate');
    }

    if (conceptionDate != null) {
      await prefs.setString('conceptionDate', conceptionDate!.toIso8601String());
    } else {
      await prefs.remove('conceptionDate');
    }

    if (babyNickname != null && babyNickname!.isNotEmpty) {
      await prefs.setString('babyNickname', babyNickname!);
    } else {
      await prefs.remove('babyNickname');
    }

    // Force immediate save
    await prefs.reload();
  }

// ✅ Enhanced Load from SharedPreferences
  static Future<PregnancyData> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    PregnancyData data = PregnancyData();

    try {
      if (prefs.containsKey('lastPeriodDate')) {
        final dateString = prefs.getString('lastPeriodDate')!;
        data.lastPeriodDate = DateTime.parse(dateString);
        print('Loaded Last Period: ${data.lastPeriodDate}');
      }

      if (prefs.containsKey('dueDate')) {
        final dateString = prefs.getString('dueDate')!;
        data.dueDate = DateTime.parse(dateString);
        print('Loaded Due Date: ${data.dueDate}');
      }

      if (prefs.containsKey('conceptionDate')) {
        final dateString = prefs.getString('conceptionDate')!;
        data.conceptionDate = DateTime.parse(dateString);
      }

      if (prefs.containsKey('babyNickname')) {
        data.babyNickname = prefs.getString('babyNickname');
        print('Loaded Nickname: ${data.babyNickname}');
      }
    } catch (e) {
      print('Error loading pregnancy data: $e');
    }

    return data;
  }



  // ✅ Clear all data
  static Future<void> clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lastPeriodDate');
    await prefs.remove('dueDate');
    await prefs.remove('conceptionDate');
    await prefs.remove('babyNickname');
  }
}


// import 'package:shared_preferences/shared_preferences.dart';
//
// class PregnancyData {
//   DateTime? lastPeriodDate;
//   DateTime? dueDate;
//   DateTime? conceptionDate;
//   String? babyNickname;
//
//   PregnancyData({
//     this.lastPeriodDate,
//     this.dueDate,
//     this.conceptionDate,
//     this.babyNickname,
//   });
//
//   // Calculate due date from last period (LMP)
//   void calculateDueDateFromLMP() {
//     if (lastPeriodDate != null) {
//       dueDate = lastPeriodDate!.add(const Duration(days: 280)); // 40 weeks
//     }
//   }
//
//   // Current week of pregnancy
//   int get currentWeekNumber {
//     if (lastPeriodDate == null) return 0;
//     final daysSinceLMP = DateTime.now().difference(lastPeriodDate!).inDays;
//     int week = (daysSinceLMP ~/ 7) + 1;
//     return week.clamp(1, 40);
//   }
//
//   // Current day in the week
//   int get currentDayNumber {
//     if (lastPeriodDate == null) return 0;
//     final daysSinceLMP = DateTime.now().difference(lastPeriodDate!).inDays;
//     return (daysSinceLMP % 7);
//   }
//
//   // Weeks pregnant as string (e.g., "5 weeks and 3 days")
//   String get weeksPregnant {
//     if (lastPeriodDate == null) return "0 weeks and 0 days";
//     final weeks = currentWeekNumber;
//     final days = currentDayNumber;
//     return "$weeks weeks and $days days";
//   }
//
//   // Weeks remaining (e.g., "35 weeks and 4 days")
//   String get weeksRemaining {
//     if (dueDate == null) return "N/A";
//     final daysLeft = dueDate!.difference(DateTime.now()).inDays;
//     if (daysLeft <= 0) return "Baby is here!";
//     final weeks = daysLeft ~/ 7;
//     final days = daysLeft % 7;
//     return "$weeks weeks and $days days";
//   }
//
//   // Baby size based on current week
//   String get babySize {
//     int week = currentWeekNumber;
//     Map<int, String> sizes = {
//       1: "Poppy Seed", 2: "Raspberry", 3: "Blueberry", 4: "Grape",
//       5: "Lime", 6: "Lemon", 7: "Peach", 8: "Avocado", 9: "Bell Pepper",
//       10: "Carrot", 11: "Apple", 12: "Mango", 13: "Lemon", 14: "Avocado",
//       15: "Orange", 16: "Onion", 17: "Turnip", 18: "Sweet Potato",
//       19: "Tomato", 20: "Banana", 21: "Carrot", 22: "Papaya", 23: "Grapefruit",
//       24: "Corn", 25: "Cauliflower", 26: "Lettuce", 27: "Cucumber",
//       28: "Eggplant", 29: "Butternut Squash", 30: "Cabbage",
//       31: "Pineapple", 32: "Squash", 33: "Durian", 34: "Cantaloupe",
//       35: "Honeydew", 36: "Romaine Lettuce", 37: "Pumpkin", 38: "Watermelon",
//       39: "Pumpkin", 40: "Jackfruit"
//     };
//     return sizes[week.clamp(1, 40)] ?? "N/A";
//   }
//
//   // Progress from 0.0 to 1.0
//   double get progress {
//     return (currentWeekNumber / 40).clamp(0.0, 1.0);
//   }
//
//   // SharedPreferences
//   Future<void> saveToPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     if (lastPeriodDate != null) prefs.setString('lastPeriodDate', lastPeriodDate!.toIso8601String());
//     if (dueDate != null) prefs.setString('dueDate', dueDate!.toIso8601String());
//     if (babyNickname != null) prefs.setString('babyNickname', babyNickname!);
//   }
//
//   static Future<PregnancyData> loadFromPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     PregnancyData data = PregnancyData();
//     if (prefs.containsKey('lastPeriodDate')) {
//       data.lastPeriodDate = DateTime.parse(prefs.getString('lastPeriodDate')!);
//     }
//     if (prefs.containsKey('dueDate')) {
//       data.dueDate = DateTime.parse(prefs.getString('dueDate')!);
//     }
//     if (prefs.containsKey('babyNickname')) {
//       data.babyNickname = prefs.getString('babyNickname');
//     }
//     return data;
//   }
// }
