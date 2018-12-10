//
//  ViewController.swift
//  Interactive Historical Maps
//
//  Created by Goki on 11/2/18.
//  Copyright © 2018 Gokulan Gnanendran. All rights reserved.
//

import UIKit
import MapKit

enum MapMode : String {
    case viewing = "Editing Map"
    case addingPoint = "Adding Points"
    case addingPath = "Adding Path"
    case editingPoint = "Editing Point"
    case editingPath = "Editing Path"
}

class MapEditorViewController: UIViewController, MKMapViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIScrollViewDelegate, UITextViewDelegate, EditorViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let model = Model.shared
    
    var path : MapPath?
    
    // Elements should become two different arrays, as overlays and annotations are treated very differently
    var paths : [MapPath] = []
    var points : [MapPoint] = []
    var mode : MapMode = .viewing
    
    var date : HistoricalDate!
    var earliest : HistoricalDate!
    var latest : HistoricalDate!
    
    var chosenStart : HistoricalDate = HistoricalDate.zero.past
    var chosenEnd : HistoricalDate = HistoricalDate.zero.future
    
    let timeIncrement = 2
    
    var map : Map!
    var index: Int!
    var selectedPoint : MapPoint!
    
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var mapNameLabel: UILabel!
    
    @IBOutlet weak var addPathButton: UIButton!
    @IBOutlet weak var addRegionButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var inspectorElementName: UITextField!
    
    @IBOutlet weak var inspectorNameFieldTitleLabel: UILabel!
    
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
    @IBOutlet weak var inspectorViewModeLabel: UILabel!
    
    @IBOutlet weak var entityDescriptionTextView: UITextView!
    @IBOutlet weak var deleteEntityButton: UIButton!
    
    @IBAction func saveClicked(_ sender: Any) {
        model.saveContext()
        switch mode {
        case .viewing:
            dismiss(animated: true, completion: nil)
        case .addingPoint, .addingPath:
            inspect(map)
            change(to: .viewing)
            mapView.deselectAnnotation(selectedPoint, animated: true)
        case .editingPoint, .editingPath:
            inspect(map)
            change(to: .viewing)
        }
    }
    
    @IBAction func sliderChanged(_ sender: Any) {
        date.rawValue = Int(slider.value)
        updateDate()
        updateMap()
    }
    
    @IBAction func doneClicked(_ sender: Any) {
        if mode == .addingPath || mode == .editingPath {
            paths.append(path!)
            model.saveContext()
        }
        change(to: .viewing)
        
        path = nil
        updateMap()
        updateUI()
    }
    
    @IBAction func deleteEntityClicked(_ sender: Any) {
        switch mode {
        case .viewing:
            model.delete(map)
            model.maps.remove(at: index)
            saveClicked(self)
        case .addingPath, .editingPath:
            if path != nil {
                path = nil
                updateMap()
                change(to: .viewing)
                inspect(map)
            }
        case .addingPoint, .editingPoint:
            if selectedPoint != nil {
                model.context.delete(selectedPoint.point)
                let index = points.firstIndex(of: selectedPoint)
                if index != nil {
                    points.remove(at: index!)
                }
                mapView.removeAnnotation(selectedPoint)
                updateMap()
                change(to: .viewing)
                inspect(map)
            }
        }
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        // check if keyboard is present? -- keyboardWillAppear/Disappear with bool stored prop flag
        self.view.endEditing(true)
    }
    
    func configure(for mapIndex: Int) {
        self.index = mapIndex
        self.map = model.maps[mapIndex]
        self.date = map!.start
        self.earliest = map!.start
        self.latest = map!.end
        self.paths = map.paths
        self.points = map.points
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
        
        startYearTextField.delegate = self
        endYearTextField.delegate = self
        
        startYearTextField.addTarget(self, action: #selector(startYearChanged(_:)), for: .editingDidEnd)
        endYearTextField.addTarget(self, action: #selector(endYearChanged(_:)), for: .editingDidEnd)
        inspectorElementName.addTarget(self, action: #selector(inspectorElementNameChanged(_:)), for: .editingDidEnd)
        
        var legalLabel: UIView?
        for subview in mapView.subviews {
            if String(describing: type(of: subview)) == "MKAttributionLabel" {
                legalLabel = subview
            }
        }
        legalLabel?.isHidden = true
        
        change(to: .viewing)
        inspect(map)
        
        mapNameLabel.text = map.name
        
        inspectorScrollView.delegate = self
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
       
        entityDescriptionTextView.delegate = self
        
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
    }
    
    @objc func updateDescriptionForElement(notification: Notification) {
        
    }
    
    @objc func keyboardWillShow(notification:Notification) {
        let info = notification.userInfo!
        let keyboardSize = info[UIResponder.keyboardFrameBeginUserInfoKey] as! CGRect
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        inspectorScrollView.contentInset = insets
        inspectorScrollView.scrollIndicatorInsets = insets
        
        var frame = inspectorScrollView.frame
        frame.size.height -= keyboardSize.height
        
        if entityDescriptionTextView.isFirstResponder {
            let scrollPoint = CGPoint(x: 0, y: entityDescriptionTextView.frame.origin.y - 45)
            inspectorScrollView.setContentOffset(scrollPoint, animated: true)
        }
    }
    
    @objc func keyboardWillHide(notification:Notification) {
        inspectorScrollView.contentInset = UIEdgeInsets.zero
        inspectorScrollView.bounds.size = inspectorView.frame.size
        inspectorScrollView.contentInset = UIEdgeInsets.zero
        inspectorScrollView.scrollIndicatorInsets = UIEdgeInsets.zero
        inspectorScrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    let touchView = TouchView(frame: CGRect.zero)
    
    @objc func longPress(_ recognizer: UIGestureRecognizer) {
        switch mode {
        case .addingPoint:
            if recognizer.state == .began {
                let touch = recognizer.location(in: mapView)
                let coordinate = mapView.convert(touch, toCoordinateFrom: mapView)
                
                let point = MapPoint(from: date.past, to: date.future, at: coordinate, on: map)
                point.new = true
                add(point: point)
                updateMap()
            }
        case .addingPath:
            switch recognizer.state {
            case .began:
                self.view.addSubview(touchView)
                touchView.bounds.size = CGSize(width: 1.0, height: 1.0)
                touchView.center = recognizer.location(in: self.view)
                
                UIView.animate(withDuration: 0.2) {
                    self.touchView.backgroundColor = UIColor.lightGray
                    self.touchView.bounds.size = CGSize(width: 100, height: 100)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    self.touchView.removeFromSuperview()
                }
                
                let touch = recognizer.location(in: mapView)
                let coordinate = mapView.convert(touch, toCoordinateFrom: mapView)
                
                path = MapPath(on: date.copy, at: coordinate, on: map)
                
                change(to: .editingPath)
                
                updateUI()
                updateDate()
                updateMap()
            case .cancelled, .failed, .possible:
                
                path = nil
                change(to: .viewing)
            default:
                print("Should have changed to .editing")
                break
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
                    path!.extend(on: date.copy, to: coordinate)
                } else {
                    recognizer.state = .ended
                }
                
                updateDate()
                updateMap()
            case .ended:
                date += timeIncrement
                path!.end(on: date.copy)
                
                updateDate()
                updateMap()
            case .cancelled, .failed, .possible:
                path = nil
                change(to: .viewing)
            }
        default:
            break
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "pointElement"
        switch annotation {
        case is MapPoint:
            let point = annotation as! MapPoint
            let isPointNew = point.new
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                let pin = annotationView as! MKPinAnnotationView
                
                pin.animatesDrop = isPointNew
                
                if isPointNew {
                    point.new = false
                }
                
                pin.annotation = annotation
                let calloutView = pin.detailCalloutAccessoryView as! CalloutView
                calloutView.element = point
                point.calloutView = calloutView
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
                    calloutView.element = point
                    point.calloutView = calloutView
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
            line.strokeColor = UIColor(hue: 327/360, saturation: 0.98, brightness: 0.98, alpha: 0.67)
            line.lineWidth = 5.0
            return line
        default:
            assert(false, "Unhandled Overlay")
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        switch view {
        case is MKPinAnnotationView:
            //            (view as! MKPinAnnotationView).setSelected(true, animated: true)
            let point = view.annotation as! MapPoint
            selectedPoint = point
            switch mode {
            case .viewing:
                (view as! MKPinAnnotationView).pinTintColor = MKPinAnnotationView.greenPinColor()
                inspect(point)
                change(to: .editingPoint)
            case .addingPath:
                break
            case .addingPoint, .editingPoint:
                (view as! MKPinAnnotationView).pinTintColor = MKPinAnnotationView.greenPinColor()
                inspect(point)
                change(to: mode)
            case .editingPath:
                break
            }
        case is MKOverlay:
            let path = view.annotation as! MapPath
            inspect(path)
        default:
            break
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        switch view {
        case is MKPinAnnotationView:
            selectedPoint = nil
            inspect(map)
            (view as! MKPinAnnotationView).pinTintColor = MKPinAnnotationView.redPinColor()
            if mode == .editingPoint {
                change(to: .viewing)
            }
        default:
            break
        }
    }
    
    @IBAction func dismissHelp() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addPath(_ sender: Any) {
        change(to: .addingPath)
    }
    
    @IBAction func addPoints(_ sender: Any) {
        change(to: .addingPoint)
    }
    
    func add(point: MapPoint) {
        points.append(point)
    }
    
    func add(path: MapPath) {
        paths.append(path)
    }
    
    func inspect(_ maybeEntity: MapEntity?) {
        if let entity = maybeEntity {
            inspectorElementName.text = entity.name
            chosenStart = entity.start
            chosenEnd = entity.end
            
            entityDescriptionTextView.text = entity.textDescription
            
            updateStartDateUI()
            updateEndDateUI()
        } else {
            inspectorElementName.text = ""
            chosenStart = date
            chosenEnd = date
            
            updateStartDateUI()
            updateEndDateUI()
        }
    }
    
    func change(to mode: MapMode) {
        self.mode = mode
        self.inspectorViewModeLabel.text = mode.rawValue
        switch mode {
        case .viewing:
            deleteEntityButton.isEnabled = true
            deleteEntityButton.setTitle("Delete Map", for: .normal)
            inspectorNameFieldTitleLabel.text = "Map Name"
        case .addingPath, .editingPath:
            deleteEntityButton.isEnabled = (path != nil)
            deleteEntityButton.setTitle("Delete Path", for: .normal)
            inspectorNameFieldTitleLabel.text = "Path Name"
        case .addingPoint, .editingPoint:
            deleteEntityButton.isEnabled = (selectedPoint != nil)
            deleteEntityButton.setTitle("Delete Point", for: .normal)
            inspectorNameFieldTitleLabel.text = "Point Name"
        }
        updateUI()
    }
    
    func updateUI() {
        switch mode {
        case .viewing:
            addPathButton.isHidden = false
            addRegionButton.isHidden = false
            
            doneButton.isHidden = true
        case .addingPoint:
            addPathButton.isHidden = true
            addRegionButton.isHidden = true
            
            doneButton.isHidden = false
            doneButton.isEnabled = true
            
        case .addingPath:
            addPathButton.isHidden = true
            addRegionButton.isHidden = true
            
            doneButton.isHidden = false
            doneButton.isEnabled = false
            
        case .editingPoint, .editingPath:
            addPathButton.isHidden = true
            addRegionButton.isHidden = true
            
            doneButton.isHidden = false
            doneButton.isEnabled = true
        }
    }
    
    func updateDate() {
        monthLabel.text = date.month
        yearLabel.text = date.year
        slider.value = Float(date.rawValue)
    }
    
    func updateMap() {
        let oldOverlays = mapView.overlays
        mapView.removeOverlays(oldOverlays)
        
        if let mapPath = path {
            let overlay = mapPath.polyline(for: date)
            if overlay != nil {
                mapView.addOverlay(overlay!)
            }
        }
        
        let currentPaths = paths.filter { (element) -> Bool in
            element.start <= date && date <= element.end
        }
        
        let newOverlays = currentPaths.map { (element) -> MKOverlay in
            element.annotation(for: date) as! MKOverlay
        }
        
        mapView.addOverlays(newOverlays)
        
        let currentPoints = points.filter { (element) -> Bool in
            element.start <= date && date <= element.end
        }
        
        let oldAnnotations = mapView.annotations as! [MapPoint]
        
        let newAnnotations = currentPoints.map { (element) -> MKAnnotation in
            element.annotation(for: date)!
        }
        
        mapView.addAnnotations(newAnnotations)
        
        for oldAnnotation in oldAnnotations {
            if !newAnnotations.contains(where: { (annotation) -> Bool in
                annotation.isEqual(oldAnnotation)
            }) {
                mapView.removeAnnotation(oldAnnotation)
            }
        }
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case startMonthPicker:
            switch mode {
            case .viewing:
                self.chosenStart.change(month: row)
                
                if attemptUpdateStartDate() {
                    self.earliest.change(month: row)
                    map.set(start: self.earliest)
                    slider.minimumValue = Float(earliest.rawValue)
                    if date.rawValue < Int(slider.minimumValue) {
                        date.rawValue = Int(slider.minimumValue)
                        slider.value = slider.minimumValue
                    }
                    updateDate()
                    inspect(map)
                }
            case .addingPath:
                print("need to implement")
                break
            case .editingPoint, .addingPoint:
                self.chosenStart.change(month: row)
                
                if attemptUpdateStartDate() {
                    selectedPoint.start.change(month: row)
                    selectedPoint.calloutView.element = selectedPoint
                    inspect(selectedPoint)
                }
            case .editingPath:
                print("need to implement")
                break
            }
        case endMonthPicker:
            switch mode {
            case .viewing:
                self.chosenEnd.change(month: row)
                
                if attemptUpdateEndDate() {
                    self.latest.change(month: row)
                    map.set(end: self.latest)
                    slider.maximumValue = Float(latest.rawValue)
                    if date.rawValue > Int(slider.maximumValue) {
                        date.rawValue = Int(slider.maximumValue)
                        slider.value = slider.maximumValue
                    }
                    updateDate()
                    inspect(map)
                }
            case .addingPath:
                print("need to implement")
                break
            case .editingPoint, .addingPoint:
                self.chosenEnd.change(month: row)
                
                if attemptUpdateEndDate() {
                    selectedPoint.end.change(month: row)
                    selectedPoint.calloutView.element = selectedPoint
                    inspect(selectedPoint)
                }
            case .editingPath:
                print("need to implement")
                break
            }
        case startEraPicker:
            switch mode {
            case .viewing:
                self.chosenStart.change(era: row)
                if attemptUpdateStartDate() {
                    
                    self.earliest.change(era: row)
                    map.set(start: self.earliest)
                    slider.minimumValue = Float(earliest.rawValue)
                    if date.rawValue < Int(slider.minimumValue) {
                        date.rawValue = Int(slider.minimumValue)
                    }
                    updateDate()
                    inspect(map)
                }
            case .addingPath:
                print("need to implement")
                break
            case .editingPoint, .addingPoint:
                
                self.chosenStart.change(era: row)
                if attemptUpdateStartDate() {
                    
                selectedPoint.start.change(era: row)
                selectedPoint.calloutView.element = selectedPoint
                inspect(selectedPoint)
                }
                break
            case .editingPath:
                print("need to implement")
                break
            }
        case endEraPicker:
            switch mode {
            case .viewing:
                self.chosenEnd.change(era: row)
                
                if attemptUpdateEndDate() {
                    self.latest.change(era: row)
                    map.set(end: self.latest)
                    slider.maximumValue = Float(latest.rawValue)
                    if date.rawValue > Int(slider.maximumValue) {
                        date.rawValue = Int(slider.maximumValue)
                    }
                    updateDate()
                    inspect(map)
                }
            case .addingPath:
                print("need to implement")
                break
            case .editingPoint, .addingPoint:
                self.chosenEnd.change(era: row)
                
                if attemptUpdateEndDate() {
                    selectedPoint.end.change(era: row)
                    selectedPoint.calloutView.element = selectedPoint
                    inspect(selectedPoint)
                }
                break
            case .editingPath:
                print("need to implement")
                break
            }
        default:
            print("Unhandled pickerView")
        }
    }
    
    // MARK: - TextField
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count == 0 {
            return true
        }
        if textField == startYearTextField || textField == endYearTextField {
            if string.rangeOfCharacter(from: NSCharacterSet.decimalDigits) == nil{
                return false
            }
        }
        return true
    }
    
    @objc func startYearChanged(_ sender: UITextField) {
        if let year = Int(sender.text!) {
            switch mode {
            case .viewing:
                self.chosenStart.change(year: year)
                if attemptUpdateStartDate() {
                    self.earliest.change(year: year)
                    map.set(start: self.earliest)
                    slider.minimumValue = Float(earliest.rawValue)
                    if date.rawValue < Int(slider.minimumValue) {
                        date.rawValue = Int(slider.minimumValue)
                    }
                    updateDate()
                    inspect(map)
                } else {
                    inspect(map)
                }
            case .editingPath, .addingPath:
                self.chosenStart.change(year: year)
                if attemptUpdateStartDate() {
                    path?.start.change(year: year)
                    inspect(path)
                } else {
                    inspect(path)
                }
            case .editingPoint, .addingPoint:
                self.chosenStart.change(year: year)
                if attemptUpdateStartDate() {
                    selectedPoint?.start.change(year: year)
                    inspect(selectedPoint)
                } else {
                    inspect(selectedPoint)
                }
            }
        }
    }
    
    @objc func endYearChanged(_ sender: UITextField) {
        if let year = Int(sender.text!) {
            switch mode {
            case .viewing:
                self.chosenEnd.change(year: year)
                if attemptUpdateEndDate() {
                    self.latest.change(year: year)
                    map.set(end: self.latest)
                    slider.maximumValue = Float(latest.rawValue)
                    if date.rawValue > Int(slider.maximumValue) {
                        date.rawValue = Int(slider.maximumValue)
                        slider.value = slider.maximumValue
                    }
                    updateDate()
                    inspect(map)
                } else {
                    inspect(map)
                }
            case .editingPath, .addingPath:
                self.chosenEnd.change(year: year)
                if attemptUpdateEndDate() {
                    path?.end.change(year: year)
                    inspect(path)
                } else {
                    inspect(path)
                }
            case .editingPoint, .addingPoint:
                self.chosenEnd.change(year: year)
                if attemptUpdateEndDate() {selectedPoint?.end.change(year: year)
                    inspect(selectedPoint)
                } else {
                    inspect(selectedPoint)
                }
            }
        } 
    }
    
    @objc func inspectorElementNameChanged(_ sender: UITextField) {
        let text = sender.text
        switch mode {
        case .viewing:
            map.name = text
            mapNameLabel.text = map.name
            inspect(map)
        case .editingPath, .addingPath:
            path?.name = text
            inspect(path)
        case .editingPoint, .addingPoint:
            selectedPoint?.name = text
            selectedPoint?.calloutView.element = selectedPoint
            inspect(selectedPoint)
        }
    }
    
    func updateStartDateUI() {
        startEraPicker.selectRow(chosenStart.rawEra, inComponent: 0, animated: true)
        startMonthPicker.selectRow(chosenStart.rawMonth, inComponent: 0, animated: true)
        startYearTextField.text = "\(chosenStart.rawYear.magnitude)"
        
        if chosenEnd <= chosenStart {
            chosenEnd = chosenStart.future
        }
    }
    
    func updateEndDateUI() {
        endEraPicker.selectRow(chosenEnd.rawEra, inComponent: 0, animated: true)
        endMonthPicker.selectRow(chosenEnd.rawMonth, inComponent: 0, animated: true)
        endYearTextField.text = "\(chosenEnd.rawYear.magnitude)"
        
        if chosenStart >= chosenEnd {
            chosenStart = chosenStart.future
        }
    }
    
    func attemptUpdateStartDate() -> Bool {
        if let year = Int(startYearTextField.text!) {
            let month = startMonthPicker.selectedRow(inComponent: 0)
            let era = startEraPicker.selectedRow(inComponent: 0)
            let modifier = era == 0 ? -1 : 1
            let adjusted = year * modifier
            let selectedStartDate = HistoricalDate(month: month, year: adjusted)
            
            if selectedStartDate >= chosenEnd {
                startDateWarningLabel.text = "Start must occur before end."
                updateStartDateUI()
                return false
            } else {
                startDateWarningLabel.text = ""
                chosenStart = selectedStartDate
                updateStartDateUI()
                return true
            }
        } else {
            startDateWarningLabel.text = "Enter a valid year."
            return false
        }
    }
    
    func attemptUpdateEndDate() -> Bool {
        if let year = Int(endYearTextField.text!) {
            let month = endMonthPicker.selectedRow(inComponent: 0)
            let era = endEraPicker.selectedRow(inComponent: 0)
            let modifier = era == 0 ? -1 : 1
            let adjusted = year * modifier
            let selectedEndDate = HistoricalDate(month: month, year: adjusted)
            
            if selectedEndDate <= chosenStart {
                endDateWarningLabel.text = "End must occur after start."
                updateEndDateUI()
                return false
            } else {
                endDateWarningLabel.text = ""
                chosenEnd = selectedEndDate
                updateEndDateUI()
                return true
            }
        } else {
            endDateWarningLabel.text = "Enter a valid year."
            return false
        }
    }
    
    func textViewDidEndEditing(_ sender: UITextView) {
        let text = sender.text!
        switch mode {
        case .viewing:
            map.textDescription = text
            inspect(map)
        case .editingPath, .addingPath:
            path?.textDescription = text
            inspect(path)
        case .editingPoint, .addingPoint:
            selectedPoint?.textDescription = text
            selectedPoint?.calloutView.element = selectedPoint
            inspect(selectedPoint)
        }
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

