import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../widgets/common/primary_button.dart';
import '../play/play_screen.dart';
import 'tactics_trainer_screen.dart';
import 'opening_explorer_screen.dart';
import 'game_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 60),
              _buildMainPlayButton(context),
              const SizedBox(height: 48),
              _buildStatsSection(),
              const SizedBox(height: 48),
              _buildQuickLinks(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Animated App Logo
        AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (ctx, child) {
            return Transform.translate(
              offset: Offset(0, -4 * _pulseCtrl.value),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.white.withValues(alpha: 0.15 + (0.1 * _pulseCtrl.value)),
                      blurRadius: 12 + (4 * _pulseCtrl.value),
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.extension, color: AppColors.white, size: 48),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        Text('CHESS', style: AppTextStyles.headline.copyWith(fontSize: 48)),
        Text('REMASTERED', style: AppTextStyles.headline.copyWith(fontSize: 24, letterSpacing: 8)),
        const SizedBox(height: 8),
        Container(width: 100, height: 4, color: AppColors.white),
      ],
    );
  }

  Widget _buildMainPlayButton(BuildContext context) {
    return PrimaryButton(
      text: 'START NEW GAME',
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PlayScreen()));
      },
    );
  }

  Widget _buildStatsSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.05),
        border: Border.all(color: AppColors.white, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.white,
            child: Text('LOCAL PLAYER RECORD',
                style: AppTextStyles.body.copyWith(color: AppColors.black, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCircle('GAMES', '0'),
                _buildStatCircle('WINS', '0'),
                _buildStatCircle('BEST', '-'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCircle(String label, String val) {
    return Column(
      children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 2),
          ),
          child: Center(
            child: Text(val, style: AppTextStyles.title.copyWith(fontSize: 18)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTextStyles.bodySecondary.copyWith(fontSize: 10)),
      ],
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('[ PRACTICE & REVIEW ]', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildLink(context, 'TACTICS TRAINER', const TacticsTrainerScreen()),
        _buildLink(context, 'OPENING EXPLORER', const OpeningExplorerScreen()),
        _buildLink(context, 'SAVED GAMES', const GameHistoryScreen()),
      ],
    );
  }

  Widget _buildLink(BuildContext context, String label, Widget targetScreen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => targetScreen));
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.gray, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.bodySecondary),
              const Icon(Icons.arrow_forward, color: AppColors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
