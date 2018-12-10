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
    @IBOutlet weak var mapsTableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var selectedMapIndex : Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Adding Prepopulated Map
        let isFirstLaunch = UserDefaults.standard.bool(forKey: "launchedBefore")
        
        if isFirstLaunch {
            let index = model.addMap()
            let map = model.maps[index]
            map.name = "Cities"
            
            MapPoint(from: HistoricalDate(month: 3, year: 0), to: HistoricalDate(month: 9, year: 1999), at: CLLocationCoordinate2D(latitude: 39.295679688615465, longitude: -99.15251449157718), on: map)
        }
        
        mapsTableView.separatorStyle = .none
        mapsTableView.dataSource = self
        mapsTableView.delegate = self
        
        mapView.delegate = self
        mapView.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 16.62150306199443, longitude: 100.91160280586966), span: MKCoordinateSpan(latitudeDelta: 89.41729308033938, longitudeDelta: 141.9002645791514))
        
        mapsTableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapsTableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            self.updateViewConstraints()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateViewConstraints()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        tableViewHeightConstraint.constant = mapsTableView.contentSize.height + 20
    }
    
    @IBAction func createNewMapClicked(_ sender: Any) {
        selectedMapIndex = model.addMap()
        performSegue(withIdentifier: "EditMap", sender: self)
    }
    
    // MARK: - Table View Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.maps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let map = model.maps[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Map Cell") {
            let mapCell = cell as! MapTableViewCell
            mapCell.configure(for: map)
            return mapCell
        } else {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Map Cell")
            let cell = UITableViewCell(style: .default, reuseIdentifier: "Map Cell") as! MapTableViewCell
            cell.configure(for: map)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMapIndex = indexPath.row
        performSegue(withIdentifier: "EditMap", sender: self)
    }

    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
//        print(mapView.region)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "EditMap":
            let editor = segue.destination as! EditorViewController
            editor.configure(for: selectedMapIndex!)
        default:
            assert(false, "Unhandled Segue")
        }
    }
 

}
