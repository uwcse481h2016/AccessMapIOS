import UIKit
import Mapbox
// UITableViewDataSource
class ViewController: UIViewController, UISearchBarDelegate, MGLMapViewDelegate, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, UITableViewDelegate, RoutingDelegate, OptionsDelegate, ReportingDelegate, SearchViewDelegate, UINavigationControllerDelegate {
    
    // Mark: properties
    
    // Enable verbal debug: output debug info to the console
    let enableDebugMode = true
    
    // iOS build-in geocoder support
    let geocoder = CLGeocoder()
    
    // iOS build-in location service
    let locManager = CLLocationManager()
    
    // store whether it is the first time to open the appliaciton
    var firstTime = true;
    
    // store whether or not to show toggleable data
    var showCurbRamps = true;
    var showElevationData = true;
    var showBusStops = true;
    
    var inReportMode = false;
    
    // store the current and end location coordintes
    // useful in several places
    var currentCoordinates: CLLocationCoordinate2D!
    var endCoordinates: CLLocationCoordinate2D!
    
    // store the bus stop, crossings, and elevation line annotations drawn on the screen
    var busStops = [MGLPointAnnotation]()
    var curbLines = [MGLPolyline]()
    var elevationLines = [MGLPolyline]()
    
    // store the start and end markers drawn on the screen
    var startEndMarkers = [MGLPointAnnotation]()
    
    // store the route lines drawn on the screen
    var routingLines = [MGLPolyline]()
    
    // store the marker displayed when the user is reporting data (to allow removal of marker after user is done reporting)
    var reportMarker: MGLPointAnnotation! = nil
    
    // Single tab gesture which enables in routing mode: User tap on a location, and it show a route from current location
    // to that location
    var singleTap: UITapGestureRecognizer!

    // Indentification of who call result scene
    var resultSceneCallerTag: Int?
    
    // Define grade
    let high_grade = 0.0833
    let mid_grade = 0.05
    
    var elevationStyleURL = NSURL(string: "mapbox://styles/wangx23/cilbmjh95000u9jm1jlg1wb26")
    
    var start : UITextField!
    var end : UITextField!
    
    
    @IBOutlet var map: MGLMapView!
    
    // buttons displayed at base of map
    @IBOutlet weak var legend: UIButton!
    @IBOutlet weak var here: UIButton!
    @IBOutlet weak var route: UIButton!
    
    @IBOutlet weak var reportInstructionLabel: UILabel!
    
    // text fields
    @IBOutlet weak var inputAddressTextField: UITextField!
    @IBOutlet weak var startAddressTextField: UITextField!
    @IBOutlet weak var endAddressTextField: UITextField!

    // labels displaying "from" and "to" in start/end address text fields
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        onShowMapMode()
        
        locManager.requestWhenInUseAuthorization()
        
        inputAddressTextField.tag = 100
        startAddressTextField.tag = 101
        endAddressTextField.tag = 102
        
