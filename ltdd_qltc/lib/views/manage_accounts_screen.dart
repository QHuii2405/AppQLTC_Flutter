import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Để định dạng số tiền
import 'package:ltdd_qltc/models/user.dart'; // Đảm bảo đường dẫn chính xác
import 'package:ltdd_qltc/models/account.dart'; // Đảm bảo đường dẫn chính xác
import 'package:ltdd_qltc/controllers/account_controller.dart'; // Đảm bảo đường dẫn chính xác

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
    // Tải danh sách tài khoản khi màn hình được khởi tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.user.id != null) {
        Provider.of<AccountController>(
          context,
          listen: false,
        ).loadAccounts(widget.user.id!);
      }
    });
  }

  // Hàm hiển thị dialog thêm/sửa tài khoản
  void _showAccountDialog({Account? account}) {
    final TextEditingController nameController = TextEditingController(
      text: account?.name,
    );
    final TextEditingController balanceController = TextEditingController(
      text: account?.balance.toString() ?? '0.0',
    );
    // Đã thay đổi: Loại bỏ lựa chọn tiền tệ, chỉ mặc định là VND
    String selectedCurrency =
        'VND'; // Chỉ set mặc định là VND, không cho phép chọn khác

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF4BAFCC), // Màu nền dialog
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          title: Text(
            account == null ? 'Thêm ví tiền mới' : 'Chỉnh sửa ví tiền',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Tên ví (Ví dụ: Tiền mặt, Ngân hàng)',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white70,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: balanceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Số dư ban đầu (Ví dụ: 1000000)',
                    hintStyle: const TextStyle(color: Colors.white70),
                    prefixIcon: const Icon(
                      Icons.attach_money,
                      color: Colors.white70,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Đã thay đổi: Hiển thị đơn vị tiền tệ chỉ là text, không cho phép chọn
                Container(
                  alignment: Alignment.centerLeft, // Căn chỉnh text sang trái
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 15.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.currency_exchange,
                        color: Colors.white70,
                      ), // Icon tiền tệ
                      const SizedBox(width: 12),
                      Text(
                        'Đơn vị tiền tệ: $selectedCurrency', // Chỉ hiển thị VND
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                final accountName = nameController.text.trim();
                final accountBalance = double.tryParse(
                  balanceController.text.trim(),
                );

                if (accountName.isEmpty) {
                  _showSnackBar('Tên ví không được để trống.');
                  return;
                }
                if (accountBalance == null || accountBalance < 0) {
                  _showSnackBar('Số dư không hợp lệ.');
                  return;
                }

                final controller = Provider.of<AccountController>(
                  context,
                  listen: false,
                );
                bool success;
                if (account == null) {
                  // Thêm mới
                  final newAccount = Account(
                    userId: widget.user.id!,
                    name: accountName,
                    balance: accountBalance,
                    currency: selectedCurrency, // Luôn là VND
                    createdAt: DateFormat(
                      'yyyy-MM-dd HH:mm:ss',
                    ).format(DateTime.now()),
                  );
                  success = await controller.addAccount(newAccount);
                } else {
                  // Cập nhật
                  final updatedAccount = account.copyWith(
                    name: accountName,
                    balance: accountBalance,
                    currency: selectedCurrency, // Luôn là VND khi cập nhật
                  );
                  success = await controller.updateAccount(updatedAccount);
                }

                if (success) {
                  Navigator.pop(context); // Đóng dialog
                  _showSnackBar(
                    account == null
                        ? 'Thêm ví tiền thành công!'
                        : 'Cập nhật ví tiền thành công!',
                  );
                } else {
                  _showSnackBar(controller.errorMessage ?? 'Đã xảy ra lỗi.');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5CBDD9),
                foregroundColor: Colors.white,
              ),
              child: Text(account == null ? 'Thêm' : 'Lưu'),
            ),
          ],
        );
      },
    );
  }

  // Hàm hiển thị dialog xác nhận xóa
  void _showDeleteConfirmationDialog(Account account) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF4BAFCC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          title: const Text(
            'Xác nhận xóa',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa ví "${account.name}" không? Thao tác này không thể hoàn tác và sẽ ảnh hưởng đến các giao dịch liên quan.',
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () async {
                final controller = Provider.of<AccountController>(
                  context,
                  listen: false,
                );
                bool success = await controller.deleteAccount(account.id!);
                if (success) {
                  Navigator.pop(context); // Đóng dialog
                  _showSnackBar('Đã xóa ví "${account.name}".');
                } else {
                  _showSnackBar(controller.errorMessage ?? 'Không thể xóa ví.');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Xóa'),
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
        title: const Text(
          'Quản lý Ví tiền',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF5CBDD9),
        foregroundColor: Colors.white,
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
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            }

            if (controller.accounts.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Bạn chưa có ví tiền nào. Nhấn nút "+" để thêm ví đầu tiên của bạn!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: controller.accounts.length,
              itemBuilder: (context, index) {
                final account = controller.accounts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  elevation: 2,
                  color: Colors.white.withOpacity(0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    title: Text(
                      account.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Số dư: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'VND').format(account.balance)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white70),
                          onPressed: () => _showAccountDialog(account: account),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () =>
                              _showDeleteConfirmationDialog(account),
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
        onPressed: () => _showAccountDialog(), // Nút thêm ví tiền mới
        backgroundColor: const Color(0xFF2196F3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
