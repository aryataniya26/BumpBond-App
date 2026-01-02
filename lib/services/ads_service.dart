import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:bump_bond_flutter_app/services/subscription_service.dart';

class AdsService {
  static bool _isInitialized = false;
  static InterstitialAd? _interstitialAd;

  // ==================== YOUR REAL IDs ====================
  static const String _appId = 'ca-app-pub-7028183120969761~9477952651';
  static const String _bannerAdId = 'ca-app-pub-7028183120969761/3328311426';
  static const String _interstitialAdId = 'ca-app-pub-7028183120969761/4386242228';

  // ==================== INITIALIZATION ====================
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      print('🎯 REAL ADS SERVICE READY');
      print('📱 Banner ID: $_bannerAdId');
      print('📱 Interstitial ID: $_interstitialAdId');

      // Load first interstitial
      _loadInterstitialAd();
    } catch (e) {
      print('❌ Initialization error: $e');
    }
  }

  // ==================== CHECK USER PLAN ====================
  static Future<bool> shouldShowAds() async {
    try {
      final currentPlan = await SubscriptionService.getCurrentPlan();
      final shouldShow = currentPlan == 'free';
      print('📊 User Plan: $currentPlan | Show Ads: $shouldShow');
      return shouldShow;
    } catch (e) {
      print('❌ Plan check error: $e');
      return false;
    }
  }

  // ==================== BANNER ADS ====================
  static Future<Widget> getBannerAd() async {
    // Check if free user
    if (!(await shouldShowAds())) {
      return const SizedBox(height: 0);
    }

    await initialize();

    try {
      print('🔄 Loading REAL Banner Ad...');

      final bannerAd = BannerAd(
        size: AdSize.banner,
        adUnitId: _bannerAdId,
        request: const AdRequest(
          keywords: [
            'pregnancy',
            'baby',
            'mother',
            'parenting',
            'health',
            'care',
            'maternity',
            'newborn'
          ],
          contentUrl: 'https://play.google.com/store/apps/details?id=com.example.bump_bond_flutter_app',
          nonPersonalizedAds: false,
        ),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            print('✅ REAL BANNER AD LOADED SUCCESSFULLY!');
            print('💰 Now earning real revenue!');
          },
          onAdFailedToLoad: (ad, error) {
            print('❌ Banner failed: ${error.code} - ${error.message}');

            // Check error type
            if (error.code == 3) {
              print('⚠️ NO_FILL Error - Wait 24 hours for ads to start');
              print('💡 This is normal for new AdMob accounts');
            }

            ad.dispose();
          },
          onAdImpression: (ad) {
            print('📈 Ad impression - Revenue generating!');
          },
          onAdClicked: (ad) {
            print('🖱️ User clicked - Higher revenue!');
          },
        ),
      );

      await bannerAd.load();

      return Container(
        height: AdSize.banner.height.toDouble(),
        width: double.infinity,
        alignment: Alignment.center,
        child: AdWidget(ad: bannerAd),
      );
    } catch (e) {
      print('🔥 Banner loading error: $e');

      // Show temporary placeholder
      return Container(
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple[50]!, Colors.blue[50]!],
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Advertisement Space',
                style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Real ads loading soon...',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  // ==================== INTERSTITIAL ADS ====================
  static void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdId,
      request: const AdRequest(
        keywords: ['pregnancy', 'baby', 'mother'],
        contentUrl: 'https://bumpbond.com',
      ),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          print('✅ REAL INTERSTITIAL AD READY!');
          _setupInterstitialListeners(ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('❌ Interstitial failed: ${error.code}');
          _interstitialAd = null;

          // Retry in 1 minute
          Future.delayed(const Duration(minutes: 1), _loadInterstitialAd);
        },
      ),
    );
  }

  static void _setupInterstitialListeners(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        print('📱 Full-screen ad displayed');
      },
      onAdDismissedFullScreenContent: (ad) {
        print('👋 Ad closed by user');
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('❌ Ad show failed: $error');
        ad.dispose();
        _interstitialAd = null;
        _loadInterstitialAd();
      },
    );
  }

  static Future<void> showInterstitialAd({
    required String screenName,
    bool forceShow = false,
  }) async {
    if (!(await shouldShowAds())) {
      print('👑 Paid user - No ads');
      return;
    }

    if (_interstitialAd == null) {
      print('⚠️ No ad available, loading...');
      _loadInterstitialAd();
      return;
    }

    try {
      print('🎬 Showing interstitial on: $screenName');
      await _interstitialAd!.show();
    } catch (e) {
      print('❌ Error showing ad: $e');
    }
  }

  static void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}

