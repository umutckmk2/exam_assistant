import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../model/kpss_user.dart';
import '../service/auth_service.dart';
import '../service/kpss_user_service.dart';

class MyAccountPage extends StatelessWidget {
  const MyAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = AuthService().currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Hesabım'),
      ),
      body: FutureBuilder<KpssUser?>(
        future: KpssUserService.instance.getUser(userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final user = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Çözülen Soru Sayısı: ${user.solvedQuestionIds.length}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.go('/');
                      AuthService().signOut();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Çıkış Yap'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
