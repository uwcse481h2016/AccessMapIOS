//
//  OptionsViewController.swift
//  FabricMap
//
//  Created by studentuser on 3/8/16.
//  Copyright © 2016 Xiaobo Wang. All rights reserved.
//

import UIKit

protocol OptionsDelegate: class {
    func toggleCurbRamps()
    func toggleElevationData()
    func toggleBusStops()
}

class OptionsViewController: UIViewController {

     weak var delegate: OptionsDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//    
//    @IBAction func sendToggleCurbRamps(sender: UISwitch) {
//        print("toggled curb ramps!")
//        delegate?.toggleCurbRamps()
//        //self.dismissViewControllerAnimated(true, completion: {});
//        
//    }
//
//    @IBAction func sendToggleElevationData(sender: UISwitch) {
//        print("toggled elevation data!")
//        delegate?.toggleElevationData()
//    }
    
    //    @IBAction func sendToggleBusStops(sender: UISwitch) {
    //        print("toggled bus stops!")
    //        delegate?.toggleBusStops()
    //    }

    @IBAction func sendToggleCurbRampsAction(sender: UISwitch) {
        print("toggled curb ramps!")
        delegate?.toggleCurbRamps()
    }
    
    @IBAction func sendToggleElevationData(sender: UISwitch) {
        print("toggled elevation data!")
        delegate?.toggleElevationData()
    }
    
    @IBAction func sendToggleBusStops(sender: UISwitch) {
        print("toggled bus stops!")
        delegate?.toggleBusStops()
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
