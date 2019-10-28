//
//  ScheduleTableControllerTableViewController.swift
//  Feeda
//
//  Created by Bruno Marra de Melo on 30/09/19.
//  Copyright © 2019 Bruno Marra de Melo. All rights reserved.
//

import UIKit

class ScheduleTableControllerTableViewController: UITableViewController {
      override func numberOfSections(in tableView: UITableView) -> Int {
          return 3
      }

      override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return 5
      }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       return "Section \(section)"
    }

      override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath)

          cell.textLabel?.text = "Section \(indexPath.section) Row \(indexPath.row)"

          return cell
      }

}
