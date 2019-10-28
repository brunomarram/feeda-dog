//
//  FirstViewController.swift
//  Feeda
//
//  Created by Bruno Marra de Melo on 30/09/19.
//  Copyright © 2019 Bruno Marra de Melo. All rights reserved.
//

import CoreBluetooth
import UIKit

import Foundation
import SwiftCron

class HomeController: UIViewController {

    @IBOutlet weak var feedNow: UIButton!
    @IBOutlet weak var scheduleDate: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func schedule(_ sender: Any) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short

        let date = dateFormatter.string(from: self.scheduleDate.date)
        
        var schedules = defaults.object(forKey: "schedules") as? [String] ?? [String]()
        
        schedules.append(date);
        defaults.set(schedules, forKey: "schedules");
    }
    
    func sendFeed(){
        var parameter = NSString("liga")
        let data = NSData(bytes: &parameter, length: 1)
        device.writeValue(data as Data, for: characteristic,
                              type: CBCharacteristicWriteType.withResponse)
    }
    
    @IBAction func feed(_ sender: Any) {
        sendFeed();
    }
}

