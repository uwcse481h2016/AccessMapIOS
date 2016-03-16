//
//  ReportViewController.swift
//  FabricMap
//
//  Created by studentuser on 3/8/16.
//  Copyright © 2016 Xiaobo Wang. All rights reserved.
//

import UIKit

protocol ReportingDelegate: class {
    func sendReport(message: String)
    func cancelReport()
}

class ReportViewController: UIViewController {

    @IBOutlet weak var textField: UITextView!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var delegate: ReportingDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //cancelButton.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    optional func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
//        delegate!.cancelReport()
//    }
    
    @IBAction func cancelReport(sender: UIButton) {
        delegate!.cancelReport()
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    @IBAction func dispatchSendReport(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: {});
        delegate!.sendReport(textField.text)
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
