import UIKit
import Mapbox

class SearchViewController: UIViewController, UITableViewDataSource {
    
    let geocoder = CLGeocoder()
    
    var globalPlaceMarks : [CLPlacemark]?
    
    @IBOutlet weak var searchLocation: UITextField!
    
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
        print("mark1")
        // let cellIdentifier = "LocationResultCell"
        // let cell = LocationResultCell()
        let cell = resultTable.dequeueReusableCellWithIdentifier("LocationResultCell", forIndexPath: indexPath) as! LocationResultCell
        print("mark2")
        
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
                    addAdm += ", "
                    addAdm += unwarp4
                } else {
                    addAdm += ", "
                    addAdm += "(No Zip Code)"
                }
                
                if let unwarp5 = one_psmk.country {
                    addCon += unwarp5
                } else {
                    addCon += "(Unamed Country)"
                }
                // cell.textLabel?.text = "\((one_psmk?.name)!), ZIP\((one_psmk?.postalCode)!)"
                // print("\((one_psmk?.name)!), ZIP\((one_psmk?.postalCode)!)")
                
                // Load data into cell
                cell.addressName.text = addName
                cell.addressAdministrative.text = addAdm
                cell.addressCountry.text = addCon
            }
        } else {
            cell.addressName.text = "(Unknown Name)"
            cell.addressAdministrative.text = "(Unamed City), (Unamed Adm. Area), (No Zip Code)"
            cell.addressCountry.text = "(Unamed Country)"
        }
        
        return cell
    }
    
    @IBAction func searchOnClick(sender: UIButton) {
        self.resignFirstResponder()
        geocoder.geocodeAddressString(searchLocation.text!, completionHandler: {(placemarks, error) -> Void in
            //show alert when address is invaled
            if((error) != nil){
                print("Error", error)
                let alertView = UIAlertView(title: "Not found",
                    message: "Please enter a valid address",
                    delegate: nil,
                    cancelButtonTitle: "Ok")
                alertView.show()
                return;
            }
            
            // Display results from Geocoder
            self.globalPlaceMarks = placemarks
            self.resultTable.reloadData()
            print("Number of placemarks: \(placemarks?.count)")
        })
    }

}
