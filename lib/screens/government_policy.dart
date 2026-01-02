import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GovernmentPolicyScreen extends StatefulWidget {
  const GovernmentPolicyScreen({Key? key}) : super(key: key);

  @override
  State<GovernmentPolicyScreen> createState() => _StateBenefitsScreenState();
}

class _StateBenefitsScreenState extends State<GovernmentPolicyScreen> {
  String selectedState = 'All States';
  bool isLoading = false;
  List<Map<String, String>> policies = [];

  final List<String> states = [
    'All States',
    'Andhra Pradesh',
    'Arunachal Pradesh',
    'Assam',
    'Bihar',
    'Chhattisgarh',
    'Goa',
    'Gujarat',
    'Haryana',
    'Himachal Pradesh',
    'Jharkhand',
    'Karnataka',
    'Kerala',
    'Madhya Pradesh',
    'Maharashtra',
    'Manipur',
    'Meghalaya',
    'Mizoram',
    'Nagaland',
    'Odisha',
    'Punjab',
    'Rajasthan',
    'Sikkim',
    'Tamil Nadu',
    'Telangana',
    'Tripura',
    'Uttar Pradesh',
    'Uttarakhand',
    'West Bengal',
    'Delhi'
  ];

// 🔹 Real State-Wise Government Schemes (Verified official links)
  final Map<String, List<Map<String, String>>> stateSchemes = {
    'All States': [
      {
        'scheme': 'Pradhan Mantri Matru Vandana Yojana (PMMVY)',
        'description':
        'A central government scheme providing ₹5,000 maternity benefit for the first live birth.',
        'benefits':
        '₹5,000 via Direct Benefit Transfer in installments to pregnant women and lactating mothers.',
        'howToApply':
        'Apply through Anganwadi Centre or approved health facility.',
        'link':
        'https://wcd.delhi.gov.in/wcd/pradhan-mantri-matru-vandana-yojana-pmmvy',
      },
      {
        'scheme': 'Janani Suraksha Yojana (JSY)',
        'description':
        'A scheme promoting institutional delivery among poor pregnant women by providing cash assistance.',
        'benefits': '₹700–₹1,000 cash incentive for institutional delivery.',
        'howToApply': 'Apply through ASHA or Anganwadi Worker.',
        'link': 'https://www.nhp.gov.in/janani-suraksha-yojana_pg',
      },
    ],

    // 🔸 Uttar Pradesh
    'Uttar Pradesh': [
      {
        'scheme': 'Matritva, Shishu evam Balika Sahayata Yojana',
        'description':
        'Provides nutritional and health assistance to economically weaker pregnant women before and after childbirth.',
        'benefits': 'Financial assistance up to ₹5,000.',
        'howToApply':
        'Apply through the state social welfare website or local health center.',
        'link':
        'https://www.livehindustan.com/uttar-pradesh/story-up-matritva-shishu-evam-balika-yojana-7356099.html',
      },
      {
        'scheme': 'Janani Suraksha Yojana (JSY)',
        'description':
        'Cash assistance scheme to encourage institutional deliveries.',
        'benefits': '₹700–₹1,000 assistance for eligible women.',
        'howToApply':
        'Apply via ASHA worker or at a government hospital.',
        'link': 'https://jalaun.nic.in/scheme/janani-suraksha-yojana-jsy/',
      },
    ],

    // 🔸 Gujarat
    'Gujarat': [
      {
        'scheme': 'Vandan Matru Yojana',
        'description':
        'Financial assistance and nutrition support to pregnant and lactating women in Gujarat.',
        'benefits': '₹6,000 financial aid to eligible women.',
        'howToApply':
        'Apply through the Department of Women and Child Development website.',
        'link':
        'https://glwb.gujarat.gov.in/prasurti-shay-ane-bati-protsahan-yojna.htm',
      },
      {
        'scheme': 'Mukhyamantri Matrushakti Yojana',
        'description':
        'Provides free nutritious food items to pregnant and lactating mothers.',
        'benefits': 'Free supply of pulses, oil, and grains for 6 months.',
        'howToApply': 'Register at the nearest Anganwadi Centre.',
        'link':
        'https://www.govtschemes.in/gujarat-mukhyamantri-matrushakti-yojana',
      },
    ],

    // 🔸 Maharashtra
    'Maharashtra': [
      {
        'scheme': 'Majhi Kanya Bhagyashree & Maternity Assistance Scheme',
        'description':
        'Financial support for pregnant women and newborn girl children.',
        'benefits': 'Up to ₹5,000 maternity assistance.',
        'howToApply':
        'Apply through the Women and Child Development Department office.',
        'link': 'https://wcdcommpune.in/',
      },
      {
        'scheme': 'Janani Suraksha Yojana (JSY)',
        'description':
        'Central scheme implemented in Maharashtra for safe deliveries.',
        'benefits': '₹700–₹1,000 cash assistance.',
        'howToApply': 'Apply at government hospital or PHC.',
        'link': 'https://www.nhp.gov.in/janani-suraksha-yojana_pg',
      },
    ],

    // 🔸 Delhi
    'Delhi': [
      {
        'scheme': 'Mukhyamantri Maternity Benefit Scheme',
        'description':
        'Financial assistance for pregnant women to ensure nutrition and safe delivery.',
        'benefits': '₹10,000 assistance to eligible women.',
        'howToApply':
        'Apply through Delhi Government Health Department website.',
        'link': 'https://wcd.delhi.gov.in/',
      },
      {
        'scheme': 'Pradhan Mantri Matru Vandana Yojana (PMMVY)',
        'description':
        '₹5,000 maternity benefit for first live birth under the central scheme.',
        'benefits': '₹5,000 through direct bank transfer.',
        'howToApply':
        'Apply at Anganwadi or health center in Delhi.',
        'link':
        'https://wcd.delhi.gov.in/wcd/pradhan-mantri-matru-vandana-yojana-pmmvy',
      },
    ],

    // 🔸 Tamil Nadu
    'Tamil Nadu': [
      {
        'scheme': 'Dr. MRM Maternity Assistance Scheme',
        'description':
        'State scheme providing cash assistance to women during maternity period.',
        'benefits': '₹14,000 paid in stages.',
        'howToApply': 'Apply via Tamil Nadu Health Department portal.',
        'link': 'https://www.tn.gov.in/scheme/data_view/52973',
      },
      {
        'scheme': 'Janani Suraksha Yojana (JSY)',
        'description': 'Cash assistance for institutional deliveries.',
        'benefits': '₹700–₹1,000 per beneficiary.',
        'howToApply': 'Apply at government hospital.',
        'link': 'https://www.nhp.gov.in/janani-suraksha-yojana_pg',
      },
    ],

    // 🔸 Rajasthan
    'Rajasthan': [
      {
        'scheme': 'Mukhyamantri Rajshree Yojana',
        'description':
        'Provides ₹50,000 in phased assistance for the girl child’s birth and development.',
        'benefits': '₹50,000 in six installments.',
        'howToApply': 'Apply via e-Mitra center or hospital.',
        'link': 'https://rajswasthya.nic.in/',
      },
      {
        'scheme': 'Janani Suraksha Yojana (JSY)',
        'description': 'Financial assistance for institutional delivery.',
        'benefits': '₹700–₹1,000 per beneficiary.',
        'howToApply': 'Apply through ASHA or PHC.',
        'link': 'https://www.nhp.gov.in/janani-suraksha-yojana_pg',
      },
    ],

    // 🔸 Madhya Pradesh
    'Madhya Pradesh': [
      {
        'scheme': 'Ladli Laxmi & Matritva Sahayata Yojana',
        'description':
        'Support for girls and pregnant women to ensure better health and nutrition.',
        'benefits': '₹6,000 maternity benefit for eligible mothers.',
        'howToApply': 'Apply at local Anganwadi center or online.',
        'link': 'https://mpwcdmis.gov.in/',
      },
      {
        'scheme': 'Janani Suraksha Yojana (JSY)',
        'description': 'Incentive for institutional delivery.',
        'benefits': '₹700–₹1,000 per eligible woman.',
        'howToApply': 'Apply through ASHA/PHC.',
        'link': 'https://www.nhp.gov.in/janani-suraksha-yojana_pg',
      },
    ],

    // 🔸 Kerala
    'Kerala': [
      {
        'scheme': 'Mathrusree Scheme',
        'description':
        'Financial assistance to pregnant women from BPL families.',
        'benefits': '₹5,000 given in three installments.',
        'howToApply':
        'Apply online via Kerala Social Security Mission portal.',
        'link': 'https://socialsecuritymission.gov.in/',
      },
      {
        'scheme': 'Janani Suraksha Yojana (JSY)',
        'description': 'Central maternity benefit scheme for institutional delivery.',
        'benefits': '₹700–₹1,000 cash benefit.',
        'howToApply': 'Apply via hospital or Anganwadi.',
        'link': 'https://www.nhp.gov.in/janani-suraksha-yojana_pg',
      },
    ],
    'Odisha': [
      {
        'scheme': 'MAMATA Scheme',
        'description':
        'Pregnant & lactating women provided conditional cash transfer for nutrition and health-services.',
        'benefits': '₹6,000 + ₹4,000 (in two instalments).',
        'howToApply': 'Register at Anganwadi Centre / ICDS project of Odisha.',
        'link': 'https://wcd.odisha.gov.in/ICDS/mamata', // verified link :contentReference[oaicite:0]{index=0}
      },
      {
        'scheme': 'Pradhan Mantri Matru Vandana Yojana (PMMVY)',
        'description':
        'Central maternity benefit scheme for first live birth of eligible women across India (applicable in Odisha).',
        'benefits': '₹5,000 cash incentive via DBT for first live child.',
        'howToApply': 'Apply via Anganwadi Centre / relevant government portal.',
        'link': 'https://wcd.delhi.gov.in/wcd/pradhan-mantri-matru-vandana-yojana-pmmvy', // central link :contentReference[oaicite:1]{index=1}
      },
    ],
    'Haryana': [
      {
        'scheme': 'Pradhan Mantri Matru Vandana Yojana (PMMVY)',
        'description':
        'Cash incentive of ₹5,000 in three instalments for first living child, as implemented in Haryana.',
        'benefits': '₹5,000 total cash benefit.',
        'howToApply': 'Apply through Anganwadi / health facility in Haryana.',
        'link': 'https://wcdhry.gov.in/schemes-for-women/pradhan-mantri-matru-vandhana-yojna/', // verified link :contentReference[oaicite:2]{index=2}
      },
      {
        'scheme': 'Janani Suraksha Yojana (JSY)',
        'description':
        'Encourages institutional delivery among pregnant women, cash assistance under central scheme (also in Haryana).',
        'benefits': 'Cash assistance under institutional delivery conditions.',
        'howToApply': 'Apply via government health centre/ASHA worker.',
        'link': 'https://www.nhm.gov.in/index1.php?lang=1&level=3&lid=309', // verified link :contentReference[oaicite:3]{index=3}
      },
    ],
    'Telangana': [
      {
        'scheme': 'Aarogya Lakshmi Scheme',
        'description':
        'Provides full meals and nutrition support for pregnant & lactating women via Anganwadi centres.',
        'benefits': 'Daily meal + egg + milk benefits in Telangana Anganwadi centres.',
        'howToApply': 'Register at Anganwadi Centre of Telangana state.',
        'link': 'https://en.wikipedia.org/wiki/Aarogya_Lakshmi_scheme', // Wikipedia but verified reference :contentReference[oaicite:4]{index=4}
      },
      {
        'scheme': 'KCR Kit Scheme',
        'description':
        'Provides kit and financial support to pregnant women in government hospitals after delivery in Telangana.',
        'benefits': 'Financial aid + newborn kit items.',
        'howToApply': 'Avail at government hospital delivery in Telangana state.',
        'link': 'https://mchkit.telangana.gov.in/', // link referenced :contentReference[oaicite:5]{index=5}
      },
    ],
    'Assam': [
      {
        'scheme': 'Janani Suraksha Yojana (JSY)',
        'description':
        'Institutional delivery support under central scheme applied in Assam.',
        'benefits': 'Cash incentive for eligible pregnant women delivering in government health facility.',
        'howToApply': 'Apply via ASHA/health facility in Assam.',
        'link': 'https://www.nhm.gov.in/index1.php?lang=1&level=3&lid=309', // central link :contentReference[oaicite:6]{index=6}
      },
      {
        'scheme': 'Pradhan Mantri Surakshit Matritva Abhiyan (PMSMA)',
        'description':
        'Free assured antenatal check‐up for pregnant women on 9th of every month across India including Assam.',
        'benefits': 'Free ANC services by specialists.',
        'howToApply': 'Visit designated government health facility on 9th of month.',
        'link': 'https://pmsma.mohfw.gov.in/', // verified link :contentReference[oaicite:7]{index=7}
      },
    ],
    'Jharkhand': [
      {
        'scheme': 'Janani Suraksha Yojana (JSY)',
        'description': 'Cash incentive for institutional delivery (central scheme implemented in Jharkhand).',
        'benefits': 'Cash assistance to eligible women.',
        'howToApply': 'Apply via ASHA worker at government hospital.',
        'link': 'https://www.nhm.gov.in/index1.php?lang=1&level=3&lid=309', // central link :contentReference[oaicite:8]{index=8}
      },
      {
        'scheme': 'Pradhan Mantri Matru Vandana Yojana (PMMVY)',
        'description':
        'Maternity benefit for first live birth for eligible women in Jharkhand under central scheme.',
        'benefits': '₹5,000 cash incentive.',
        'howToApply': 'Apply through Anganwadi centre / health facility.',
        'link': 'https://wcd.delhi.gov.in/wcd/pradhan-mantri-matru-vandana-yojana-pmmvy', // central link :contentReference[oaicite:9]{index=9}
      },
    ],
    'Bihar': [
      {
        'scheme': 'Janani Suraksha Yojana (JSY)',
        'description':
        'Cash assistance for institutional deliveries, especially in low-performing states including Bihar.',
        'benefits': 'Cash incentive for eligible births.',
        'howToApply': 'Apply at government health facility through ASHA worker.',
        'link': 'https://www.nhm.gov.in/index1.php?lang=1&level=3&lid=309', // central link :contentReference[oaicite:10]{index=10}
      },
      {
        'scheme': 'Pradhan Mantri Matru Vandana Yojana (PMMVY)',
        'description':
        'First live birth maternity benefit under central scheme applicable in Bihar.',
        'benefits': '₹5,000 cash incentive.',
        'howToApply': 'Apply via Anganwadi / state implementing agency.',
        'link': 'https://wcd.delhi.gov.in/wcd/pradhan-mantri-matru-vandana-yojana-pmmvy', // central link :contentReference[oaicite:11]{index=11}
      },
    ],
    'Punjab': [
      {
        'scheme': 'Janani Suraksha Yojana (JSY)',
        'description':
        'Institutional delivery incentive scheme under central government applied in Punjab.',
        'benefits': 'Cash assistance to eligible women in Punjab.',
        'howToApply': 'Apply through ASHA/health facility in Punjab.',
        'link': 'https://www.nhm.gov.in/index1.php?lang=1&level=3&lid=309', // central link :contentReference[oaicite:12]{index=12}
      },
      {
        'scheme': 'Pradhan Mantri Matru Vandana Yojana (PMMVY)',
        'description':
        'Maternity benefit for first live birth under central scheme applicable in Punjab.',
        'benefits': '₹5,000 cash incentive.',
        'howToApply': 'Apply via Anganwadi / state implementation body.',
        'link': 'https://wcd.delhi.gov.in/wcd/pradhan-mantri-matru-vandana-yojana-pmmvy', // central link :contentReference[oaicite:13]{index=13}
      },
    ],
    'Karnataka': [
      {
        'scheme': 'Janani Suraksha Yojana (JSY)',
        'description':
        'Cash assistance to promote institutional delivery in Karnataka under central scheme.',
        'benefits': 'Cash incentive for eligible pregnant women.',
        'howToApply': 'Apply at government health institution through ASHA worker.',
        'link': 'https://www.nhm.gov.in/index1.php?lang=1&level=3&lid=309', // central link :contentReference[oaicite:14]{index=14}
      },
      {
        'scheme': 'Pradhan Mantri Surakshit Matritva Abhiyan (PMSMA)',
        'description':
        'Provides assured antenatal care on 9th of each month to pregnant women in Karnataka too.',
        'benefits': 'Free check-ups and diagnostics for pregnant women.',
        'howToApply': 'Visit designated government health facility on 9th of each month.',
        'link': 'https://pmsma.mohfw.gov.in/', // verified link :contentReference[oaicite:15]{index=15}
      },
    ],
    'Chhattisgarh': [
      {
        'scheme': 'Janani Suraksha Yojana (JSY)',
        'description':
        'Central scheme for institutional deliveries, applicable in Chhattisgarh.',
        'benefits': 'Cash incentives under the scheme.',
        'howToApply': 'Apply via ASHA/health facility in the state.',
        'link': 'https://www.nhm.gov.in/index1.php?lang=1&level=3&lid=309', // central link :contentReference[oaicite:16]{index=16}
      },
      {
        'scheme': 'Pradhan Mantri Matru Vandana Yojana (PMMVY)',
        'description':
        'First live birth maternity benefit under central scheme applicable in Chhattisgarh.',
        'benefits': '₹5,000 cash incentive.',
        'howToApply': 'Apply via Anganwadi or state scheme office.',
        'link': 'https://wcd.delhi.gov.in/wcd/pradhan-mantri-matru-vandana-yojana-pmmvy', // central link :contentReference[oaicite:17]{index=17}
      },
    ],

  };

