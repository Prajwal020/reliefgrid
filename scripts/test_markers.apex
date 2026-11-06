List<MapMarkerController.Marker> markers = MapMarkerController.getMarkers();
System.debug('MARKERS_COUNT: ' + markers.size());
for (MapMarkerController.Marker m : markers) {
    System.debug('MARKER: ' + m.title + ' | ' + m.kind + ' | ' + m.latitude + ',' + m.longitude);
}
