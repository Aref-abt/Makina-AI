import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import '../../../../shared/widgets/spin_360.dart';
import '../../../../core/constants/constants.dart';
import '../../../../shared/data/models/models.dart';
import '../../../../shared/data/services/mock_data_service.dart';

// Helper class for component positioning
class _ComponentPosition {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double width;
  final double height;

  _ComponentPosition({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.width,
    required this.height,
  });
}

class Machine3DViewer extends StatefulWidget {
  final String machineId;
  final String? highlightedComponentId;

  const Machine3DViewer({
    super.key,
    required this.machineId,
    this.highlightedComponentId,
  });

  @override
  State<Machine3DViewer> createState() => _Machine3DViewerState();
}

class _Machine3DViewerState extends State<Machine3DViewer>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  double _rotationX = 0.15;
  double _rotationY = 0.0;
  double _scale = 1.0;
  String? _selectedComponentId;
  final MockDataService _mockData = MockDataService();

  List<ComponentModel> get components =>
      _mockData.getMachineComponents(widget.machineId);

  @override
  void initState() {
    super.initState();
    _selectedComponentId = widget.highlightedComponentId;
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > AppDimensions.mobileBreakpoint;

    return Column(
      children: [
        Expanded(
          flex: isTablet ? 2 : 3,
          child: GestureDetector(
            onScaleUpdate: (details) {
              setState(() {
                _scale = (_scale * details.scale).clamp(0.5, 2.0);
                _rotationY += details.focalPointDelta.dx * 0.01;
                _rotationX += details.focalPointDelta.dy * 0.01;
                _rotationX = _rotationX.clamp(-0.5, 0.5);
              });
            },
            child: Container(
              margin: const EdgeInsets.all(AppDimensions.paddingL),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: AnimatedBuilder(
                      animation: _rotationController,
                      builder: (context, child) {
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateX(_rotationX)
                            ..rotateY(_rotationY +
                                _rotationController.value * 2 * math.pi * 0.05)
                            ..scale(_scale),
                          child: _build3DMachine(isDark),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    right: 12,
                    top: 12,
                    child: Column(
                      children: [
                        _buildControlButton(
                          icon: Icons.add,
                          onTap: () => setState(
                              () => _scale = (_scale * 1.2).clamp(0.5, 2.0)),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 8),
                        _buildControlButton(
                          icon: Icons.remove,
                          onTap: () => setState(
                              () => _scale = (_scale / 1.2).clamp(0.5, 2.0)),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 8),
                        _buildControlButton(
                          icon: Icons.refresh,
                          onTap: () => setState(() {
                            _rotationX = 0.15;
                            _rotationY = 0.0;
                            _scale = 1.0;
                          }),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.darkCard : AppColors.white)
                            .withOpacity(0.95),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusM),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Health Status',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkText
                                  : AppColors.lightText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildLegendItem('Critical', AppColors.critical),
                          _buildLegendItem('Warning', AppColors.warning),
                          _buildLegendItem('Healthy', AppColors.healthy),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 12,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.darkCard : AppColors.white)
                              .withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Drag to rotate • Pinch to zoom',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: isTablet ? 1 : 2,
          child: Container(
            margin: const EdgeInsets.fromLTRB(AppDimensions.paddingL, 0,
                AppDimensions.paddingL, AppDimensions.paddingL),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingL),
                  child: Row(
                    children: [
                      Icon(Icons.settings_outlined,
                          size: 20,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.lightText),
                      const SizedBox(width: 8),
                      Text('Components',
                          style: AppTextStyles.h6.copyWith(
                              color: isDark
                                  ? AppColors.darkText
                                  : AppColors.lightText)),
                      const Spacer(),
                      Text('Tap to inspect',
                          style: AppTextStyles.labelSmall.copyWith(
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary)),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingS),
                    itemCount: components.length,
                    itemBuilder: (context, index) {
                      final component = components[index];
                      final isSelected = _selectedComponentId == component.id;
                      final isHighlighted =
                          widget.highlightedComponentId == component.id;
                      return _buildComponentTile(
                          component, isSelected, isHighlighted, isDark);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _build3DMachine(bool isDark) {
    final machine =
        _mockData.machines.firstWhere((m) => m.id == widget.machineId);
    final String imagePath = _getMachineImagePath(machine.type);
    // Prefer a 3D model asset named after the machine id (assets/models/<machineId>.glb or .gltf).
    // If present, show a ModelViewer for true 3D rotation; otherwise fall back to the SVG image.
    final Future<String?> _hasModel = rootBundle
        .load('assets/models/${machine.id}.glb')
        .then((_) => 'assets/models/${machine.id}.glb')
        .catchError((_) => rootBundle
            .load('assets/models/${machine.id}.gltf')
            .then((_) => 'assets/models/${machine.id}.gltf')
            .catchError((_) => null));

    return FutureBuilder<String?>(
      future: _hasModel,
      builder: (context, snapshot) {
        final modelPath = snapshot.data;

        if (modelPath != null) {
          final modelWidget = SizedBox(
            width: 320,
            height: 320,
            child: ModelViewer(
              src: modelPath,
              autoRotate: false,
              cameraControls: true,
              alt: machine.name,
              loading: Loading.eager,
              disableZoom: false,
            ),
          );
          return Stack(
            alignment: Alignment.center,
            children: [modelWidget, _buildComponentHealthOverlays(isDark)],
          );
        }

        // If no 3D model, check for a 360 image spin sequence at
        // assets/images/spins/<machineId>/frame_000.png and use Spin360 if present.
        return FutureBuilder<bool>(
          future: rootBundle
              .load('assets/images/spins/${machine.id}/frame_000.png')
              .then((_) => true)
              .catchError((_) => false),
          builder: (context, spinSnapshot) {
            final hasSpin = spinSnapshot.data == true;
            final imageWidget = Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: SvgPicture.asset(
                imagePath,
                width: 240,
                height: 240,
              ),
            );

            if (hasSpin) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 320,
                    height: 320,
                    child: Center(
                      child: Spin360(
                          folder: 'assets/images/spins/${machine.id}',
                          frameCount: 36),
                    ),
                  ),
                  _buildComponentHealthOverlays(isDark),
                ],
              );
            }

            return Stack(
              alignment: Alignment.center,
              children: [imageWidget, _buildComponentHealthOverlays(isDark)],
            );
          },
        );
      },
    );
  }

  Widget _buildComponentHealthOverlays(bool isDark) {
    return SizedBox.expand(
      child: Stack(
        children: components.asMap().entries.map((entry) {
          final index = entry.key;
          final component = entry.value;
          final color = component.healthStatus == HealthStatus.critical
              ? AppColors.critical
              : component.healthStatus == HealthStatus.warning
                  ? AppColors.warning
                  : AppColors.healthy;

          // Position overlays based on component index - using simple class instead of records
          final positions = [
            _ComponentPosition(
                top: 50.0, left: 80.0, width: 80.0, height: 50.0),
            _ComponentPosition(
                top: 100.0, left: 20.0, width: 50.0, height: 40.0),
            _ComponentPosition(
                top: 140.0, right: 20.0, width: 45.0, height: 35.0),
            _ComponentPosition(
                top: 60.0, right: 60.0, width: 60.0, height: 50.0),
            _ComponentPosition(
                bottom: 40.0, left: 50.0, width: 50.0, height: 40.0),
          ];

          if (index >= positions.length) return const SizedBox.shrink();

          final pos = positions[index];
          final isSelected = _selectedComponentId == component.id;

          return Positioned(
            top: pos.top,
            bottom: pos.bottom,
            left: pos.left,
            right: pos.right,
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedComponentId = component.id);
                _showComponentDetails(component.id);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: pos.width,
                height: pos.height,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? color : color.withOpacity(0.4),
                    width: isSelected ? 3 : 2,
                  ),
                  boxShadow: isSelected ||
                          component.healthStatus == HealthStatus.critical
                      ? [
                          BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 3)
                        ]
                      : null,
                ),
                child: Center(
                  child: Icon(
                    Icons.warning_rounded,
                    size: isSelected ? 28 : 20,
                    color: color,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getMachineImagePath(String machineType) {
    final key = machineType.toLowerCase();
    if (key.contains('cnc') ||
        key.contains('milling') ||
        key.contains('lathe')) {
      return 'assets/images/machine_cnc.svg';
    }
    if (key.contains('motor')) {
      return 'assets/images/machine_motor.svg';
    }
    if (key.contains('pump')) {
      return 'assets/images/machine_pump.svg';
    }
    if (key.contains('press') || key.contains('hydraulic')) {
      return 'assets/images/machine_press.svg';
    }
    if (key.contains('conveyor')) {
      return 'assets/images/machine_conveyor.svg';
    }
    if (key.contains('robot')) {
      return 'assets/images/machine_robot.svg';
    }
    if (key.contains('packag')) {
      return 'assets/images/machine_packaging.svg';
    }
    if (key.contains('hvac') || key.contains('air handler')) {
      return 'assets/images/machine_hvac.svg';
    }
    if (key.contains('compressor')) {
      return 'assets/images/machine_compressor.svg';
    }

    return 'assets/images/machine_cnc.svg';
  }

  Widget _buildControlButton(
      {required IconData icon,
      required VoidCallback onTap,
      required bool isDark}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)
          ],
        ),
        child: Icon(icon,
            size: 20, color: isDark ? AppColors.darkText : AppColors.lightText),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 6),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }

  Widget _buildComponentTile(ComponentModel component, bool isSelected,
      bool isHighlighted, bool isDark) {
    return InkWell(
      onTap: () {
        setState(() => _selectedComponentId = component.id);
        _showComponentDetails(component.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingXS),
        padding: const EdgeInsets.all(AppDimensions.paddingM),
        decoration: BoxDecoration(
          color: isSelected || isHighlighted
              ? component.healthStatus.color.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
              color: isSelected || isHighlighted
                  ? component.healthStatus.color
                  : Colors.transparent,
              width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: component.healthStatus.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(_getComponentIcon(component.type),
                  color: component.healthStatus.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(component.name,
                      style: AppTextStyles.labelLarge.copyWith(
                          color:
                              isDark ? AppColors.darkText : AppColors.lightText,
                          fontWeight: isHighlighted
                              ? FontWeight.bold
                              : FontWeight.w500)),
                  Text(component.type,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: component.healthStatus.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(component.healthStatus.displayName,
                      style: AppTextStyles.labelSmall.copyWith(
                          color: component.healthStatus.color,
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 4),
                Text('Risk: ${(component.riskLevel * 100).toStringAsFixed(0)}%',
                    style: AppTextStyles.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getComponentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'motor':
        return Icons.electric_bolt;
      case 'bearing':
        return Icons.settings;
      case 'pump':
        return Icons.water_drop;
      case 'electronics':
        return Icons.memory;
      default:
        return Icons.build;
    }
  }

  void _showComponentDetails(String componentId) {
    final component = components.firstWhere((c) => c.id == componentId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppDimensions.paddingXL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: component.healthStatus.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(_getComponentIcon(component.type),
                          color: component.healthStatus.color, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(component.name, style: AppTextStyles.h5),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: component.healthStatus.color
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(component.healthStatus.displayName,
                                style: AppTextStyles.labelSmall.copyWith(
                                    color: component.healthStatus.color,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Risk Level',
                    style: AppTextStyles.labelMedium.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: component.riskLevel,
                    minHeight: 8,
                    backgroundColor:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        component.healthStatus.color),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                    '${(component.riskLevel * 100).toStringAsFixed(0)}% risk of failure',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: component.healthStatus.color)),
                const SizedBox(height: 24),
                Text('Sensor Readings', style: AppTextStyles.h6),
                const SizedBox(height: 12),
                ...component.sensorReadings.entries.map((entry) =>
                    _buildSensorReading(entry.key, entry.value, isDark)),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSensorReading(String type, double value, bool isDark) {
    String unit = '';
    bool isAbnormal = false;
    switch (type.toLowerCase()) {
      case 'temperature':
        unit = '°C';
        isAbnormal = value > 85;
        break;
      case 'vibration':
        unit = 'mm/s';
        isAbnormal = value > 5;
        break;
      case 'current':
        unit = 'A';
        isAbnormal = value > 42;
        break;
      case 'pressure':
        unit = 'bar';
        isAbnormal = value > 6;
        break;
      default:
        unit = '';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightGrey,
        borderRadius: BorderRadius.circular(10),
        border: isAbnormal
            ? Border.all(color: AppColors.critical.withOpacity(0.5))
            : null,
      ),
      child: Row(
        children: [
          Icon(_getSensorIcon(type),
              size: 20,
              color:
                  isAbnormal ? AppColors.critical : AppColors.primaryDarkGreen),
          const SizedBox(width: 12),
          Expanded(
              child: Text(
                  type.substring(0, 1).toUpperCase() + type.substring(1),
                  style: AppTextStyles.labelMedium)),
          Text('${value.toStringAsFixed(1)} $unit',
              style: AppTextStyles.labelLarge.copyWith(
                  color: isAbnormal
                      ? AppColors.critical
                      : AppColors.primaryDarkGreen,
                  fontWeight: FontWeight.bold)),
          if (isAbnormal) ...[
            const SizedBox(width: 8),
            Icon(Icons.warning_amber, size: 16, color: AppColors.critical)
          ],
        ],
      ),
    );
  }

  IconData _getSensorIcon(String type) {
    switch (type.toLowerCase()) {
      case 'temperature':
        return Icons.thermostat;
      case 'vibration':
        return Icons.vibration;
      case 'current':
        return Icons.electric_bolt;
      case 'pressure':
        return Icons.speed;
      default:
        return Icons.sensors;
    }
  }
}
