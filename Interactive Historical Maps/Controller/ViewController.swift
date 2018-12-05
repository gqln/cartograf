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

class ViewController: UIViewController, MKMapViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let model = Model.shared
    
    var element : MapElement?
    
    // Elements should become two different arrays, as overlays and annotations are treated very differently
    var elements : [MapElement] = []
    var mode : MapMode = .viewing
    
    var date : HistoricalDate = HistoricalDate(month: 8, year: 1332)
    var earliest : HistoricalDate = HistoricalDate(month: 8, year: 1332)
    var latest : HistoricalDate = HistoricalDate(month: 2, year: 1346)
    
    let timeIncrement = 2
    
    
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var addPathButton: UIButton!
    @IBOutlet weak var addRegionButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var inspectorElementName: UITextField!
    
    @IBOutlet weak var startMonthPicker: UIPickerView!
    @IBOutlet weak var endMonthPicker: UIPickerView!
    
    @IBOutlet weak var startYearTextField: UITextField!
    @IBOutlet weak var endYearTextField: UITextField!
    
    @IBOutlet weak var startEraPicker: UIPickerView!
    @IBOutlet weak var endEraPicker: UIPickerView!
    
    @IBOutlet weak var startDateWarningLabel: UILabel!
    @IBOutlet weak var endDateWarningLabel: UILabel!
    
    @IBOutlet weak var inspectorScrollView: UIScrollView!
    @IBOutlet weak var inspectorView: UIView!
    
    @IBAction func sliderChanged(_ sender: Any) {
        date.rawValue = Int(slider.value)
        updateDate()
        updateMap()
    }
    
    @IBAction func doneClicked(_ sender: Any) {
        mode = .viewing
        elements.append(element!)
        
        element = nil
        updateMap()
        updateUI()
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        mode = .viewing
       
        element = nil
        updateMap()
        updateUI()
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        // check if keyboard is present? -- keyboardWillAppear/Disappear with bool stored prop flag
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        // Gestures
        let pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        pressGesture.minimumPressDuration = 0.75
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        
        mapView.addGestureRecognizer(pressGesture)
        mapView.addGestureRecognizer(tapGesture)
        
        startMonthPicker.delegate = self
        startEraPicker.delegate = self
        endMonthPicker.delegate = self
        endEraPicker.delegate = self
        startMonthPicker.dataSource = self
        startEraPicker.dataSource = self
        endMonthPicker.dataSource = self
        endEraPicker.dataSource = self
        
        startYearTextField.keyboardType = .numberPad
        endYearTextField.keyboardType = .numberPad
        
        inspect(point: nil)
        
        inspectorScrollView.delegate = self
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inspectorScrollView.contentSize = inspectorView.frame.size
        inspectorScrollView.bounds.size = inspectorView.frame.size
        
        print(inspectorScrollView.contentSize, inspectorView.frame.size)
    }
    
    @objc func keyboardWillShow(notification:Notification) {
        let info = notification.userInfo!
        let keyboardSize = info[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect
        inspectorScrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: (keyboardSize?.height)! + 25, right: 0)
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        inspectorScrollView.contentInset = UIEdgeInsets.zero
        inspectorScrollView.bounds.size = inspectorView.frame.size
        inspectorScrollView.contentInset = UIEdgeInsets.zero
    }
    
    @objc func longPress(_ recognizer: UIGestureRecognizer) {
        switch mode {
        case .viewing:
            if recognizer.state == .began {
                let touch = recognizer.location(in: mapView)
                let coordinate = mapView.convert(touch, toCoordinateFrom: mapView)
                
                let point = Point(from: date.past, to: date.future, at: coordinate)
                point.new = true
                add(element: point)
                updateMap()
            }
        case .addingPath:
            switch recognizer.state {
            case .began:
                let touch = recognizer.location(in: mapView)
                let coordinate = mapView.convert(touch, toCoordinateFrom: mapView)
                
                element = Path(on: date.copy, at: coordinate)
                
                mode = .editingPath
                
                updateUI()
                updateDate()
                updateMap()
            case .cancelled, .failed, .possible:
                element = nil
                mode = .viewing
            default:
                assert(false, "Should have changed to .editing")
            }
        case .editingPath:
            switch recognizer.state {
            case .began:
                break
            case .changed:
                let touch = recognizer.location(in: mapView)
                let coordinate = mapView.convert(touch, toCoordinateFrom: mapView)
                
                if date + timeIncrement < latest {
                    date += timeIncrement
                    let path = element as! Path
                    path.extend(on: date.copy, to: coordinate)
                } else {
                    recognizer.state = .ended
                }
                
                updateDate()
                updateMap()
            case .ended:
                let path = element as! Path
                date += timeIncrement
                path.end(on: date.copy)
                
                updateDate()
                updateMap()
            case .cancelled, .failed, .possible:
                element = nil
                mode = .viewing
            }
        default:
            break
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "pointElement"
        switch annotation {
        case is Point:
            let point = annotation as! Point
            let isPointNew = point.new
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                let pin = annotationView as! MKPinAnnotationView
                
                pin.animatesDrop = isPointNew
                
                if isPointNew {
                    point.new = false
                }
                
                pin.annotation = annotation
                let calloutView = pin.detailCalloutAccessoryView as! CalloutView
                calloutView.element = annotation as! Point
                return pin
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
                    
//                    calloutView.delegate = self
                    calloutView.element = annotation as! Point
                }
                
                annotationView.isEnabled = true
                annotationView.canShowCallout = true
                annotationView.animatesDrop = point.new
                
                if isPointNew {
                    point.new = false
                }
                
                return annotationView
            }
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        switch view {
        case is MKPinAnnotationView:
//            (view as! MKPinAnnotationView).setSelected(true, animated: true)
            (view as! MKPinAnnotationView).pinTintColor = MKPinAnnotationView.greenPinColor()
            let point = view.annotation as! Point
            inspect(point: point)
        case is MKOverlay:
            let path = view.annotation as! Path
            inspect(path: path)
        default:
            break
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        switch view {
        case is MKPinAnnotationView:
            (view as! MKPinAnnotationView).pinTintColor = MKPinAnnotationView.redPinColor()
            inspect(point: nil)
        default:
            break
        }
    }
    
    @IBAction func dismissHelp() {
        dismiss(animated: true, completion: nil)
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
    
    func inspect(point maybePoint: Point?) {
        if let point = maybePoint {
            inspectorElementName.text = point.name
            startMonthPicker.selectRow(point.start.rawMonth, inComponent: 0, animated: false)
            startYearTextField.text = String(point.start.rawYear.magnitude)
            startEraPicker.selectRow(point.start.rawEra, inComponent: 0, animated: false)
            
            endMonthPicker.selectRow(point.end.rawMonth, inComponent: 0, animated: false)
            endYearTextField.text = String(point.end.rawYear.magnitude)
            endEraPicker.selectRow(point.end.rawEra, inComponent: 0, animated: false)
        } else {
            inspectorElementName.text = ""
            startMonthPicker.selectRow(0, inComponent: 0, animated: false)
            startYearTextField.text = "0"
            startEraPicker.selectRow(0, inComponent: 0, animated: false)
            
            endMonthPicker.selectRow(0, inComponent: 0, animated: false)
            endYearTextField.text = "0"
            endEraPicker.selectRow(0, inComponent: 0, animated: false)
        }
    }
    
    func inspect(path maybePath: Path?) {
        if let path = maybePath {
            inspectorElementName.text = path.name
            startMonthPicker.selectRow(path.start.rawMonth, inComponent: 0, animated: false)
            startYearTextField.text = String(path.start.rawYear.magnitude)
            startEraPicker.selectRow(path.start.rawEra, inComponent: 0, animated: false)
            
            endMonthPicker.selectRow(path.end.rawMonth, inComponent: 0, animated: false)
            endYearTextField.text = String(path.end.rawYear.magnitude)
            endEraPicker.selectRow(path.end.rawEra, inComponent: 0, animated: false)
        } else {
            inspectorElementName.text = ""
            startMonthPicker.selectRow(0, inComponent: 0, animated: false)
            startYearTextField.text = "0"
            startEraPicker.selectRow(0, inComponent: 0, animated: false)
            
            endMonthPicker.selectRow(0, inComponent: 0, animated: false)
            endYearTextField.text = "0"
            endEraPicker.selectRow(0, inComponent: 0, animated: false)
        }
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
        slider.value = Float(date.rawValue)
    }
    
    func updateMap() {
        let oldAnnotations = mapView.annotations as! [Point]
        // mapView.removeAnnotations(oldAnnotations)
        
        let oldOverlays = mapView.overlays
        mapView.removeOverlays(oldOverlays)
        
        let currentElements = elements.filter { (element) -> Bool in
            element.start <= date && date <= element.end
        }
        
        let newMapObjects = currentElements.map { (element) -> MKAnnotation in
            element.annotation(for: date)
        }
        
        let newAnnotations = newMapObjects.filter { (annotation) -> Bool in
            !(annotation is MKOverlay)
        }
        let newOverlays = newMapObjects.filter { (annotation) -> Bool in
            annotation is MKOverlay
        } as! [MKOverlay]
        
//        let newDivider = newAnnotations.partition { (newAnnotation) -> Bool in
//            oldAnnotations.contains(where: { (oldAnnotation) -> Bool in
//                oldAnnotation.isEqual(newAnnotation)
//            })
//        }
//
//        let oldDivider = oldAnnotations.partition { (oldAnnotation) -> Bool in
//            !newAnnotations.contains(where: { (newAnnotation) -> Bool in
//                oldAnnotation.isEqual(newAnnotation)
//            })
//        }
//
//        if newDivider <= newAnnotations.count {
//             let annotationsToAdd = Array(newAnnotations[0..<newDivider])
//             mapView.addAnnotations(annotationsToAdd)
//             print("added", annotationsToAdd)
//        }
//
//        if oldDivider <= oldAnnotations.count {
//            let annotationsToRemove = Array(oldAnnotations[0..<oldDivider])
//            mapView.removeAnnotations(annotationsToRemove)
//            print("removed", annotationsToRemove)
//        }
        
        if element != nil {
            switch element {
            case is Point:
                 mapView.addAnnotation(element!.annotation(for: date))
            case is Path:
                 mapView.addOverlay(element!.annotation(for: date) as! MKOverlay)
            default:
                assert(false, "unhandled element type")
            }
        }
        
        mapView.addAnnotations(newAnnotations)
        
        for oldAnnotation in oldAnnotations {
            if !newAnnotations.contains(where: { (annotation) -> Bool in
                annotation.isEqual(oldAnnotation)
            }) {
                mapView.removeAnnotation(oldAnnotation)
            }
        }
        
        mapView.addOverlays(newOverlays)
        // mapView.addAnnotations(newAnnotations)
    }
    
    // MARK: - PickerView
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case is CustomPickerView:
            let customPickerView = pickerView as! CustomPickerView
            switch component {
            case 0:
                return customPickerView.count
            default:
                assert(false, "Unhandled picker component")
            }
        default:
            assert(false, "Unhandled pickerView")
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case is CustomPickerView:
            let customPickerView = pickerView as! CustomPickerView
            switch component {
            case 0:
                return customPickerView.options[row]
            default:
                assert(false, "Unhandled picker component")
            }
        default:
            assert(false, "Unhandled pickerView")
        }
    }
    
    // MARK: - TextField
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        inspectorView.frame = CGRect(x: 0, y: -110, width: 300, height: 834)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        inspectorView.frame = CGRect(x: 0, y: 0, width: 300, height: 834)
        self.view.endEditing(true)
        return true
    }
    
    // MARK: - REMOVE
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(inspectorScrollView.contentSize, inspectorView.frame.size)
        print(inspectorScrollView.contentOffset)
        print(inspectorScrollView.bounds.size.height)
        print(inspectorScrollView.contentInset)
    }
    
}

protocol CustomPickerView  {
    var count : Int { get }
    var options : [String] { get }
}

class MonthPickerView : UIPickerView, CustomPickerView {
    let count = 12
    let options = HistoricalDate.months
}

class EraPickerView : UIPickerView, CustomPickerView {
    let count = 2
    let options = HistoricalDate.eras
}