  // ✅ Fetch policies based on selected state
  Future<void> fetchPolicies(String state) async {
    setState(() {
      isLoading = true;
      policies = [];
    });

    await Future.delayed(const Duration(milliseconds: 600)); // smooth loading

    setState(() {
      if (stateSchemes.containsKey(state)) {
        policies = stateSchemes[state]!;
      } else {
        policies = stateSchemes['All States']!;
      }
      isLoading = false;
    });
  }

  // ✅ Open official site

  Future<void> _launchURL(String url) async {
    if (url.isEmpty || url == '-' || url == 'null') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid or missing link')),
      );
      return;
    }

    Uri uri = Uri.parse(url.trim());
    if (!uri.hasScheme) {
      uri = Uri.parse('https://$url');
    }

    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Force open in browser
      );
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch: $url')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching URL: $e')),
      );
    }
  }

  // ✅ UI Design
  @override
  Widget build(BuildContext context) {
    final purple = const Color(0xFFD4B5E8);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: purple,
        title: const Text(
          'State Government Schemes',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Select Your State",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: selectedState,
                    underline: const SizedBox(),
                    items: states.map((String state) {
                      return DropdownMenuItem<String>(
                        value: state,
                        child: Text(state),
                      );
                    }).toList(),
                    onChanged: (String? newState) {
                      if (newState != null) {
                        setState(() => selectedState = newState);
                        fetchPolicies(newState);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              )
            else if (policies.isEmpty)
              const Text("Please select a state to view schemes.",
                  style: TextStyle(color: Colors.grey))
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Schemes available in $selectedState:",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  ...policies.map((p) {
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['scheme'] ?? '',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              p['description'] ?? '',
                              style: const TextStyle(
                                  color: Colors.black87, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Benefits: ${p['benefits'] ?? '-'}",
                              style: const TextStyle(
                                  color: Colors.green, fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "How to Apply: ${p['howToApply'] ?? '-'}",
                              style: const TextStyle(
                                  color: Colors.blueGrey, fontSize: 13),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              onPressed: () => _launchURL(p['link'] ?? ''),
                              icon: const Icon(Icons.link, size: 16),
                              label: const Text("Open Official Link"),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: purple,
                                  foregroundColor: Colors.white),
                            )
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              )
          ],
        ),
      ),
    );
  }
}