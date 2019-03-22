//
//  ViewController.swift
//  Teprature_Test
//
//  Created by IBS on 3/20/19.
//  Copyright © 2019 IBS. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import SDWebImage

class areaAroundMeCell: UITableViewCell {
    
    @IBOutlet var viewFCell:UIView!
    @IBOutlet var imgTemprature:UIImageView!
    @IBOutlet var lblAreaName:UILabel!
    @IBOutlet var lblTemp:UILabel!
    @IBOutlet var lblHumidity:UILabel!
}


class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet var tblArea_List:UITableView!
    var strC_Latitude = Double()
    var strC_Logitude = Double()
    
    let locationManager = CLLocationManager()
    var timer = Timer()
    
    var arrWeatherData:NSArray=[]
    
    var refreshController:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadInitialUI()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //MARK: Load Initial UI
    func loadInitialUI() {
        
        refreshController=UIRefreshControl()
        tblArea_List.addSubview(refreshController)
        refreshController.attributedTitle=NSAttributedString(string: "Pull to refresh")
        refreshController.tintColor=UIColor(r: 163, g: 208, b: 77)
        refreshController.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tblArea_List.tableFooterView=UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        
        timer = Timer.scheduledTimer(timeInterval: 0.10, target: self, selector: #selector(checkLocationServices), userInfo: nil, repeats: false)
        print(timer)

    }
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    @objc func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
        }
    }
    
    @objc func pullToRefresh()
    {
        getAreaAroundMe_API()
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .denied:
            // Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            break
        }
    }
    
    //MARK: Load UITableView delegate and datasource methods.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrWeatherData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let cell:areaAroundMeCell = self.tblArea_List.dequeueReusableCell(withIdentifier: "aroundMe") as! areaAroundMeCell
        
        cell.backgroundColor = .clear
        cell.selectionStyle=UITableViewCell.SelectionStyle.none
        
        var dict=NSDictionary()
        var dict1=NSDictionary()
        var arrWeather:NSArray=[]
        
        dict=self.arrWeatherData.object(at: indexPath.row) as! NSDictionary
        cell.lblAreaName.text = dict["name"] as? String
        dict1=dict.value(forKey: "main") as! NSDictionary
       
        
        
        //Set weather image
         arrWeather=dict.value(forKey: "weather") as! NSArray
        var str_Img=""
        dict=arrWeather.object(at: 0) as! NSDictionary
        str_Img=dict.value(forKey: "icon") as! String
        str_Img="http://openweathermap.org/img/w/\(str_Img).png"
        cell.imgTemprature.sd_setImage(with: URL(string: str_Img), placeholderImage: UIImage(named: ""))
        
        
        var temp=Double()
        temp=dict1.value(forKey: "temp") as! Double
        
        //Temprature Convert Kelvin into Celsius
        let temperatureInCelsius = temp - 273.15
        cell.lblTemp.text = String(format: "%.0f°c", temperatureInCelsius)
        
        //set Humidity
        var humd=Int()
        humd=dict1.value(forKey: "humidity") as! Int
        cell.lblHumidity.text="\(humd)"
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        return 60
    }
    
    //MARK: Call API to get Locations around me
    func getAreaAroundMe_API()
    {
        
        let parameters: Parameters = [:]
        print(parameters)
        
        let URL = "http://api.openweathermap.org/data/2.5/find?lat=\(strC_Latitude)&lon=\(strC_Logitude)&cnt=10&appid=1e12efd7cea1b56f736f48cf17bfddac"
        
        showSpinner("Please wait...")
        if #available(iOS 10.0, *)
        {
            
            AFWrapper.requestGETURL(URL, success: {
                (JSONResponse) -> Void in
                
                self.getTempAroundMeResponse(data:JSONResponse)
            }) {
                (error) -> Void in
                print(error)
            }
        }
        else
        {
            print("Hello")
        }
    }
    
    
    //MARK: Get Area & Temprature API Response
    func getTempAroundMeResponse(data:JSON)
    {
        OperationQueue.main.addOperation({
            dismissSpinner()
            self.refreshController.endRefreshing()
            var strData=""
            strData=data.rawString()!
            
            dismissSpinner()
            let jsonData =  strData.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
            var convertedJsonIntoDict = NSDictionary()
            convertedJsonIntoDict=try! JSONSerialization.jsonObject(with: jsonData, options: []) as! NSDictionary
            
            let arrData:NSArray=[]
            var strMessage=""
            
            strMessage=convertedJsonIntoDict.value(forKey: "message") as! String
            
            if strMessage == "accurate"{
                
                self.arrWeatherData=convertedJsonIntoDict.value(forKey: "list") as! NSArray
                
            }
            else{
             
                self.arrWeatherData=arrData
            }
            self.tblArea_List.reloadData()
            dismissSpinner()
        })
    }
    
}


//MARK: Core Location manager Delegate
extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        strC_Latitude=location.coordinate.latitude
        self.strC_Logitude=location.coordinate.longitude
        getAreaAroundMe_API()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
