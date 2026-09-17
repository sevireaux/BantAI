import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/api_client.dart';
import '../../core/theme.dart';

const Map<String, Color> _severityMarkerColor = {
  'Low': AppColors.severityLow,
  'Moderate': AppColors.severityModerate,
  'High': AppColors.severityHigh,
  'Critical': AppColors.severityCritical,
};

class CitizenMapScreen extends StatefulWidget {
  const CitizenMapScreen({super.key});

  @override
  State<CitizenMapScreen> createState() => _CitizenMapScreenState();
}

class _CitizenMapScreenState extends State<CitizenMapScreen> {
  Set<Marker> _markers = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient.instance.get('/map/reports');
      final pins = res['pins'] as List;
      setState(() {
        _markers = pins
            .map((p) => Marker(
                  markerId: MarkerId(p['id'] as String),
                  position: LatLng((p['lat'] as num).toDouble(), (p['lng'] as num).toDouble()),
                  icon: BitmapDescriptor.defaultMarkerWithHue(_hueFor(p['severity'] as String?)),
                  infoWindow: InfoWindow(title: p['title'] as String?, snippet: '${p['status']} · ${p['category'] ?? ''}'),
                ))
            .toSet();
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  double _hueFor(String? severity) {
    switch (severity) {
      case 'Critical':
        return BitmapDescriptor.hueRed;
      case 'High':
        return BitmapDescriptor.hueOrange;
      case 'Moderate':
        return BitmapDescriptor.hueYellow;
      default:
        return BitmapDescriptor.hueGreen;
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
          myLocationButtonEnabled: false,
        ),
        if (_loading) const Positioned(top: AppSpacing.md, left: 0, right: 0, child: Center(child: CircularProgressIndicator())),
      ]),
    );
  }
}
