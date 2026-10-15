import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/location_service.dart';
import 'app_providers.dart';

final currentLocationProvider = FutureProvider<LocationResult>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return locationService.getCurrentLocation();
});
