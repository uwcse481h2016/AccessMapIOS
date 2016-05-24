import UIKit
import Mapbox

protocol SearchViewDelegate: class {
    func getBackFromSearch(destination: CLPlacemark)
}

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    let geocoder = CLGeocoder()
    
    var globalPlaceMarks : [CLPlacemark]?
    
    // delegate will be set to main ViewController in ViewController.swift
    weak var delegate: SearchViewDelegate? = nil
    
    // Destination input text field
    @IBOutlet weak var searchLocation: UITextField!
    
    // The table view that display the search result
    @IBOutlet weak var resultTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (globalPlaceMarks == nil) {
            return 1
        } else {
            return (globalPlaceMarks?.count)!
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Use custom defined cell instead of default cell
        let cell = resultTable.dequeueReusableCellWithIdentifier("LocationResultCell", forIndexPath: indexPath) as! LocationResultCell
        
        if (globalPlaceMarks != nil) {
            if (!(globalPlaceMarks?.isEmpty)!) {
                // Get data to display
                let one_psmk = globalPlaceMarks![indexPath.row]
                let addName = one_psmk.name
                var addAdm = ""
                var addCon = ""
                
                if let unwarp2 = one_psmk.locality {
                    addAdm += unwarp2
                } else {
                    addAdm += "(Unamed City)"
                }
                
                if let unwarp3 = one_psmk.administrativeArea {
                    addAdm += ", "
                    addAdm += unwarp3
                } else {
                    addAdm += ", "
                    addAdm += "(Unamed Adm. Area)"
                }
                
                if let unwarp4 = one_psmk.postalCode {
                    addAdm += " "
                    addAdm += unwarp4
                } else {
                    addAdm += " "
                    addAdm += "(No Zip Code)"
                }
                
                if let unwarp5 = one_psmk.country {
                    addCon += unwarp5
                } else {
                    addCon += "(Unamed Country)"
                }
                
                // Load data into cell
                cell.addressName.text = addName
                cell.addressAdministrative.text = addAdm
                cell.addressCountry.text = addCon
                cell.PlaceMark = one_psmk
            }
        } else {
            // What to do when no place searched
            cell.addressName.text = "(Unknown Name)"
            cell.addressAdministrative.text = "(Unamed City), (Unamed Adm. Area), (No Zip Code)"
            cell.addressCountry.text = "(Unamed Country)"
        }
        
        return cell
    }
    
    @IBAction func searchOnClick(sender: UIButton) {
        self.resignFirstResponder()
        getResult(searchLocation.text!)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.resignFirstResponder()
        return getResult(textField.text!)
    }
    
    func getResult(inputLocation: String) -> Bool {
        geocoder.geocodeAddressString(inputLocation, completionHandler: {(placemarks, error) -> Void in
            //show alert when address is invaled
            if((error) != nil){
                print("Error", error)
                
                let alertController = UIAlertController(title: "Invalid Location", message: "Please enter a valid address", preferredStyle: .Alert)
                let OKAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
                    print("Error Dismissed");
                    return
                    
                }
                alertController.addAction(OKAction)
                
                self.presentViewController(alertController, animated: true, completion:nil)
                
                return
            }
            
            // Display results from Geocoder
            self.globalPlaceMarks = placemarks
            self.resultTable.reloadData()
            print("Number of placemarks: \(placemarks?.count)")
        })
        
        return true
    }
    
    // TODO: Figure out how to take actions after a cell in table view is selected
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        print("Row: \(row)")
        
        // performSegueWithIdentifier("resultSelectedSegue", sender: indexPath)
        let place_mark = globalPlaceMarks![row]
        delegate!.getBackFromSearch(place_mark)
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let row = indexPath.row
        print("Row: \(row)")
        
        // performSegueWithIdentifier("resultSelectedSegue", sender: indexPath)
        let place_mark = globalPlaceMarks![row]
        delegate!.getBackFromSearch(place_mark)
        if let navigationController = self.navigationController
        {
            navigationController.popViewControllerAnimated(true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if  segue.identifier == "resultSelectedSegue",
            let destination = segue.destinationViewController as? ViewController
        {
            let cell = sender as! LocationResultCell
            let placeMark = cell.PlaceMark!
            print("Cell: \(placeMark)")
            // destination.inputAddressTextField.text = placeMark.name
            destination.getBackFromSearch(placeMark)
        }
    }

}
