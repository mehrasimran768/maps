//
//  ViewController.swift
//  map_assignment
//
//  Created by simran mehra on 2023-01-13.
//

import UIKit
import MapKit

class ViewController: UIViewController,CLLocationManagerDelegate{
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var directionBtn: UIButton!
    @IBOutlet weak var zoomOut: UIButton!
    @IBOutlet weak var zoomIN: UIButton!
    @IBOutlet weak var segmentControlOutlet: UISegmentedControl!
    // create location manager
    var locationMnager = CLLocationManager()
    
    // destination variable
    var destination: CLLocationCoordinate2D!
    
    // create the places array
    let places = Place.getPlaces()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        map.isZoomEnabled = false
        map.showsUserLocation = true
        
        directionBtn.isHidden = true
        
        // we assign the delegate property of the location manager to be this class
        locationMnager.delegate = self
        
        // we define the accuracy of the location
        locationMnager.desiredAccuracy = kCLLocationAccuracyBest
        
        // rquest for the permission to access the location
        locationMnager.requestWhenInUseAuthorization()
        
        // start updating the location
        locationMnager.startUpdatingLocation()
        
        // 1st step is to define latitude and longitude
        let latitude: CLLocationDegrees = 43.64
        let longitude: CLLocationDegrees = -79.38
        
        // 2nd step is to display the marker on the map
        //        displayLocation(latitude: latitude, longitude: longitude, title: "Toronto City", subtitle: "You are here")
        
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(addLongPressAnnotattion))
        map.addGestureRecognizer(uilpgr)
        
        // add double tap
        addDoubleTap()
        
        // giving the delegate of MKMapViewDelegate to this class
        map.delegate = self
        
        // add annotations for the places
        addAnnotationsForPlaces()
        
        // add polyline
        
        
        // add polygon
        addPolygon()
        
        
    }

    
    @IBAction func zoomOut(_ sender: UIButton){
            let span = MKCoordinateSpan(latitudeDelta: map.region.span.latitudeDelta*2, longitudeDelta: map.region.span.longitudeDelta*2)
            let region = MKCoordinateRegion(center: map.region.center, span: span)

            map.setRegion(region, animated: true)
        }
  
    @IBAction func zoomIn(_ sender: Any) {
        let span = MKCoordinateSpan(latitudeDelta: map.region.span.latitudeDelta*0.5, longitudeDelta: map.region.span.longitudeDelta*0.5)
        let region = MKCoordinateRegion(center: map.region.center, span: span)

        map.setRegion(region, animated: true)
    }
    
    
    //MARK: - draw route between two places
    @IBAction func drawRoutee(_ sender: Any) {
        map.removeOverlays(map.overlays)
        
        let sourcePlaceMark = MKPlacemark(coordinate: locationMnager.location!.coordinate)
        let destinationPlaceMark = MKPlacemark(coordinate: destination)
        // request a direction
        let directionRequest = MKDirections.Request()
        
        // assign the source and destination properties of the request
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        
        // transportation type
        directionRequest.transportType = .walking
        
        // calculate the direction
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResponse = response else {return}
            // create the route
            let route = directionResponse.routes[0]
            // drawing a polyline
            self.map.addOverlay(route.polyline, level: .aboveRoads)
            
            // define the bounding map rect
            let rect = route.polyline.boundingMapRect
            self.map.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100), animated: true)
            
           self.map.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }

    //MARK: - didupdatelocation method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        removePin()
//        print(locations.count)
        let userLocation = locations[0]
        
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        displayLocation(latitude: latitude, longitude: longitude, title: "my location", subtitle: "you are here")
    }
    
    //MARK: - add annotations for the places
    func addAnnotationsForPlaces() {
        map.addAnnotations(places)
        
        let overlays = places.map {MKCircle(center: $0.coordinate, radius: 2000)}
        map.addOverlays(overlays)
    }
    
    //MARK: - polyline method
    func addPolyline() {
        let coordinates = places.map {$0.coordinate}
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        map.addOverlay(polyline)
    }
    func addPolygon() {
        let coordinates = places.map {$0.coordinate}
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        map.addOverlay(polygon)
    }
    //MARK: - double tap func
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin))
        doubleTap.numberOfTapsRequired = 2
        map.addGestureRecognizer(doubleTap)
        
    }

    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        
        removePin()
        
        // add annotation
        let touchPoint = sender.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        let annotation = MKPointAnnotation()
        annotation.title = "my destination"
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
        
        destination = coordinate
        directionBtn.isHidden = false
    }
    
    //MARK: - long press gesture recognizer for the annotation
    @objc func addLongPressAnnotattion(gestureRecognizer: UIGestureRecognizer) {
        let touchPoint = gestureRecognizer.location(in: map)
        let coordinate = map.convert(touchPoint, toCoordinateFrom: map)
        
        // add annotation for the coordinatet
        let annotation = MKPointAnnotation()
        annotation.title = "my favorite"
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
    }
    
    //MARK: - remove pin from map
    func removePin() {
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }
        
//        map.removeAnnotations(map.annotations)
    }
    
    //MARK: - display user location method
    func displayLocation(latitude: CLLocationDegrees,
                         longitude: CLLocationDegrees,
                         title: String,
                         subtitle: String) {
        // 2nd step - define span
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        // 3rd step is to define the location
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        // 4th step is to define the region
        let region = MKCoordinateRegion(center: location, span: span)
        
        // 5th step is to set the region for the map
        map.setRegion(region, animated: true)
        
        // 6th step is to define annotation
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        map.addAnnotation(annotation)
    }

}

extension ViewController: MKMapViewDelegate {
    
    //MARK: - viewFor annotation method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        switch annotation.title {
        case "my location":
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
            annotationView.markerTintColor = UIColor.blue
            return annotationView
        case "my destination":
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
            annotationView.animatesDrop = true
            annotationView.pinTintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            return annotationView
        case "my favorite":
            let annotationView = map.dequeueReusableAnnotationView(withIdentifier: "customPin") ?? MKPinAnnotationView()
            annotationView.image = UIImage(named: "ic_place_2x")
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return annotationView
        default:
            return nil
        }
    }
    
    //MARK: - rendrer for overlay func
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let rendrer = MKCircleRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.black.withAlphaComponent(0.5)
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 2
            return rendrer
        } else if overlay is MKPolyline {
            let rendrer1 = MKPolylineRenderer(overlay: overlay)
            rendrer1.strokeColor = UIColor.blue
            rendrer1.lineWidth = 5
            rendrer1.lineDashPattern = [0,8]
            return rendrer1
        }
        else if overlay is MKPolyline {
            let rendrer = MKPolylineRenderer(overlay: overlay)
            rendrer.strokeColor = UIColor.blue
            rendrer.lineWidth = 3
            rendrer.lineDashPattern = [0,1]
            return rendrer
        }
        else if overlay is MKPolygon {
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red.withAlphaComponent(0.6)
            rendrer.strokeColor = UIColor.yellow
            rendrer.lineWidth = 2
            return rendrer}
        
        return MKOverlayRenderer()
    }
}
