import '../complaint_store.dart';

class AiClassificationResult {
  final String category;
  final String priority;
  final String department;
  final double urgencyScore;
  final int etaHours;
  final List<String> matchedSignals;
  final String reasoning;

  const AiClassificationResult({
    required this.category,
    required this.priority,
    required this.department,
    required this.urgencyScore,
    required this.etaHours,
    required this.matchedSignals,
    required this.reasoning,
  });
}

class ZoneInsight {
  final String zone;
  final int incidents;
  final String risk;

  const ZoneInsight({
    required this.zone,
    required this.incidents,
    required this.risk,
  });
}

class CityInsightBundle {
  final List<ZoneInsight> accidentZones;
  final List<ZoneInsight> garbageHotspots;
  final List<ZoneInsight> waterLeakageTrends;
  final String predictiveSummary;
  final String recommendation;

  const CityInsightBundle({
    required this.accidentZones,
    required this.garbageHotspots,
    required this.waterLeakageTrends,
    required this.predictiveSummary,
    required this.recommendation,
  });
}

class SmartCityAiEngine {
  static const Map<String, List<String>> _categorySignals = {
    'Road Damage': [
      'pothole',
      'road',
      'accident',
      'crack',
      'street broken',
      'flyover',
      'traffic',
      'bump',
    ],
    'Water Leakage': [
      'water',
      'pipeline',
      'leak',
      'sewer',
      'drain',
      'flood',
      'overflow',
      'burst',
    ],
    'Street Light': [
      'street light',
      'dark',
      'light',
      'electric',
      'pole',
      'voltage',
      'wire',
    ],
    'Garbage': [
      'garbage',
      'waste',
      'trash',
      'smell',
      'dump',
      'bin',
      'cleaning',
    ],
    'Emergency': [
      'fire',
      'injured',
      'blood',
      'critical',
      'sos',
      'ambulance',
      'unsafe',
      'danger',
    ],
  };

  static const Map<String, String> _departmentMap = {
    'Road Damage': 'Roads & Transport',
    'Water Leakage': 'Water & Sanitation',
    'Street Light': 'Power & Electrical',
    'Garbage': 'Waste Management',
    'Emergency': 'Emergency Response Unit',
  };

  static AiClassificationResult classifyComplaint({
    required String description,
    String? selectedCategory,
  }) {
    final text = description.toLowerCase().trim();

    final categoryScores = <String, double>{
      for (final category in _categorySignals.keys) category: 0,
    };
    final matchedSignals = <String>[];

    for (final entry in _categorySignals.entries) {
      for (final signal in entry.value) {
        if (text.contains(signal)) {
          categoryScores[entry.key] = (categoryScores[entry.key] ?? 0) + 0.16;
          matchedSignals.add(signal);
        }
      }
    }

    if (selectedCategory != null &&
        selectedCategory.isNotEmpty &&
        selectedCategory != 'Auto Detect') {
      categoryScores[selectedCategory] =
          (categoryScores[selectedCategory] ?? 0) + 0.20;
    }

    String category = selectedCategory ?? 'Road Damage';
    double bestScore = -1;
    for (final entry in categoryScores.entries) {
      if (entry.value > bestScore) {
        bestScore = entry.value;
        category = entry.key;
      }
    }

    if (bestScore <= 0 &&
        (selectedCategory == null || selectedCategory == 'Auto Detect')) {
      category = 'Road Damage';
    }

    double urgency = 0.35;
    urgency += (bestScore * 0.80).clamp(0, 0.40);

    if (_containsAny(text, const [
      'accident',
      'injured',
      'fire',
      'danger',
      'critical',
      'burst',
      'electrocution',
    ])) {
      urgency += 0.22;
    }

    if (_containsAny(text, const [
      'school',
      'hospital',
      'main road',
      'market',
    ])) {
      urgency += 0.08;
    }

    if (text.length > 110) {
      urgency += 0.05;
    }

    urgency = urgency.clamp(0.0, 0.99);

    String priority;
    if (urgency >= 0.75) {
      priority = 'High';
    } else if (urgency >= 0.50) {
      priority = 'Medium';
    } else {
      priority = 'Low';
    }

    final department = _departmentMap[category] ?? 'General Civic Services';
    final etaHours = _estimateEtaHours(category: category, priority: priority);

    final reasoning =
        'AI classified this complaint as $category with urgency ${(urgency * 100).toStringAsFixed(0)}%. '
        'Auto-assigned to $department with estimated resolution in $etaHours hours.';

    return AiClassificationResult(
      category: category,
      priority: priority,
      department: department,
      urgencyScore: urgency,
      etaHours: etaHours,
      matchedSignals: matchedSignals,
      reasoning: reasoning,
    );
  }

  static CityInsightBundle buildCityInsights(List<Complaint> complaints) {
    final accidentZones = _topZones(
      complaints.where((c) => c.issueType == 'Road Damage').toList(),
    );
    final garbageHotspots = _topZones(
      complaints.where((c) => c.issueType == 'Garbage').toList(),
    );
    final leakageTrends = _topZones(
      complaints.where((c) => c.issueType == 'Water Leakage').toList(),
    );

    final openCount = complaints.where((c) => c.status != 'Resolved').length;
    final highPriority = complaints.where((c) => c.priority == 'High').length;

    final predictiveSummary =
        'AI trend model predicts ${openCount > 6 ? 'increased' : 'stable'} complaint volume over next 72 hours. '
        'High-priority load is $highPriority, requiring faster officer routing and preventive maintenance.';

    final recommendation =
        'Deploy preventive teams to top accident and leakage zones during off-peak hours, '
        'and schedule waste removal at hotspots every 12 hours for 1 week.';

    return CityInsightBundle(
      accidentZones: accidentZones,
      garbageHotspots: garbageHotspots,
      waterLeakageTrends: leakageTrends,
      predictiveSummary: predictiveSummary,
      recommendation: recommendation,
    );
  }

  static List<ZoneInsight> _topZones(List<Complaint> complaints) {
    final zoneCount = <String, int>{};

    for (final complaint in complaints) {
      final zone = _extractZone(complaint.location);
      zoneCount[zone] = (zoneCount[zone] ?? 0) + 1;
    }

    final zones = zoneCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return zones.take(4).map((entry) {
      final risk = entry.value >= 4
          ? 'Critical'
          : entry.value >= 2
          ? 'High'
          : 'Moderate';

      return ZoneInsight(zone: entry.key, incidents: entry.value, risk: risk);
    }).toList();
  }

  static bool _containsAny(String text, List<String> values) {
    for (final value in values) {
      if (text.contains(value)) {
        return true;
      }
    }
    return false;
  }

  static String _extractZone(String location) {
    final parts = location.split(',');
    if (parts.isEmpty) return location.trim();
    return parts.first.trim();
  }

  static int _estimateEtaHours({
    required String category,
    required String priority,
  }) {
    final baseCategoryEta = <String, int>{
      'Road Damage': 36,
      'Water Leakage': 24,
      'Street Light': 30,
      'Garbage': 18,
      'Emergency': 6,
    };

    final base = baseCategoryEta[category] ?? 32;
    if (priority == 'High') return (base * 0.50).round();
    if (priority == 'Medium') return base;
    return (base * 1.45).round();
  }
}
