import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapView extends StatefulWidget {
  final Function(LatLng) onLocationSelected;

  MapView({required this.onLocationSelected});

  @override
  _MapViewState createState() => _MapViewState(onLocationSelected: onLocationSelected);
}

class _MapViewState extends State<MapView> {
  final Function(LatLng) onLocationSelected;
  LatLng _markerLocation = LatLng(-25.3905, -51.4623); // Alterado para a localização inicial de Guarapuava

  _MapViewState({required this.onLocationSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Color.fromRGBO(0, 0, 0, 0), // Verde em RGB
          width: 2, // Espessura da borda
        ),
        borderRadius: BorderRadius.circular(12), // Cantos arredondados
      ),
      width: 390, // Ajuste conforme necessário
      height: 200, // Ajuste conforme necessário
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12), // Isso vai garantir que o mapa também tenha cantos arredondados
        child: FlutterMap(
          options: MapOptions(
            center: LatLng(-25.3905, -51.4623), // Coordenadas para Guarapuava, Brasil
            zoom: 13.0,
            onTap: (TapPosition position, LatLng latLng) {
              setState(() {
                _markerLocation = latLng;
                onLocationSelected(latLng);  // Chame a função callback com a nova localização
              });
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
              "https://tile.thunderforest.com/atlas/{z}/{x}/{y}.png?apikey=58a5f6a7ac864b49b32410f82c8ceca0",
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 90.0,
                  height: 90.0,
                  point: _markerLocation,
                  builder: (ctx) => Container(
                    child: Icon(
                      Icons.location_pin,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
