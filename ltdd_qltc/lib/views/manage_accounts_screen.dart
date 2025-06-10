import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:ltdd_qltc/models/account.dart';
import 'package:ltdd_qltc/controllers/account_controller.dart';
import 'package:ltdd_qltc/controllers/auth_controller.dart';

class ManageAccountsScreen extends StatefulWidget {
  const ManageAccountsScreen({super.key});

  @override
  State<ManageAccountsScreen> createState() => _ManageAccountsScreenState();
}

class _ManageAccountsScreenState extends State<ManageAccountsScreen> {
  @override
  void initState() {
    super.initState();
    // Tải danh sách tài khoản ngay khi widget được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthController>(
        context,
        listen: false,
      ).currentUser;
      if (user != null && user.id != null) {
        Provider.of<AccountController>(
          context,
          listen: false,
        ).loadAccounts(user.id!);
      }
    });
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // Hiển thị dialog để thêm hoặc sửa tài khoản
  void _showAccountDialog({Account? account}) {
    final nameController = TextEditingController(text: account?.name);
    // ĐÃ XÓA: balanceController đã bị loại bỏ
    final formKey = GlobalKey<FormState>();
    final user = Provider.of<AuthController>(
      context,
      listen: false,
    ).currentUser;

    if (user == null) {
      _showSnackBar("Lỗi: Người dùng không tồn tại.");
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(account == null ? 'Thêm ví mới' : 'Sửa tên ví'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên ví',
                    hintText: 'Ví dụ: Tiền mặt, Ngân hàng...',
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Vui lòng nhập tên ví'
                      : null,
                ),
                // ĐÃ XÓA: TextFormField cho số dư đã bị loại bỏ
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

                  // CHỈNH SỬA: Logic thêm và cập nhật
                  if (account == null) {
                    // THÊM VÍ MỚI
                    final newAccount = Account(
                      userId: user.id!,
                      name: nameController.text.trim(),
                      balance: 0.0, // Số dư mặc định là 0
                      currency: 'VND',
                      createdAt: DateFormat(
                        'yyyy-MM-dd HH:mm:ss',
                      ).format(DateTime.now()),
                    );
                    success = await controller.addAccount(newAccount);
                  } else {
                    // CẬP NHẬT TÊN VÍ
                    final updatedAccount = account.copyWith(
                      name: nameController.text.trim(),
                      // Không thay đổi số dư khi chỉnh sửa
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
                  'Chưa có ví nào.\nNhấn nút + để thêm mới.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
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
                        decimalDigits: 0,
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
                                  'Bạn có chắc muốn xóa ví "${account.name}" không?\nTất cả giao dịch liên quan đến ví này sẽ bị xóa theo.',
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
                                    child: const Text(
                                      'Xóa',
                                      style: TextStyle(color: Colors.red),
                                    ),
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
