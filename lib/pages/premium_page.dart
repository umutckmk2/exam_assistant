import 'package:flutter/material.dart';

import '../main.dart';
import '../service/generation_limit_service.dart';
import '../service/premium_service.dart';
import '../widgets/premium_banner_widget.dart';
import '../widgets/premium_usage_card.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  final PremiumService _premiumService = PremiumService();
  final GenerationLimitService _generationService =
      GenerationLimitService.instance;
  bool _isLoading = false;
  bool _isPremium = false;
  int _remainingGenerations = 0;
  static const int _totalGenerations = GenerationLimitService.premiumDailyLimit;

  @override
  void initState() {
    super.initState();
    _initializePremiumStatus();
  }

  Future<void> _initializePremiumStatus() async {
    if (mounted) setState(() => _isLoading = true);
    await _premiumService.initialize();
    final userId = userNotifier.value?.id;
    if (userId != null) {
      final remaining = await _generationService.getRemainingGenerations(
        userId,
      );
      _remainingGenerations = remaining;
      if (mounted) setState(() {});
    }
    _isPremium = userNotifier.value?.isPremium ?? false;
    _isLoading = false;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _premiumService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: DhAppBar(title: const Text('Premium Üyelik'), elevation: 0),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isPremium) ...[
                      PremiumUsageCard(
                        remainingGenerations: _remainingGenerations,
                        totalGenerations: _totalGenerations,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            setState(() => _isLoading = true);
                            await _premiumService.restorePurchases();
                            setState(() => _isLoading = false);
                          },
                          icon: const Icon(Icons.restore),
                          label: const Text('Satın Alımları Geri Yükle'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor),
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, primaryColor.withAlpha(200)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 64,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Premium'a Yükselt",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Daha fazla özellik için şimdi yükseltin',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () async {
                                setState(() => _isLoading = true);
                                await _premiumService.purchasePremium();
                                setState(() => _isLoading = false);
                              },
                              icon: Icon(Icons.star, color: primaryColor),
                              label: const Text("Premium'a Yükselt"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Premium Özellikleri',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        padding: const EdgeInsets.all(16),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        children: [
                          _buildFeatureCard(
                            icon: Icons.auto_awesome,
                            title: 'Günlük 50 AI\nÜretimi',
                            subtitle:
                                'Daha fazla soru ve\nkonu özeti oluşturun',
                            color: primaryColor,
                          ),
                          _buildFeatureCard(
                            icon: Icons.block,
                            title: 'Reklamsız\nDeneyim',
                            subtitle: 'Kesintisiz öğrenme\ndeneyimi',
                            color: primaryColor,
                          ),
                          _buildFeatureCard(
                            icon: Icons.speed,
                            title: 'Öncelikli İşlem',
                            subtitle: 'Daha hızlı AI yanıtları',
                            color: primaryColor,
                          ),
                          _buildFeatureCard(
                            icon: Icons.analytics,
                            title: 'Gelişmiş\nİstatistikler',
                            subtitle: 'Detaylı öğrenme\nanalizi',
                            color: primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withAlpha(50), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
