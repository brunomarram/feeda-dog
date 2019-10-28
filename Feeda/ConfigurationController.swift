//
//  ConfigurationController.swift
//  Feeda
//
//  Created by Bruno Marra de Melo on 06/10/19.
//  Copyright © 2019 Bruno Marra de Melo. All rights reserved.
//

import CoreBluetooth
import UIKit

let deviceCBUUID = CBUUID(string: "0x1800")
var device: CBPeripheral!
var service: CBService!
var characteristic: CBCharacteristic!
let defaults = UserDefaults.standard

class ConfigurationController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet weak var connected: UILabel!
    @IBOutlet weak var tableDevices: UITableView!
    @IBOutlet weak var tabs: UISegmentedControl!
    let refreshControl = UIRefreshControl()
    var devices = Array<CBPeripheral>()
    var centralManager: CBCentralManager!
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
          case .unknown:
            print("central.state is .unknown")
          case .resetting:
            print("central.state is .resetting")
          case .unsupported:
            print("central.state is .unsupported")
          case .unauthorized:
            print("central.state is .unauthorized")
          case .poweredOff:
            print("central.state is .poweredOff")
          case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: nil)
          @unknown default:
            fatalError("Critical error")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        devices.append(peripheral);
        tableDevices.reloadData()
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        device.delegate = self;
        device.discoverServices(nil);
        self.connected.text = device.name;
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for s in services {
            service = s
        }
        
        peripheral.discoverCharacteristics(nil, for: service)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristics = service.characteristics else { return }

        for c in characteristics {
            characteristic = c;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)

        tableDevices.dataSource = self
        tableDevices.delegate = self
        
        refreshControl.addTarget(self, action:  #selector(refresh), for: .valueChanged)
        tableDevices.addSubview(refreshControl)
    }
    
    @objc func refresh() {
        self.devices = [];
        centralManager.scanForPeripherals(withServices: nil)
        refreshControl.endRefreshing()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath) as! PrototypeTableViewCell
        
        cell.scheduleLabel.text = devices[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        device = devices[indexPath.row];
        centralManager.stopScan()
        centralManager.connect(device);
    }
    
    @IBAction func changeTab(_ sender: Any) {
        self.devices = []
        if(tabs.selectedSegmentIndex == 0) {
            centralManager.scanForPeripherals(withServices: nil)
        }
        tableDevices.reloadData()
    }

}
