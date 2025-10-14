import 'package:habitbegone_admin/test2/widgets/sidebar.dart';
import 'package:habitbegone_admin/test2/widgets/summary_card.dart';
import 'package:habitbegone_admin/test2/widgets/topbar_profile.dart';
import 'package:flutter/material.dart';

class DashboardMobile extends StatelessWidget {
  const DashboardMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(), // Sidebar appears as Drawer on mobile
      appBar: const TopBar(showMenu: true, heading: 'DASHBOARD'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            SummaryCard(title: "Users", value: "1,245", icon: Icons.person),
            SizedBox(height: 12),
            SummaryCard(
              title: "Orders",
              value: "312",
              icon: Icons.shopping_cart,
            ),
            SizedBox(height: 12),
            SummaryCard(
              title: "Revenue",
              value: "\$12,450",
              icon: Icons.attach_money,
            ),
          ],
        ),
      ),
    );
  }
}
