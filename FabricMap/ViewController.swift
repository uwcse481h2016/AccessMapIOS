//
//  ViewController.swift
//  FabricMap
//
//  Created by Xiaobo Wang on 1/27/16.
//  Copyright © 2016 Xiaobo Wang. All rights reserved.
//

import UIKit
import Mapbox

//class ViewController: UIViewController, UIPopoverPresentationControllerDelegate, MGLMapViewDelegate {
class ViewController: UIViewController, UISearchBarDelegate, MGLMapViewDelegate, UITextFieldDelegate, UIPopoverPresentationControllerDelegate, UITableViewDelegate, UITableViewDataSource, RoutingDelegate, OptionsDelegate, ReportingDelegate {
    
    var manager:CLLocationManager!
    
    // Mark: properties
    @IBOutlet weak var HereButton: UIButton!

    // store whether it is the first time to open the appliaciton
    var firstTime = true;
    
    var showCurbRamps = true;
    var showElevationData = true;
    var showBusStops = true;
    
    var inReportMode = false;
    
    // store the current location coordintes
    var currentCoordinates: CLLocationCoordinate2D!
    
    var endCoordinates : CLLocationCoordinate2D!
    
    // store the elevations lines drawed on the screen
    var elevationLines = [MGLPolyline]()
    
    // store the bus stops anotation
    var busStops = [MGLPointAnnotation]()
    
    // store the curblines annotation
    var curbLines = [MGLPolyline]()
    
    // store the start and end markers drawed on the screen
    var startEndMarkers = [MGLPointAnnotation]()
    
    // store the routing lines drawed on the screen
    var routingLines = [MGLPolyline]()
    
    var reportMarker : MGLPointAnnotation!
    
    var elevationTileStyleURL = NSURL(string: "mapbox-raster-v8.json")
    
    var elevationStyleURL = NSURL(string: "mapbox://styles/wangx23/cilbmjh95000u9jm1jlg1wb26")
    
    var start : UITextField!
    var end : UITextField!
  
    
    @IBOutlet var map: MGLMapView!
    
    @IBOutlet weak var legend: UIButton!
    
    @IBOutlet weak var here: UIButton!
    
    @IBOutlet weak var route: UIButton!
    
    @IBOutlet weak var reportInstructionLabel: UILabel!
    
    //@IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var inputAddressTextField: UITextField!
    
    @IBOutlet weak var startAddressTextField: UITextField!
    
    @IBOutlet weak var endAddressTextField: UITextField!
    
    @IBOutlet weak var fromLabel: UILabel!
    
    @IBOutlet weak var toLabel: UILabel!
    
    @IBOutlet weak var wheelChairButton: UIButton!
    
    @IBOutlet weak var powerWheelChairButton: UIButton!
    
    @IBOutlet weak var pedestrianButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        map.delegate = self
        map.styleURL = elevationStyleURL
        
        formatBaseButton(here)
        formatBaseButton(legend)
        formatBaseButton(route)
        
        let lightBlueColor = UIColor.init(red: 89,
            green: 171,
            blue: 227,
            alpha: 1)
        route.layer.borderColor = UIColor.clearColor().CGColor
        

        inputAddressTextField.borderStyle = UITextBorderStyle.RoundedRect
        startAddressTextField.borderStyle = UITextBorderStyle.RoundedRect
        endAddressTextField.borderStyle = UITextBorderStyle.RoundedRect
        inputAddressTextField.delegate = self
        startAddressTextField.delegate = self
        endAddressTextField.delegate = self
        
        startAddressTextField.leftViewMode = UITextFieldViewMode.Always
        startAddressTextField.leftView = fromLabel
        
        endAddressTextField.leftViewMode = UITextFieldViewMode.Always
        endAddressTextField.leftView = toLabel
        
        startAddressTextField.hidden = true;
        endAddressTextField.hidden = true;
        
        //backButton.hidden = true;
        fromLabel.hidden = true;
        toLabel.hidden = true;
        
        reportInstructionLabel.hidden = true;
        wheelChairButton.hidden = true;
        powerWheelChairButton.hidden = true;
        pedestrianButton.hidden = true;
        route.hidden = true;
        
        // hold to show change the map style
        map.addGestureRecognizer(UILongPressGestureRecognizer(target: self,
            action: "changeStyle:"))

