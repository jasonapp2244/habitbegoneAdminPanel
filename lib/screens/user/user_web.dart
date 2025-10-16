import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:habitbegone_admin/model/app-user_model.dart';
import 'package:habitbegone_admin/screens/user/user_deatils/user_deatail_web.dart';
import 'package:habitbegone_admin/widgets/sidebar.dart';
import 'package:habitbegone_admin/widgets/user_eidt_dialog.dart';

class UsersWeb extends StatefulWidget {
  const UsersWeb({super.key});

  @override
  State<UsersWeb> createState() => _UsersWebState();
}

class _UsersWebState extends State<UsersWeb> {
  final _firestore = FirebaseFirestore.instance;

  List<AppUserModel> allUsers = [];
  late UserDataSource _userDataSource;

  final Set<String> _selectedIds = {};
  final int _rowsPerPage = 5;
  int _currentPage = 0;
  bool isLoading = true;
  String searchQuery = '';
  Timer? _debounce;

  int get totalPages => (filteredUsers.length / _rowsPerPage).ceil();

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();

      final fetchedUsers = snapshot.docs.map((doc) {
        return AppUserModel.fromMap(doc.data(), doc.id);
      }).toList();

      setState(() {
        allUsers = fetchedUsers;
        _userDataSource = UserDataSource(
          users: allUsers,
          selectedIds: _selectedIds,
          onEdit: _editUser,
          onToggle: _toggleUser,
          onSelected: _onSelectChanged,
          context: context,
        );
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching users: $e');
      setState(() => isLoading = false);
    }
  }

  List<AppUserModel> get filteredUsers {
    final q = searchQuery.toLowerCase();
    return allUsers
        .where(
          (u) =>
              u.name.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q),
        )
        .toList();
  }

  void _onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        searchQuery = val;
        _userDataSource.update(filteredUsers);
      });
    });
  }

  void _onSelectChanged(bool selected, String id) {
    setState(() {
      if (selected) {
        _selectedIds.add(id);
      } else {
        _selectedIds.remove(id);
      }
    });
  }

  void _toggleUser(AppUserModel user) {
    setState(() {
      user.isActive = !user.isActive;
      _firestore.collection('users').doc(user.uid).update({
        'isActive': user.isActive,
      });
    });
  }

  void _editUser(AppUserModel user) async {
    final updated = await showDialog<AppUserModel>(
      context: context,
      builder: (_) => UserEditDialog(user: user),
    );
    if (updated != null) {
      setState(() {
        final i = allUsers.indexWhere((u) => u.uid == updated.uid);
        allUsers[i] = updated;
        _firestore.collection('users').doc(updated.uid).update(updated.toMap());
        _userDataSource.update(filteredUsers);
      });
    }
  }

  void _deleteSelected() {
    setState(() async {
      for (var uid in _selectedIds) {
        await _firestore.collection('users').doc(uid).delete();
      }
      allUsers.removeWhere((u) => _selectedIds.contains(u.uid));
      _selectedIds.clear();
      _userDataSource.update(filteredUsers);
    });
  }

  void _exportCSV() {
    List<List<dynamic>> rows = [
      [
        "UID",
        "Name",
        "Email",
        "Paid",
        "Active",
        "Verified",
        "Joined At",
        "Last Login At",
      ],
    ];

    for (var u in filteredUsers) {
      rows.add([
        u.uid,
        u.name,
        u.email,
        u.isPaid,
        u.isActive ? "Yes" : "No",
        u.emailVerified ,
        u.joinedAt?.toString().split(' ').first ?? "",
      ]);
    }

    final csvData = const ListToCsvConverter().convert(rows);
    final bytes = utf8.encode(csvData);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "users_export.csv")
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  void _goToFirstPage() => setState(() => _currentPage = 0);
  void _goToLastPage() => setState(() => _currentPage = totalPages - 1);
  void _goToNextPage() => setState(() {
    if (_currentPage < totalPages - 1) _currentPage++;
  });
  void _goToPreviousPage() => setState(() {
    if (_currentPage > 0) _currentPage--;
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final start = _currentPage * _rowsPerPage;
    final end = start + _rowsPerPage;
    final currentPageUsers = filteredUsers.sublist(
      start,
      end > filteredUsers.length ? filteredUsers.length : end,
    );

    _userDataSource.update(currentPageUsers);

    return Scaffold(
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 3),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "User Management",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: TextField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: "Search...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: _onSearchChanged,
                        ),
                      ),
                    ],
                  ),
                ),

                // Bulk Actions
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _selectedIds.isEmpty
                            ? null
                            : _deleteSelected,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text("Delete"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                        ),
                      ),
                      const SizedBox(width: 20),
                      OutlinedButton.icon(
                        onPressed: _exportCSV,
                        icon: const Icon(Icons.download),
                        label: const Text("Export CSV"),
                      ),
                      const Spacer(),
                      Text("Selected: ${_selectedIds.length}"),
                    ],
                  ),
                ),

                // Data Table
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 3,
                      child: PaginatedDataTable2(
                        source: _userDataSource,
                        columns: const [
                          DataColumn(label: Text("Name")),
                          DataColumn(label: Text("Email")),
                          DataColumn(label: Text("Paid")),
                          DataColumn(label: Text("Active")),
                          DataColumn(label: Text("Verified")),
                          DataColumn(label: Text("Joined At")),
                          DataColumn(label: Text("Last Online At")),
                          DataColumn(label: Text("Actions")),
                        ],
                        rowsPerPage: _rowsPerPage,
                        showCheckboxColumn: true,
                        headingRowColor: WidgetStatePropertyAll(
                          Colors.blue.shade50,
                        ),
                      ),
                    ),
                  ),
                ),

                // Pagination Controls
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _goToFirstPage,
                        icon: const Icon(Icons.first_page),
                      ),
                      IconButton(
                        onPressed: _goToPreviousPage,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text('Page ${_currentPage + 1} of $totalPages'),
                      IconButton(
                        onPressed: _goToNextPage,
                        icon: const Icon(Icons.chevron_right),
                      ),
                      IconButton(
                        onPressed: _goToLastPage,
                        icon: const Icon(Icons.last_page),
                      ),
                    ],
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

