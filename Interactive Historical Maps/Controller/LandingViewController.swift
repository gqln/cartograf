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
        let map = model.maps.last!
        
        if (map.name == "Cities" && map.points.count < 5) {
            MapPoint(from: HistoricalDate(month: 4, year: 1782), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 13.7542529, longitude: 100.493087), on: map).name = "Bangkok, Thailand"
            
            MapPoint(from: HistoricalDate(month: 6, year: 1840), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 22.5445697, longitude: 114.0545346), on: map).name = "Shenzhen, China"
            
            MapPoint(from: HistoricalDate(month: 5, year: 1820), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 40.4167047, longitude: -3.7035825), on: map).name = "Madrid, Spain"
            
            MapPoint(from: HistoricalDate(month: 7, year: 1850), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 37.7792808, longitude: -122.4192363), on: map).name = "San Francisco, United States"
            
            MapPoint(from: HistoricalDate(month: 8, year: 1700), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 55.7504461, longitude: 37.6174943), on: map).name = "Moscow, Russia"
            
            MapPoint(from: HistoricalDate(month: 9, year: 1740), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 25.2683521, longitude: 55.2961962), on: map).name = "Dubai, United Arab Emirates"
            
            MapPoint(from: HistoricalDate(month: 10, year: 1540), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 52.3727598, longitude: 4.8936041), on: map).name = "Amsterdam, Netherlands"
            
            MapPoint(from: HistoricalDate(month: 11, year: 1879), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 48.1371079, longitude: 11.5753822), on: map).name = "Munich, Germany"
            
            MapPoint(from: HistoricalDate(month: 1, year: 1894), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 43.653963, longitude: -79.387207), on: map).name = "Toronto, Canada"
            
            MapPoint(from: HistoricalDate(month: 1, year: 1645), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 52.5170365, longitude: 13.3888599), on: map).name = "Berlin, Germany"
            
            MapPoint(from: HistoricalDate(month: 1, year: 1920), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: -33.8548157, longitude: 151.2164539), on: map).name = "Sydney, Australia"
            
            MapPoint(from: HistoricalDate(month: 2, year: 1589), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 25.7742658, longitude: -80.1936589), on: map).name = "Miami, United States"
            
            MapPoint(from: HistoricalDate(month: 3, year: 1756), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 29.7589382, longitude: -95.3676974), on: map).name = "Houston, United States"
            
            MapPoint(from: HistoricalDate(month: 4, year: 1803), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 53.3497645, longitude: -6.2602732), on: map).name = "Dublin, Ireland"
            
            MapPoint(from: HistoricalDate(month: 5, year: 1200), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 51.5073219, longitude: -0.1276474), on: map).name = "London, United Kingdom"
            
            MapPoint(from: HistoricalDate(month: 6, year: 1758), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: -37.8142176, longitude: 144.9631608), on: map).name = "Melbourne, Australia"
            
            MapPoint(from: HistoricalDate(month: 7, year: 1850), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 39.7391428, longitude: -104.984696), on: map).name = "Denver, United States"
            
            MapPoint(from: HistoricalDate(month: 8, year: 1783), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 45.4371908, longitude: 12.3345898), on: map).name = "Venice, Italy"
            
            MapPoint(from: HistoricalDate(month: 9, year: 1589), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 48.8566101, longitude: 2.3514992), on: map).name = "Paris, France"
            
            MapPoint(from: HistoricalDate(month: 10, year: 1840), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: -36.8534665, longitude: 174.7655514), on: map).name = "Auckland, New Zealand"
            
            MapPoint(from: HistoricalDate(month: 5, year: 1802), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: -36.8534665, longitude: -36.8534665), on: map).name = "Tokyo, Japan"
            
            MapPoint(from: HistoricalDate(month: 7, year: 1834), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: -36.3789925, longitude: -60.3855889), on: map).name = "Buenos Aires, Argentina"
            
            MapPoint(from: HistoricalDate(month: 7, year: 1683), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 39.1235635, longitude: 117.1980785), on: map).name = "Tianjin, China"
            
            MapPoint(from: HistoricalDate(month: 9, year: 1742), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 14.5906216, longitude: 120.9799696), on: map).name = "Manila, Philippines"
            
            MapPoint(from: HistoricalDate(month: 8, year: 1854), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 23.7593572, longitude: 90.3788136), on: map).name = "Dhaka, Bangladesh"
            
            MapPoint(from: HistoricalDate(month: 3, year: 1620), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 41.0096334, longitude: 28.9651646), on: map).name = "Istanbul, Turkey"
            
            MapPoint(from: HistoricalDate(month: 1, year: 1453), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 30.5941299, longitude: 114.2984414), on: map).name = "Wuhan, China"
            
            MapPoint(from: HistoricalDate(month: 7, year: 1392), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: -12.0621065, longitude: -77.0365256), on: map).name = "Lima, Peru"
            
            MapPoint(from: HistoricalDate(month: 0, year: 1432), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 35.7006177, longitude: 51.4013785), on: map).name = "Tehran, Iran"
            
            MapPoint(from: HistoricalDate(month: 9, year: 1302), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 33.3024309, longitude: 44.3787992), on: map).name = "Baghdad, Iraq"
            
            MapPoint(from: HistoricalDate(month: 5, year:1350), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: -6.1753942, longitude: 106.827183), on: map).name = "Jakarta, Indonesia"
            
            MapPoint(from: HistoricalDate(month: 4, year: 1840), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 37.5666791, longitude: 126.9782914), on: map).name = "Seoul, South Korea"
            
            MapPoint(from: HistoricalDate(month: 2, year: 1305), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: -23.5506507, longitude: -46.6333824), on: map).name = "Sao Paulo, Brazil"
            
            MapPoint(from: HistoricalDate(month: 5, year: 1504), to: HistoricalDate(month: 11, year: 2018), at: CLLocationCoordinate2D(latitude: 12.971599, longitude: 77.594566), on: map).name = "Bangalore, India"
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
