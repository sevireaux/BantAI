import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';

class LguMapScreen extends StatefulWidget {
  const LguMapScreen({super.key});

  @override
  State<LguMapScreen> createState() => _LguMapScreenState();
}

class _LguMapScreenState extends State<LguMapScreen> {
  Set<Marker> _markers = {};
  Set<Circle> _hotspots = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final reportsRes = await ApiClient.instance.get('/map/reports');
      final hotspotsRes = await ApiClient.instance.get('/map/hotspots');
      final pins = reportsRes['pins'] as List;
      final hotspots = hotspotsRes['hotspots'] as List;

      setState(() {
        _markers = pins
            .map((p) => Marker(
                  markerId: MarkerId(p['id'] as String),
                  position: LatLng((p['lat'] as num).toDouble(), (p['lng'] as num).toDouble()),
                  infoWindow: InfoWindow(title: p['title'] as String?, snippet: p['status'] as String?),
                ))
            .toSet();
        _hotspots = hotspots
            .map((h) => Circle(
                  circleId: CircleId(h['id'] as String),
                  center: LatLng((h['centerLat'] as num).toDouble(), (h['centerLng'] as num).toDouble()),
                  radius: 40.0 + ((h['reportCount'] as num).toDouble() * 8),
                  fillColor: AppColors.accent.withValues(alpha: 0.15),
                  strokeColor: AppColors.accent,
                  strokeWidth: 1,
                ))
            .toSet();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Civic Map')),
      body: Stack(children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(target: LatLng(14.6760, 121.0437), zoom: 13),
          markers: _markers,
          circles: _hotspots,
          myLocationButtonEnabled: false,
        ),
        if (_loading) const Positioned(top: AppSpacing.md, left: 0, right: 0, child: Center(child: CircularProgressIndicator())),
      ]),
    );
  }
}
