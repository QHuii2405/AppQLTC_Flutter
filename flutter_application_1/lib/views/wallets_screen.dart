import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/controllers/wallet_controller.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/models/account.dart';
import 'package:intl/intl.dart';

class WalletsScreen extends StatefulWidget {
  const WalletsScreen({super.key});

  @override
  State<WalletsScreen> createState() => _WalletsScreenState();
}

class _WalletsScreenState extends State<WalletsScreen> {
  User? _loggedInUser;
  int _currentIndex = 1; // Chỉ mục cho màn hình ví tiền

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loggedInUser == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is User) {
        _loggedInUser = args;
        if (_loggedInUser!.id != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<WalletController>(
              context,
              listen: false,
            ).loadWallets(_loggedInUser!.id!);
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletController>(
      builder: (context, walletController, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Ví tiền của tôi',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF5CBDD9),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  _showAddWalletDialog(walletController);
                },
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF5CBDD9), Color(0xFF4BAFCC)],
              ),
            ),
            child:
                walletController.isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : walletController.wallets.isEmpty
                    ? const Center(
                      child: Text(
                        'Bạn chưa có ví nào. Hãy thêm một ví mới!',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: walletController.wallets.length,
                      itemBuilder: (context, index) {
                        final account = walletController.wallets[index];
                        return _buildWalletCard(account, walletController);
                      },
                    ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(walletController),
        );
      },
    );
  }

  Widget _buildWalletCard(Account account, WalletController walletController) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.white.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  account.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditWalletDialog(account, walletController);
                    } else if (value == 'delete') {
                      _confirmDeleteWallet(account, walletController);
                    }
                  },
                  itemBuilder:
                      (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Chỉnh sửa'),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Text('Xóa'),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Số dư: ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(account.balance)}',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Tiền tệ: ${account.currency}',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Ngày tạo: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(account.createdAt))}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWalletDialog(WalletController walletController) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Thêm ví mới'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên ví'),
                ),
                TextField(
                  controller: balanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Số dư ban đầu'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty) {
                    _showSnackBar('Tên ví không được để trống.');
                    return;
                  }
                  if (_loggedInUser?.id == null) {
                    _showSnackBar('Lỗi: Không tìm thấy ID người dùng.');
                    return;
                  }

                  final newAccount = Account(
                    userId: _loggedInUser!.id!,
                    name: nameController.text,
                    balance: double.tryParse(balanceController.text) ?? 0.0,
                    currency: 'VND', // Mặc định là VND
                    createdAt: DateTime.now().toIso8601String(),
                  );

                  bool success = await walletController.addWallet(newAccount);
                  Navigator.pop(context); // Đóng dialog
                  if (success) {
                    _showSnackBar('Đã thêm ví thành công!');
                  } else {
                    _showSnackBar(
                      walletController.errorMessage ?? 'Thêm ví thất bại.',
                    );
                  }
                },
                child: const Text('Thêm'),
              ),
            ],
          ),
    );
  }

  void _showEditWalletDialog(
    Account account,
    WalletController walletController,
  ) {
    final nameController = TextEditingController(text: account.name);
    final balanceController = TextEditingController(
      text: account.balance.toString(),
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Chỉnh sửa ví'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên ví'),
                ),
                TextField(
                  controller: balanceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Số dư'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isEmpty) {
                    _showSnackBar('Tên ví không được để trống.');
                    return;
                  }
                  if (_loggedInUser?.id == null) {
                    _showSnackBar('Lỗi: Không tìm thấy ID người dùng.');
                    return;
                  }

                  final updatedAccount = Account(
                    id: account.id,
                    userId: account.userId,
                    name: nameController.text,
                    balance:
                        double.tryParse(balanceController.text) ??
                        account.balance,
                    currency: account.currency,
                    createdAt: account.createdAt,
                  );

                  bool success = await walletController.updateWallet(
                    updatedAccount,
                  );
                  Navigator.pop(context); // Đóng dialog
                  if (success) {
                    _showSnackBar('Đã cập nhật ví thành công!');
                  } else {
                    _showSnackBar(
                      walletController.errorMessage ?? 'Cập nhật ví thất bại.',
                    );
                  }
                },
                child: const Text('Lưu'),
              ),
            ],
          ),
    );
  }

  void _confirmDeleteWallet(
    Account account,
    WalletController walletController,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text(
              'Bạn có chắc chắn muốn xóa ví "${account.name}" không?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_loggedInUser?.id == null) {
                    _showSnackBar('Lỗi: Không tìm thấy ID người dùng.');
                    return;
                  }
                  bool success = await walletController.deleteWallet(
                    account.id!,
                    _loggedInUser!.id!,
                  );
                  Navigator.pop(context); // Đóng dialog
                  if (success) {
                    _showSnackBar('Đã xóa ví thành công!');
                  } else {
                    _showSnackBar(
                      walletController.errorMessage ?? 'Xóa ví thất bại.',
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Xóa', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  Widget _buildBottomNavigationBar(WalletController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (_currentIndex != index) {
              setState(() {
                _currentIndex = index;
              });

              switch (index) {
                case 0: // Trang chủ
                  Navigator.pushReplacementNamed(
                    context,
                    '/home',
                    arguments: _loggedInUser,
                  );
                  break;
                case 1: // Ví tiền (đã ở đây)
                  break;
                case 2: // Nút thêm (hành động)
                  _showSnackBar('Mở màn hình thêm giao dịch!');
                  // Navigator.pushNamed(context, '/add_transaction', arguments: _loggedInUser);
                  break;
                case 3: // Thống kê
                  Navigator.pushReplacementNamed(
                    context,
                    '/statistics',
                    arguments: _loggedInUser,
                  );
                  break;
                case 4: // Cài đặt
                  Navigator.pushReplacementNamed(
                    context,
                    '/settings',
                    arguments: _loggedInUser,
                  );
                  break;
                default:
                  _showSnackBar('Tính năng này sẽ sớm ra mắt!');
              }
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF5CBDD9),
          unselectedItemColor: Colors.grey[600],
          showUnselectedLabels: true,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      _currentIndex == 0
                          ? const Color(0xFF5CBDD9).withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.home_filled),
              ),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      _currentIndex == 1
                          ? const Color(0xFF5CBDD9).withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet),
              ),
              label: 'Ví tiền',
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF5CBDD9),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5CBDD9).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      _currentIndex == 3
                          ? const Color(0xFF5CBDD9).withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.pie_chart),
              ),
              label: 'Thống kê',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      _currentIndex == 4
                          ? const Color(0xFF5CBDD9).withOpacity(0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.settings),
              ),
              label: 'Cài đặt',
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.black87),
    );
  }
}
