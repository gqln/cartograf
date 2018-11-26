//
//  ViewController.swift
//  Interactive Historical Maps
//
//  Created by Goki on 11/2/18.
//  Copyright © 2018 Gokulan Gnanendran. All rights reserved.
//

import UIKit
import MapKit

enum MapMode {
    case viewing, creatingPoint, addingPath, addingRegion, editingPath, editingRegion
}

protocol MapDelegate {
    func pickDates(for element: MapElement)
}

class ViewController: UIViewController, MKMapViewDelegate, MapDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var element : MapElement?
    var elements : [MapElement] = []
    var mode : MapMode = .viewing
    
    var date : HistoricalDate = HistoricalDate(month: 8, year: 1332)
    var earliest : HistoricalDate = HistoricalDate(month: 8, year: 1332)
    var latest : HistoricalDate = HistoricalDate(month: 2, year: 1346)
    
    let rateOfChange = 2
    
    
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var addPathButton: UIButton!
    @IBOutlet weak var addRegionButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func sliderChanged(_ sender: Any) {
        date.rawValue = Int(slider.value)
        updateDate()
        updateMap()
    }
    
    @IBAction func doneClicked(_ sender: Any) {
        mode = .viewing
        updateUI()
    }
    
    
    @IBAction func cancelClicked(_ sender: Any) {
        mode = .viewing
        updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        // Gestures
        let pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        pressGesture.minimumPressDuration = 1.0
        
        mapView.addGestureRecognizer(pressGesture)
        
        
        // Example Data -- REMOVE EVENTUALLY
        let element1 = Point(from: HistoricalDate(month: 4, year: 1333), to: HistoricalDate(month: 3, year: 1335), at: CLLocationCoordinate2D(latitude: 34.642763, longitude: -97.327818))
        let element2 = Point(from: earliest, to: HistoricalDate(month: 3, year: 1338), at: CLLocationCoordinate2D(latitude: 37.642763, longitude: -99.327818))
        let element3 = Point(from: HistoricalDate(month: 2, year: 1339), to: latest, at: CLLocationCoordinate2D(latitude: 38.642763, longitude: -98.327818))
        add(element: element1)
        add(element: element2)
        add(element: element3)
        
        slider.minimumValue = Float(earliest.rawValue)
        slider.maximumValue = Float(latest.rawValue)
        slider.value = Float(date.rawValue)
        
        updateDate()
        updateMap()
    }
    
    @objc func longPress(_ recognizer: UIGestureRecognizer) {
        switch mode {
        case .viewing:
            if recognizer.state == .began {
                let touch = recognizer.location(in: mapView)
                let coordinate = mapView.convert(touch, toCoordinateFrom: mapView)
                
                let point = Point(from: date.copy, to: date.copy, at: coordinate)
                print(date.copy)
                add(element: point)
                updateMap()
            }
        case .addingPath:
            switch recognizer.state {
            case .began:
                let touch = recognizer.location(in: mapView)
                let coordinate = mapView.convert(touch, toCoordinateFrom: mapView)
                
                element = Path(on: date.copy, at: coordinate)
                
                updateDate()
                updateMap()
            case .changed:
                let touch = recognizer.location(in: mapView)
                let coordinate = mapView.convert(touch, toCoordinateFrom: mapView)
                
                date.advance(by: rateOfChange)
                let path = element as! Path
                path.extend(on: date.copy, to: coordinate)
                
                updateDate()
                updateMap()
            case .ended:
                let path = element as! Path
                date.advance(by: rateOfChange)
                path.end(on: date.copy)
                elements.append(path)
                element = nil
                
                updateDate()
                updateMap()
            case .cancelled, .failed, .possible:
                break
            }
        default:
            break
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "pointElement"
        switch annotation {
        case is Point:
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                annotationView.annotation = annotation
                return annotationView
            } else {
                // TODO: Make this another function
                let annotationView = MKPinAnnotationView(annotation:annotation, reuseIdentifier: identifier)
                
                let calloutViewNib = UINib(nibName: "CalloutView", bundle: nil)
                let calloutViewNibViews = calloutViewNib.instantiate(withOwner: self, options: nil)
                if let calloutView = calloutViewNibViews.first as? CalloutView {
                    // Officially attach to annotation
                    annotationView.detailCalloutAccessoryView = calloutView
                    // Set constraints to keep view consistent
                    let widthConstraint = NSLayoutConstraint(item: calloutView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: 320)
                    calloutView.addConstraint(widthConstraint)
                    let heightConstraint = NSLayoutConstraint(item: calloutView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: 86)
                    calloutView.addConstraint(heightConstraint)
                    
                    calloutView.delegate = self
                    calloutView.element = annotation as! Point
                }
                
                annotationView.isEnabled = true
                annotationView.canShowCallout = true
                annotationView.leftCalloutAccessoryView = nil
                return annotationView
            }
        case is Path:
            return nil
        case is MKOverlay:
            return nil
        default:
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        switch overlay {
        case is MKPolyline:
            let line = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            line.strokeColor = UIColor.blue
            line.lineWidth = 4.0
            return line
        default:
            assert(false, "Unhandled Overlay")
        }
    }
    
    @IBAction func dismissHelp() {
        dismiss(animated: true, completion: nil)
    }
    
    func pickDates(for element: MapElement) {
        // TODO: Implement
    }
    
    @IBAction func addPath(_ sender: Any) {
        mode = .addingPath
        updateUI()
    }
    
    @IBAction func addRegion(_ sender: Any) {
        mode = .addingRegion
        updateUI()
    }
    
    func add(element: MapElement) {
        elements.append(element)
    }
    
    func updateUI() {
        switch mode {
        case .viewing:
            addPathButton.isHidden = false
            addRegionButton.isHidden = false
            
            doneButton.isHidden = true
            cancelButton.isHidden = true
        case .creatingPoint, .addingPath, .addingRegion:
            addPathButton.isHidden = true
            addRegionButton.isHidden = true
            
            doneButton.isHidden = false
            doneButton.isEnabled = false
            
            cancelButton.isHidden = false
        case .editingPath, .editingRegion:
            addPathButton.isHidden = true
            addRegionButton.isHidden = true
            
            doneButton.isHidden = false
            doneButton.isEnabled = true
            
            cancelButton.isHidden = false
        }
    
    }
    
    func updateDate() {
        monthLabel.text = date.month
        yearLabel.text = date.year
    }
    
    func updateMap() {
        let oldAnnotations = mapView.annotations
        mapView.removeAnnotations(oldAnnotations)
        
        let currentElements = elements.filter { (element) -> Bool in
            element.start <= date && date <= element.end
        }
        
        var newAnnotations = currentElements.map { (element) -> MKAnnotation in
            element.annotation(for: date)
        }
        
        if element != nil {
            newAnnotations.append(element!.annotation(for: date))
        }
        
        mapView.addAnnotations(newAnnotations)
    }
    
}

// Will be used to pick Historical Dates for points and to edit dates for other components
class HistoricalDatePicker: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    var dataSource = self
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 12
        case 1:
            // Incomplete
            return 0
        default:
            assert(false, "Not enough components in pickerview")
        }
    }
}