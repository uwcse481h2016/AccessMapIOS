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

// Manages the report pop-up that allows the user to send a report back to the developer
class ReportViewController: UIViewController {

    @IBOutlet weak var textField: UITextView!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    // delegate will be set to main ViewController in ViewController.swift
    weak var delegate: ReportingDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    optional func popoverControllerDidDismissPopover(popoverController: UIPopoverController) {
//        delegate!.cancelReport()
//    }
    
    // Notify main ViewController to cancel report, and dismiss this ViewController
    @IBAction func cancelReport(sender: UIButton) {
        delegate!.cancelReport()
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    // Dismiss this ViewController, and dispatch message in pop-up's text field back
    // to main ViewController
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
