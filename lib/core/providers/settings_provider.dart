import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global settings state that persists to disk.
/// Wrap your app with ChangeNotifierProvider of SettingsProvider and listen here.
class SettingsProvider extends ChangeNotifier {
  static const _kSoundEffects         = 'sound_effects';
  static const _kPieceAudio           = 'piece_audio';
  static const _kAnimations           = 'animations';
  static const _kPixelGridOverlay     = 'pixel_grid_overlay';
  static const _kBoardType            = 'board_type';
  static const _kPieceStyle           = 'piece_style';

  bool soundEffects     = true;
  bool pieceMovementAudio = false;
  bool animations       = true;
  bool pixelGridOverlay = true;
  String boardType      = 'PERSPECTIVE';
  String pieceStyle     = 'BATTLE';

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    soundEffects      = p.getBool(_kSoundEffects)         ?? true;
    pieceMovementAudio= p.getBool(_kPieceAudio)           ?? false;
    animations        = p.getBool(_kAnimations)           ?? true;
    pixelGridOverlay  = p.getBool(_kPixelGridOverlay)     ?? true;
    boardType         = p.getString(_kBoardType)          ?? 'PERSPECTIVE';
    pieceStyle        = p.getString(_kPieceStyle)         ?? 'BATTLE';
    notifyListeners();
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kSoundEffects,     soundEffects);
    await p.setBool(_kPieceAudio,       pieceMovementAudio);
    await p.setBool(_kAnimations,       animations);
    await p.setBool(_kPixelGridOverlay, pixelGridOverlay);
    await p.setString(_kBoardType,      boardType);
    await p.setString(_kPieceStyle,     pieceStyle);
  }

  void setSoundEffects(bool v)     { soundEffects      = v; _save(); notifyListeners(); }
  void setPieceAudio(bool v)       { pieceMovementAudio= v; _save(); notifyListeners(); }
  void setAnimations(bool v)       { animations        = v; _save(); notifyListeners(); }
  void setPixelGrid(bool v)        { pixelGridOverlay  = v; _save(); notifyListeners(); }
  void setBoardType(String v)      { boardType         = v; _save(); notifyListeners(); }
  void setPieceStyle(String v)     { pieceStyle        = v; _save(); notifyListeners(); }
}
