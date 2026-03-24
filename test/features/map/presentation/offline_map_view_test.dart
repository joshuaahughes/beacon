import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

class StubOfflineMapView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FlutterMap(
           options: MapOptions(
            initialCenter: LatLng(0,0),
            initialZoom: 2,
          ),
          children: []
        )
      )
    );
  }
}

void main() {
  group('OfflineMapView Widget', () {
    testWidgets('renders a Flutter Map instance', (tester) async {
       await tester.pumpWidget(StubOfflineMapView());
       await tester.pumpAndSettle();

       expect(find.byType(FlutterMap), findsOneWidget);
    });
  });
}
