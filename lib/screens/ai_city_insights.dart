import 'package:flutter/material.dart';

import '../complaint_store.dart';
import '../services/ai_engine.dart';
import '../theme/app_theme.dart';

class AiCityInsightsScreen extends StatelessWidget {
  const AiCityInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final insights = SmartCityAiEngine.buildCityInsights(
      ComplaintStore.complaints,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI City Insights',
          style: TextStyle(color: AppTheme.headingOnLight),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _headerCard(
              title: 'Predictive Intelligence Engine',
              subtitle:
                  'AI continuously analyzes complaint patterns, severity, and area behavior to detect risk zones before escalation.',
            ),
            const SizedBox(height: 12),
            _insightGroup(
              title: 'High Accident Zones',
              icon: Icons.car_crash_rounded,
              color: const Color(0xFFD84D4D),
              items: insights.accidentZones,
            ),
            const SizedBox(height: 12),
            _insightGroup(
              title: 'Garbage Accumulation Pattern',
              icon: Icons.delete_sweep_rounded,
              color: const Color(0xFF2EAF63),
              items: insights.garbageHotspots,
            ),
            const SizedBox(height: 12),
            _insightGroup(
              title: 'Water Leakage Trends',
              icon: Icons.water_damage_rounded,
              color: const Color(0xFF2B87D1),
              items: insights.waterLeakageTrends,
            ),
            const SizedBox(height: 12),
            _predictionCard(
              heading: 'Predictive Analysis',
              body: insights.predictiveSummary,
              recommendation: insights.recommendation,
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCard({required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.mainHeadingDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: AppTheme.headingOnDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(color: Color(0xFFE8EEF3), height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _insightGroup({
    required String title,
    required IconData icon,
    required Color color,
    required List<ZoneInsight> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withValues(alpha: 0.14),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppTheme.headingOnLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const Text(
              'No incidents yet. AI needs more data points.',
              style: TextStyle(color: Color(0xFF546D80)),
            ),
          ...items.map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF4F9FF),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.zone,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    '${item.incidents} incidents',
                    style: const TextStyle(color: Color(0xFF5A7288)),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      item.risk,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
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

  Widget _predictionCard({
    required String heading,
    required String body,
    required String recommendation,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFFEEF7FF),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_graph_rounded, color: Color(0xFF0F609B)),
              SizedBox(width: 8),
              Text(
                'Predictive Analysis',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppTheme.headingOnLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(height: 1.35)),
          const SizedBox(height: 10),
          const Text(
            'AI Recommendation',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppTheme.headingOnLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(recommendation, style: const TextStyle(height: 1.35)),
        ],
      ),
    );
  }
}
