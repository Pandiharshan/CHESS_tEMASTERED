import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('SETTINGS', style: AppTextStyles.headline.copyWith(fontSize: 20)),
        backgroundColor: AppColors.black,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Divider(color: AppColors.white, height: 2, thickness: 2),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          _title('AUDIO'),
          _toggle(context, 'SOUND EFFECTS',      s.soundEffects,      s.setSoundEffects),
          _toggle(context, 'PIECE MOVEMENT AUDIO', s.pieceMovementAudio, s.setPieceAudio),
          const SizedBox(height: 32),
          _title('VISUALS'),
          _toggle(context, 'ANIMATIONS',         s.animations,        s.setAnimations),
          _toggle(context, 'PIXEL GRID OVERLAY', s.pixelGridOverlay,  s.setPixelGrid),
          const SizedBox(height: 32),
          _title('BOARD STYLE'),
          _picker(context, 'TYPE',   ['FLAT', 'PERSPECTIVE'], s.boardType,  s.setBoardType),
          _picker(context, 'PIECES', ['SIMPLE', 'BATTLE'],   s.pieceStyle, s.setPieceStyle),
          const SizedBox(height: 48),
          _resetButton(context),
          const SizedBox(height: 16),
          _versionInfo(),
        ],
      ),
    );
  }

  Widget _title(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text('[ $t ]', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
  );

  Widget _toggle(BuildContext ctx, String label, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(border: Border.all(color: AppColors.gray)),
      child: SwitchListTile(
        title: Text(label, style: AppTextStyles.bodySecondary),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.black,
        activeTrackColor: AppColors.white,
        inactiveThumbColor: AppColors.gray,
        inactiveTrackColor: AppColors.black,
      ),
    );
  }

  Widget _picker(BuildContext ctx, String label, List<String> options, String current, Function(String) onSelect) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySecondary),
          Row(
            children: options.map((opt) {
              bool sel = current == opt;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () => onSelect(opt),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: sel ? AppColors.white : AppColors.black,
                    child: Text(opt, style: AppTextStyles.bodySecondary.copyWith(color: sel ? AppColors.black : AppColors.white)),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _resetButton(BuildContext ctx) {
    final s = ctx.read<SettingsProvider>();
    return GestureDetector(
      onTap: () async {
        s.setSoundEffects(true);
        s.setPieceAudio(false);
        s.setAnimations(true);
        s.setPixelGrid(true);
        s.setBoardType('PERSPECTIVE');
        s.setPieceStyle('BATTLE');
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('SETTINGS RESET', style: AppTextStyles.body), backgroundColor: AppColors.black),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border.all(color: Colors.red, width: 2)),
        child: Center(child: Text('RESET ALL DATA', style: AppTextStyles.body.copyWith(color: Colors.red))),
      ),
    );
  }

  Widget _versionInfo() => Center(
    child: Text('CHESS REMASTERED v1.0.0', style: AppTextStyles.bodySecondary.copyWith(fontSize: 10)),
  );
}
