//
//  LandingViewController.swift
//  Interactive Historical Maps
//
//  Created by Goki on 12/2/18.
//  Copyright © 2018 Gokulan Gnanendran. All rights reserved.
//

import UIKit
import MapKit

class LandingViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource {

    let model = Model.shared
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        mapView.delegate = self
        mapView.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 16.62150306199443, longitude: 100.91160280586966), span: MKCoordinateSpan(latitudeDelta: 89.41729308033938, longitudeDelta: 141.9002645791514))
    }
    
    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.maps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Map Cell") {
            cell.textLabel?.text = model.maps[indexPath.row].title
            return cell
        } else {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Map Cell")
            let cell = UITableViewCell(style: .default, reuseIdentifier: "Map Cell")
            cell.textLabel?.text = model.maps[indexPath.row].title
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "EditMap", sender: self)
    }

    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
//        print(mapView.region)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
 

}
