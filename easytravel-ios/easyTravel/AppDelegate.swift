//
//  AppDelegate.swift
//  testapp
//
//  Created by Marcel Breitenfellner on 17.07.17.
//  Copyright © 2017 Dynatrace. All rights reserved.
//

import UIKit
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    var locationManager: CLLocationManager?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let startDate = Date()
        DTUtils.initUserDefaults()
        
        let timeSinceLaunch = startDate.timeIntervalSince(Date())
        if timeSinceLaunch < 0.5 {
            //ensure that splash is shown even on fast devices for at least 0.5 sec
            Thread.sleep(forTimeInterval: timeSinceLaunch)
        }
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager?.startUpdatingLocation()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        locationManager?.stopUpdatingLocation()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        //for cookie testing purpose - single-cookies
        locationManager?.stopUpdatingLocation()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        locationManager?.startUpdatingLocation()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        locationManager?.startUpdatingLocation()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        locationManager?.stopUpdatingLocation()
    }
    
}
