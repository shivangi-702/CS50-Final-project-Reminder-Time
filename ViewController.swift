//
//  ViewController.swift
//  Reminder Time
//
//  Created by Shivangi Krishna on 27/07/2021.
//

import UserNotifications
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var table: UITableView!
    
    var models = [ReminderTime]()

    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
    }
    
    @IBAction func tapped()
    {
        // show add vc
        guard let vc = storyboard?.instantiateViewController(identifier: "add") as? AddViewController else {
            return
        }
        vc.title = "New Reminder"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = { title, body, date in
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
                let new = ReminderTime(title: title, date: date, identifier: "id_\(title)")
                self.models.append(new)
                self.table.reloadData()
                
                let content = UNMutableNotificationContent()
                    content.title = title
                    content.sound = .default
                    content.body = body
                    
                    let targetDate = date
                    let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate), repeats: false)
                    
                    let request = UNNotificationRequest(identifier: "some_info", content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
                        if error != nil {
                            print("Something went Wrong")
                        }
                    })
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func tested()
    {
        // fire test notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: {success, error in
            if success {
                //test
                self.scheduleTest()
            }
            else if let error = error {
                print("An Error has occured")
            }
        })
    }
    
    func scheduleTest()
    {   let content = UNMutableNotificationContent()
        content.title = "Hello Shivangi"
        content.sound = .default
        content.body = "Hello CS50"
        
        let targetDate = Date().addingTimeInterval(10)
        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate), repeats: false)
        
        let request = UNNotificationRequest(identifier: "some_info", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if error != nil {
                print("Something went Wrong")
            }
        })
    }
    
}
extension ViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController: UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = models[indexPath.row].title
        let date = models[indexPath.row].date
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM, dd, YYYY at hh:mm a"
        cell.detailTextLabel?.text = formatter.string(from: date)
        return cell
    }
    
    func tableview(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            models.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
    }

}

struct ReminderTime {
    let title: String
    let date: Date
    let identifier: String
}
