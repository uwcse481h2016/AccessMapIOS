//
//  LegendViewController.swift
//  FabricMap
//
//  Created by studentuser on 3/7/16.
//  Copyright © 2016 Xiaobo Wang. All rights reserved.
//

import UIKit

protocol RoutingDelegate: class {
    func onChooseManualWheelchairOption()
    func onChoosePowerWheelchairOption()
    func onChooseOtherMobilityAidOption()
}

class RoutingViewController: UIViewController {
    
    weak var delegate: RoutingDelegate? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad in RoutingViewController!")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendManualWheelchairAction(sender: UIButton) {
        print("chose manual wheelchair!")
        delegate?.onChooseManualWheelchairOption()
        self.dismissViewControllerAnimated(true, completion: {});
    }

    @IBAction func sendPowerWheelChairAction(sender: UIButton) {
        print("chose power wheelchair!")
        delegate?.onChoosePowerWheelchairOption()
        self.dismissViewControllerAnimated(true, completion: {});
    }

    @IBAction func sendOtherAction(sender: UIButton) {
        print("chose other mobility aid!")
        delegate?.onChooseOtherMobilityAidOption()
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
