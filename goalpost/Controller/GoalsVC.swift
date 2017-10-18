//
//  GoalsVC.swift
//  goalpost
//
//  Created by 張書涵 on 2017/10/10.
//  Copyright © 2017年 AliceChang. All rights reserved.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as? AppDelegate

class GoalsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var goals:[Goal] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCoreDataObject()
        tableView.reloadData()
    }
    
    func fetchCoreDataObject(){
        self.fetch { (complete) in
            if complete {
                if goals.count >= 1 {
                    tableView.isHidden = false
                }else{
                    tableView.isHidden = true
                }
            }
        }
    }
    
    
    @IBAction func addGoalBtnWasPressed(_ sender: UIButton) {
        guard let creatGoalVC = storyboard?.instantiateViewController(withIdentifier: "CreatGoalVC")else { return }
        presentDetail(creatGoalVC)
    }
}

    extension GoalsVC: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goals.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "goalCell") as? GoalCell else{
            return UITableViewCell()}
        
        let goal = goals[indexPath.row]
        
        cell.configureCell(goal: goal)
        return cell
        }
        
        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
        
        func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
            return .none
        }
        
        func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
            let deleteAction = UITableViewRowAction(style: .destructive, title: "DELETE") { (rowAction, indexPath) in
                self.removeGoal(atIndexPath: indexPath)
                self.fetchCoreDataObject()
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            let addAction = UITableViewRowAction(style: .normal , title: "ADD 1") { (rowAction, indexPath) in
                self.setProgress(atIndexPath: indexPath)
                tableView.reloadRows(at: [indexPath], with:.automatic)
            }
            
            
            deleteAction.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            addAction.backgroundColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
            return [deleteAction,addAction]
        }
    }


extension GoalsVC{
    func setProgress(atIndexPath indexPath: IndexPath){
       guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let chosenGoal = goals[indexPath.row]
        if chosenGoal.goalProgress < chosenGoal.goalCompletionValue{
            chosenGoal.goalProgress = chosenGoal.goalProgress + 1
        }else{
            return
        }
        do{
            try managedContext.save()
            print("Successfully set progress!")
        } catch {
             debugPrint("Could not set progress :\(error.localizedDescription)")
        }
    }
    
    
    func removeGoal(atIndexPath indexPath: IndexPath){
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        managedContext.delete(goals[indexPath.row])
        do{
            try managedContext.save()
            print("Successfully removed goal!")
        }catch{
            debugPrint("Could not remove:\(error.localizedDescription)")
        }
    }
    
    
    func fetch(completion:(_ _complete: Bool)->()){
        guard let manageContext = appDelegate?.persistentContainer.viewContext else{return}
        let fetchRequest = NSFetchRequest<Goal>(entityName: "Goal")
        do{
            goals = try manageContext.fetch(fetchRequest)
            print("Successfully fetched data")
            completion(true)
        }catch{
            debugPrint("Could not fetch:\(error.localizedDescription)")
            completion(false)
        }
       
    }
}