class UserDataSource extends DataTableSource {
  List<AppUserModel> users;
  final Set<String> selectedIds;
  final void Function(AppUserModel) onEdit;
  final void Function(AppUserModel) onToggle;
  final void Function(bool, String) onSelected;
  final BuildContext context;

  UserDataSource({
    required this.users,
    required this.selectedIds,
    required this.onEdit,
    required this.onToggle,
    required this.onSelected,
    required this.context,
  });

  void update(List<AppUserModel> newUsers) {
    users = newUsers;
    notifyListeners();
  }

  @override
  DataRow? getRow(int index) {
    if (index >= users.length) return null;
    final user = users[index];
    return DataRow.byIndex(
      index: index,
      selected: selectedIds.contains(user.uid),
      onSelectChanged: (val) {
        if (val != null) onSelected(val, user.uid);
      },
      onLongPress: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserDetailScreen(user: user)),
        );
      },
      cells: [
        DataCell(Text(user.name)),
        DataCell(Text(user.email)),
        DataCell(Text(user.isPaid.toString())),
        DataCell(Text(user.isActive ? "Yes" : "No")),
        DataCell(Text(user.emailVerified ? "Yes" : "No")),
        DataCell(Text(user.joinedAt?.toString().split(' ').first ?? "-")),
        DataCell(Text(user.lastOnline?.toString().split(' ').first ?? "-")),
        DataCell(
          Row(
            children: [
              Switch(value: user.isActive, onChanged: (_) => onToggle(user)),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => onEdit(user),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => users.length;
  @override
  int get selectedRowCount => selectedIds.length;
}
















































// import 'dart:async';
// import 'dart:convert';
// import 'dart:html' as html;

// import 'package:habitbegone_admin/test2/model/user_model.dart';
// import 'package:habitbegone_admin/test2/screens/user/user_deatils/user_deatail_web.dart';
// import 'package:habitbegone_admin/test2/widgets/sidebar.dart';
// import 'package:habitbegone_admin/test2/widgets/user_eidt_dialog.dart';
// import 'package:data_table_2/data_table_2.dart';
// import 'package:flutter/material.dart';
// import 'package:csv/csv.dart';

// class UsersWeb extends StatefulWidget {
//   const UsersWeb({super.key});

//   @override
//   State<UsersWeb> createState() => _UsersWebState();
// }

// class _UsersWebState extends State<UsersWeb> {
//   List<AppUserModel> allUsers = [
//     AppUserModel(
//       id: "1",
//       name: "Alice Johnson",
//       email: "alice@example.com",
//       role: "Admin",
//       isActive: true,
//     ),
//     AppUserModel(
//       id: "2",
//       name: "Bob Smith",
//       email: "bob@example.com",
//       role: "Editor",
//       isActive: false,
//     ),
//     AppUserModel(
//       id: "3",
//       name: "Carla Gomez",
//       email: "carla@example.com",
//       role: "Manager",
//       isActive: true,
//     ),
//     AppUserModel(
//       id: "4",
//       name: "David Lee",
//       email: "david@example.com",
//       role: "Viewer",
//       isActive: true,
//     ),
//     AppUserModel(
//       id: "5",
//       name: "Evelyn Wu",
//       email: "evelyn@example.com",
//       role: "Admin",
//       isActive: false,
//     ),
//     AppUserModel(
//       id: "6",
//       name: "Frank Carter",
//       email: "frank@example.com",
//       role: "Editor",
//       isActive: true,
//     ),
//     AppUserModel(
//       id: "7",
//       name: "Grace Kim",
//       email: "grace@example.com",
//       role: "Manager",
//       isActive: true,
//     ),
//     AppUserModel(
//       id: "8",
//       name: "Henry Park",
//       email: "henry@example.com",
//       role: "Viewer",
//       isActive: false,
//     ),
//   ];

//   final Set<String> _selectedIds = {};
//   late UserDataSource _userDataSource;

//   final int _rowsPerPage = 5;
//   int _currentPage = 0;
//   int get totalPages => (filteredUsers.length / _rowsPerPage).ceil();

//   String searchQuery = '';
//   Timer? _debounce;

//   @override
//   void initState() {
//     super.initState();
//     _userDataSource = UserDataSource(
//       users: allUsers,
//       selectedIds: _selectedIds,
//       onEdit: _editUser,
//       onToggle: _toggleUser,
//       onSelected: _onSelectChanged,
//       context: context, // 👈 pass context
//     );
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     super.dispose();
//   }

//   List<AppUserModel> get filteredUsers {
//     final q = searchQuery.toLowerCase();
//     return allUsers
//         .where(
//           (u) =>
//               u.name.toLowerCase().contains(q) ||
//               u.email.toLowerCase().contains(q) ||
//               u.role.toLowerCase().contains(q),
//         )
//         .toList();
//   }

//   void _onSearchChanged(String val) {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     _debounce = Timer(const Duration(milliseconds: 300), () {
//       setState(() {
//         searchQuery = val;
//         _userDataSource.update(filteredUsers);
//       });
//     });
//   }

//   void _onSelectChanged(bool selected, String id) {
//     setState(() {
//       if (selected) {
//         _selectedIds.add(id);
//       } else {
//         _selectedIds.remove(id);
//       }
//     });
//   }

//   void _toggleUser(AppUserModel user) {
//     setState(() => user.isActive = !user.isActive);
//   }

//   void _editUser(AppUserModel user) async {
//     final updated = await showDialog<AppUserModel>(
//       context: context,
//       builder: (_) => UserEditDialog(user: user),
//     );
//     if (updated != null) {
//       setState(() {
//         final i = allUsers.indexWhere((u) => u.id == updated.id);
//         allUsers[i] = updated;
//         _userDataSource.update(filteredUsers);
//       });
//     }
//   }

//   void _activateSelected() {
//     setState(() {
//       for (var u in allUsers) {
//         if (_selectedIds.contains(u.id)) u.isActive = true;
//       }
//       _userDataSource.update(filteredUsers);
//     });
//   }

//   void _deactivateSelected() {
//     setState(() {
//       for (var u in allUsers) {
//         if (_selectedIds.contains(u.id)) u.isActive = false;
//       }
//       _userDataSource.update(filteredUsers);
//     });
//   }

//   void _deleteSelected() {
//     setState(() {
//       allUsers.removeWhere((u) => _selectedIds.contains(u.id));
//       _selectedIds.clear();
//       _userDataSource.update(filteredUsers);
//     });
//   }

//   void _exportCSV() {
//     List<List<dynamic>> rows = [
//       ["ID", "Name", "Email", "Role", "Status"],
//     ];

//     for (var u in filteredUsers) {
//       rows.add([
//         u.id,
//         u.name,
//         u.email,
//         u.role,
//         u.isActive ? "Active" : "Inactive",
//       ]);
//     }

//     final csvData = const ListToCsvConverter().convert(rows);
//     final bytes = utf8.encode(csvData);
//     final blob = html.Blob([bytes]);
//     final url = html.Url.createObjectUrlFromBlob(blob);

//     final anchor = html.AnchorElement(href: url)
//       ..setAttribute("download", "users_export.csv")
//       ..click();

//     html.Url.revokeObjectUrl(url);
//   }

//   void _goToFirstPage() => setState(() => _currentPage = 0);
//   void _goToLastPage() => setState(() => _currentPage = totalPages - 1);
//   void _goToNextPage() => setState(() {
//     if (_currentPage < totalPages - 1) _currentPage++;
//   });
//   void _goToPreviousPage() => setState(() {
//     if (_currentPage > 0) _currentPage--;
//   });

//   @override
//   Widget build(BuildContext context) {
//     final start = _currentPage * _rowsPerPage;
//     final end = start + _rowsPerPage;
//     final currentPageUsers = filteredUsers.sublist(
//       start,
//       end > filteredUsers.length ? filteredUsers.length : end,
//     );

//     _userDataSource.update(currentPageUsers);

//     return Scaffold(
//       body: Row(
//         children: [
//           Sidebar(),

//           Expanded(
//             child: Column(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(color: Colors.black12, blurRadius: 3),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         "User Management",
//                         style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(
//                         width: 300,
//                         child: TextField(
//                           decoration: InputDecoration(
//                             prefixIcon: const Icon(Icons.search),
//                             hintText: "Search...",
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           onChanged: _onSearchChanged,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Bulk action bar
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Row(
//                     children: [
//                       ElevatedButton.icon(
//                         onPressed: _selectedIds.isEmpty
//                             ? null
//                             : _activateSelected,
//                         icon: const Icon(Icons.check_circle_outline),
//                         label: const Text("Activate"),
//                       ),
//                       const SizedBox(width: 10),
//                       ElevatedButton.icon(
//                         onPressed: _selectedIds.isEmpty
//                             ? null
//                             : _deactivateSelected,
//                         icon: const Icon(Icons.cancel_outlined),
//                         label: const Text("Deactivate"),
//                       ),
//                       const SizedBox(width: 10),
//                       ElevatedButton.icon(
//                         onPressed: _selectedIds.isEmpty
//                             ? null
//                             : _deleteSelected,
//                         icon: const Icon(Icons.delete_outline),
//                         label: const Text("Delete"),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red.shade600,
//                         ),
//                       ),
//                       const SizedBox(width: 20),
//                       OutlinedButton.icon(
//                         onPressed: _exportCSV,
//                         icon: const Icon(Icons.download),
//                         label: const Text("Export CSV"),
//                       ),
//                       const Spacer(),
//                       Text("Selected: ${_selectedIds.length}"),
//                     ],
//                   ),
//                 ),

//                 // Data Table
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Card(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(16),
//                       ),
//                       elevation: 3,
//                       child: PaginatedDataTable2(
//                         source: _userDataSource,
//                         columns: const [
//                           DataColumn(label: Text("Name")),
//                           DataColumn(label: Text("Email")),
//                           DataColumn(label: Text("Role")),
//                           DataColumn(label: Text("Status")),
//                           DataColumn(label: Text("Actions")),
//                         ],
//                         rowsPerPage: _rowsPerPage,
//                         showCheckboxColumn: true,
//                         headingRowColor: WidgetStatePropertyAll(
//                           Colors.blue.shade50,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),

//                 // Pagination Controls
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 24),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       IconButton(
//                         onPressed: _goToFirstPage,
//                         icon: const Icon(Icons.first_page),
//                       ),
//                       IconButton(
//                         onPressed: _goToPreviousPage,
//                         icon: const Icon(Icons.chevron_left),
//                       ),
//                       Text('Page ${_currentPage + 1} of $totalPages'),
//                       IconButton(
//                         onPressed: _goToNextPage,
//                         icon: const Icon(Icons.chevron_right),
//                       ),
//                       IconButton(
//                         onPressed: _goToLastPage,
//                         icon: const Icon(Icons.last_page),
//                       ),
//                       const SizedBox(width: 16),
//                       SizedBox(
//                         width: 60,
//                         child: TextField(
//                           textAlign: TextAlign.center,
//                           decoration: const InputDecoration(
//                             hintText: "Go",
//                             isDense: true,
//                             contentPadding: EdgeInsets.symmetric(vertical: 6),
//                           ),
//                           onSubmitted: (val) {
//                             final page = int.tryParse(val);
//                             if (page != null &&
//                                 page > 0 &&
//                                 page <= totalPages) {
//                               setState(() => _currentPage = page - 1);
//                             }
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class UserDataSource extends DataTableSource {
//   List<AppUserModel> users;
//   final Set<String> selectedIds;
//   final void Function(AppUserModel) onEdit;
//   final void Function(AppUserModel) onToggle;
//   final void Function(bool, String) onSelected;
//   final BuildContext context; // 👈 add this

//   UserDataSource({
//     required this.users,
//     required this.selectedIds,
//     required this.onEdit,
//     required this.onToggle,
//     required this.onSelected,
//     required this.context, // 👈 add this
//   });

//   void update(List<AppUserModel> newUsers) {
//     users = newUsers;
//     notifyListeners();
//   }

//   @override
//   DataRow? getRow(int index) {
//     if (index >= users.length) return null;
//     final user = users[index];
//     return DataRow.byIndex(
//       index: index,
//       selected: selectedIds.contains(user.id),
//       onSelectChanged: (val) {
//         if (val != null) onSelected(val, user.id);
//       },
//       // onLongPress: () {}, // optional for long-press features later
//       onLongPress: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => UserDetailScreen(user: user)),
//         );
//       }, // 👈 open user detail screen on double-click / tap
//       cells: [
//         DataCell(Text(user.name)),
//         DataCell(Text(user.email)),
//         DataCell(Text(user.role)),
//         DataCell(
//           Text(
//             user.isActive ? "Active" : "Inactive",
//             style: TextStyle(
//               color: user.isActive ? Colors.green : Colors.red,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//         DataCell(
//           Row(
//             children: [
//               Switch(value: user.isActive, onChanged: (_) => onToggle(user)),
//               IconButton(
//                 icon: const Icon(Icons.edit, color: Colors.blue),
//                 onPressed: () => onEdit(user),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   // @override
//   // DataRow? getRow(int index) {
//   //   if (index >= users.length) return null;
//   //   final user = users[index];
//   //   return
//   //   DataRow.byIndex(
//   //     index: index,
//   //     selected: selectedIds.contains(user.id),
//   //     onSelectChanged: (val) {
//   //       if (val != null) onSelected(val, user.id);
//   //     },
//   //     cells: [
//   //       DataCell(Text(user.name)),
//   //       DataCell(Text(user.email)),
//   //       DataCell(Text(user.role)),
//   //       DataCell(
//   //         Text(
//   //           user.isActive ? "Active" : "Inactive",
//   //           style: TextStyle(
//   //             color: user.isActive ? Colors.green : Colors.red,
//   //             fontWeight: FontWeight.bold,
//   //           ),
//   //         ),
//   //       ),
//   //       DataCell(Row(
//   //         children: [
//   //           Switch(
//   //             value: user.isActive,
//   //             onChanged: (_) => onToggle(user),
//   //           ),
//   //           IconButton(
//   //             icon: const Icon(Icons.edit, color: Colors.blue),
//   //             onPressed: () => onEdit(user),
//   //           ),
//   //         ],
//   //       )),
//   //     ],
//   //   );
//   // }

//   @override
//   bool get isRowCountApproximate => false;

//   @override
//   int get rowCount => users.length;

//   @override
//   int get selectedRowCount => selectedIds.length;
// }

// // import 'dart:async';
// // import 'package:habitbegone_admin/test2/model/data/user_data_source.dart';
// // import 'package:habitbegone_admin/test2/model/user_model.dart';
// // import 'package:habitbegone_admin/test2/widgets/user_eidt_dialog.dart';
// // import 'package:flutter/material.dart';
// // import 'package:data_table_2/data_table_2.dart';

// // class UsersWeb extends StatefulWidget {
// //   const UsersWeb({super.key});
// //   @override
// //   State<UsersWeb> createState() => _UsersWebState();
// // }

// // class _UsersWebState extends State<UsersWeb> {
// //   // Master list of users (in real app, fetched from backend)
// //   List<AppUserModel> allUsers = [
// //     AppUserModel(
// //       id: "1",
// //       name: "Alice Johnson",
// //       email: "alice@example.com",
// //       role: "Admin",
// //       isActive: true,
// //     ),
// //     AppUserModel(
// //       id: "2",
// //       name: "Bob Smith",
// //       email: "bob@example.com",
// //       role: "Editor",
// //       isActive: false,
// //     ),
// //     AppUserModel(
// //       id: "3",
// //       name: "Carla Gomez",
// //       email: "carla@example.com",
// //       role: "Manager",
// //       isActive: true,
// //     ),
// //     AppUserModel(
// //       id: "4",
// //       name: "David Lee",
// //       email: "david@example.com",
// //       role: "Viewer",
// //       isActive: true,
// //     ),
// //     AppUserModel(
// //       id: "5",
// //       name: "Evelyn Wu",
// //       email: "evelyn@example.com",
// //       role: "Admin",
// //       isActive: false,
// //     ),
// //     AppUserModel(
// //       id: "1",
// //       name: "Alice Johnson",
// //       email: "alice@example.com",
// //       role: "Admin",
// //       isActive: true,
// //     ),
// //     AppUserModel(
// //       id: "2",
// //       name: "Bob Smith",
// //       email: "bob@example.com",
// //       role: "Editor",
// //       isActive: false,
// //     ),
// //     AppUserModel(
// //       id: "3",
// //       name: "Carla Gomez",
// //       email: "carla@example.com",
// //       role: "Manager",
// //       isActive: true,
// //     ),
// //     AppUserModel(
// //       id: "4",
// //       name: "David Lee",
// //       email: "david@example.com",
// //       role: "Viewer",
// //       isActive: true,
// //     ),
// //     AppUserModel(
// //       id: "5",
// //       name: "Evelyn Wu",
// //       email: "evelyn@example.com",
// //       role: "Admin",
// //       isActive: false,
// //     ),
// //     AppUserModel(
// //       id: "1",
// //       name: "Alice Johnson",
// //       email: "alice@example.com",
// //       role: "Admin",
// //       isActive: true,
// //     ),
// //     AppUserModel(
// //       id: "2",
// //       name: "Bob Smith",
// //       email: "bob@example.com",
// //       role: "Editor",
// //       isActive: false,
// //     ),
// //     AppUserModel(
// //       id: "3",
// //       name: "Carla Gomez",
// //       email: "carla@example.com",
// //       role: "Manager",
// //       isActive: true,
// //     ),
// //     AppUserModel(
// //       id: "4",
// //       name: "David Lee",
// //       email: "david@example.com",
// //       role: "Viewer",
// //       isActive: true,
// //     ),
// //     AppUserModel(
// //       id: "5",
// //       name: "Evelyn Wu",
// //       email: "evelyn@example.com",
// //       role: "Admin",
// //       isActive: false,
// //     ),
// //     // (You can add more to test multiple pages)
// //   ];

// //   String _searchQuery = "";
// //   Timer? _debounce;

// //   // Sort state
// //   int? _sortColumnIndex;
// //   bool _sortAscending = true;

// //   // Selected items
// //   final Set<String> _selectedIds = {};

// //   late UserDataSource _userDataSource;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _userDataSource = UserDataSource(
// //       allUsers: allUsers,
// //       onEdit: _editUser,
// //       onToggle: _toggleStatus,
// //       selectedIds: _selectedIds,
// //       onSelectedChanged: _onRowSelectChanged,
// //     );
// //   }

// //   @override
// //   void dispose() {
// //     _debounce?.cancel();
// //     super.dispose();
// //   }

// //   void _onSearchChanged(String value) {
// //     if (_debounce?.isActive ?? false) {
// //       _debounce!.cancel();
// //     }
// //     _debounce = Timer(const Duration(milliseconds: 300), () {
// //       setState(() {
// //         _searchQuery = value;
// //         _userDataSource.filter(_searchQuery);
// //       });
// //     });
// //   }

// //   void _sort<T>(
// //     Comparable<T> Function(AppUserModel u) getField,
// //     int columnIndex,
// //     bool ascending,
// //   ) {
// //     _userDataSource.sort<T>(getField, ascending);
// //     setState(() {
// //       _sortColumnIndex = columnIndex;
// //       _sortAscending = ascending;
// //     });
// //   }

// //   void _toggleStatus(AppUserModel user) {
// //     setState(() {
// //       user.isActive = !user.isActive;
// //     });
// //   }

// //   void _editUser(AppUserModel user) async {
// //     final updated = await showDialog<AppUserModel>(
// //       context: context,
// //       builder: (_) => UserEditDialog(user: user),
// //     );
// //     if (updated != null) {
// //       setState(() {
// //         final index = allUsers.indexWhere((u) => u.id == updated.id);
// //         if (index != -1) {
// //           allUsers[index] = updated;
// //           _userDataSource.refresh();
// //         }
// //       });
// //     }
// //   }

// //   void _onRowSelectChanged(bool selected, String id) {
// //     setState(() {
// //       if (selected) {
// //         _selectedIds.add(id);
// //       } else {
// //         _selectedIds.remove(id);
// //       }
// //     });
// //   }

// //   void _activateSelected() {
// //     setState(() {
// //       for (var u in allUsers) {
// //         if (_selectedIds.contains(u.id)) {
// //           u.isActive = true;
// //         }
// //       }
// //       _userDataSource.refresh();
// //     });
// //   }

// //   void _deactivateSelected() {
// //     setState(() {
// //       for (var u in allUsers) {
// //         if (_selectedIds.contains(u.id)) {
// //           u.isActive = false;
// //         }
// //       }
// //       _userDataSource.refresh();
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Row(
// //         children: [
// //           // Sidebar placeholder (replace with your Sidebar widget)
// //           Container(
// //             width: 220,
// //             color: Colors.blueGrey.shade50,
// //             child: const Center(child: Text("Sidebar")),
// //           ),
// //           Expanded(
// //             child: Column(
// //               children: [
// //                 // Top Bar
// //                 Container(
// //                   padding: const EdgeInsets.symmetric(
// //                     horizontal: 24,
// //                     vertical: 16,
// //                   ),
// //                   decoration: BoxDecoration(
// //                     color: Theme.of(context).colorScheme.surface,
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: Colors.black12,
// //                         blurRadius: 4,
// //                         offset: const Offset(0, 2),
// //                       ),
// //                     ],
// //                   ),
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       const Text(
// //                         "User Management",
// //                         style: TextStyle(
// //                           fontSize: 22,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                       SizedBox(
// //                         width: 300,
// //                         child: TextField(
// //                           decoration: InputDecoration(
// //                             hintText: "Search users...",
// //                             prefixIcon: const Icon(Icons.search),
// //                             border: OutlineInputBorder(
// //                               borderRadius: BorderRadius.circular(12),
// //                             ),
// //                           ),
// //                           onChanged: _onSearchChanged,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),

// //                 // Bulk action buttons
// //                 Padding(
// //                   padding: const EdgeInsets.all(16.0),
// //                   child: Row(
// //                     children: [
// //                       ElevatedButton(
// //                         onPressed: _selectedIds.isEmpty
// //                             ? null
// //                             : _activateSelected,
// //                         child: const Text("Activate Selected"),
// //                       ),
// //                       const SizedBox(width: 16),
// //                       ElevatedButton(
// //                         onPressed: _selectedIds.isEmpty
// //                             ? null
// //                             : _deactivateSelected,
// //                         child: const Text("Deactivate Selected"),
// //                       ),
// //                       const SizedBox(width: 24),
// //                       Text("Selected: ${_selectedIds.length}"),
// //                     ],
// //                   ),
// //                 ),

// //                 // The PaginatedDataTable2
// //                 Expanded(
// //                   child: Padding(
// //                     padding: const EdgeInsets.symmetric(horizontal: 16),
// //                     child: Card(
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(16),
// //                       ),
// //                       elevation: 3,
// //                       child: Padding(
// //                         padding: const EdgeInsets.all(16),
// //                         child: PaginatedDataTable2(
// //                           header: Text(
// //                             "Total Users: ${_userDataSource.filteredCount}",
// //                           ),
// //                           columns: [
// //                             DataColumn2(
// //                               label: const Text("Name"),
// //                               onSort: (ci, asc) =>
// //                                   _sort<String>((u) => u.name, ci, asc),
// //                             ),
// //                             DataColumn2(
// //                               label: const Text("Email"),
// //                               onSort: (ci, asc) =>
// //                                   _sort<String>((u) => u.email, ci, asc),
// //                             ),
// //                             DataColumn2(
// //                               label: const Text("Role"),
// //                               onSort: (ci, asc) =>
// //                                   _sort<String>((u) => u.role, ci, asc),
// //                             ),
// //                             DataColumn2(label: const Text("Status")),
// //                             DataColumn2(label: const Text("Actions")),
// //                           ],
// //                           source: _userDataSource,
// //                           sortColumnIndex: _sortColumnIndex,
// //                           sortAscending: _sortAscending,
// //                           showCheckboxColumn: true,
// //                           rowsPerPage: 5,
// //                           availableRowsPerPage: const [5, 10, 20],
// //                           onRowsPerPageChanged: (v) {
// //                             setState(() {
// //                               _userDataSource.rowsPerPage = v!;
// //                             });
// //                           },
// //                           // optional: control paginator externally via controller
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // import 'package:habitbegone_admin/test2/model/user_model.dart';
// // // import 'package:habitbegone_admin/test2/widgets/sidebar.dart';
// // // import 'package:habitbegone_admin/test2/widgets/user_eidt_dialog.dart';
// // // import 'package:flutter/material.dart';

// // // class UsersWeb extends StatefulWidget {
// // //   const UsersWeb({super.key});

// // //   @override
// // //   State<UsersWeb> createState() => _UsersWebState();
// // // }

// // // class _UsersWebState extends State<UsersWeb> {
// // //   List<AppUserModel> users = [
// // //     AppUserModel(
// // //       id: "1",
// // //       name: "Alice Johnson",
// // //       email: "alice@example.com",
// // //       role: "Admin",
// // //       isActive: true,
// // //     ),
// // //     AppUserModel(
// // //       id: "2",
// // //       name: "Bob Smith",
// // //       email: "bob@example.com",
// // //       role: "Editor",
// // //       isActive: false,
// // //     ),
// // //     AppUserModel(
// // //       id: "3",
// // //       name: "Carla Gomez",
// // //       email: "carla@example.com",
// // //       role: "Manager",
// // //       isActive: true,
// // //     ),
// // //     AppUserModel(
// // //       id: "4",
// // //       name: "David Lee",
// // //       email: "david@example.com",
// // //       role: "Viewer",
// // //       isActive: true,
// // //     ),
// // //     AppUserModel(
// // //       id: "5",
// // //       name: "Evelyn Wu",
// // //       email: "evelyn@example.com",
// // //       role: "Admin",
// // //       isActive: false,
// // //     ),
// // //     AppUserModel(
// // //       id: "1",
// // //       name: "Alice Johnson",
// // //       email: "alice@example.com",
// // //       role: "Admin",
// // //       isActive: true,
// // //     ),
// // //     AppUserModel(
// // //       id: "2",
// // //       name: "Bob Smith",
// // //       email: "bob@example.com",
// // //       role: "Editor",
// // //       isActive: false,
// // //     ),
// // //     AppUserModel(
// // //       id: "3",
// // //       name: "Carla Gomez",
// // //       email: "carla@example.com",
// // //       role: "Manager",
// // //       isActive: true,
// // //     ),
// // //     AppUserModel(
// // //       id: "4",
// // //       name: "David Lee",
// // //       email: "david@example.com",
// // //       role: "Viewer",
// // //       isActive: true,
// // //     ),
// // //     AppUserModel(
// // //       id: "5",
// // //       name: "Evelyn Wu",
// // //       email: "evelyn@example.com",
// // //       role: "Admin",
// // //       isActive: false,
// // //     ),
// // //     AppUserModel(
// // //       id: "1",
// // //       name: "Alice Johnson",
// // //       email: "alice@example.com",
// // //       role: "Admin",
// // //       isActive: true,
// // //     ),
// // //     AppUserModel(
// // //       id: "2",
// // //       name: "Bob Smith",
// // //       email: "bob@example.com",
// // //       role: "Editor",
// // //       isActive: false,
// // //     ),
// // //     AppUserModel(
// // //       id: "3",
// // //       name: "Carla Gomez",
// // //       email: "carla@example.com",
// // //       role: "Manager",
// // //       isActive: true,
// // //     ),
// // //     AppUserModel(
// // //       id: "4",
// // //       name: "David Lee",
// // //       email: "david@example.com",
// // //       role: "Viewer",
// // //       isActive: true,
// // //     ),
// // //     AppUserModel(
// // //       id: "5",
// // //       name: "Evelyn Wu",
// // //       email: "evelyn@example.com",
// // //       role: "Admin",
// // //       isActive: false,
// // //     ),
// // //   ];

// // //   String searchQuery = "";
// // //   bool sortAsc = true;

// // //   List<AppUserModel> get filteredUsers {
// // //     final query = searchQuery.toLowerCase();
// // //     return users
// // //         .where(
// // //           (u) =>
// // //               u.name.toLowerCase().contains(query) ||
// // //               u.email.toLowerCase().contains(query),
// // //         )
// // //         .toList();
// // //   }

// // //   void toggleStatus(AppUserModel user) {
// // //     setState(() {
// // //       user.isActive = !user.isActive;
// // //     });
// // //   }

// // //   void editUser(AppUserModel user) async {
// // //     final updatedUser = await showDialog<AppUserModel>(
// // //       context: context,
// // //       builder: (_) => UserEditDialog(user: user),
// // //     );

// // //     if (updatedUser != null) {
// // //       setState(() {
// // //         final index = users.indexWhere((u) => u.id == updatedUser.id);
// // //         users[index] = updatedUser;
// // //       });
// // //     }
// // //   }

// // //   void sortByName() {
// // //     setState(() {
// // //       sortAsc = !sortAsc;
// // //       users.sort(
// // //         (a, b) => sortAsc ? a.name.compareTo(b.name) : b.name.compareTo(a.name),
// // //       );
// // //     });
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       body: Row(
// // //         children: [
// // //           // Example sidebar placeholder — replace with your real sidebar if needed
// // //           Sidebar(),
// // //           Expanded(
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 // Top bar
// // //                 Container(
// // //                   padding: const EdgeInsets.symmetric(
// // //                     horizontal: 24,
// // //                     vertical: 16,
// // //                   ),
// // //                   decoration: BoxDecoration(
// // //                     color: Theme.of(context).colorScheme.surface,
// // //                     boxShadow: [
// // //                       BoxShadow(
// // //                         color: Colors.black12,
// // //                         blurRadius: 4,
// // //                         offset: const Offset(0, 2),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                   child: Row(
// // //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                     children: [
// // //                       const Text(
// // //                         "User Management",
// // //                         style: TextStyle(
// // //                           fontSize: 22,
// // //                           fontWeight: FontWeight.bold,
// // //                         ),
// // //                       ),
// // //                       SizedBox(
// // //                         width: 300,
// // //                         child: TextField(
// // //                           decoration: InputDecoration(
// // //                             hintText: "Search user...",
// // //                             prefixIcon: const Icon(Icons.search),
// // //                             border: OutlineInputBorder(
// // //                               borderRadius: BorderRadius.circular(12),
// // //                             ),
// // //                           ),
// // //                           onChanged: (val) => setState(() => searchQuery = val),
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),

// // //                 // Main content
// // //                 Expanded(
// // //                   child: Padding(
// // //                     padding: const EdgeInsets.all(24),
// // //                     child: Card(
// // //                       shape: RoundedRectangleBorder(
// // //                         borderRadius: BorderRadius.circular(16),
// // //                       ),
// // //                       elevation: 3,
// // //                       child: Padding(
// // //                         padding: const EdgeInsets.all(16),
// // //                         child: Column(
// // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // //                           children: [
// // //                             Row(
// // //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                               children: [
// // //                                 Text(
// // //                                   "Total Users: ${filteredUsers.length}",
// // //                                   style: const TextStyle(
// // //                                     fontWeight: FontWeight.bold,
// // //                                     fontSize: 18,
// // //                                   ),
// // //                                 ),
// // //                                 TextButton.icon(
// // //                                   onPressed: sortByName,
// // //                                   icon: Icon(
// // //                                     sortAsc
// // //                                         ? Icons.arrow_downward
// // //                                         : Icons.arrow_upward,
// // //                                   ),
// // //                                   label: const Text("Sort by Name"),
// // //                                 ),
// // //                               ],
// // //                             ),
// // //                             const SizedBox(height: 16),

// // //                             Expanded(
// // //                               child: SingleChildScrollView(
// // //                                 scrollDirection: Axis.vertical,
// // //                                 child: DataTable(
// // //                                   border: TableBorder.all(
// // //                                     color: Colors.black12,
// // //                                   ),
// // //                                   headingRowColor: WidgetStatePropertyAll(
// // //                                     Colors.blue.shade50,
// // //                                   ),
// // //                                   columns: const [
// // //                                     DataColumn(label: Text("Name")),
// // //                                     DataColumn(label: Text("Email")),
// // //                                     DataColumn(label: Text("Role")),
// // //                                     DataColumn(label: Text("Status")),
// // //                                     DataColumn(label: Text("Actions")),
// // //                                   ],
// // //                                   rows: filteredUsers.map((user) {
// // //                                     return DataRow(
// // //                                       cells: [
// // //                                         DataCell(Text(user.name)),
// // //                                         DataCell(Text(user.email)),
// // //                                         DataCell(Text(user.role)),
// // //                                         DataCell(
// // //                                           Container(
// // //                                             padding: const EdgeInsets.symmetric(
// // //                                               horizontal: 8,
// // //                                               vertical: 4,
// // //                                             ),
// // //                                             decoration: BoxDecoration(
// // //                                               color: user.isActive
// // //                                                   ? Colors.green.withOpacity(
// // //                                                       0.2,
// // //                                                     )
// // //                                                   : Colors.red.withOpacity(0.2),
// // //                                               borderRadius:
// // //                                                   BorderRadius.circular(8),
// // //                                             ),
// // //                                             child: Text(
// // //                                               user.isActive
// // //                                                   ? "Active"
// // //                                                   : "Inactive",
// // //                                               style: TextStyle(
// // //                                                 color: user.isActive
// // //                                                     ? Colors.green
// // //                                                     : Colors.red,
// // //                                                 fontWeight: FontWeight.bold,
// // //                                               ),
// // //                                             ),
// // //                                           ),
// // //                                         ),
// // //                                         DataCell(
// // //                                           Row(
// // //                                             children: [
// // //                                               Switch(
// // //                                                 value: user.isActive,
// // //                                                 onChanged: (_) =>
// // //                                                     toggleStatus(user),
// // //                                               ),
// // //                                               IconButton(
// // //                                                 icon: const Icon(
// // //                                                   Icons.edit,
// // //                                                   color: Colors.blue,
// // //                                                 ),
// // //                                                 onPressed: () => editUser(user),
// // //                                               ),
// // //                                             ],
// // //                                           ),
// // //                                         ),
// // //                                       ],
// // //                                     );
// // //                                   }).toList(),
// // //                                 ),
// // //                               ),
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
