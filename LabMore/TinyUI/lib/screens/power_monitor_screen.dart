import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';

class PowerMonitorScreen extends StatelessWidget {
  final MqttService mqttService;

  const PowerMonitorScreen({super.key, required this.mqttService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141A18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2420),
        title: const Text('Power Monitor', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ValueListenableBuilder<PowerMetrics>(
        valueListenable: mqttService.powerMetrics,
        builder: (context, metrics, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildMetricCard(
                  'Voltage',
                  '${metrics.voltage.toStringAsFixed(1)} V',
                  Icons.electrical_services,
                  Colors.yellow,
                ),
                const SizedBox(height: 12),
                _buildMetricCard(
                  'Current',
                  '${metrics.current.toStringAsFixed(3)} A',
                  Icons.electric_bolt,
                  Colors.cyan,
                ),
                const SizedBox(height: 12),
                _buildMetricCard(
                  'Power',
                  '${metrics.power.toStringAsFixed(1)} W',
                  Icons.power,
                  Colors.orange,
                ),
                const SizedBox(height: 12),
                _buildMetricCard(
                  'Energy',
                  '${metrics.energy.toStringAsFixed(3)} kWh',
                  Icons.battery_full,
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildMetricCard(
                  'Frequency',
                  '${metrics.frequency.toStringAsFixed(1)} Hz',
                  Icons.timer,
                  Colors.purple,
                ),
                const SizedBox(height: 12),
                _buildMetricCard(
                  'Power Factor',
                  metrics.powerFactor.toStringAsFixed(2),
                  Icons.speed,
                  Colors.red,
                ),
                const Spacer(),
                Text(
                  'Last update: ${metrics.lastUpdate.toString().split('.').first}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2420),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
