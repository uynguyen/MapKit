//
//  ViewController.swift
//  iTrust
//
//  Created by Uy Nguyen Long on 11/24/17.
//  Copyright © 2017 Uy Nguyen Long. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
class Artwork: NSObject, MKAnnotation {
    let title: String?
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
}

extension UIImage {
    func crop( rect: CGRect) -> UIImage {
        var rect = rect
        rect.origin.x*=self.scale
        rect.origin.y*=self.scale
        rect.size.width*=self.scale
        rect.size.height*=self.scale
        
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
}

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var selectedChurchIndex: Int?
    var churchs = [Church]()
    var selectedChurch: Church?
    
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        self.selectedChurch = self.churchs[self.selectedChurchIndex!]
        
    }
    
    func addAnnotation(location: CLLocationCoordinate2D) {
        // show artwork on map
        let artwork = Artwork(title: (self.selectedChurch?.name)!,
                              locationName: (self.selectedChurch?.address)!,
                              discipline: "Sculpture",
                              coordinate: location)
        mapView.addAnnotation(artwork)
    }
    
    var lineColor = UIColor.red
    
    func drawRoutes(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        let sourcePlaceMark = MKPlacemark.init(coordinate: source, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark.init(coordinate: destination, addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlaceMark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        // 7.
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        // 8.
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            let eta = response.routes[0].expectedTravelTime
            print("ETA time \(eta/60) mins")
            let mins = eta / 60
            if (mins <= 0.7) {
                self.lineColor = UIColor.gray
            }
            else if (mins <= 1) {
                self.lineColor = UIColor.red
            }
            else {
                self.lineColor = UIColor.orange
            }
            
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        LoggerManager.instance.debug("Selected church \(selectedChurch?.name) \(selectedChurch?.address)")
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = selectedChurch?.address
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            
            let matchingItems = response.mapItems
            for place in matchingItems {
                self.addAnnotation(location:  place.placemark.coordinate)
                
                self.drawRoutes(source: locValue, destination: place.placemark.coordinate)
            }
        }
        
        
//        let destination = CLLocationCoordinate2D(latitude: locValue.latitude + 0.00123, longitude: locValue.longitude + 0.00123)
//        
//        self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(locValue, 250, 250), animated: true)
//        
//        // show artwork on map
//        self.addAnnotation(location: destination)
//        
//        let des2 = CLLocationCoordinate2D(latitude: locValue.latitude - 0.00123, longitude: locValue.longitude + 0.00123)
//        let des3 = CLLocationCoordinate2D(latitude: locValue.latitude - 0.00123, longitude: locValue.longitude - 0.00123)
//        let des4 = CLLocationCoordinate2D(latitude: locValue.latitude + 0.00123, longitude: locValue.longitude - 0.00123)
//        
//        self.addAnnotation(location: des2)
//        
//        self.addAnnotation(location: des3)
//        
//        self.addAnnotation(location: des4)
//        
//        
//        self.drawRoutes(source: locValue, destination: destination)
//        self.drawRoutes(source: locValue, destination: des2)
//        self.drawRoutes(source: locValue, destination: des3)
//        self.drawRoutes(source: locValue, destination: des4)
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = self.lineColor
        
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't want to show a custom image if the annotation is the user's location.
        guard !(annotation is MKUserLocation) else {
            return nil
        }
        
        // Better to make this class property
        let annotationIdentifier = "AnnotationIdentifier"
        
        var annotationView: MKAnnotationView?
        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
            annotationView = dequeuedAnnotationView
            annotationView?.annotation = annotation
        }
        else {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        
        if let annotationView = annotationView {
            // Configure your annotation view here
            annotationView.canShowCallout = true
            
            
            
            annotationView.image = self.resizeImage(image: (self.selectedChurch?.image!)! , targetSize: CGSize.init(width: 100, height: 100))
        }
        
        return annotationView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

