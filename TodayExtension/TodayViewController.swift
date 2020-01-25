//
//  TodayViewController.swift
//  TodayExtension
//
//  Created by Thomas Guilleminot on 25/01/2020.
//  Copyright © 2020 Thomas Guilleminot. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {

  @IBOutlet private var bikesLabel: UILabel!
  @IBOutlet private var standsLabel: UILabel!
  @IBOutlet private var nameLabel: UILabel!

  private let userDefaults = UserDefaults(suiteName: "group.com.zlatan.velib-map")!
  private let session = URLSession(configuration: URLSessionConfiguration.default)

  override func viewDidLoad() {
    super.viewDidLoad()

    self.showLoadingView()
    self.downloadStationInfo()
  }

  func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
    self.downloadStationInfo()
    completionHandler(NCUpdateResult.newData)
  }

  private func showLoadingView() {
    self.bikesLabel.text = ""
    self.bikesLabel.textColor = UIColor.white
    self.standsLabel.text = ""
    self.standsLabel.textColor = UIColor.white
    self.nameLabel.text = "Chargment en cours"
  }

  private func downloadStationInfo() {
    let id = (self.userDefaults.array(forKey: "favoriteStationsCode") as! [String]).first!
    let url = URL(string: "https://opendata.paris.fr/api/records/1.0/search/?dataset=velib-disponibilite-en-temps-reel&rows=1000&q=station_code%3D+\(id)")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"

    self.session.dataTask(with: url) { data, _,  _ in
      let resources = try! JSONDecoder().decode(FetchStationObjectResponseRoot.self, from: data!)

      DispatchQueue.main.async {
        self.showStationDetails(from: resources.records.first!.station)
      }
    }.resume()
  }

  private func showStationDetails(from station: Station) {
    let bikes = station.freeBikes + station.freeElectricBikes
    let stands = station.freeDocks
    let name = station.name

    self.bikesLabel.text = "\(bikes) vélo\(bikes > 0 ? "s" : "")"
    self.standsLabel.text = "\(stands) place\(stands > 0 ? "s" : "")"
    self.nameLabel.text = name
  }
}