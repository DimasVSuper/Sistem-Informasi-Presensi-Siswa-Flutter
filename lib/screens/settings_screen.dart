import 'package:flutter/material.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _urlController = TextEditingController();
  late final SettingsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SettingsViewModel();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _viewModel.loadSettings();
    if (mounted) {
      _urlController.text = _viewModel.savedUrl;
    }
  }

  Future<void> _testConnection() async {
    if (_urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan URL server terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    await _viewModel.testConnection(_urlController.text.trim());
  }

  Future<void> _saveSettings() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL server tidak boleh kosong'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final success = await _viewModel.saveSettings(url);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Konfigurasi server berhasil disimpan!'),
            ],
          ),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _clearLogs() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Riwayat?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Semua riwayat pemindaian lokal akan dihapus secara permanen. Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Hapus',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _viewModel.clearLogs();
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seluruh riwayat scan berhasil dibersihkan.'),
            backgroundColor: Colors.blueGrey,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F0F1A)
          : const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text(
          'Pengaturan Server',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : Colors.black87,
      ),
      body: AnimatedBuilder(
        animation: _viewModel,
        builder: (context, _) {
          if (_viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.indigo),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.dns_rounded,
                              color: Colors.indigo.shade400,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Konfigurasi Endpoint API',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Masukkan alamat URL API Laravel Anda. Pastikan HP dan server Laravel berada di jaringan Wi-Fi yang sama.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _urlController,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Laravel API Base URL',
                            hintText: 'http://192.168.1.100:8000/api',
                            prefixIcon: const Icon(Icons.link_rounded),
                            labelStyle: TextStyle(
                              color: Colors.indigo.shade300,
                            ),
                            hintStyle: const TextStyle(color: Colors.grey),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.indigo.withOpacity(0.3),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.indigo,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF161622)
                                : Colors.grey.shade50,
                          ),
                        ),
                        const SizedBox(height: 15),
                        if (_viewModel.latency != -2 ||
                            _viewModel.isTestingConnection)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: _viewModel.latency >= 0
                                  ? const Color(0xFF10B981).withOpacity(0.1)
                                  : (_viewModel.latency == -1
                                        ? Colors.redAccent.withOpacity(0.1)
                                        : Colors.blue.withOpacity(0.1)),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _viewModel.latency >= 0
                                    ? const Color(0xFF10B981).withOpacity(0.3)
                                    : (_viewModel.latency == -1
                                          ? Colors.redAccent.withOpacity(0.3)
                                          : Colors.blue.withOpacity(0.3)),
                              ),
                            ),
                            child: Row(
                              children: [
                                if (_viewModel.isTestingConnection)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.indigo,
                                    ),
                                  )
                                else
                                  Icon(
                                    _viewModel.latency >= 0
                                        ? Icons.online_prediction
                                        : Icons.error_outline,
                                    color: _viewModel.latency >= 0
                                        ? const Color(0xFF10B981)
                                        : Colors.redAccent,
                                    size: 20,
                                  ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _viewModel.isTestingConnection
                                        ? 'Mencoba terhubung ke server...'
                                        : (_viewModel.latency >= 0
                                              ? 'Terhubung! Latensi: ${_viewModel.latency} ms'
                                              : 'Gagal terhubung! Periksa kembali IP & port server Anda.'),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: _viewModel.latency >= 0
                                          ? const Color(0xFF10B981)
                                          : (_viewModel.latency == -1
                                                ? Colors.redAccent
                                                : Colors.indigo),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _viewModel.isTestingConnection
                                    ? null
                                    : _testConnection,
                                icon: _viewModel.isTestingConnection
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.flash_on_rounded),
                                label: const Text('Tes Koneksi'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.indigo,
                                  side: const BorderSide(color: Colors.indigo),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _saveSettings,
                                icon: const Icon(
                                  Icons.save_rounded,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Simpan URL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 4,
                  color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.storage_rounded,
                              color: Colors.amber.shade600,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Manajemen Data Lokal',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Kelola data hasil scanning lokal yang tersimpan di memori cache perangkat Anda.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton.icon(
                          onPressed: _clearLogs,
                          icon: const Icon(
                            Icons.delete_sweep_rounded,
                            color: Colors.redAccent,
                          ),
                          label: const Text(
                            'Hapus Riwayat Scan Lokal',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    'Attendance Scanner v1.0.0 Laravel 11 API Gateway Integration',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
