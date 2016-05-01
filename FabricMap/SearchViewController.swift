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
        let cell = UITableViewCell()
        
        if (globalPlaceMarks == nil) {
            cell.textLabel?.text = "No Result"
        } else {
            // cell.textLabel?.text = "One of the Result"
            if (!(globalPlaceMarks?.isEmpty)!) {
                let one_psmk = globalPlaceMarks?.popLast()
                cell.textLabel?.text = "\((one_psmk?.name)!), ZIP\((one_psmk?.postalCode)!)"
                print("\((one_psmk?.name)!), ZIP\((one_psmk?.postalCode)!)")            }
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
