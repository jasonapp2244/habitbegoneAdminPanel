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
