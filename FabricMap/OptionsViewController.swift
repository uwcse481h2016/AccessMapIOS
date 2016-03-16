//
//  OptionsViewController.swift
//  FabricMap
//
//  Created by studentuser on 3/8/16.
//  Copyright © 2016 Xiaobo Wang. All rights reserved.
//

import UIKit
// Global variables to maintain the data toggle states between opening and closing
// options menu
var showCurbramps = true
var showElevation = true
var showBusStops = true

protocol OptionsDelegate: class {
    func toggleCurbRamps()
    func toggleElevationData()
    func toggleBusStops()
    func enterReportMode()
}

// Manages the options pop-up (accessed by clicking "More" in the navigation bar) 
// that allows the user to toggle data displayed and send reports (as well as 
// log in, eventually).
class OptionsViewController: UIViewController {
    // delegate will be set to main ViewController in ViewController.swift
    weak var delegate: OptionsDelegate? = nil

    // MARK: Properties
    @IBOutlet weak var curbrampSwitch: UISwitch!
    @IBOutlet weak var elevationSwitch: UISwitch!
    @IBOutlet weak var busStopSwitch: UISwitch!
    
    
    // MARK: Types
    struct PropertyKey {
        static let curbKey = "curbramps"
        static let elevationKey = "elevation"
        static let busKey = "busStops"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // use global variables to set toggle switches to their previous states
        curbrampSwitch.setOn(showCurbramps, animated:false)
        elevationSwitch.setOn(showElevation, animated:false)
        busStopSwitch.setOn(showBusStops, animated:false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Notify main ViewController to toggle curb ramps
    @IBAction func sendToggleCurbRampsAction(sender: UISwitch) {
        showCurbramps = !showCurbramps
        delegate?.toggleCurbRamps()
    }
    
    // Notify main ViewController to toggle elevation data
    @IBAction func sendToggleElevationData(sender: UISwitch) {
        showElevation = !showElevation
        delegate?.toggleElevationData()
    }
    
    // Notify main ViewController to toggle bus stops
    @IBAction func sendToggleBusStops(sender: UISwitch) {
        showBusStops = !showBusStops
        delegate?.toggleBusStops()
    }

    // Notify main ViewController to enter report mode, and dismiss this ViewController
    @IBAction func sendReportMode(sender: UIButton) {
        delegate?.enterReportMode()
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
