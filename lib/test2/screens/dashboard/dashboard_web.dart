import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitbegone_admin/test2/widgets/sidebar.dart';
import 'package:habitbegone_admin/test2/widgets/summary_card.dart';
import 'package:habitbegone_admin/test2/widgets/topbar_profile.dart';
import 'package:flutter/material.dart';

class DashboardWeb extends StatefulWidget {
  const DashboardWeb({super.key});

  @override
  State<DashboardWeb> createState() => _DashboardWebState();
}

class _DashboardWebState extends State<DashboardWeb> {
  @override
  Widget build(BuildContext context) {
   

    FirebaseFirestore.instance.collection('users').snapshots();

    Stream<int> userCountStream() {
      return FirebaseFirestore.instance
          .collection('users')
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    }

    return Scaffold(
      body: Row(
        children: [
          // Sidebar always visible on web
          const Sidebar(),
          Expanded(
            child: Column(
              children: [
                const TopBar(showMenu: false, heading: 'DASHBOARD'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: StreamBuilder<int>(
                                stream: userCountStream(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Text(
                                      '👥 Total Registered Users: 0 ',
                                      style: const TextStyle(fontSize: 24),
                                    );
                                  }
                                  return SummaryCard(
                                    title: "Users",
                                    value: '${snapshot.data ?? "no user"}',
                                    icon: Icons.person,
                                  );
                                  // Text(
                                  // '👥 Total Registered Users: ${snapshot.data??"no user"}',
                                  // style: const TextStyle(fontSize: 24),
                                  // );
                                },
                              ),

                              //  SummaryCard(
                              //   title: "Users",
                              //   value: "1,245",
                              //   icon: Icons.person,
                              // ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: SummaryCard(
                                title: "Orders",
                                value: "312",
                                icon: Icons.shopping_cart,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: SummaryCard(
                                title: "Revenue",
                                value: "\$12,450",
                                icon: Icons.attach_money,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Placeholder for charts, tables, etc.
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text("📊 Analytics Chart Area"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
