import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import '../service/user_service.dart';
import '../service/api_client.dart';
import '../models/user_model.dart';

class AddressManagementPage extends StatefulWidget {
  const AddressManagementPage({super.key});

  @override
  State<AddressManagementPage> createState() => _AddressManagementPageState();
}

class _AddressManagementPageState extends State<AddressManagementPage> {
  late final UserService _userService;
  List<AddressModel> _addresses = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _userService = UserService(ApiClient());
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    try {
      final addresses = await _userService.getAddresses();
      if (mounted) {
        setState(() {
          _addresses = addresses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Địa chỉ giao hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddAddressDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadAddresses,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _addresses.length,
                    itemBuilder: (context, index) {
                      final address = _addresses[index];
                      return _buildAddressCard(address);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 80,
            color: AppTheme.char300,
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có địa chỉ nào',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.char500,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddAddressDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Thêm địa chỉ mới'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(AddressModel address) {
    final isDefault = address.isDefault;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDefault ? AppTheme.beige100 : Colors.white,
        border: Border.all(
          color: isDefault ? AppTheme.primary500 : AppTheme.char200,
          width: isDefault ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        address.fullName ?? '',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '|',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.char400,
                            ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        address.phone ?? '',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                if (isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary500,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Mặc định',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${address.address}, ${address.ward}, ${address.district}, ${address.province}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.char700,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showEditAddressDialog(address),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Sửa'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primary500,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _handleDeleteAddress(address.id ?? ''),
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Xóa'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAddressDialog() {
    final fullNameController = TextEditingController();
    final phoneController = TextEditingController();
    final provinceController = TextEditingController();
    final districtController = TextEditingController();
    final wardController = TextEditingController();
    final addressController = TextEditingController();
    bool isDefault = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Thêm địa chỉ mới'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên người nhận',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: provinceController,
                      decoration: const InputDecoration(
                        labelText: 'Tỉnh/Thành phố',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: districtController,
                      decoration: const InputDecoration(
                        labelText: 'Quận/Huyện',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: wardController,
                      decoration: const InputDecoration(
                        labelText: 'Phường/Xã',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Địa chỉ cụ thể',
                        prefixIcon: Icon(Icons.home),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Đặt làm địa chỉ mặc định'),
                      value: isDefault,
                      onChanged: (value) {
                        setState(() => isDefault = value ?? false);
                      },
                      contentPadding: EdgeInsets.zero,
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
                    await _handleAddAddress(
                      fullNameController.text,
                      phoneController.text,
                      provinceController.text,
                      districtController.text,
                      wardController.text,
                      addressController.text,
                      isDefault,
                    );
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Thêm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditAddressDialog(AddressModel address) {
    final fullNameController = TextEditingController(text: address.fullName);
    final phoneController = TextEditingController(text: address.phone);
    final provinceController = TextEditingController(text: address.province);
    final districtController = TextEditingController(text: address.district);
    final wardController = TextEditingController(text: address.ward);
    final addressController = TextEditingController(text: address.address);
    bool isDefault = address.isDefault;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Sửa địa chỉ'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên người nhận',
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Số điện thoại',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: provinceController,
                      decoration: const InputDecoration(
                        labelText: 'Tỉnh/Thành phố',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: districtController,
                      decoration: const InputDecoration(
                        labelText: 'Quận/Huyện',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: wardController,
                      decoration: const InputDecoration(
                        labelText: 'Phường/Xã',
                        prefixIcon: Icon(Icons.location_city),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Địa chỉ cụ thể',
                        prefixIcon: Icon(Icons.home),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Đặt làm địa chỉ mặc định'),
                      value: isDefault,
                      onChanged: (value) {
                        setState(() => isDefault = value ?? false);
                      },
                      contentPadding: EdgeInsets.zero,
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
                    await _handleUpdateAddress(
                      address.id ?? '',
                      fullNameController.text,
                      phoneController.text,
                      provinceController.text,
                      districtController.text,
                      wardController.text,
                      addressController.text,
                      isDefault,
                    );
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleAddAddress(
    String fullName,
    String phone,
    String province,
    String district,
    String ward,
    String address,
    bool isDefault,
  ) async {
    try {
      await _userService.addAddress(
        fullName: fullName,
        phone: phone,
        province: province,
        district: district,
        ward: ward,
        address: address,
        isDefault: isDefault,
      );

      if (mounted) {
        await _loadAddresses();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thêm địa chỉ thành công'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleUpdateAddress(
    String id,
    String fullName,
    String phone,
    String province,
    String district,
    String ward,
    String address,
    bool isDefault,
  ) async {
    try {
      await _userService.updateAddress(
        addressId: id,
        fullName: fullName,
        phone: phone,
        province: province,
        district: district,
        ward: ward,
        address: address,
        isDefault: isDefault,
      );

      if (mounted) {
        await _loadAddresses();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật địa chỉ thành công'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteAddress(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa địa chỉ'),
          content: const Text('Bạn có chắc chắn muốn xóa địa chỉ này?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await _userService.deleteAddress(id);

        if (mounted) {
          await _loadAddresses();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa địa chỉ thành công'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${e.toString()}'),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
}
