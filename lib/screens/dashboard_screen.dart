import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import 'scanner_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final DashboardViewModel _viewModel;

  // Aesthetic Colors
  static const Color emeraldGreen = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel()..loadDashboardData();
  }

  @override
  void dispose() {
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
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _viewModel,
          builder: (context, _) {
            return RefreshIndicator(
              onRefresh: _viewModel.loadDashboardData,
              color: Colors.indigo,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Presensi Siswa',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat(
                                'EEEE, d MMMM yyyy',
                                'id_ID',
                              ).format(DateTime.now()),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1E2E)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.settings_rounded,
                              color: Colors.indigo,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SettingsScreen(),
                                ),
                              ).then((_) => _viewModel.loadDashboardData());
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _buildServerStatusWidget(isDark),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScannerScreen(),
                          ),
                        ).then((_) => _viewModel.loadDashboardData());
                      },
                      child: Container(
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.indigo.shade800,
                              Colors.purple.shade700,
                              Colors.deepPurple.shade900,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              right: -30,
                              top: -30,
                              child: CircleAvatar(
                                radius: 90,
                                backgroundColor: Colors.white.withOpacity(0.06),
                              ),
                            ),
                            Positioned(
                              left: -20,
                              bottom: -20,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white.withOpacity(0.04),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.12),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.qr_code_scanner_rounded,
                                      color: Color(0xFF00FFCC),
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Mulai Pindai QR Code',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Tap di sini untuk mengaktifkan kamera scan kartu presensi siswa',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const SizedBox(height: 28),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Riwayat Pemindaian Terkini',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_viewModel.logs.isNotEmpty)
                          TextButton(
                            onPressed: _viewModel.loadDashboardData,
                            child: const Text('Segarkan'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildLogsList(isDark),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildServerStatusWidget(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5),
        ],
        border: Border.all(
          color: _viewModel.isServerOnline
              ? emeraldGreen.withOpacity(0.2)
              : Colors.redAccent.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _viewModel.isServerOnline
                  ? emeraldGreen
                  : Colors.redAccent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _viewModel.isServerOnline
                      ? emeraldGreen.withOpacity(0.5)
                      : Colors.redAccent.withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _viewModel.isServerOnline
                          ? 'Server Online'
                          : 'Server Terputus',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: _viewModel.isServerOnline
                            ? emeraldGreen
                            : Colors.redAccent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_viewModel.isServerOnline)
                      Text(
                        '(${_viewModel.serverLatency}ms)',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _viewModel.serverUrl.isEmpty
                      ? 'Belum Dikonfigurasi'
                      : _viewModel.serverUrl,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey.shade400 : Colors.black54,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _viewModel.checkServerConnection,
            child: _viewModel.isCheckingServer
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.indigo,
                    ),
                  )
                : const Icon(
                    Icons.sync_rounded,
                    color: Colors.indigo,
                    size: 22,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsList(bool isDark) {
    if (_viewModel.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40.0),
        child: Center(child: CircularProgressIndicator(color: Colors.indigo)),
      );
    }

    if (_viewModel.logs.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 3),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.history_toggle_off_rounded,
              color: Colors.grey.shade400,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Scan Terkini',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Riwayat absensi siswa yang berhasil dipindai hari ini akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _viewModel.logs.length > 8 ? 8 : _viewModel.logs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final log = _viewModel.logs[index];

        Color cardBorderColor = Colors.grey.withOpacity(0.1);
        Color statusBgColor = Colors.grey.withOpacity(0.12);
        Color statusTextColor = Colors.grey;

        if (log.isSuccess) {
          cardBorderColor = emeraldGreen.withOpacity(0.1);
          statusBgColor = emeraldGreen.withOpacity(0.12);
          statusTextColor = emeraldGreen;
        } else if (log.status == 'Sudah Hadir' ||
            log.message.contains('sudah melakukan presensi')) {
          cardBorderColor = Colors.amber.withOpacity(0.1);
          statusBgColor = Colors.amber.withOpacity(0.12);
          statusTextColor = Colors.amber.shade800;
        } else {
          cardBorderColor = Colors.redAccent.withOpacity(0.1);
          statusBgColor = Colors.redAccent.withOpacity(0.12);
          statusTextColor = Colors.redAccent;
        }

        final timeFormatted = DateFormat('HH:mm:ss').format(log.scannedAt);

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorderColor, width: 1),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 2),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: log.isSuccess
                    ? emeraldGreen.withOpacity(0.1)
                    : Colors.redAccent.withOpacity(0.1),
                child: Icon(
                  log.isSuccess
                      ? Icons.person_rounded
                      : Icons.warning_amber_rounded,
                  color: log.isSuccess ? emeraldGreen : Colors.redAccent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.studentName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          log.nis.isNotEmpty ? log.nis : 'NIS: -',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.circle, size: 4, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(
                          timeFormatted,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  log.status,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusTextColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
