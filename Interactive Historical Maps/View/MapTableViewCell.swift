//
//  MapTableViewCell.swift
//  Interactive Historical Maps
//
//  Created by Goki on 12/8/18.
//  Copyright © 2018 Gokulan Gnanendran. All rights reserved.
//

import UIKit

class MapTableViewCell: UITableViewCell {

    @IBOutlet weak var mapNameLabel: UILabel!
    @IBOutlet weak var mapAuthorLabel: UILabel!
    @IBOutlet weak var mapTimeRangeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let f = contentView.frame
        let fr = f.insetBy(dx: 0, dy: 5)
        contentView.frame = fr
    }

    func configure(for map: Map) {
        let name = map.name
        let author = map.author
        let start = map.start
        let end = map.end
        
        let range = "\(start) to \(end)"
        
        mapNameLabel.text = name
        mapAuthorLabel.text = author
        mapTimeRangeLabel.text = range
    }
}
