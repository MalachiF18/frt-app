import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../models/target_spec.dart';
import '../models/weapon_spec.dart';
import '../services/feedback_service.dart';
import '../widgets/painters/range_painter.dart';
import '../widgets/painters/weapon_painter.dart';
import '../widgets/target_controls_bar.dart';

class RangeScreen extends StatefulWidget {
  const RangeScreen({
    super.key,
    required this.weapon,
    this.feedbackService = const FeedbackService(),
  });

  final WeaponSpec weapon;
  final FeedbackService feedbackService;

  @override
  State<RangeScreen> createState() => _RangeScreenState();
}

class _RangeScreenState extends State<RangeScreen>
    with SingleTickerProviderStateMixin {
  final _random = math.Random();
  final List<HitMark> _hits = [];

  Timer? _fireTimer;

  late int _rounds;
  late AnimationController _reloadController;

  bool _rapidFire = false;
  bool _firing = false;
  bool _reloading = false;

  int _shot = 0;

  // Target customization state
  TargetType _targetType = TargetType.bullseye;
  TargetDistance _targetDistance = TargetDistance.yd7;

  // Timer & Statistics state
  DateTime? _firstShotTime;
  DateTime? _lastShotTime;
  double _latestSplit = 0.0;

  @override
  void initState() {
    super.initState();
    _rounds = widget.weapon.capacity;

    _reloadController = AnimationController(
      vsync: this,
      duration: _reloadDuration(),
    );
  }

  Duration _reloadDuration() {
    switch (widget.weapon.type) {
      case WeaponType.glock19x:
      case WeaponType.glock17:
        return const Duration(milliseconds: 900);
      case WeaponType.riflePistol:
        return const Duration(milliseconds: 1100);
      case WeaponType.dp12:
        return const Duration(milliseconds: 950);
    }
  }

  int get _totalScore {
    return _hits.fold(0, (sum, hit) => sum + hit.score);
  }

  double get _accuracyPercentage {
    if (_hits.isEmpty) return 0.0;
    final onTargetHits = _hits.where((h) => h.score > 0).length;
    return (onTargetHits / _hits.length) * 100;
  }

  double get _totalElapsedTime {
    if (_firstShotTime == null || _lastShotTime == null) return 0.0;
    return _lastShotTime!.difference(_firstShotTime!).inMilliseconds / 1000.0;
  }

  void _pressStart() {
    if (_rounds == 0 || _reloading) {
      widget.feedbackService.triggerClickHaptic();
      return;
    }

    _fire();

    if (_rapidFire) {
      _fireTimer = Timer.periodic(
        const Duration(milliseconds: 110),
        (_) => _fire(),
      );
    }
  }

  void _fire() {
    if (_rounds == 0 || _reloading) {
      _pressEnd();
      return;
    }

    final now = DateTime.now();

    setState(() {
      _rounds--;
      _shot++;
      _firing = true;

      if (_firstShotTime == null) {
        _firstShotTime = now;
        _latestSplit = 0.0;
      } else if (_lastShotTime != null) {
        _latestSplit = now.difference(_lastShotTime!).inMilliseconds / 1000.0;
      }
      _lastShotTime = now;

      // Dispersion scale based on target distance
      final dispersion = _targetDistance.dispersionFactor;
      final hitDx = .5 + (_random.nextDouble() - .5) * .34 * dispersion;
      final hitDy = .5 + (_random.nextDouble() - .5) * .34 * dispersion;
      final hitRatio = Offset(hitDx.clamp(0.0, 1.0), hitDy.clamp(0.0, 1.0));

      final score = TargetScoring.calculateScore(hitRatio, _targetType);

      _hits.add(HitMark(
        offset: hitRatio,
        score: score,
        timestamp: now,
        shotIndex: _shot,
      ));
    });

    if (_targetType == TargetType.steelGong) {
      widget.feedbackService.triggerSteelImpactHaptic();
    } else {
      widget.feedbackService.triggerFireHaptic();
    }

    Future<void>.delayed(
      const Duration(milliseconds: 75),
      () {
        if (mounted) {
          setState(() {
            _firing = false;
          });
        }
      },
    );
  }

  void _pressEnd() {
    _fireTimer?.cancel();
    _fireTimer = null;
  }

  Future<void> _reload() async {
    if (_reloading) return;

    _pressEnd();

    setState(() {
      _reloading = true;
      _firing = false;
    });

    widget.feedbackService.triggerReloadHaptic();

    await _reloadController.forward(from: 0);

    if (!mounted) return;

    setState(() {
      _rounds = widget.weapon.capacity;
      _reloading = false;
    });

    _reloadController.reset();
  }

  void _resetTarget() {
    _pressEnd();
    setState(() {
      _hits.clear();
      _firstShotTime = null;
      _lastShotTime = null;
      _latestSplit = 0.0;
    });
    widget.feedbackService.triggerClickHaptic();
  }

  double _recoilX() {
    switch (widget.weapon.type) {
      case WeaponType.glock19x:
      case WeaponType.glock17:
        return -10;
      case WeaponType.riflePistol:
        return -16;
      case WeaponType.dp12:
        return -22;
    }
  }

  double _recoilY() {
    switch (widget.weapon.type) {
      case WeaponType.glock19x:
      case WeaponType.glock17:
        return 2;
      case WeaponType.riflePistol:
        return 4;
      case WeaponType.dp12:
        return 7;
    }
  }

  double _recoilAngle() {
    switch (widget.weapon.type) {
      case WeaponType.glock19x:
      case WeaponType.glock17:
        return -0.035;
      case WeaponType.riflePistol:
        return -0.05;
      case WeaponType.dp12:
        return -0.075;
    }
  }

  double _recoilScale() {
    switch (widget.weapon.type) {
      case WeaponType.glock19x:
      case WeaponType.glock17:
        return .992;
      case WeaponType.riflePistol:
        return .987;
      case WeaponType.dp12:
        return .98;
    }
  }

  double _reloadAngle(double progress) {
    final wave = math.sin(math.pi * progress);
    switch (widget.weapon.type) {
      case WeaponType.glock19x:
      case WeaponType.glock17:
        return -.10 * wave;
      case WeaponType.riflePistol:
        return -.14 * wave;
      case WeaponType.dp12:
        return .055 * math.sin(math.pi * 2 * progress);
    }
  }

  double _reloadY(double progress) {
    final wave = math.sin(math.pi * progress);
    switch (widget.weapon.type) {
      case WeaponType.glock19x:
      case WeaponType.glock17:
        return 7 * wave;
      case WeaponType.riflePistol:
        return 11 * wave;
      case WeaponType.dp12:
        return 13 * wave;
    }
  }

  double _reloadX(double progress) {
    switch (widget.weapon.type) {
      case WeaponType.glock19x:
      case WeaponType.glock17:
        return 0;
      case WeaponType.riflePistol:
        return -5 * math.sin(math.pi * progress);
      case WeaponType.dp12:
        return -8 * math.sin(math.pi * progress);
    }
  }

  @override
  void dispose() {
    _fireTimer?.cancel();
    _reloadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090A0B),
      appBar: AppBar(
        title: Text(widget.weapon.name),
        backgroundColor: const Color(0xFF17191B),
      ),
      body: Column(
        children: [
          // Target custom controls bar
          TargetControlsBar(
            targetType: _targetType,
            targetDistance: _targetDistance,
            accentColor: widget.weapon.accent,
            onTargetTypeChanged: (type) => setState(() => _targetType = type),
            onTargetDistanceChanged: (dist) => setState(() => _targetDistance = dist),
            onResetTarget: _resetTarget,
          ),

          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Range Target View
                CustomPaint(
                  painter: RangePainter(
                    hits: _hits,
                    targetType: _targetType,
                    targetDistance: _targetDistance,
                  ),
                ),

                // Interactive Firearm View
                Align(
                  alignment: const Alignment(0, .72),
                  child: AnimatedBuilder(
                    animation: _reloadController,
                    builder: (context, child) {
                      final progress = _reloadController.value;

                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..translate(
                            _reloading ? _reloadX(progress) : 0.0,
                            _reloading ? _reloadY(progress) : 0.0,
                          )
                          ..rotateZ(
                            _reloading ? _reloadAngle(progress) : 0.0,
                          ),
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (_) => _pressStart(),
                          onTapUp: (_) => _pressEnd(),
                          onTapCancel: _pressEnd,
                          child: AnimatedContainer(
                            key: const Key('fire-control'),
                            duration: const Duration(milliseconds: 70),
                            curve: Curves.easeOutCubic,
                            transformAlignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..translate(
                                _firing ? _recoilX() : 0.0,
                                _firing ? _recoilY() : 0.0,
                              )
                              ..rotateZ(
                                _firing ? _recoilAngle() : 0.0,
                              )
                              ..scale(
                                _firing ? _recoilScale() : 1.0,
                              ),
                            child: CustomPaint(
                              size: const Size(360, 160),
                              painter: WeaponPainter(
                                weapon: widget.weapon,
                                firing: _firing,
                                shot: _shot,
                                reloading: _reloading,
                                reloadProgress: progress,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Top Left: Ammo Display
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: widget.weapon.accent),
                    ),
                    child: Text(
                      'AMMO  $_rounds / ${widget.weapon.capacity}',
                      key: const Key('ammo-count'),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

                // Top Right: Score & Timer HUD
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: widget.weapon.accent.withOpacity(0.6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'SCORE  $_totalScore (${_accuracyPercentage.toStringAsFixed(0)}%)',
                          key: const Key('score-count'),
                          style: TextStyle(
                            color: widget.weapon.accent,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'TIME ${_totalElapsedTime.toStringAsFixed(2)}s  SPLIT +${_latestSplit.toStringAsFixed(2)}s',
                          key: const Key('timer-count'),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Reloading Overlay
                if (_reloading)
                  Positioned(
                    top: 70,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: widget.weapon.accent),
                      ),
                      child: const Text(
                        'RELOADING...',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Bottom Control Dock
          Container(
            color: const Color(0xFF17191B),
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 14),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: SwitchListTile(
                        key: const Key('rapid-fire-switch'),
                        title: const Text(
                          'FRT / RAPID FIRE',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          _rapidFire ? 'ON - hold to fire' : 'OFF - single shot',
                        ),
                        value: _rapidFire,
                        activeThumbColor: widget.weapon.accent,
                        onChanged: _reloading
                            ? null
                            : (value) {
                                _pressEnd();
                                setState(() {
                                  _rapidFire = value;
                                });
                              },
                      ),
                    ),
                  ),

                  FilledButton.icon(
                    key: const Key('reload-button'),
                    onPressed: _reloading ? null : _reload,
                    icon: _reloading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      _reloading ? 'RELOADING' : 'RELOAD',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
