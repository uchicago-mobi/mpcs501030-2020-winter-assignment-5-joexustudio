//
//  ViewController.swift
//  Where in the World
//
//  Created by Sheng Xu (TT) on 2/5/20.
//  Copyright © 2020 Sheng Xu. All rights reserved.
//

import UIKit
import MapKit
import UserNotifications

class MapViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var detailView: UIView!
    @IBOutlet var detailTitleLabel: UILabel!
    @IBOutlet var detailDescriptionLabel: UILabel!
    @IBOutlet var detailFavoriteButton: UIButton!

    var places: [Place] = []  // Array of place annotations
    
    let id = MKMapViewDefaultAnnotationViewReuseIdentifier

    let dataManagerInstance = DataManager.sharedInstance  // Instance of DataManager
    
    // Extra Credit: location manager
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Request authorization and set the view controller as the location manager's delegate
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        
        // Set the view controller as the map view's delegate
        mapView.delegate = self
        
        // Set the map view's properties
        mapView.showsCompass = false  // Disable the compass
        mapView.pointOfInterestFilter = .excludingAll  // It does not show any points of intersest

        // Track the user's location on the map
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        
        // The map’s initial region
        var initialCoordinate = CLLocationCoordinate2D(latitude: 41.8781, longitude: -87.6298)
        var span = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
        // Get region data from Data.plist
        if let data = dataManagerInstance.dataFromPlist() {
            let regionData = data.region
            initialCoordinate = CLLocationCoordinate2D(latitude: regionData[0], longitude: regionData[1])
            span = MKCoordinateSpan(latitudeDelta: regionData[2], longitudeDelta: regionData[3])
        }
        // Set the current region of the map.
        let region = MKCoordinateRegion(center: initialCoordinate, span: span)
        mapView.region = region

        // Set the Detail view's properties
        detailView.alpha = 0
        detailFavoriteButton.isUserInteractionEnabled = false
        view.bringSubviewToFront(detailView)
        
        // Register the annotation view: PlaceMarkerView
        mapView.register(PlaceMarkerView.self, forAnnotationViewWithReuseIdentifier: id)

        // Add Annotations
        places = dataManagerInstance.loadAnnotationFromPlist()
        for place in places {
            mapView.addAnnotation(place)
        }
        
        // Extra Credit: Add local notifications that use a location based trigger to inform the user when they are near a point of interest.
        // Requesting authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert], completionHandler: { (isGranted, error) in
            guard isGranted && error == nil else { return }
        })
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                self.scheduleNotifications()
            }
        }

    }
    
    func scheduleNotifications() -> Void {
        for place in places {
            let notificationIdentifier = "place-notification"
            let notificationContent = UNMutableNotificationContent()
            notificationContent.title = "Close to a point of interest"
            notificationContent.subtitle = "You are near a point of interest"
            notificationContent.body = "You are near \(place.name ?? "")"
            notificationContent.sound = UNNotificationSound(named: UNNotificationSoundName("ding"))
            notificationContent.threadIdentifier = "\(place.name ?? "")-notification"
            let notificationCenter = place.coordinate
            let notificationRegion = CLCircularRegion(center: notificationCenter, radius: 200.0, identifier: "\(place.name ?? "")")
            notificationRegion.notifyOnEntry = true
            notificationRegion.notifyOnExit = false
            locationManager.startMonitoring(for: notificationRegion)
            let notificationTrigger = UNLocationNotificationTrigger(region: notificationRegion, repeats: true)
            let notificationRequest = UNNotificationRequest(identifier: notificationIdentifier, content: notificationContent, trigger: notificationTrigger)
            UNUserNotificationCenter.current().add(notificationRequest) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    @IBAction func tapDetailFavoriteButton(_ sender: UIButton)  {
        if let placeName = sender.titleLabel?.text {
            dataManagerInstance.toggleFavorite(placeName)
            if dataManagerInstance.isFavorite(placeName) {
                detailFavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            } else {
                detailFavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let favoritesVC = segue.destination as! FavoritesViewController
        favoritesVC.placeNames = dataManagerInstance.listFavorites()
        // Set the view controller as the favorite view controller's delegate
        favoritesVC.delegate = self
    }
    
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Return nil to use default annotation view for user's location
        if annotation is MKUserLocation { return nil }
        
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: id, for: annotation) as? PlaceMarkerView else {
            return nil
        }
        /*
        // Configure annotation view differently, based on whether it is favorite. NOT working when toggling favorite :(
        if dataManagerInstance.isFavorite((annotationView.annotation as! Place).name!) {
            annotationView.markerTintColor = .systemRed
            annotationView.glyphImage = UIImage(systemName: "star.fill")
        } else {
            annotationView.markerTintColor = .systemBlue
            annotationView.glyphImage = UIImage(systemName: "pin.fill")
        }
        */
        return annotationView
    }
    
    // When an annotation is tapped, the title and description of the annotation appears in the display view
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Do nothing if a cluster annotation or a user location is tapped
        if view.annotation is MKClusterAnnotation || view.annotation is MKUserLocation { return }
        // If a Place annotation is tapped
        if let place = view.annotation as! Place? {
            detailTitleLabel.text = place.name
            detailDescriptionLabel.text = place.longDescription
            if dataManagerInstance.isFavorite(place.name ?? "") {
                detailFavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            } else {
                detailFavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
            }
            detailView.alpha = 0.8
            detailFavoriteButton.isUserInteractionEnabled = true
            // Pass place name to the button. So when the button is tapped, it knows which place it's toggling
            // There should be another better way to achieve this ...
            detailFavoriteButton.titleLabel?.text = place.name
        }
    }

    // When an annotation is deselected, hide/disable the detail view
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        detailView.alpha = 0
        detailFavoriteButton.isUserInteractionEnabled = false
    }
    
}

