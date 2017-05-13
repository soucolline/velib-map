//
//  MapViewController.swift
//  velib-map
//
//  Created by Thomas Guilleminot on 16/04/2017.
//  Copyright © 2017 Thomas Guilleminot. All rights reserved.
//

import UIKit
import Just
import SwiftyJSON
import MBProgressHUD
import MapKit
import CoreLocation

class MapViewController: UIViewController {
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var reloadBtn: UIBarButtonItem! {
    didSet {
      let icon = UIImage(named: "reload")
      let iconSize = CGRect(origin: CGPoint(x: 0,y :0), size: icon!.size)
      let iconButton = UIButton(frame: iconSize)
      iconButton.setBackgroundImage(icon, for: .normal)
      iconButton.setBackgroundImage(icon, for: .highlighted)
      reloadBtn.customView = iconButton
    }
  }
  
  var stations = [Station]()
  let initialLocation = CLLocation(latitude: 48.866667, longitude: 2.333333)
  let locationManager = CLLocationManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "Velibs"
    self.navigationController?.navigationBar.barTintColor = UIColor.orange
    self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(reloadPins))
    self.reloadBtn.customView?.addGestureRecognizer(tap)
    
    self.mapView.delegate = self
    self.locationManager.delegate = self
    self.locationManager.requestWhenInUseAuthorization()
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    self.locationManager.requestLocation()
    
    self.reloadPins()
  }
  
  func fetchPins() {
    let response = Just.get(Api.stationFrom(.paris).url)
    if response.ok {
      let responseJSON = JSON(response.json as Any)
      let _ = responseJSON.map{ $0.1 }.map {
        let station = Mapper.mapStations(newsJSON: $0)
        self.stations.append(station)
      }
    } else {
      self.present(PopupManager.errorPopup(message: "Impossible de recuperer les informations des stations"), animated: true)
    }
  }
  
  func showPins() {
    let _ = self.stations.map{ self.mapView.addAnnotation($0) }
  }
  
  func centerMapOnLocation(location: CLLocation) {
    let regionRadius: CLLocationDistance = 1000
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                              regionRadius * 2.0, regionRadius * 2.0)
    self.mapView.setRegion(coordinateRegion, animated: true)
  }
  
  func reloadPins() {
    let loader = MBProgressHUD.showAdded(to: self.view, animated: true)
    loader.label.text = "Downloading pins"
    
    self.mapView.removeAnnotations(self.stations)
    self.stations.removeAll()
    self.fetchPins()
    self.showPins()
    UIView.animate(withDuration: 0.5, animations: { () -> Void in
      self.reloadBtn.customView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
    })
    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: { () -> Void in
      self.reloadBtn.customView?.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 2))
    })
    MBProgressHUD.hide(for: self.view, animated: true)
  }
  
}

extension MapViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard let annotation = annotation as? Station
      else { return nil }
    
    let identifier = "velibPin"
    let pin: MKAnnotationView
    var imageName = ""
    
    if let bikes = annotation.availableBikes {
      imageName = "pin-\(bikes)"
    }
    
    if annotation.status! == "CLOSED" {
      imageName = "pin-red"
    }
    
    if let deqeuedView = self.mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
      deqeuedView.annotation = annotation
      pin = deqeuedView
    } else {
      pin = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
      pin.canShowCallout = true
    }
    
    pin.image = UIImage(named: imageName)
    
    return pin
  }
}

extension MapViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = manager.location
      else { return }
    
    self.centerMapOnLocation(location: location)
    self.locationManager.stopUpdatingLocation()
    self.locationManager.delegate = nil
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    self.centerMapOnLocation(location: self.initialLocation)
  }
}