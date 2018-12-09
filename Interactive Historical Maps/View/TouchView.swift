//
//  TouchView.swift
//  Interactive Historical Maps
//
//  Created by Goki on 12/9/18.
//  Copyright © 2018 Gokulan Gnanendran. All rights reserved.
//

import UIKit

class TouchView : UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.gray
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Update the corner radius when the bounds change.
    override var bounds: CGRect {
        get { return super.bounds }
        set(newBounds) {
            super.bounds = newBounds
            layer.cornerRadius = newBounds.size.width / 2.0
        }
    }
}

