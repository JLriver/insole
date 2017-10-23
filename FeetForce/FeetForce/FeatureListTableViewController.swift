//
//  FeatureListTableViewController.swift
//  FeetForce
//
//  Created by JL on 21.10.17.
//  Copyright © 2017 JL. All rights reserved.
//

import UIKit
import BlueSTSDK

class FeatureListTableViewController: UITableViewController, BlueSTSDKNodeStateDelegate, BlueSTSDKFeatureDelegate  {

    var node:BlueSTSDKNode!
    var mAvailableFeatures:[BlueSTSDKFeature]!
    var mActionConsole:UIAlertAction!
    var mActionSettings:UIAlertAction!
    var mAlertController:UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        mAvailableFeatures = node.getFeatures()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //NSLog("%d", mAvailableFeatures.count)
        
        //enable the action only if the service is available
        //mActionConsole.enabled = (self.node.debugConsole!=nil);
        //mActionSettings.enabled = (self.node.configControl!=nil);
        
        //notify change in the node status for move to the previous view if there is
        //some error during the transmission
        node.addStatusDelegate(self)
        
        //fill the table
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // remove the listener
        node.removeStatusDelegate(self)
        
        // stop the notification and remove the listener
        for f in mAvailableFeatures {
            if node.isEnableNotification(f) {
                node.disableNotification(f)
                //f.remove(self as! BlueSTSDKFeatureDelegate)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mAvailableFeatures.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)

        // Configure the cell...
        let f = mAvailableFeatures[indexPath.row]
        
        cell.textLabel?.text = f.name
        cell.detailTextLabel?.text = "Click for enable the notification"
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let f = mAvailableFeatures[indexPath.row]
        
        if node.isEnableNotification(f) {
            // disable the notification and remove the delegate
            node.disableNotification(f)
            f.remove(self as BlueSTSDKFeatureDelegate)
            
            tableView.cellForRow(at: indexPath)?.detailTextLabel?.text = "Click for enable the notification"
        } else {
            // register the delegate and start the notification
            f.add(self as BlueSTSDKFeatureDelegate)
            node.enableNotification(f)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: BlueSTSDKNodeStateDelegate
    func node(_ node: BlueSTSDKNode, didChange newState: BlueSTSDKNodeState, prevState: BlueSTSDKNodeState) {
        if newState == .lost || newState == .unreachable || newState == .dead {
            DispatchQueue.main.sync { () -> Void in
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: BlueSTSDKFeatureAutoConfigurableDelegate
    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        // find the cell to update
        let index = mAvailableFeatures.index(of: feature)
        let cellIndex = IndexPath(row: index!, section: 0)
        
        // generate the object description
        let desc = feature.description()
        
        // update the table with the new description, we have to do a dispatch
        // since the notification are submited in a concurrent queue
        DispatchQueue.main.sync(execute: {() -> Void in
            tableView.beginUpdates()
            let cell = tableView.cellForRow(at: cellIndex)
            cell?.detailTextLabel?.text = desc
            tableView.endUpdates()
        })
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
