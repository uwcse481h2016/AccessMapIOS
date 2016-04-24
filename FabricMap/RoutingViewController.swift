import UIKit

protocol RoutingDelegate: class {
    func onChooseManualWheelchairOption()
    func onChoosePowerWheelchairOption()
    func onChooseOtherMobilityAidOption()
}

// Manages the routing options pop-up that allows the user to choose between several
// route types (manual wheelchair, power wheelchair, and other mobility aid).
class RoutingViewController: UIViewController {
    
    // delegate will be set to main ViewController in ViewController.swift
    weak var delegate: RoutingDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Dispatch manual wheelchair action to delegate and dismiss this ViewController
    @IBAction func sendManualWheelchairAction(sender: UIButton) {
        delegate?.onChooseManualWheelchairOption()
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    // Dispatch power wheelchair action to delegate and dismiss this ViewController
    @IBAction func sendPowerWheelChairAction(sender: UIButton) {
        delegate?.onChoosePowerWheelchairOption()
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    // Dispatch other action (for other mobility aid) to delegate and dismiss this
    // ViewController
    @IBAction func sendOtherAction(sender: UIButton) {
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
