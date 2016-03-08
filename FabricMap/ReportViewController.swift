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
}

class ReportViewController: UIViewController {

    @IBOutlet weak var textField: UITextView!
    
    weak var delegate: ReportingDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dispatchSendReport(sender: UIButton) {
        delegate!.sendReport(textField.text)
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
