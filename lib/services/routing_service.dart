import 'package:geolocator/geolocator.dart';

class RouteStep {
  final String instruction;
  final String distance;
  final String icon;

  RouteStep({
    required this.instruction,
    required this.distance,
    required this.icon,
  });
}

class RouteDetail {
  final double distanceMeters;
  final int estimatedDurationMinutes;
  final List<RouteStep> steps;

  RouteDetail({
    required this.distanceMeters,
    required this.estimatedDurationMinutes,
    required this.steps,
  });
}

class RoutingService {
  RouteDetail computeRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    final distanceMeters = Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
    // Average municipal city vehicle speed ~25 km/h -> ~416 meters per minute
    final minutes = (distanceMeters / 400).ceil().clamp(3, 45);

    return RouteDetail(
      distanceMeters: distanceMeters,
      estimatedDurationMinutes: minutes,
      steps: [
        RouteStep(
          instruction: 'Depart Field Depot on Central Expressway',
          distance: '450 m',
          icon: 'straight',
        ),
        RouteStep(
          instruction: 'Turn right onto Metro North Boulevard',
          distance: '1.2 km',
          icon: 'turn_right',
        ),
        RouteStep(
          instruction: 'Take second exit at Grand Roundabout onto Elm St',
          distance: '800 m',
          icon: 'roundabout_right',
        ),
        RouteStep(
          instruction: 'Arrive at civic reported hazard site on right',
          distance: '150 m',
          icon: 'location_on',
        ),
      ],
    );
  }
}