        map.delegate = self
        map.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        map.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ViewController.startReport(_:))))
        map.styleURL = elevationStyleURL
        
        formatBaseButton(here)
        formatBaseButton(legend)
        formatBaseButton(route)
        
        route.layer.borderColor = UIColor.clearColor().CGColor
        
        inputAddressTextField.delegate = self
        startAddressTextField.delegate = self
        endAddressTextField.delegate = self
        styleTextFields()
        
        reportInstructionLabel.hidden = true;
        route.hidden = true;
        
        singleTap = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleSingleTap(_:)))
        route.hidden = false
    }

    // Call tutorial scene
    func activateTutorial() {
        self.performSegueWithIdentifier("TutorialSegue", sender: nil)
    }

    // In routing mode, tap on a destination on map to get the route from current location to the destination
    func handleSingleTap(tap: UITapGestureRecognizer) {
        if currentCoordinates == nil {
            print("Current Coordinate not avaliable, use current location as current coordinate")
            locManager.requestWhenInUseAuthorization()
            
            let currentLocation = locManager.location
            print(currentLocation!.coordinate.longitude)
            print(currentLocation!.coordinate.latitude)
            
            startAddressTextField.text = "Current Location"
            self.currentCoordinates = currentLocation!.coordinate
        }
        
        // Convert tap location (CGPoint) to geographic coordinates (CLLocationCoordinate2D)
        let location: CLLocationCoordinate2D = map.convertPoint(tap.locationInView(map), toCoordinateFromView: map)
        let InputLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        geocoder.reverseGeocodeLocation(InputLocation, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print("Error", error)
                
                let alertController = UIAlertController(title: "Invalid Location", message: "Tapped Location Info not Found", preferredStyle: .Alert)
                let closeAction = UIAlertAction(title: "Close", style: .Default) { (action:UIAlertAction!) in
                    print("Error Dismissed");
                    return
                }
                alertController.addAction(closeAction)
                
                self.presentViewController(alertController, animated: true, completion:nil)
                
                return
            }
            if let namedPlaces = placemarks {
                if let firstPlace = namedPlaces.first {
                     self.endAddressTextField.text = firstPlace.name
                } else {
                    self.endAddressTextField.text = "Dropped Pin"
                }
            } else {
                self.endAddressTextField.text = "Dropped Pin"
            }
            
            
        })
        
        self.endCoordinates = location
        drawStartEndMarker(self.currentCoordinates, endCoordinates: self.endCoordinates)
        
        routeByAddress()
    }
    
    
    func styleTextFields() {
        inputAddressTextField.borderStyle = UITextBorderStyle.RoundedRect
        startAddressTextField.borderStyle = UITextBorderStyle.RoundedRect
        endAddressTextField.borderStyle = UITextBorderStyle.RoundedRect
        
        startAddressTextField.leftViewMode = UITextFieldViewMode.Always
        startAddressTextField.leftView = fromLabel
        
        endAddressTextField.leftViewMode = UITextFieldViewMode.Always
        endAddressTextField.leftView = toLabel
        
        startAddressTextField.hidden = true;
        endAddressTextField.hidden = true;
        fromLabel.hidden = true;
        toLabel.hidden = true;
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if enableDebugMode {
            print("called touchesBegan")
        }


        if let touch = touches.first {
            let position = touch.locationInView(view)
            print(position)
        }
    }
    
    func onChooseManualWheelchairOption() {
        if enableDebugMode {
            print("onChooseManualWheelchairOption() called")
        }
        
        onShowRoutingMode()
        reverseTextFieldHideAndShow()

        routeByAddress()
    }
    
    func onChoosePowerWheelchairOption() {
        if enableDebugMode {
            print("onChoosePowerWheelchairOption() called")
        }
        
        onShowRoutingMode()
        reverseTextFieldHideAndShow()

        routeByAddress()
    }
    
    func onChooseOtherMobilityAidOption() {
        if enableDebugMode {
            print("onChooseOtherMobilityAidOption() called")
        }
        
        onShowRoutingMode()
        reverseTextFieldHideAndShow()

        routeByAddress()
    }
    
    func toggleCurbRamps() {
        showCurbRamps = !showCurbRamps
        if !showCurbRamps {
            clearCurbRamps()
        } else {
            drawCurbramps()
        }
    }
    
    func toggleElevationData() {
        showElevationData = !showElevationData
        if !showElevationData {
            clearElevationLines()
        } else {
            drawElevationData()
        }
    }
    
    func toggleBusStops() {
        showBusStops = !showBusStops
        if !showBusStops {
            clearBusStops()
        } else {
            drawBusStops()
        }
    }
    
    // Dispatches report to developer (TODO; currently prints message to console) and
    // displays alert view notifying user that message has been sent
    func sendReport(message: String) {
        print("message is " + message)
        // Add code for sending message to a developer's email
        
        let alertView = UIAlertController(title: "Sent!",
                                          message: "Your ressage:\n" + message + "\n\n report is not yet supported in current version, but we'll definitely add it in the future :)",
                                          preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alertView, animated: true, completion: self.removeReportAnnotation)
    }
    
    func removeReportAnnotation() {
        self.map.removeAnnotation(reportMarker)
    }
    
    func cancelReport() {
        removeReportAnnotation()
    }
    
    // enter reporting mode, so that user's next tap will display an annotation and textbox
    func enterReportMode() {
        if enableDebugMode {
            print("entered Report mode")
        }

        inReportMode = true
        reportInstructionLabel.hidden = false
    }
    
    // style legend, here, and route buttons
    func formatBaseButton(button: UIButton) {
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.whiteColor().CGColor
        
        button.layer.shadowColor = UIColor.grayColor().CGColor
        button.layer.shadowOpacity = 0.8
        button.layer.shadowRadius = 5
        button.layer.shadowOffset = CGSizeMake(5, 5)
    }
    
    
    // MARK: Actions
    
    func routeByAddress() {
        if endCoordinates == nil {
            return
        }
        onShowRoutingMode()
        map.userTrackingMode = .Follow
        locManager.requestWhenInUseAuthorization()
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
            
            
            if currentCoordinates == nil {
                let currentLocation = locManager.location
                if enableDebugMode {
                    print("current location")
                }
                
                print(currentLocation!.coordinate.longitude)
                print(currentLocation!.coordinate.latitude)
                self.currentCoordinates = currentLocation!.coordinate
            }
            
            
            let center = CLLocationCoordinate2DMake((currentCoordinates.latitude + endCoordinates.latitude) / 2, (currentCoordinates.longitude + self.endCoordinates.longitude) / 2)
            let verticalDifference = 180 / (currentCoordinates.latitude - self.endCoordinates.latitude)
            
            let horizontalDifference = 360 / (currentCoordinates.longitude - endCoordinates.longitude)
            let maxC = min(abs(verticalDifference), abs(horizontalDifference))
            //
            //                        // get the zoom level
            if (enableDebugMode) {
                print(log(maxC))
            }

            //                        // set the map position
            self.map.setCenterCoordinate(center, zoomLevel: log(maxC) + 3, animated: true)
            self.drawRouting(currentCoordinates, endCoordinates: self.endCoordinates)
            clearAnnotations()
        }
    }
    
    @IBAction func powerWheelChairButtonAction(sender: AnyObject) {
        if enableDebugMode {
            print("powerWheelChairButton called")
        }

        routeByAddress()
    }
    
    @IBAction func manualWheelchairButtonAction(sender: UIButton) {
        if enableDebugMode {
            print("manualWheelchairButton called")
        }

        routeByAddress()
    }
    
    @IBOutlet weak var otherUserButton: UIButton!
    @IBOutlet weak var powerWheelchairButton: UIButton!
    @IBOutlet weak var manualWheelchairButton: UIButton!
    
    @IBAction func pedestrianButtonAction(sender: AnyObject) {
        print("pedestrian button called")
        routeByAddress()
    }
    
    @IBAction func wheelChairButtonAction(sender: AnyObject) {
        print("WheelChairButton called")
        routeByAddress()
    }
    
    @IBAction func backButtonAction(sender: AnyObject) {
        print("back button clicked")
        for i in 0..<self.routingLines.count {
            self.map.removeAnnotation(self.routingLines[i])
        }
        
        self.routingLines.removeAll()
        reverseTextFieldHideAndShow()
    }
    
    func getBackFromSearch(returnedLocation: CLPlacemark) {
        print("Get Back From Search Called")

        if resultSceneCallerTag == nil {
            print("Get Back From Search Failed to identify its caller")
            return
        }

        if resultSceneCallerTag == 100 {
            // Caller is inputAddressTextField

            inputAddressTextField.text = returnedLocation.name

            // Set start and end address input field, even when they are invisible
            startAddressTextField.text = "Current Location"
            endAddressTextField.text = inputAddressTextField.text
            // show up the route button
            self.route.hidden = false
            // when maker is valid
            self.endCoordinates = returnedLocation.location!.coordinate

            // remove the markers for start and end;
            for i in 0..<self.startEndMarkers.count {
                self.map.removeAnnotation(self.startEndMarkers[i])
            }
            
            // make the new end makers
            let endMarkers = self.drawMarker(self.endCoordinates, title: "end")
            // append to the startEndMarkers
            self.startEndMarkers.append(endMarkers);
            // set the center of the map to be the markers
            self.map.setCenterCoordinate(self.endCoordinates, zoomLevel:15, animated: true)
        } else {
            if resultSceneCallerTag == 101 {
                // Caller is startAddressTextField
                startAddressTextField.text = returnedLocation.name
                self.currentCoordinates = returnedLocation.location!.coordinate
            } else if resultSceneCallerTag == 102 {
                // Caller is endAddressTextField
                endAddressTextField.text = returnedLocation.name
                self.endCoordinates = returnedLocation.location!.coordinate
            }
            
            if currentCoordinates != nil && endCoordinates != nil {
                // draw makers
                self.drawStartEndMarker(currentCoordinates, endCoordinates: endCoordinates)
                routeByAddress()
            }
        }

        resultSceneCallerTag = nil
    }
    
    /** Callback function when the text finished edit.
     * It grab the address from the user and try to place marker or find route for the user
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("textFieldShouldReturn is on called")
        // Hide the keyboard.
        textField.resignFirstResponder()
        if textField.text == "" || textField.text == "Dropped Pin" || textField.text == "Current Location"{
            return true
        }
        
        resultSceneCallerTag = textField.tag

        if resultSceneCallerTag == 100 || resultSceneCallerTag == 101 || resultSceneCallerTag == 102 {
            performSegueWithIdentifier("searchResultSegue", sender: textField)
            return true
        }

        return false
    }
    
    /** get the current location of the user
     */
    @IBAction func showHere(sender: AnyObject) {
        map.userTrackingMode = .Follow
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case "searchResultSegue"?:
            let nextView = segue.destinationViewController as! SearchViewController
            nextView.delegate = self
            let textField = sender as! UITextField
            if let destination = textField.text {
                nextView.LocationToSearch = destination
                nextView.getResult(destination)
            }
        case "legendSegue"?:
            let popoverViewController = segue.destinationViewController
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverViewController.popoverPresentationController!.delegate = self
            segue.destinationViewController.popoverPresentationController?.sourceRect = sender!.bounds
        case "routeSegue"?:
            let popoverViewController = segue.destinationViewController as! RoutingViewController
            popoverViewController.delegate = self
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverViewController.popoverPresentationController!.delegate = self
            segue.destinationViewController.popoverPresentationController?.sourceRect = sender!.bounds
        case "optionsSegue"?:
            let popoverViewController = segue.destinationViewController as! OptionsViewController
            popoverViewController.delegate = self
            popoverViewController.modalPresentationStyle = UIModalPresentationStyle.Popover
            popoverViewController.popoverPresentationController!.delegate = self
        //segue.destinationViewController.popoverPresentationController?.sourceRect = sender!.bounds
        default:
            break
        }
    }
    
    // Additional work when pop overs are dismissed
    func popoverPresentationControllerDidDismissPopover(popoverPresentationController: UIPopoverPresentationController) {
        if reportMarker != nil {
            map.removeAnnotation(reportMarker)
            reportMarker = nil
        }
    }
    
    // Allows PopupPresentationViewControllers to be displayed as pop-up rather than alert
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    // Action when back button is clicked, reverting app from "routing" to "map" mode
    // And remove gesture
    @IBAction func returnToMapMode(sender: UIBarButtonItem) {
        for i in 0..<self.routingLines.count {
            self.map.removeAnnotation(self.routingLines[i])
        }
        
        for i in 0..<self.startEndMarkers.count {
            map.removeAnnotation(self.startEndMarkers[i])
        }
        
        if endCoordinates != nil {
            self.map.setCenterCoordinate(self.endCoordinates, zoomLevel:15, animated: true)
        }
        
        self.routingLines.removeAll()
        reverseTextFieldHideAndShow()
        map.removeGestureRecognizer(singleTap)
        
        // Reset Current and End coordinates
        currentCoordinates = nil
        endCoordinates = nil
        startAddressTextField.text = ""
        endAddressTextField.text = ""
        
        onShowMapMode()
        // route.hidden = true
    }
    
    // modify navbar on entering map mode, hiding back button and showing Map as the title
    func onShowMapMode() {
        self.navigationItem.title = "Map"
        hideAndDisableBackButton()
    }
    
    // hide back button in top navbar
    func hideAndDisableBackButton (){
        self.navigationItem.leftBarButtonItem?.enabled = false
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.clearColor()
    }
    
    // show back button in  top navbar
    func showAndEnableBackButton(){
        self.navigationItem.leftBarButtonItem?.enabled = true
        self.navigationItem.leftBarButtonItem?.tintColor = nil
        
    }
    
    // modify navbar on entering routing mode, showing back button and showing Routing as the title
    // And add the gesture
    func onShowRoutingMode() {
        let nav = self.navigationController?.navigationBar
        nav?.topItem!.title = "Routing"
        map.addGestureRecognizer(singleTap)
        showAndEnableBackButton()
    }
    
    /** reverse the text field to shown up on the map
     */
    func reverseTextFieldHideAndShow() {
        self.inputAddressTextField.hidden = !self.inputAddressTextField.hidden
        self.startAddressTextField.hidden = !self.startAddressTextField.hidden
        self.endAddressTextField.hidden = !self.endAddressTextField.hidden
        self.fromLabel.hidden = !self.fromLabel.hidden
        self.toLabel.hidden = !self.toLabel.hidden
        self.route.hidden = !self.route.hidden
    }
    
    /** draw the start and end markers of the routes
     * @param: startCoordinnates: start coordinates, endCoordinates: end coordinates
     */
    func drawStartEndMarker(startCoordinnates: CLLocationCoordinate2D, endCoordinates:CLLocationCoordinate2D) {
        if enableDebugMode {
            print("draw start and end markers")
        }

        for i in 0..<self.startEndMarkers.count {
            map.removeAnnotation(self.startEndMarkers[i])
        }
        
        let start = drawMarker(startCoordinnates, title: "")
        let end = drawMarker(endCoordinates, title: "")
        self.startEndMarkers.append(start);
        self.startEndMarkers.append(end);
        
    }
    
    /** draw the marker on the map
     * @param: coordinate: for what coordinates the marker should be put. Title: the tittle for the markers
     */
    func drawMarker(coordinate: CLLocationCoordinate2D, title: String) -> MGLPointAnnotation{
        let marker = MGLPointAnnotation()
        marker.coordinate = coordinate
        if title != "" {
            marker.title = title
            marker.subtitle = title
        }
        map.addAnnotation(marker)
        map.selectAnnotation(marker, animated: true)
        
        return marker
    }
    
    /**draw the routing between the start and end point
     * @param: startCordinates: the start of the route. endCoordinates: the end of the route
     *
     */
    func drawRouting (startCoordinates: CLLocationCoordinate2D, endCoordinates:CLLocationCoordinate2D) {
        // set up the route api
        let apiURL = "http://dssg-db.cloudapp.net/api/routing/route.json?waypoints=[" + String(startCoordinates.latitude) + ",%20" + String(startCoordinates.longitude) + ",%20" + String(endCoordinates.latitude) + ",%20" + String(endCoordinates.longitude) + "]"
        
        let nsURL = NSURL(string: apiURL)
        
        let routingData = NSData(contentsOfURL: nsURL!)
        
        //show alert when handdle there's no route
        if(routingData == nil) {
            print("error: can't get routing data")
            
            let alertController = UIAlertController(title: "No Route", message: "No accessible route from start to end location.", preferredStyle: .Alert)
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
                print("Error Dismissed");
                return
                
            }
            alertController.addAction(OKAction)
            
            self.presentViewController(alertController, animated: true, completion:nil)
            
            return
        }
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // clean the previous route data drawn on the map
            for i in 0..<self.routingLines.count {
                self.map.removeAnnotation(self.routingLines[i])
            }
            // clean the previous route data store in the lines
            self.routingLines.removeAll()
            do {
                // Load and serialize the GeoJSON into a dictionary filled with properly-typed objects
                if let jsonDict = try NSJSONSerialization.JSONObjectWithData(routingData!, options: []) as? NSDictionary {
                    var numFeatures = 0
                    // Load the `features` array for iteration
                    if let routes = jsonDict["routes"] as? NSArray {
                        for route in routes {
                            if let route = route as? NSDictionary {
                                if let geometry = route["geometry"] as? NSDictionary {
                                    // Create an array to hold the formatted coordinates for our line
                                    
                                    if let locations = geometry["coordinates"] as? NSArray {
                                        // Iterate over line coordinates, stored in GeoJSON as many lng, lat arrays
                                        for i in 1..<locations.count {
                                            
                                            var coordinates: [CLLocationCoordinate2D] = []
                                            
                                            if let points1 = locations[i - 1] as? NSArray {
                                                let coordinate = CLLocationCoordinate2DMake(points1[1].doubleValue, points1[0].doubleValue)
                                                coordinates.append(coordinate)
                                            }
                                            
                                            if let points2 = locations[i] as? NSArray {
                                                let coordinate2 = CLLocationCoordinate2DMake(points2[1].doubleValue, points2[0].doubleValue)
                                                coordinates.append(coordinate2)
                                            }
                                            
                                            // Make a CLLocationCoordinate2D with the lat, lng
                                            // Add coordinate to coordinates array
                                            let line = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
                                            self.routingLines.append(line)
                                            line.title = "route"
                                            line.subtitle = "route"
                                            numFeatures += 1
                                            // Add the annotation on the main thread
                                            dispatch_async(dispatch_get_main_queue(), {
                                                // Unowned reference to self to prevent retain cycle
                                                [unowned self] in
                                                self.map.addAnnotation(line)
                                                })
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            catch
            {
                print("GeoJSON parsing failed")
            }
        })
    }
    
    /** draw the curbramps data for the map
     */
    func drawCurbramps() {
        if !showCurbRamps {
            return
        }
        
        clearCurbRamps()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // try to get data for curb ramps
            let bounds = self.map.visibleCoordinateBounds
            let apiURL = "http://accessmap-api.azurewebsites.net/v2/crossings.geojson?bbox=" + String(bounds.sw.longitude) + "," + String(bounds.sw.latitude) + "," + String(bounds.ne.longitude) + "," + String(bounds.ne.latitude)
            let nsURL = NSURL(string: apiURL)
            let curbrampsData = NSData(contentsOfURL: nsURL!)
            // can't get curbramsData
            if(curbrampsData == nil) {
                print("can't get cubramps data ")
                return;
            }
            
            do {
                // Load and serialize the GeoJSON into a dictionary filled with properly-typed objects
                if let jsonDict = try NSJSONSerialization.JSONObjectWithData(curbrampsData!, options: []) as? NSDictionary {
                    var numFeatures = 0
                    // Load the `features` array for iteration
                    if let features = jsonDict["features"] as? NSArray {
                        for feature in features {
                            if let feature = feature as? NSDictionary {
                                if let geometry = feature["geometry"] as? NSDictionary {
                                    
                                    
                                    if geometry["type"] as? String == "LineString" {
                                        // Create an array to hold the formatted coordinates for our line
                                        var coordinates: [CLLocationCoordinate2D] = []
                                        
                                        if let locations = geometry["coordinates"] as? NSArray {
                                            // Iterate over line coordinates, stored in GeoJSON as many lng, lat arrays
                                            for location in locations {
                                                // Make a CLLocationCoordinate2D with the lat, lng
                                                let coordinate = CLLocationCoordinate2DMake(location[1].doubleValue, location[0].doubleValue)
                                                
                                                // Add coordinate to coordinates array
                                                coordinates.append(coordinate)
                                            }
                                        }
                                        numFeatures += 1
                                        let line = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
                                        
                                        line.title = "curbcut"
                                        
                                        self.curbLines.append(line)
                                        
                                        // Add the annotation on the main thread
                                        dispatch_async(dispatch_get_main_queue(), {
                                            // Unowned reference to self to prevent retain cycle
                                            [unowned self] in
                                            self.map.addAnnotation(line)
                                            })
                                    }
                                }
                            }
                        }
                    }
                    
                    print("Number of features = " + String(numFeatures))
                    
                }
            }
            catch
            {
                print("GeoJSON parsing failed")
            }
            
        })
        
    }
    
    
    // draw bus stop icons at locations retrieved from OBA API
    func drawBusStops() {
        if enableDebugMode {
            print("Called drawBusStops")
        }
        
        if !showBusStops {
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // Get the path for example.geojson in the app's bundle
            let OBA_KEY = "88c668dd-1d01-42a1-a600-0caa8029df65"
            let bounds = self.map.visibleCoordinateBounds
            let center = self.map.centerCoordinate
            
            let obaURL = "http://api.pugetsound.onebusaway.org/api/where/stops-for-location.json?key=" + OBA_KEY + "&lat=" + String(center.latitude) + "&lon=" + String(center.longitude) + "&latSpan=" + String(abs(bounds.ne.latitude - bounds.sw.latitude)) + "&lonSpan=" + String(abs(bounds.ne.longitude - bounds.sw.longitude))
            
            let nsURL = NSURL(string: obaURL)
            let obaData = NSData(contentsOfURL: nsURL!)
            if(obaData == nil) {
                print("error: can't get obaData")
                return;
            }
            
            do {
                // Load and serialize the GeoJSON into a dictionary filled with properly-typed objects
                if let jsonDict = try NSJSONSerialization.JSONObjectWithData(obaData!, options: []) as? NSDictionary {
                    //print("jsonDict = " + String(jsonDict))
                    var numFeatures = 0
                    // Load the `features` array for iteration
                    if let data = jsonDict["data"] as? NSDictionary {
                        //print("jsonData = " + String(data))
                        if let list = data["list"] as? NSArray {
                            //print("jsonList = " + String(list))
                            for row in list {
                                let coordinate = CLLocationCoordinate2DMake(row["lat"]!!.doubleValue, row["lon"]!!.doubleValue)
                                print("coordinate = " + String(coordinate))
                                numFeatures += 1
                                
                                let point = MGLPointAnnotation()
                                point.title = "busstop"
                                point.coordinate = coordinate
                                self.busStops.append(point)
                                
                                // Add the annotation on the main thread
                                dispatch_async(dispatch_get_main_queue(), {
                                    // Unowned reference to self to prevent retain cycle
                                    [unowned self] in
                                    self.map.addAnnotation(point)
                                    })
                                
                            }
                            
                        }
                    }
                    print("Number of features = " + String(numFeatures))
                }
            }
            catch
            {
                print("GeoJSON parsing failed")
            }
            
        })
    }
    
    // Draw lines representing elevation of sidewalks retrieved from AccessMap API
    func drawElevationData() {
        if enableDebugMode {
            print("Called drawElevationData")
        }
        
        // Parsing GeoJSON can be CPU intensive, do it on a background thread
        if !showElevationData {
            return
        }
        
        for i in 0..<self.elevationLines.count {
            self.map.removeAnnotation(self.elevationLines[i])
        }
        
        self.elevationLines.removeAll()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // Get the path for example.geojson in the app's bundle
            
            let bounds = self.map.visibleCoordinateBounds
            let apiURL = "http://accessmap-api.azurewebsites.net/v2/sidewalks.geojson?bbox=" + String(bounds.sw.longitude) + "," + String(bounds.sw.latitude) + "," + String(bounds.ne.longitude) + "," + String(bounds.ne.latitude)
            let nsURL = NSURL(string: apiURL)
            let sidewalkData = NSData(contentsOfURL: nsURL!)
            if(sidewalkData == nil) {
                print("error: can't get side walk data")
                return;
            }
            // Gradations (drawn from https://github.com/AccessMap/AccessMap-webapp/blob/master/static/js/elevation.js)
            
            do {
                // Load and serialize the GeoJSON into a dictionary filled with properly-typed objects
                if let jsonDict = try NSJSONSerialization.JSONObjectWithData(sidewalkData!, options: []) as? NSDictionary {
                    var numFeatures = 0
                    // Load the `features` array for iteration
                    if let features = jsonDict["features"] as? NSArray {
                        for feature in features {
                            if let feature = feature as? NSDictionary {
                                if let geometry = feature["geometry"] as? NSDictionary {
                                    if geometry["type"] as? String == "LineString" {
                                        // Create an array to hold the formatted coordinates for our line
                                        var coordinates: [CLLocationCoordinate2D] = []
                                        
                                        if let locations = geometry["coordinates"] as? NSArray {
                                            // Iterate over line coordinates, stored in GeoJSON as many lng, lat arrays
                                            for location in locations {
                                                // Make a CLLocationCoordinate2D with the lat, lng
                                                let coordinate = CLLocationCoordinate2DMake(location[1].doubleValue, location[0].doubleValue)
                                                
                                                // Add coordinate to coordinates array
                                                coordinates.append(coordinate)
                                            }
                                        }
                                        numFeatures += 1
                                        let line = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
                                        
                                        line.title = "elevation line"
                                        if let properties = feature["properties"] as? NSDictionary {
                                            // let grade = properties["grade"] as? Double
                                            if let grade = properties["grade"] as? Double {
                                                line.subtitle = NSString(format: "%.3f", grade) as String
                                            } else {
                                                line.subtitle = "No grade info"
                                            }

                                        }
                                        self.elevationLines.append(line)
                                        
                                        // Add the annotation on the main thread
                                        dispatch_async(dispatch_get_main_queue(), {
                                            // Unowned reference to self to prevent retain cycle
                                            [unowned self] in
                                            self.map.addAnnotation(line)
                                            
                                            })
                                    }
                                }
                            }
                        }
                    }
                    
                    print("Number of features = " + String(numFeatures))
                }
            }
            catch
            {
                print("GeoJSON parsing failed")
            }
        })
    }
    
    func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController) {
        print("Preparing for popover presentation!")
    }
    
    // If user is in report mode, recognize the location of a tap and display marker there,
    // showing a popup where user can enter text
    func startReport(sender: UITapGestureRecognizer) {
        if !inReportMode {
            return
        }
        reportInstructionLabel.hidden = true
        print("Entered startReport()")
        if sender.state == .Ended {
            let location1 = sender.locationInView(map)
            print("location in View = " + String(location1))
            // handling code
            let location: CLLocationCoordinate2D = map.convertPoint(sender.locationInView(map), toCoordinateFromView: map)
            print("You tapped at: \(location.latitude), \(location.longitude)")
            
            reportMarker = MGLPointAnnotation()
            reportMarker.coordinate = location
            
            map.addAnnotation(reportMarker)
            map.selectAnnotation(reportMarker, animated: true)
            
            let storyboard = self.storyboard
            let reportPopupController = storyboard!.instantiateViewControllerWithIdentifier("reportPopup") as! ReportViewController
            reportPopupController.modalPresentationStyle = .Popover
            reportPopupController.delegate = self
            
            let reportPresentationController = reportPopupController.popoverPresentationController
            reportPresentationController?.permittedArrowDirections = .Any
            reportPresentationController?.delegate = self
            reportPresentationController?.sourceView = map
            reportPresentationController?.sourceRect = CGRect(
                x: location1.x,
                y: location1.y - 20,
                width: 1,
                height: 1)
            self.presentViewController(
                reportPopupController,
                animated: true,
                completion: nil)
            
            inReportMode = false
        }
    }
    
    
    // clear elevation data, crossings, and bus stops from map
    func clearAnnotations() {
        clearElevationLines()
        clearCurbRamps()
        clearBusStops()
        return
    }
    
    // clear elevation annotations stored in elevationLines from map
    func clearElevationLines() {
        for i in 0..<self.elevationLines.count {
            self.map.removeAnnotation(self.elevationLines[i])
        }
        
        self.elevationLines.removeAll()
    }
    
    // clear crossing annotations stored in curbLines from map
    func clearCurbRamps() {
        for i in 0..<self.curbLines.count {
            self.map.removeAnnotation(self.curbLines[i])
        }
        
        self.curbLines.removeAll()
    }
    
    // clear bus stop annotations stored in busStops from map
    func clearBusStops() {
        for i in 0..<self.busStops.count {
            self.map.removeAnnotation(self.busStops[i])
        }
        
        self.busStops.removeAll()
    }
    
    // update map whenever region is changed, by clearing/redrawing all annotations
    func mapView(mapView: MGLMapView, regionDidChangeAnimated animated: Bool) -> Void {
        print("Region changed")
        print("Zoom level = " + String(mapView.zoomLevel))
        
        if( firstTime ){
            firstTime = false
        }
        
        clearAnnotations()
        if (mapView.zoomLevel >= 14) {
            drawElevationData()
            drawCurbramps()
            
            if (mapView.zoomLevel > 15) {
                // Draw bus stops only if zoomed in close enough to prevent bus stop icons from cluttering up map
                drawBusStops()
            }
        }
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    // Show information for elevation lines
//    func mapView(mapView: MGLMapView, leftCalloutAccessoryViewForAnnotation annotation: MGLAnnotation) -> UIView? {
//
//        print("Annotation title: \(annotation.title!)")
//        print("Eval: \(annotation.title! == "elevation line")")
//
//        if (annotation.title! == "elevation line") {
//            let label = UILabel(frame: CGRectMake(0, 0, 60, 50))
//            label.textAlignment = .Right
//            label.textColor = UIColor(red: 0.81, green: 0.71, blue: 0.23, alpha: 1)
//            // label.text = NSString(format: "Grade: %s", annotation.subtitle!!) as String
//            label.text = "HAHAHAHA"
//
//            return label
//        }
//
//        return nil
//    }
    
//    func mapView(mapView: MGLMapView, tapOnCalloutForAnnotation annotation: MGLAnnotation) {
//        // pop-up the callout view
//        print("Annotation get taped!!")
//        mapView.selectAnnotation(annotation, animated: true)
//    }
    
    func mapView(mapView: MGLMapView, rightCalloutAccessoryViewForAnnotation annotation: MGLAnnotation) -> UIView? {
        return UIButton(type: .DetailDisclosure)
    }
    
//    func mapView(mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        // hide the callout view
//        mapView.deselectAnnotation(annotation, animated: false)
        
//        UIAlertView(title: annotation.title!!, message: "More information goes here.", delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK").show()
//    }
    
    // use bus stop image for annotations titled "busstop"; standard annotation otherwise
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        if (annotation.title! == "busstop") {
            var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("busStop")
            
            if annotationImage == nil {
                // bus stop image
                let image = UIImage(named: "Bus_Stop")!
                annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "busStop")
            }
            
            return annotationImage
        } else {
            return nil
        }
        
    }
    
    func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        // Set line width for polyline annotations
        let zoomLv = mapView.zoomLevel
        if zoomLv > 17 {
            return 6.0
        } else if zoomLv > 15 {
            return 4.0
        } else {
            return 2.5
        }
    }
    
    func mapView(mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return 0.5
    }
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        
        if(annotation.title == "curbcut" && annotation is MGLPolyline) {
            return UIColor.blueColor()
        }
        
        if(annotation.title == "route" && annotation is MGLPolyline) {
            return UIColor.blackColor()
        }
        
        if (annotation.title == "elevation line" && annotation is MGLPolyline) {

            if (annotation.subtitle == "No grade info") {
                return UIColor.blackColor()
            } else {
                let grade = (annotation.subtitle! as NSString).doubleValue
                
                if grade >= high_grade {
                    return UIColor.redColor()
                } else if grade > mid_grade {
                    return UIColor.yellowColor()
                } else {
                    return UIColor.greenColor()
                }
            }
        } else {
            return UIColor.purpleColor()
        }
    }
    
    func mapView(mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return UIColor.purpleColor()
    }
    
}