extension MapViewController: PlacesFavoritesDelegate {
    
    // Update the map view based on the favorite place that was passed in
    func favoritePlace(name: String) {
        // 3. When the MapViewController appears, the map’s region should change to highlight the favorite place.
        let selectedFavoritePlaces = places.filter() { $0.name == name }
        if selectedFavoritePlaces.count == 0 { return }
        let selectedFavoritePlace = selectedFavoritePlaces[0]
        let selectedFavoritePlaceCoordinate = CLLocationCoordinate2D(latitude: selectedFavoritePlace.data!.lat, longitude: selectedFavoritePlace.data!.long)
        let selectedFavoritePlaceCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
        mapView.region = MKCoordinateRegion(center: selectedFavoritePlaceCoordinate, span: selectedFavoritePlaceCoordinateSpan)
        // 4. The map view’s display view should show the information for the selected favorite place.
        detailTitleLabel.text = selectedFavoritePlace.name
        detailDescriptionLabel.text = selectedFavoritePlace.longDescription
        detailFavoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
        if dataManagerInstance.isFavorite(selectedFavoritePlace.name ?? "") {
            detailFavoriteButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        }
        detailView.alpha = 0.8
        detailFavoriteButton.isUserInteractionEnabled = true
        detailFavoriteButton.titleLabel?.text = selectedFavoritePlace.name
    }
    
}

// Extra Credit
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            print("Authorized!")
            locationManager.startUpdatingLocation()
        case .notDetermined:
            print("We need to request authorization")
        default:
            print("Not authorized :(")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            for place in places {
                // https://developer.apple.com/documentation/corelocation/cllocation/1423689-distance
                if location.distance(from: CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)) < 200 {
                    // print("User is near \(place.name ?? "")!")
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let region = region as? CLCircularRegion {
            let identifier = region.identifier
            // print("User did enter region of \(identifier)!")
            let alert = UIAlertController(title: "Close to \(identifier)", message: "You are near \(identifier)!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

