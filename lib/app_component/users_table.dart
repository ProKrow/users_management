import 'package:flutter/material.dart';
import 'package:users_management/app_component/user.dart';
import 'package:users_management/app_theme.dart';

class UsersTable extends StatefulWidget {
  final List<dynamic> usersList; // Replace with your User type
  final VoidCallback? onRefresh;

  const UsersTable({super.key, required this.usersList, this.onRefresh});

  @override
  State<UsersTable> createState() => _UsersTableState();
}

class _UsersTableState extends State<UsersTable> {
  final ScrollController _scrollController = ScrollController();

  Widget _buildModernDataTable() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor.withValues(alpha: .3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DataTable(
          horizontalMargin: 24,
          columnSpacing: 20,
          headingRowHeight: 56,
          dataRowMinHeight: 64,
          dataRowMaxHeight: 80,
          headingRowColor: WidgetStateProperty.all(
            AppTheme.cardColor.withValues(alpha: .7),
          ),
          dataRowColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.hovered)) {
              return AppTheme.primaryColor.withValues(alpha: .05);
            }
            return AppTheme.surfaceColor;
          }),
          dividerThickness: 0.5,
          border: TableBorder(
            horizontalInside: BorderSide(
              color: AppTheme.borderColor.withValues(alpha: .2),
              width: 0.5,
            ),
          ),
          columns: _buildColumns(),
          rows: _buildRows(),
        ),
      ),
    );
  }

  List<DataColumn> _buildColumns() {
    return [
      DataColumn(label: _buildColumnHeader('ID', Icons.tag)),
      DataColumn(label: _buildColumnHeader('User Name', Icons.person)),
      DataColumn(
        label: _buildColumnHeader('Subscription', Icons.card_membership),
      ),
      DataColumn(label: _buildColumnHeader('Tower', Icons.cell_tower_rounded)),
      DataColumn(label: _buildColumnHeader('Amount', Icons.payments)),
      DataColumn(label: _buildColumnHeader('Activated', Icons.event)),
      DataColumn(label: _buildColumnHeader('Expires', Icons.event_busy)),
      DataColumn(label: _buildColumnHeader('Notes', Icons.note)),
      DataColumn(label: _buildActionsHeader()),
    ];
  }

  Widget _buildColumnHeader(String title, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 16),
        SizedBox(width: 8),
        Text(title, style: AppTheme.headerTextStyle),
      ],
    );
  }

  Widget _buildActionsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _buildHeaderAction(
          icon: Icons.person_add,
          tooltip: 'Add User',
          onPressed: () {
            _addUser();
            if (widget.onRefresh != null) widget.onRefresh!();
          },
        ),
        SizedBox(width: 8),
        _buildHeaderAction(
          icon: Icons.save,
          tooltip: 'Save Data',
          onPressed: () => _saveData(),
        ),
      ],
    );
  }

  Widget _buildHeaderAction({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: .3)),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppTheme.primaryColor, size: 18),
        onPressed: onPressed,
        tooltip: tooltip,
        constraints: BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.all(6),
      ),
    );
  }

  List<DataRow> _buildRows() {
    return widget.usersList.map((user) => _buildUserRow(user)).toList();
  }

  DataRow _buildUserRow(dynamic user) {
    final hasSubscription = user.activations.isNotEmpty;

    return DataRow(
      cells: [
        DataCell(_buildIdCell(user.userId)),
        DataCell(_buildUserNameCell(user)),
        DataCell(_buildSubscriptionCell(user, hasSubscription)),
        DataCell(_buildDaysLeftCell(user, hasSubscription)),
        DataCell(_buildAmountCell(user, hasSubscription)),
        DataCell(
          _buildDateCell(
            hasSubscription ? user.activations.last.activationDate : null,
            Icons.play_circle,
          ),
        ),
        DataCell(
          _buildDateCell(
            hasSubscription ? user.activations.last.expiryDate : null,
            Icons.stop_circle,
          ),
        ),
        DataCell(_buildNotesCell(user.notes)),
        DataCell(_buildActionButtons(user)),
      ],
    );
  }

  Widget _buildIdCell(int userId) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.textSecondary.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$userId',
        style: AppTheme.cellTextStyle.copyWith(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildUserNameCell(User user) {
    return InkWell(
      onTap: () => user.showActivationsDialog(context),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: user.daysLeft > 15
                  ? AppTheme.successColor
                  : (user.daysLeft > 7 ? Colors.orange : AppTheme.errorColor),
              child: Text(
                user.userName.isNotEmpty ? user.daysLeft.toString() : '?',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                user.userName,
                style: AppTheme.cellTextStyle.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCell(dynamic user, bool hasSubscription) {
    if (!hasSubscription) {
      return _buildNoSubscriptionChip();
    }

    final subscriptionType = user.activations.last.type;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.accentColor.withValues(alpha: .15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: .5),
          width: 1,
        ),
      ),
      child: Text(subscriptionType, style: AppTheme.subscriptionTextStyle),
    );
  }

  Widget _buildDaysLeftCell(dynamic user, bool hasSubscription) {
    if (!hasSubscription) {
      return Text('—', style: AppTheme.noSubscriptionTextStyle);
    }

    return Center(
      child: Text(
        user.activations.last.tower,
        style: AppTheme.cellTextStyle,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAmountCell(dynamic user, bool hasSubscription) {
    if (!hasSubscription) {
      return Text('—', style: AppTheme.noSubscriptionTextStyle);
    }

    return Text(
      '\$${user.activations.last.debtAmount}',
      style: AppTheme.cellTextStyle.copyWith(
        color: AppTheme.accentColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDateCell(DateTime? date, IconData icon) {
    if (date == null) {
      return Text('—', style: AppTheme.noSubscriptionTextStyle);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.textHint, size: 14),
        SizedBox(width: 6),
        Text(
          _formatDate(date),
          style: AppTheme.cellTextStyle.copyWith(color: AppTheme.textSecondary),
        ),
      ],
    );
  }

  Widget _buildNotesCell(String notes) {
    return Container(
      constraints: BoxConstraints(maxWidth: 120),
      child: Text(
        notes.isEmpty ? 'No notes' : notes,
        style: notes.isEmpty
            ? AppTheme.noSubscriptionTextStyle
            : AppTheme.cellTextStyle,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }

  Widget _buildActionButtons(dynamic user) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionButton(
          icon: Icons.receipt,
          onPressed: () async {
            await user.showAddActivationDialog(context);
            if (widget.onRefresh != null) widget.onRefresh!();
          },
          tooltip: 'Add Activation',
        ),
        SizedBox(width: 8),
        _buildActionButton(
          icon: Icons.edit,
          onPressed: () {
            // Handle edit
          },
          tooltip: 'Edit User',
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.borderColor.withValues(alpha: .5)),
      ),
      child: IconButton(
        icon: Icon(icon, color: AppTheme.primaryColor, size: 16),
        onPressed: onPressed,
        tooltip: tooltip,
        constraints: BoxConstraints(minWidth: 32, minHeight: 32),
        padding: EdgeInsets.all(4),
      ),
    );
  }

  Widget _buildNoSubscriptionChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.errorColor.withAlpha(3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.block, color: AppTheme.errorColor, size: 12),
          SizedBox(width: 4),
          Text(
            'No Subscription',
            style: AppTheme.noSubscriptionTextStyle.copyWith(
              color: AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _addUser() async {
    final user = await User.showAddUserDialog(
      context,
      widget.usersList.length + 1,
    );
    widget.usersList.add(user);
    if (widget.onRefresh != null) widget.onRefresh!();
  }

  void _saveData() {}

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.people,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Users Management',
                    style: AppTheme.titleLarge.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    '${widget.usersList.length} users registered',
                    style: AppTheme.labelMedium.copyWith(
                      color: AppTheme.textHint,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24),

          // Table section
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              child: Container(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width - 32,
                ),
                child: _buildModernDataTable(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
