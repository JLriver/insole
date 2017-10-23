//
//  DeviceTableViewController.swift
//  FeetForce
//
//  Created by JL on 21.10.17.
//  Copyright © 2017 JL. All rights reserved.
//

import UIKit
import BlueSTSDK
//import Foundation

class DeviceTableViewController: UITableViewController, BlueSTSDKManagerDelegate, BlueSTSDKNodeStateDelegate {

    var mManager:BlueSTSDKManager!
    var mNodes:[BlueSTSDKNode]!
    //var networkCheckConnHud:MBProgressHUD!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        mManager = BlueSTSDKManager.sharedInstance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // close the connection and remove known nodes
        if mManager.nodes().count != 0 {
            for node in mManager.nodes() as! [BlueSTSDKNode] {
                if node.isConnected() {
                    node.disconnect()
                }
            }
            mManager.resetDiscovery() // remove known nodes
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        assert(mManager != nil)
        mManager.add(self)
        
        // create virtual node
        mManager.addVirtualNode()

        //if some node are already discovered show it, and we disconnect
        mManager.discoveryStart(10000)
        setNavigationDiscoveryButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        assert(mManager != nil)
        mManager.remove(self)
        mManager.discoveryStop()
    }
    
    // MARK: PrivateFunctions
    /**
     * function called each time the user click in the uibarbutton,
     * it change the status of the discovery
     */
    @objc func manageDiscoveryButton() {
        if mManager.isDiscovering() {
            mManager.discoveryStop()
        } else {
            //remove old data
            mManager.resetDiscovery()
            tableView.reloadData();
            //start to discovery new data
            mManager.discoveryStart(10000)
        }
    }
    
    /**
     *  add the view a bar button for enable/disable the discovery the button will
     * have a search icon if the manager is NOT searching for new nodes, or an X othewise
     */
    func setNavigationDiscoveryButton() {
        if mManager.isDiscovering() {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(manageDiscoveryButton))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(manageDiscoveryButton))
        }
    }
    
    /**
     *  display the activity indicator view while we wait that the connection is done
     *
     *  @param node node selecte by the user
     */
    func showConnectionProgress(_ node: BlueSTSDKNode) {
        if !node.isConnected() {
            //we have to connect to the node
            //networkCheckConnHud = MBProgressHUD.showAdded(to: view, animated: true)
            //networkCheckConnHud.mode = MBProgressHUDModeIndeterminate
            //networkCheckConnHud.removeFromSuperViewOnHide = true
            //networkCheckConnHud.labelText = "Connecting"
            //networkCheckConnHud.show(true)
            node.connect()
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        mNodes = mManager.nodes() as! [BlueSTSDKNode]
        return mNodes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DeviceTableViewCell

        // Configure the cell...
        let node = mNodes[indexPath.row]
        cell.boardName.text = node.name
        cell.boardDetail.text = node.address
        switch node.type {
        case .nucleo:
            cell.boardImage.image = UIImage(named: "board_nucleo")
        case .STEVAL_WESU1:
            cell.boardImage.image = UIImage(named: "board_steval_wesu1")
        default:
            cell.boardImage.image = UIImage(named: "board_generic")
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let node = mNodes[indexPath.row]
        node.addStatusDelegate(self)
        showConnectionProgress(node)
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

    // MARK: BlueSTSDKManagerDelegate
    // change the button state when the manager start/stop a discovery
    func manager(_ manager: BlueSTSDKManager!, didChangeDiscovery enable: Bool) {
        DispatchQueue.main.sync(execute: { () -> Void in
            setNavigationDiscoveryButton()
        })
    }
    
    // when a new node is discover reload the table
    func manager(_ manager: BlueSTSDKManager!, didDiscover node: BlueSTSDKNode!) {
        DispatchQueue.main.sync(execute: { () -> Void in
            tableView.reloadData()
        })
    }
    
    // MARK: BlueSTSDKNodeStateDelegate
    // When the node complete the connection hide the view and do the segue for the demo
    func node(_ node: BlueSTSDKNode, didChange newState: BlueSTSDKNodeState, prevState: BlueSTSDKNodeState) {
        /*if newState == .connected {
            DispatchQueue.main.sync(execute: { () -> Void in
                networkCheckConnHud.hide(true)
                networkCheckConnHud = nil
                self.performSegue(withIdentifier: "S", sender: self)
            })
        } else if newState == .dead || newState == .unreachable {
            let str = "Cannot connect with the device: \(node.name)"
            DispatchQueue.main.sync(execute: { () -> Void in
                networkCheckConnHud.hide(true)
                networkCheckConnHud = nil
                networkCheckConnHud = MBProgressHUD.showAdded(to: self.view, animated: true)
                networkCheckConnHud.mode = MBProgressHUDModeText
                networkCheckConnHud.labelText = str
                networkCheckConnHud.show(true)
                networkCheckConnHud.hide(true, afterDelay: 100)
            })
        }*/
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ToFeatures" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let destinationController = segue.destination as! FeatureListTableViewController
                destinationController.node = mNodes[indexPath.row]
            }
        }
    }

}
