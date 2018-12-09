//
//  AudioIntegrationViewController.swift
//  Interactive Historical Maps
//
//  Created by Goki on 12/8/18.
//  Copyright © 2018 Gokulan Gnanendran. All rights reserved.
//

import UIKit

class AudioIntegrationViewController: UIViewController, EditorViewController {

    let model = Model.shared
    var map: Map?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func configure(for mapIndex: Int) {
        self.map = model.maps[mapIndex]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
