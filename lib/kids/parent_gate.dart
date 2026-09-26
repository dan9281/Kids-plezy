import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'kids_config.dart';

/// Shows a "grown-ups only" PIN pad instead of [child] until the parent PIN
/// from [KidsConfig.parentPin] has been entered.
///
/// Designed for a TV remote first: every key is reachable with the D-pad and
/// activated with the centre/OK button. Number keys on a keyboard or remote
/// also work.
class ParentGate extends StatefulWidget {
  const ParentGate({super.key, required this.child, this.relockOnDispose = false});

  final Widget child;

  /// Lock again when this gate leaves the tree (used for pushed settings
  /// routes, which are disposed when popped).
  final bool relockOnDispose;

  @override
  State<ParentGate> createState() => _ParentGateState();
}

class _ParentGateState extends State<ParentGate> {
  @override
  void dispose() {
    if (widget.relockOnDispose) KidsConfig.lock();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: KidsConfig.parentUnlocked,
      builder: (context, unlocked, _) => unlocked ? widget.child : const _PinPad(),
    );
  }
}

class _PinPad extends StatefulWidget {
  const _PinPad();

  @override
  State<_PinPad> createState() => _PinPadState();
}

class _PinPadState extends State<_PinPad> {
  String _entered = '';
  bool _wrong = false;

  int get _pinLength => KidsConfig.parentPin.length;

  void _press(String digit) {
    if (_entered.length >= _pinLength) return;
    setState(() {
      _wrong = false;
      _entered += digit;
    });
    if (_entered.length == _pinLength) {
      if (_entered == KidsConfig.parentPin) {
        KidsConfig.parentUnlocked.value = true;
      } else {
        setState(() {
          _wrong = true;
          _entered = '';
        });
      }
    }
  }

  void _backspace() {
    if (_entered.isEmpty) return;
    setState(() {
      _wrong = false;
      _entered = _entered.substring(0, _entered.length - 1);
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final label = event.character;
    if (label != null && label.length == 1 && RegExp(r'[0-9]').hasMatch(label)) {
      _press(label);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      _backspace();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Widget padKey(String label, {VoidCallback? onTap, IconData? icon, bool autofocus = false}) {
      return Padding(
        padding: const EdgeInsets.all(6),
        child: _PadKey(
          autofocus: autofocus,
          onTap: onTap ?? () => _press(label),
          child: icon != null ? Icon(icon, size: 28) : Text(label, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        ),
      );
    }

    Widget row(List<Widget> keys) => Row(mainAxisSize: MainAxisSize.min, children: keys);

    return Focus(
      onKeyEvent: _onKey,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_rounded, size: 56, color: scheme.primary),
                const SizedBox(height: 12),
                Text('Grown-ups only', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(
                  _wrong ? 'That PIN wasn\'t right — try again' : 'Enter the parent PIN to open Settings',
                  style: theme.textTheme.bodyMedium?.copyWith(color: _wrong ? scheme.error : null),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < _pinLength; i++)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < _entered.length ? scheme.primary : Colors.transparent,
                          border: Border.all(color: scheme.primary, width: 2),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                row([padKey('1', autofocus: true), padKey('2'), padKey('3')]),
                row([padKey('4'), padKey('5'), padKey('6')]),
                row([padKey('7'), padKey('8'), padKey('9')]),
                row([
                  const SizedBox(width: 84, height: 84),
                  padKey('0'),
                  padKey('', icon: Icons.backspace_rounded, onTap: _backspace),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A round keypad button with an obvious focus ring for D-pad navigation.
class _PadKey extends StatefulWidget {
  const _PadKey({required this.onTap, required this.child, this.autofocus = false});

  final VoidCallback onTap;
  final Widget child;
  final bool autofocus;

  @override
  State<_PadKey> createState() => _PadKeyState();
}

class _PadKeyState extends State<_PadKey> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FocusableActionDetector(
      autofocus: widget.autofocus,
      mouseCursor: SystemMouseCursors.click,
      onShowFocusHighlight: (v) {
        if (mounted) setState(() => _focused = v);
      },
      actions: {ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
        widget.onTap();
        return null;
      })},
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.select): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
        SingleActivator(LogicalKeyboardKey.gameButtonA): ActivateIntent(),
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _focused ? scheme.primary : scheme.surface,
            border: Border.all(color: _focused ? scheme.onSurface : scheme.outline, width: _focused ? 3 : 1),
          ),
          child: IconTheme.merge(
            data: IconThemeData(color: _focused ? scheme.onPrimary : scheme.onSurface),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: _focused ? scheme.onPrimary : scheme.onSurface),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
