import 'package:habitbegone_admin/test2/model/app-user_model.dart';
import 'package:flutter/material.dart';

class UserDataSource extends DataTableSource {
  final List<AppUserModel> allUsers;
  final void Function(AppUserModel) onEdit;
  final void Function(AppUserModel) onToggle;
  final Set<String> selectedIds;
  final void Function(bool, String) onSelectedChanged;

  List<AppUserModel> _filtered;
  int rowsPerPage;

  UserDataSource({
    required this.allUsers,
    required this.onEdit,
    required this.onToggle,
    required this.selectedIds,
    required this.onSelectedChanged,
    this.rowsPerPage = 5,
  }) : _filtered = List.from(allUsers);

  int get filteredCount => _filtered.length;

  void refresh() {
    _filtered = List.from(allUsers);
    notifyListeners();
  }

  void filter(String query) {
    if (query.isEmpty) {
      _filtered = List.from(allUsers);
    } else {
      final q = query.toLowerCase();
      _filtered = allUsers.where((u) {
        return u.name.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q);
      }).toList();
    }
    notifyListeners();
  }

  void sort<T>(Comparable<T> Function(AppUserModel u) getField, bool ascending) {
    _filtered.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  @override
  DataRow getRow(int index) {
    assert(index < _filtered.length);
    final user = _filtered[index];
    final selected = selectedIds.contains(user.uid);

    return DataRow.byIndex(
      index: index,
      selected: selected,
      onSelectChanged: (bool? isSelected) {
        if (isSelected != null) {
          onSelectedChanged(isSelected, user.uid);
          notifyListeners();
        }
      },
      cells: [
        DataCell(Text(user.name)),
        DataCell(Text(user.email)),
        // DataCell(Text(user.role)),
        DataCell(
          Text(
            user.isActive ? "Active" : "Inactive",
            style: TextStyle(
              color: user.isActive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
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
  int get rowCount => _filtered.length;

  @override
  int get selectedRowCount => selectedIds.length;
}
