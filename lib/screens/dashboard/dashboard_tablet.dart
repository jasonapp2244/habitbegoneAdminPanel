import 'package:habitbegone_admin/widgets/sidebar.dart';
import 'package:habitbegone_admin/widgets/summary_card.dart';
import 'package:habitbegone_admin/widgets/topbar_profile.dart';
import 'package:flutter/material.dart';

class DashboardTablet extends StatelessWidget {
  const DashboardTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      appBar: const TopBar(showMenu: true, heading: 'DASHBOARD'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: const [
                SummaryCard(title: "Users", value: "1,245", icon: Icons.person),
                SummaryCard(
                  title: "Orders",
                  value: "312",
                  icon: Icons.shopping_cart,
                ),
                SummaryCard(
                  title: "Revenue",
                  value: "\$12,450",
                  icon: Icons.attach_money,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(child: Text("📈 Tablet Chart Area")),
            ),
          ],
        ),
      ),
    );
  }
}
