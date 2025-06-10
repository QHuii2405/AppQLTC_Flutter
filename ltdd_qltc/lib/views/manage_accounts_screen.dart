import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ltdd_qltc/models/user.dart';
import 'package:ltdd_qltc/models/account.dart';
import 'package:ltdd_qltc/controllers/account_controller.dart';

class ManageAccountsScreen extends StatefulWidget {
  final User user;
  const ManageAccountsScreen({super.key, required this.user});

  @override
  State<ManageAccountsScreen> createState() => _ManageAccountsScreenState();
}

class _ManageAccountsScreenState extends State<ManageAccountsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.user.id != null) {
        Provider.of<AccountController>(
          context,
          listen: false,
        ).loadAccounts(widget.user.id!);
      }
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showAccountDialog({Account? account}) {
    final nameController = TextEditingController(text: account?.name);
    final balanceController = TextEditingController(
      text: account?.balance.toString() ?? '0.0',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(account == null ? 'Thêm ví mới' : 'Sửa ví'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên ví'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Vui lòng nhập tên ví'
                      : null,
                ),
                TextFormField(
                  controller: balanceController,
                  decoration: const InputDecoration(labelText: 'Số dư ban đầu'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Vui lòng nhập số dư';
                    if (double.tryParse(value) == null)
                      return 'Số dư không hợp lệ';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final controller = Provider.of<AccountController>(
                    context,
                    listen: false,
                  );
                  bool success;
                  if (account == null) {
                    final newAccount = Account(
                      userId: widget.user.id!,
                      name: nameController.text,
                      balance: double.parse(balanceController.text),
                      currency: 'VND',
                      createdAt: DateFormat(
                        'yyyy-MM-dd HH:mm:ss',
                      ).format(DateTime.now()),
                    );
                    success = await controller.addAccount(newAccount);
                  } else {
                    final updatedAccount = account.copyWith(
                      name: nameController.text,
                      balance: double.parse(balanceController.text),
                    );
                    success = await controller.updateAccount(updatedAccount);
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    _showSnackBar(
                      success
                          ? (account == null
                                ? 'Thêm ví thành công'
                                : 'Cập nhật ví thành công')
                          : controller.errorMessage ?? 'Thao tác thất bại',
                    );
                  }
                }
              },
              child: Text(account == null ? 'Thêm' : 'Lưu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Ví tiền'),
        backgroundColor: const Color(0xFF5CBDD9),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5CBDD9), Color(0xFF4BAFCC)],
          ),
        ),
        child: Consumer<AccountController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            if (controller.accounts.isEmpty) {
              return const Center(
                child: Text(
                  'Chưa có ví nào.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }
            return ListView.builder(
              itemCount: controller.accounts.length,
              itemBuilder: (context, index) {
                final account = controller.accounts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Colors.white.withOpacity(0.2),
                  child: ListTile(
                    leading: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                    ),
                    title: Text(
                      account.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      NumberFormat.currency(
                        locale: 'vi_VN',
                        symbol: 'VND',
                      ).format(account.balance),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () => _showAccountDialog(account: account),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () async {
                            bool? confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Xác nhận xóa'),
                                content: Text(
                                  'Bạn có chắc muốn xóa ví "${account.name}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Xóa'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              bool success = await controller.deleteAccount(
                                account.id!,
                              );
                              _showSnackBar(
                                success
                                    ? 'Xóa ví thành công'
                                    : controller.errorMessage ?? 'Xóa thất bại',
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAccountDialog(),
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.add),
      ),
    );
  }
}
