//
//  CalloutView.swift
//  C Squared
//
//  Created by Goki on 10/22/18.
//  Copyright © 2018 Gokulan Gnanendran. All rights reserved.
//

import UIKit
import MapKit

// Custom callout view for annotations
class CalloutView : UIView {
    
    @IBOutlet weak var elementNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var coordinateLabel: UILabel!
    
    // Unused (for now)
    @IBOutlet weak var infoButton: UIButton!
    
    // Populate the callout's view elements upon setting properties
    var element : MapElement? {
        didSet {
            elementNameLabel.text = element!.name
            
            timeLabel.text = "\(element!.start) to \(element!.end)"
            
            var coordinate : CLLocationCoordinate2D?
            switch element {
            case is MapPoint:
                let annotation = element as! MKAnnotation
                coordinate = annotation.coordinate
            case is MapPath:
                let path = element as! MapPath
                coordinate = path.last().coordinate
            default:
                break
            }
            coordinateLabel.text = coordinate != nil ? "\(coordinate!.latitude), \(coordinate!.longitude)" : "N/A"

        }
    }
    
    // Required, unused
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // Map View handles action sheets
    @IBAction func detailDisclosureClicked(_ sender: Any) {
        
    }
    
}
