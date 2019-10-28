//
//  AgendamentoController.swift
//  Feeda
//
//  Created by Bruno Marra de Melo on 30/09/19.
//  Copyright © 2019 Bruno Marra de Melo. All rights reserved.
//

import UIKit

class AgendamentoController: UIViewController, UITableViewDelegate, UITableViewDataSource,
    UITabBarDelegate {
    
    @IBOutlet weak var cancelSchedule: UIButton!
    @IBOutlet weak var scheduleBar: UITabBarItem!
    @IBOutlet weak var scheduleTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        scheduleTable.dataSource = self
        scheduleTable.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated);
        scheduleTable.reloadData();
    }
    
    func getSchedules() -> [String] {
        let defaults = UserDefaults.standard
        return defaults.object(forKey: "schedules") as? [String] ?? [String]()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "scheduleCell", for: indexPath) as! PrototypeTableViewCell
        
        let schedules = self.getSchedules();
        
        cell.scheduleLabel.text = schedules[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let schedules = self.getSchedules();
        return schedules.count
    }
    
    @IBAction func cancelSchedule(_ sender: Any) {
        let index = scheduleTable.indexPathForSelectedRow?.item as Any

        var schedules = self.getSchedules();
        schedules.remove(at: index as! Int);
        
        let defaults = UserDefaults.standard
        defaults.set(schedules, forKey: "schedules");
        scheduleTable.reloadData();
    }
}