        map.addGestureRecognizer(UITapGestureRecognizer(target: self,
            action: "startReport:"))
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        print("called touchesBegan")
        if let touch = touches.first {
            let position = touch.locationInView(view)
            print(position)
        }
    }
    
    func onChooseManualWheelchairOption() {
        print("onChooseManualWheelchairOption() called")
        reverseChoiceButtonHidden()
        routeByAddress()
    }

    func onChoosePowerWheelchairOption() {
        print("onChoosePowerWheelchairOption() called")
        reverseChoiceButtonHidden()
        routeByAddress()
    }
    
    func onChooseOtherMobilityAidOption() {
        print("onChooseOtherMobilityAidOption() called")
        reverseChoiceButtonHidden()
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
    
    func sendReport(message: String) {
        print("message is " + message)
        // Add code for sending message to a developer's email
        
        let alertView = UIAlertController(title: "Sent!", message: "Your ressage:\n" + message + "\n\n has been sent to the AccessMap team for review. Thanks for contributing to our database!", preferredStyle: .Alert)
        alertView.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        self.presentViewController(alertView, animated: true, completion: self.removeReportAnnotation)
    }
    
    func removeReportAnnotation() {
        self.map.removeAnnotation(reportMarker)
    }
    func cancelReport() {
        self.map.removeAnnotation(reportMarker)
    }
    
    func enterReportMode() {
        print("entered Report mode")
        inReportMode = true
        reportInstructionLabel.hidden = false
    }
    
    func formatBaseButton(button: UIButton) {
        //button.backgroundColor = UIColor.whiteColor()
        button.layer.cornerRadius = 5
        //button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 0.0)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.whiteColor().CGColor

        button.layer.shadowColor = UIColor.grayColor().CGColor;
        button.layer.shadowOpacity = 0.8;
        button.layer.shadowRadius = 5;
        button.layer.shadowOffset = CGSizeMake(5, 5);
    }
    
    
    // MARK: Actions
    @IBAction func routeButtonAction(sender: AnyObject) {
        print("routeCalled")
        reverseChoiceButtonHidden()
    }
    
    
    func reverseChoiceButtonHidden() {
        //wheelChairButton.hidden = !wheelChairButton.hidden
        //powerWheelChairButton.hidden = !powerWheelChairButton.hidden
        //pedestrianButton.hidden = !pedestrianButton.hidden
    }
    
    func routeByAddress() {
        onShowRoutingMode()
        reverseTextFieldHideAndShow()
        map.userTrackingMode = .Follow
        startAddressTextField.text = "current location"
        endAddressTextField.text = inputAddressTextField.text
        let locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Authorized){
                
                let currentLocation = locManager.location
                print("current location")
                print(currentLocation!.coordinate.longitude)
                print(currentLocation!.coordinate.latitude)
                self.currentCoordinates = currentLocation!.coordinate
                
                let center = CLLocationCoordinate2DMake((currentCoordinates.latitude + endCoordinates.latitude) / 2, (currentCoordinates.longitude + self.endCoordinates.longitude) / 2)
                let verticalDifference = 180 / (currentCoordinates.latitude - self.endCoordinates.latitude)
                
                let horizontalDifference = 360 / (currentCoordinates.longitude - endCoordinates.longitude)
                let maxC = min(abs(verticalDifference), abs(horizontalDifference))
                //
                //                        // get the zoom level
                print(log(maxC))
                //                        // set the map position
                self.map.setCenterCoordinate(center, zoomLevel: log(maxC) + 3, animated: true)
                self.drawRouting(currentCoordinates, endCoordinates: self.endCoordinates)
                clearAnnotations()
                
                print("annotation cleared!!!!!!!!!!!!!!!!!!!!!!!!!!!!")

        }
    }
    
    @IBAction func powerWheelChairButtonAction(sender: AnyObject) {
        print("powerWheelChairButton called")
        reverseChoiceButtonHidden()
        routeByAddress()
    }

    @IBAction func manualWheelchairButtonAction(sender: UIButton) {
        print("manualWheelchairButton called")
        reverseChoiceButtonHidden()
        routeByAddress()
    }
    @IBOutlet weak var otherUserButton: UIButton!
    @IBOutlet weak var powerWheelchairButton: UIButton!
    @IBOutlet weak var manualWheelchairButton: UIButton!
    @IBAction func pedestrianButtonAction(sender: AnyObject) {
        print("pedestrian button called")
        reverseChoiceButtonHidden()
        routeByAddress()
    }
    
    @IBAction func wheelChairButtonAction(sender: AnyObject) {
        print("WheelChairButton called")
        reverseChoiceButtonHidden()
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
    
    
    /** Callback function when the text finished edit. 
     * It grab the address from the user and try to place marker or find route for the user
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("textFieldShouldReturn is on called")
        // Hide the keyboard.
        textField.resignFirstResponder()

        if(!inputAddressTextField.hidden) {
            // when the destination address text field is showed
            let endAddress = inputAddressTextField.text
            if(inputAddressTextField.text == "") {
                // when input text field is called
                return false;
            }
            
            let geocoder = CLGeocoder()
            // get the coordinates of the input address
            geocoder.geocodeAddressString(endAddress!, completionHandler: {(placemarks, error) -> Void in
                if((error) != nil){
                    // when address is wrong, can't find the route;
                    print("Error", error)
                    let alertView = UIAlertView(title: "Not found",
                                message: "Please enter a valid address.",
                                delegate: nil,
                                cancelButtonTitle: "Ok")
                    alertView.show()
                    return;
                    
                }
                
                // show up the route button
                self.route.hidden = false
                if let placemark = placemarks?.first {
                    // when maker is valid
                    self.endCoordinates = placemark.location!.coordinate
                    
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
                }
            })
        } else {
            // when it shows the from and to input text field
            let startAddress = startAddressTextField.text
            let endAddress = endAddressTextField.text
            let geocoder = CLGeocoder()
            var startCoordinates:CLLocationCoordinate2D!
            if(startAddress == "current location") {
                startCoordinates = self.currentCoordinates
            }
            
            // get the coordinates of the start address
            geocoder.geocodeAddressString(startAddress!, completionHandler: {(placemarks, error) -> Void in
                if(startAddress != "current location") {
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
                }
                
                // set the startCoodrinates
                if let placemark = placemarks?.first {
                    startCoordinates = placemark.location!.coordinate
                }
                
                // try to get the destination coordinates
                if(startCoordinates != nil) {
                    geocoder.geocodeAddressString(endAddress!, completionHandler: {(placemarks, error) -> Void in
                        // pop up alert if the end coordintes is not valid
                        if((error) != nil){
                            print("Error", error)
                            let alertView = UIAlertView(title: "Not found",
                                message: "Please enter a valid address",
                                delegate: nil,
                                cancelButtonTitle: "Ok")
                            alertView.show()
                            return;
                        }
                        
                        // when both start and end coordinates are valid
                        if let placemark = placemarks?.first {
                            let endCoordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                            
                            // try to get the center of the start and end coordinates
                            let center = CLLocationCoordinate2DMake((startCoordinates.latitude + endCoordinates.latitude) / 2,
                                (startCoordinates.longitude + endCoordinates.longitude) / 2)
                            
                            // calculate for the zoom in levels;
                            let verticalDifference = 180 / (startCoordinates.latitude - endCoordinates.latitude)
                            let horizontalDifference = 360 / (startCoordinates.longitude - endCoordinates.longitude)
                            let maxC = min(abs(verticalDifference), abs(horizontalDifference))
                            
                            // set the map position
                            self.map.setCenterCoordinate(center, zoomLevel: log(maxC) + 3, animated: true)
                            
                            // draw makers
                            self.drawStartEndMarker(startCoordinates, endCoordinates: endCoordinates)
                            
                            // draw routing
                            self.drawRouting(startCoordinates, endCoordinates: endCoordinates)
                        }
                    })
                    
                }
            })
        }
        return true
    }

    
    
    
    @IBAction func showLegend(sender: AnyObject) {
        
        let image = UIImage(named: "Legend-01.png")!
        
        let imageView = UIImageView(frame: CGRectMake(25, 10, 300, 350))
        imageView.image = image
        
        let alert = UIAlertController(title: "Legend", message: "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "Exit", style: UIAlertActionStyle.Cancel, handler: {(alertAction: UIAlertAction!) in alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        alert.view.addSubview(imageView)
        //imageView.center = alert.view.center
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    /** get the current location of the user
     */
    @IBAction func showHere(sender: AnyObject) {
        map.userTrackingMode = .Follow
       
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier {
        case "legendSegue"?:
            let popoverViewController = segue.destinationViewController as! UIViewController
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
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    @IBAction func showOptionsMenu(sender: UIBarButtonItem) {
        
    }
    
    @IBAction func returnToMapMode(sender: UIBarButtonItem) {
        onShowMapMode()
        
        print("back button clicked")
        for i in 0..<self.routingLines.count {
            self.map.removeAnnotation(self.routingLines[i])
        }
        
        print("set map to destination location")
        self.map.setCenterCoordinate(self.endCoordinates, zoomLevel:15, animated: true)
        self.routingLines.removeAll()
        reverseTextFieldHideAndShow()
    }
    
    @IBAction func enterRoutingMode(sender: UIButton) {
        onShowRoutingMode()
    }
    
    func onShowMapMode() {
        self.navigationItem.title = "Map"
        hideAndDisableBackButton()
    }

    func hideAndDisableBackButton (){
        self.navigationItem.leftBarButtonItem?.enabled = false
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.clearColor()
    }
    
    func showAndEnableBackButton(){
        self.navigationItem.leftBarButtonItem?.enabled = true
        self.navigationItem.leftBarButtonItem?.tintColor = nil
    }
    func onShowRoutingMode() {
        var nav = self.navigationController?.navigationBar
        nav?.topItem!.title = "Routing"
        showAndEnableBackButton()
    }
    
    override func viewDidAppear(animated: Bool) {
        onShowMapMode()
    }
    

    /** reverse the text field to shown up on the map
     */
    func reverseTextFieldHideAndShow() {
        
        inputAddressTextField.hidden = !inputAddressTextField.hidden
        startAddressTextField.hidden = !startAddressTextField.hidden
        endAddressTextField.hidden = !endAddressTextField.hidden
        fromLabel.hidden = !fromLabel.hidden
        toLabel.hidden = !toLabel.hidden
        route.hidden = !route.hidden
    }
    
    /** draw the start and end markers of the routes
     * @param: startCoordinnates: start coordinates, endCoordinates: end coordinates
     */
    func drawStartEndMarker(startCoordinnates: CLLocationCoordinate2D, endCoordinates:CLLocationCoordinate2D) {
        print("draw start and end markers")
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

        //let sidewalkData = NSData(contentsOfFile: apiPath!)
        let routingData = NSData(contentsOfURL: nsURL!)
        
        //show alert when handdle there's no route
        if(routingData == nil) {
            print("error: can't get routing data")
            let alertView = UIAlertView(title: "No Route",
                message: "No accessible route from start to end location.",
                delegate: nil,
                cancelButtonTitle: "Ok")
            alertView.show()
            return;
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
                                            numFeatures++
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
                                        numFeatures++
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
    

    
    func drawBusStops() {
        print("Called drawBusStops")

        if !showBusStops {
            return
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // Get the path for example.geojson in the app's bundle
            let OBA_KEY = "88c668dd-1d01-42a1-a600-0caa8029df65"
            let bounds = self.map.visibleCoordinateBounds
            let center = self.map.centerCoordinate
            
            let obaURL = "http://api.pugetsound.onebusaway.org/api/where/stops-for-location.json?key=" + OBA_KEY + "&lat=" + String(center.latitude) + "&lon=" + String(center.longitude) + "&latSpan=" + String(abs(bounds.ne.latitude - bounds.sw.latitude)) + "&lonSpan=" + String(abs(bounds.ne.longitude - bounds.sw.longitude))
            print("apiURL = " + obaURL)

            let nsURL = NSURL(string: obaURL)
            let obaData = NSData(contentsOfURL: nsURL!)
            //print("obaData = " + String(obaData))
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
                                numFeatures++

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
    
    func drawElevationData() {
        print("Called drawElevationData")
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

            //let jsonPath = NSBundle.mainBundle().pathForResource("example", ofType: "geojson")
            //let jsonData = NSData(contentsOfFile: jsonPath!)
            
            // url for data with Washington state as bounding box http://accessmap-api.azurewebsites.net/v2/sidewalks.geojson?bbox=-124.785717,45.548599,-116.915580,49.002431
            let bounds = self.map.visibleCoordinateBounds
            let apiURL = "http://accessmap-api.azurewebsites.net/v2/sidewalks.geojson?bbox=" + String(bounds.sw.longitude) + "," + String(bounds.sw.latitude) + "," + String(bounds.ne.longitude) + "," + String(bounds.ne.latitude)
            print("apiURL = " + apiURL)
            //let nsURL = NSURL(string: "-122.32893347740172%2C47.60685023396842%2C-122.32033967971802%2C47.61254994698394")
            let nsURL = NSURL(string: apiURL)
            //let apiPath = NSBundle.mainBundle().pathForResource("sidewalks", ofType: "json")
            
            //let sidewalkData = NSData(contentsOfFile: apiPath!)
            let sidewalkData = NSData(contentsOfURL: nsURL!)
            if(sidewalkData == nil) {
                print("error: can't get side walk data")
                return;
            }
            // Gradations (drawn from https://github.com/AccessMap/AccessMap-webapp/blob/master/static/js/elevation.js)
            let high = 0.0833
            let mid = 0.05

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
                                        numFeatures++
                                        let line = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
                                        
                                        // Optionally set the title of the polyline, which can be used for:
                                        //  - Callout view
                                        //  - Object identification
                                        line.title = "Crema to Council Crest"
                                        if let properties = feature["properties"] as? NSDictionary {
                                            let grade = properties["grade"] as? Double
                                            if grade >= high {
                                                line.subtitle = "high"
                                            } else {
                                                if grade > mid {
                                                    line.subtitle = "mid"
                                                } else {
                                                    line.subtitle = "low"
                                                }
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
    

    
    func showLabel() {
        let button = UIButton(type: UIButtonType.DetailDisclosure) as UIButton
        button.setTitle("Legend", forState: .Normal)
        button.backgroundColor = UIColor.whiteColor()
        
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.blueColor().CGColor
        
        button.frame = CGRectMake(0, 620, 100, 50);
        button.addTarget(self, action: "showLegend:", forControlEvents: UIControlEvents.TouchUpInside)
        //button.setTitle(_, title: "Click me!", forState: UIControlState.Normal)
        self.view.addSubview(button)
    }
    
    func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController) {
        print("Preparing for popover presentation!")
    }
    
    
    func startReport(sender: UITapGestureRecognizer) {
        if !inReportMode {
            return
        }
        reportInstructionLabel.hidden = true
        print("Entered startReport()")
        if sender.state == .Ended {
            var location1 = sender.locationInView(map)
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
            
            //self.presentViewController(reportPopupController, animated: true, completion: nil)
            
            
            inReportMode = false
        }
    }
    
    
    
    func clearAnnotations() {
        clearElevationLines()
        clearCurbRamps()
        clearBusStops()
    }
    
    func clearElevationLines() {
        for i in 0..<self.elevationLines.count {
            self.map.removeAnnotation(self.elevationLines[i])
        }
        
        self.elevationLines.removeAll()
    }
    
    func clearCurbRamps() {
        for i in 0..<self.curbLines.count {
            self.map.removeAnnotation(self.curbLines[i])
        }
        
        self.curbLines.removeAll()
    }
    
    func clearBusStops() {
        for i in 0..<self.busStops.count {
            self.map.removeAnnotation(self.busStops[i])
        }
        
        self.busStops.removeAll()
    }
    
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
                // Prevent bus stop icons from cluttering up map; make bus stop icon smaller?
                drawBusStops()
            }
            //map.styleURL = MGLStyle.streetsStyleURL()
        } else {
            //map.styleURL = elevationTileStyleURL
        }
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
   
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        print("Getting image for annotation!")
        if (annotation.title! == "busstop") {
            var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("busStop")
        
            if annotationImage == nil {
                // bus stop image
                var image = UIImage(named: "busstop5.png")!
                //image = image.imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, image.size.height/2, 0))
                annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "busStop")
            }

            return annotationImage
        } else {
            return nil
        }
    
    }
    

    func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        // Set line width for polyline annotations
        if(annotation.title == "curbcut" && annotation is MGLPolyline) {
            return 4;
        }
        
        if(annotation.title == "route" && annotation is MGLPolyline) {
            return 4;
        }

        return 3.0
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
        
        if (annotation.title == "Crema to Council Crest" && annotation is MGLPolyline) {
            if (annotation.subtitle == "high") {
                return UIColor.redColor()
            } else {
                if (annotation.subtitle == "mid") {
                    return UIColor.yellowColor()
                } else {
                    return UIColor.greenColor()
                }
            }
                // Mapbox cyan
            //return UIColor(red: 59/255, green: 178/255, blue: 208/255, alpha:1)
        } else {
            return UIColor.purpleColor()
        }
    }
    
    func mapView(mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return UIColor.purpleColor()
    }


}

