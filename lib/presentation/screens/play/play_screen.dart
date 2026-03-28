import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../widgets/common/primary_button.dart';
import '../game/game_screen.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  String _selectedMode = 'PLAYER vs AI';
  int _selectedLevel = 2; // Level 2 (Medium)
  bool _autoAI = false;
  String _selectedColor = 'WHITE';
  String _boardStyle = 'PERSPECTIVE';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('NEW GAME', style: AppTextStyles.headline.copyWith(fontSize: 20)),
        backgroundColor: AppColors.black,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Divider(color: AppColors.white, height: 2, thickness: 2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('MODE'),
            _buildModeSelector(),
            const SizedBox(height: 32),
            _buildSectionTitle('AI SETTINGS'),
            _buildAISettings(),
            const SizedBox(height: 32),
            _buildSectionTitle('SETUP'),
            _buildGameSetup(),
            const SizedBox(height: 48),
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text('[ $title ]', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildModeSelector() {
    return Row(
      children: [
        Expanded(child: _buildSelectBtn('PLAYER vs AI')),
        const SizedBox(width: 12),
        Expanded(child: _buildSelectBtn('PLAYER vs PLAYER')),
      ],
    );
  }

  Widget _buildSelectBtn(String label) {
    bool isSelected = _selectedMode == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = label),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : AppColors.black,
          border: Border.all(color: AppColors.white, width: 2),
        ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary.copyWith(
              color: isSelected ? AppColors.black : AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAISettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.white, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('LEVEL', style: AppTextStyles.body),
              DropdownButton<int>(
                value: _selectedLevel,
                dropdownColor: AppColors.black,
                underline: const SizedBox(),
                items: [1, 2, 3, 4].map((int val) {
                  return DropdownMenuItem<int>(
                    value: val,
                    child: Text('LEVEL $val', style: AppTextStyles.body),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedLevel = v!),
              ),
            ],
          ),
          const Divider(color: AppColors.white, thickness: 1),
          SwitchListTile(
            title: Text('AUTO AI MODE', style: AppTextStyles.body),
            subtitle: Text('AI PLAYS WHEN IDLE', style: AppTextStyles.bodySecondary),
            value: _autoAI,
            onChanged: (v) => setState(() => _autoAI = v),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildGameSetup() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.white, width: 2),
      ),
      child: Column(
        children: [
          _buildSetupRow('COLOR', ['WHITE', 'BLACK'], (v) => setState(() => _selectedColor = v)),
          const Divider(color: AppColors.white, thickness: 1),
          _buildSetupRow('BOARD', ['CLASSIC', 'PERSPECTIVE'], (v) => setState(() => _boardStyle = v)),
        ],
      ),
    );
  }

  Widget _buildSetupRow(String label, List<String> options, Function(String) onSelect) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body),
        Row(
          children: options.map((opt) {
            bool isSel = (label == 'COLOR' && _selectedColor == opt) || (label == 'BOARD' && _boardStyle == opt);
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: GestureDetector(
                onTap: () => onSelect(opt),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  color: isSel ? AppColors.white : AppColors.black,
                  child: Text(
                    opt,
                    style: AppTextStyles.bodySecondary.copyWith(color: isSel ? AppColors.black : AppColors.white),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return PrimaryButton(
      text: 'START GAME',
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => GameScreen(
          aiLevel: _selectedLevel,
          playerIsWhite: _selectedColor == 'WHITE',
          vsPlayer: _selectedMode == 'PLAYER vs PLAYER',
          autoAiMode: _autoAI,
        )));
      },
    );
  }
}
