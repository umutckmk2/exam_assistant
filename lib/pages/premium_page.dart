import 'package:flutter/material.dart';

import '../main.dart';
import '../service/premium_service.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  final PremiumService _premiumService = PremiumService();
  bool _isLoading = false;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _initializePremiumStatus();
  }

  Future<void> _initializePremiumStatus() async {
    setState(() => _isLoading = true);
    await _premiumService.initialize();
    setState(() {
      _isPremium = userNotifier.value?.isPremium ?? false;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _premiumService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium Üyelik')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 48,
                              color: Colors.amber,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isPremium ? 'Premium Üye' : 'Premium\'a Yükselt',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Premium üyelik avantajları:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const ListTile(
                              leading: Icon(Icons.block),
                              title: Text('Reklamsız Deneyim'),
                              subtitle: Text('Tüm reklamları kaldırır'),
                            ),
                            const SizedBox(height: 24),
                            if (!_isPremium)
                              ElevatedButton(
                                onPressed: () async {
                                  setState(() => _isLoading = true);
                                  await _premiumService.purchasePremium();
                                  setState(() => _isLoading = false);
                                },
                                child: const Text('Premium\'a Yükselt'),
                              ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () async {
                                setState(() => _isLoading = true);
                                await _premiumService.restorePurchases();
                                setState(() => _isLoading = false);
                              },
                              child: const Text('Satın Alımları Geri Yükle'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
