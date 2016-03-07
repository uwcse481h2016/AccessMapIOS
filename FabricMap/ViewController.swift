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
class ViewController: UIViewController, UISearchBarDelegate, MGLMapViewDelegate, UITextFieldDelegate, UIPopoverPresentationControllerDelegate {
    
    var manager:CLLocationManager!
    
    // Mark: properties
    @IBOutlet weak var HereButton: UIButton!
//    var map: MGLMapView!

    // store the map object
//    var mapView: MGLMapView!
    
    // store whether it is the first time to open the appliaciton
    var firstTime = true;
    
    var currentCoordinates: CLLocationCoordinate2D!
    
    var endCoordinates : CLLocationCoordinate2D!
    
    // store the elevations lines drawed on the screen
    var elevationLines = [MGLPolyline]()
    
    // store the curb lines drawed on the screen
    var curbLines = [MGLPolyline]()
    
    // store the start and end markers drawed on the screen
    var startEndMarkers = [MGLPointAnnotation]()
    
    // store the routing lines drawed on the screen
    var routingLines = [MGLPolyline]()
    
//    var start : UITextField!
//    var end : UITextField!
    
//    var here : UIButton!
//    var route : UIButton!
    
    var isShowInputField = false;
    
    
    @IBOutlet var map: MGLMapView!
    
    @IBOutlet weak var legend: UIButton!
    
    @IBOutlet weak var here: UIButton!
    
    @IBOutlet weak var route: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var inputAddressTextField: UITextField!
    
    @IBOutlet weak var startAddressTextField: UITextField!
    
    @IBOutlet weak var endAddressTextField: UITextField!
    
    @IBOutlet weak var fromLabel: UILabel!
    
    @IBOutlet weak var toLabel: UILabel!
    
    @IBOutlet weak var wheelChairButton: UIButton!
    
    @IBOutlet weak var powerWheelChairButton: UIButton!
    
    @IBOutlet weak var pedestrianButton: UIButton!
    
    
    // MARK: UITextFieldDelegate

    // MARK: Actions
    
  
    @IBAction func routeButtonAction(sender: AnyObject) {
        print("routeCalled")
        reverseChoiceButtonHidden()
    }
    
    
    func reverseChoiceButtonHidden() {
        wheelChairButton.hidden = !wheelChairButton.hidden
        powerWheelChairButton.hidden = !powerWheelChairButton.hidden
        pedestrianButton.hidden = !pedestrianButton.hidden
    }
    
    func routeByAddress() {
        reverseTextFieldHideAndShow()
        map.userTrackingMode = .Follow
        startAddressTextField.text = "current location"
        endAddressTextField.text = inputAddressTextField.text
        var locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Authorized){
                
                var currentLocation = locManager.location
                print("current location")
                print(currentLocation!.coordinate.longitude)
                print(currentLocation!.coordinate.latitude)
                self.currentCoordinates = currentLocation!.coordinate
                
                let center = CLLocationCoordinate2DMake((currentLocation!.coordinate.latitude + endCoordinates.latitude) / 2, (currentLocation!.coordinate.longitude + self.endCoordinates.longitude) / 2)
                let verticalDifference = 180 / (currentLocation!.coordinate.latitude - self.endCoordinates.latitude)
                
                let horizontalDifference = 360 / (currentLocation!.coordinate.longitude - endCoordinates.longitude)
                let maxC = min(abs(verticalDifference), abs(horizontalDifference))
                //
                //                        // get the zoom level
                print(log(maxC))
                //                        // set the map position
                self.map.setCenterCoordinate(center, zoomLevel: log(maxC) + 3, animated: true)
                
                self.drawRouting(currentLocation!.coordinate, endCoordinates: self.endCoordinates)
        }
    }
    
    @IBAction func powerWheelChairButtonAction(sender: AnyObject) {
        print("powerWheelChairButton called")
        reverseChoiceButtonHidden()
        routeByAddress()
    }

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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        if(!inputAddressTextField.hidden) {
            print("text should return got called")
            let endAddress = inputAddressTextField.text
            let geocoder = CLGeocoder()
            // get the coordinates of the input address
            geocoder.geocodeAddressString(endAddress!, completionHandler: {(placemarks, error) -> Void in
                if((error) != nil){
                    print("Error", error)
                }
                
                if let placemark = placemarks?.first {
                    self.endCoordinates = placemark.location!.coordinate
                    print(self.endCoordinates)
                    print("draw start and end markers")
                    for i in 0..<self.startEndMarkers.count {
                        self.map.removeAnnotation(self.startEndMarkers[i])
                    }
                    var endMarkers = self.drawMarker(self.endCoordinates, title: "start")
                    self.startEndMarkers.append(endMarkers);
                    self.map.setCenterCoordinate(self.endCoordinates, zoomLevel:15, animated: true)
                }
            })
        } else {
            let startAddress = startAddressTextField.text
            let endAddress = endAddressTextField.text
            let geocoder = CLGeocoder()
            var startCoordinates:CLLocationCoordinate2D!
            if(startAddress == "current location") {
                startCoordinates = self.currentCoordinates
            }
            
            // get the coordinates of the input address
            geocoder.geocodeAddressString(startAddress!, completionHandler: {(placemarks, error) -> Void in
                if((error) != nil){
                    print("Error", error)
                }
                
                if let placemark = placemarks?.first {
                    print("commint in")
                    startCoordinates = placemark.location!.coordinate
                }
                
                if(startCoordinates != nil) {
                    geocoder.geocodeAddressString(endAddress!, completionHandler: {(placemarks, error) -> Void in
                        if((error) != nil){
                            print("Error", error)
                        }
                        if let placemark = placemarks?.first {
                            let endCoordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                            
                            let center = CLLocationCoordinate2DMake((startCoordinates.latitude + endCoordinates.latitude) / 2,
                                (startCoordinates.longitude + endCoordinates.longitude) / 2)
                            let verticalDifference = 180 / (startCoordinates.latitude - endCoordinates.latitude)
                            
                            let horizontalDifference = 360 / (startCoordinates.longitude - endCoordinates.longitude)
                            
                            let maxC = min(abs(verticalDifference), abs(horizontalDifference))
                            
                            // get the zoom level
                            print(log(maxC))
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
        
        let image = UIImage(named: "map_legend.gif")!
        
        var imageView = UIImageView(frame: CGRectMake(80, 0, 200, 180))
        imageView.image = image
        
        let alert = UIAlertController(title: "Legend", message: "\n\n\n\n\n\n\n\n", preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "Exit", style: UIAlertActionStyle.Cancel, handler: {(alertAction: UIAlertAction!) in alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        alert.view.addSubview(imageView)
        //imageView.center = alert.view.center
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    
    
    @IBAction func showHere(sender: AnyObject) {
        print("call show Here")
        map.userTrackingMode = .Follow
       
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        map = MGLMapView(frame: view.bounds)
//        
//        // seattle 47.6062 -122.332
//        
//        map.setCenterCoordinate(CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.332),
//            zoomLevel: 16,
//            animated: false)
//        view.addSubview(map)
//        map.delegate = self
//        
//        
        // hold to show change the map style
//        map.addGestureRecognizer(UILongPressGestureRecognizer(target: self,
//            action: "changeStyle:"))
//
//        // show the label
//        showLabel()
//
//        drawInputField();
        inputAddressTextField.delegate = self
        startAddressTextField.delegate = self
        endAddressTextField.delegate = self
        
        startAddressTextField.hidden = true;
        endAddressTextField.hidden = true;
        
        backButton.hidden = true;
        fromLabel.hidden = true;
        toLabel.hidden = true;
        
        wheelChairButton.hidden = true;
        powerWheelChairButton.hidden = true;
        pedestrianButton.hidden = true;
    }
    
    
    func reverseTextFieldHideAndShow() {
        
        inputAddressTextField.hidden = !inputAddressTextField.hidden
        startAddressTextField.hidden = !startAddressTextField.hidden
        endAddressTextField.hidden = !endAddressTextField.hidden
        fromLabel.hidden = !fromLabel.hidden
        toLabel.hidden = !toLabel.hidden
        backButton.hidden = !backButton.hidden
        route.hidden = !route.hidden
        
    }
    
//    
//    
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        // Hide the keyboard.
//        textField.resignFirstResponder()
//        return true
//    }
//
    
//    func drawInputField() {
////        start = drawTextField(30, y:22, width:300, height:40)
////        end = drawTextField(30, y:65, width:300, height:40)
//        route = drawButton(275, y: 620, width: 100, height: 50, title: "route", actionSelector : "routeAction:")
//        here = drawButton(140, y: 620, width: 100, height: 50, title: "here", actionSelector : "locationAction:")
//        
//        route.hidden = true
//        here.hidden = true
//        
//        // tap to show the input filed
//        map.addGestureRecognizer(UITapGestureRecognizer(target: self,
//            action: "hideAndShow:"))
//        drawTop()
//
//    }
//
//    
//    func hideAndShow(tap: UITapGestureRecognizer) {
//        route.hidden = !route.hidden
//        here.hidden = !here.hidden
//    }
//    
//    
//    // draw the top bar on the app
//    @IBOutlet weak var abc: UIButton!
//    
//    
//    func drawTop() {
//        
//        
//        
//        let button   = UIButton(type: UIButtonType.System) as UIButton
//        button.frame = CGRectMake(0, 0, 400, 20)
//        button.backgroundColor = UIColor.whiteColor()
//        self.view.addSubview(button)
//    }
//    
//
//    
//    // draw the start route button base on the position and size
//    func drawButton(x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat, title:String, actionSelector:Selector)->UIButton {
//        let button   = UIButton(type: UIButtonType.System) as UIButton
//        button.frame = CGRectMake(x, y, width, height)
//        button.layer.cornerRadius = 5
//        button.layer.borderWidth = 1
//        button.layer.borderColor = UIColor.blueColor().CGColor
//        
//        button.backgroundColor = UIColor.whiteColor()
//        button.setTitle(title, forState: UIControlState.Normal)
//        
//        button.addTarget(self, action: actionSelector, forControlEvents: UIControlEvents.TouchUpInside)
//        
//        
////        button.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
//        self.view.addSubview(button)
//        return button
//    }
//    
//    @IBAction func testCarButton(sender: AnyObject) {
//        
////        alert("abcd")
//
//
//    }
//
//
////    // let the map get the user's current location
////    func locationAction(sender:UIButton!) {
////        
////        map.userTrackingMode = .Follow
////    }
//
//    
//    
//    // draw the textField based on the position and size
//    func drawTextField(x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat) -> UITextField {
//        let sampleTextField = UITextField(frame: CGRectMake(x, y, width, height))
//        sampleTextField.placeholder = "enter address"
//        sampleTextField.font = UIFont.systemFontOfSize(15)
//        sampleTextField.borderStyle = UITextBorderStyle.RoundedRect
//        sampleTextField.autocorrectionType = UITextAutocorrectionType.No
//        sampleTextField.keyboardType = UIKeyboardType.Default
//        sampleTextField.returnKeyType = UIReturnKeyType.Done
//        sampleTextField.clearButtonMode = UITextFieldViewMode.WhileEditing;
//        sampleTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
//        sampleTextField.delegate = self
//        sampleTextField.resignFirstResponder()
//        self.view.addSubview(sampleTextField)
//        return sampleTextField
//        
//    }
//    
//    // MARK: UITextFieldDelegate
//
//
//    // listenr when editing the text
//    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
//        print("TextField should begin editing method called")
//        return true;
//    }
//    
//    // listener when the textFiled is clear
//    func textFieldShouldClear(textField: UITextField) -> Bool {
//        print("TextField should clear method called")
//
//
//        return true;
//    }
//    
//    
//
//    
//
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        print("TextField should return method called")
//        
//        textField.resignFirstResponder()
//
//        return true;
//    }
//    
//    // listener when button pressed start the route
//    func routeAction(sender:UIButton!) {
//        // make keyboards disappear;
////        start.resignFirstResponder()
////        end.resignFirstResponder()
////        
//        let startAddress = ""
//        let endAddress = ""
//        
//        let geocoder = CLGeocoder()
//        
//        // get the coordinates of the input address
//        geocoder.geocodeAddressString(startAddress, completionHandler: {(placemarks, error) -> Void in
//            if((error) != nil){
//                print("Error", error)
//            }
//            
//            if let placemark = placemarks?.first {
//                let startCoordinates:CLLocationCoordinate2D = placemark.location!.coordinate
//                
//                
//                geocoder.geocodeAddressString(endAddress, completionHandler: {(placemarks, error) -> Void in
//                    if((error) != nil){
//                        print("Error", error)
//                    }
//                    
//                    
//                    if let placemark = placemarks?.first {
//                        let endCoordinates:CLLocationCoordinate2D = placemark.location!.coordinate
//
//                        let center = CLLocationCoordinate2DMake((startCoordinates.latitude + endCoordinates.latitude) / 2,
//                                                                (startCoordinates.longitude + endCoordinates.longitude) / 2)
//                        let verticalDifference = 180 / (startCoordinates.latitude - endCoordinates.latitude)
//                        
//                        let horizontalDifference = 360 / (startCoordinates.longitude - endCoordinates.longitude)
//                        
//                        let maxC = min(abs(verticalDifference), abs(horizontalDifference))
//                        
//                        // get the zoom level
//                        print(log(maxC))
//                        // set the map position
//                        self.map.setCenterCoordinate(center, zoomLevel: log(maxC) + 3, animated: true)
//                        
//                        // draw makers
//                        self.drawStartEndMarker(startCoordinates, endCoordinates: endCoordinates)
//                        
//                        // draw routing
//                        self.drawRouting(startCoordinates, endCoordinates: endCoordinates)
//                        
//                    }
//                })
//            }
//        })
//    }
//    
//    
//    
    //placing marker at the start point and end point to start route
    func drawStartEndMarker(startCoordinnates: CLLocationCoordinate2D, endCoordinates:CLLocationCoordinate2D) {
        print("draw start and end markers")
                for i in 0..<self.startEndMarkers.count {
            map.removeAnnotation(self.startEndMarkers[i])
        }
    
        let start = drawMarker(startCoordinnates, title: "start")
        let end = drawMarker(endCoordinates, title: "end")
        self.startEndMarkers.append(start);
        self.startEndMarkers.append(end);
        
        
    }
//
//    
    // draw one markers on the map
    func drawMarker(coordinate: CLLocationCoordinate2D, title: String) -> MGLPointAnnotation{
        let marker = MGLPointAnnotation()
        marker.coordinate = coordinate
        marker.title = title
        marker.subtitle = title
        map.addAnnotation(marker)
        map.selectAnnotation(marker, animated: true)
        return marker
        
    }
//
//    
//    
    // draw the routing between the start and end point
    func drawRouting (startCoordingnates: CLLocationCoordinate2D, endCoordinates:CLLocationCoordinate2D) {
        print("call draw routing")
        print(startCoordingnates)
        print(endCoordinates)
  
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            let apiURL = "http://dssg-db.cloudapp.net/api/routing/route.json?waypoints=[" + String(startCoordingnates.latitude) + ",%20" + String(startCoordingnates.longitude) + ",%20" + String(endCoordinates.latitude) + ",%20" + String(endCoordinates.longitude) + "]"
            
            let nsURL = NSURL(string: apiURL)
            
            print("nsURL")
            print(nsURL)
            //let sidewalkData = NSData(contentsOfFile: apiPath!)
            let routingData = NSData(contentsOfURL: nsURL!)
            
            if(routingData == nil) {
                print("error: can't get routing data")
                return;
            }
            
            
            for i in 0..<self.routingLines.count {
                self.map.removeAnnotation(self.routingLines[i])
            }
            
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
                    
                    print("Number of features = " + String(numFeatures))
                }
            }
            catch
            {
                print("GeoJSON parsing failed")
            }
        })
    }
    
    

    
    
    
    func drawCurbramps(zoomLevel: Double) {
        
        print("Called drawCrossings")
        
        print("count")
        print(self.curbLines.count)
        for i in 0..<self.curbLines.count {
            print("length" + String(self.curbLines.count))
            print("index" + String(i))
            
            self.map.removeAnnotation(self.curbLines[i])
        }
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {


            let bounds = self.map.visibleCoordinateBounds

            let apiURL = "http://accessmap-api.azurewebsites.net/v1/curbramps.geojson?bbox=" + String(bounds.sw.longitude) + "," + String(bounds.sw.latitude) + "," + String(bounds.ne.longitude) + "," + String(bounds.ne.latitude)
            let nsURL = NSURL(string: apiURL)

            let curbrampsData = NSData(contentsOfURL: nsURL!)
            
            if(curbrampsData == nil) {
                print("can't get cubramps data ")
                return;
            }
        
            
            self.curbLines.removeAll()

            do {
                // Load and serialize the GeoJSON into a dictionary filled with properly-typed objects
                if let jsonDict = try NSJSONSerialization.JSONObjectWithData(curbrampsData!, options: []) as? NSDictionary {
                    var numFeatures = 0
                    // Load the `features` array for iteration
                    if let features = jsonDict["features"] as? NSArray {
                        for feature in features {
                            if let feature = feature as? NSDictionary {
                                if let geometry = feature["geometry"] as? NSDictionary {
                                    if geometry["type"] as? String == "Point" {
                                        // Create an array to hold the formatted coordinates for our line
                                        var coordinates: [CLLocationCoordinate2D] = []
                                        
                                        if let location = geometry["coordinates"] as? NSArray {
                                            // Iterate over line coordinates, stored in GeoJSON as many lng, lat arrays
                                            // Make a CLLocationCoordinate2D with the lat, lng
                                            let coordinate = CLLocationCoordinate2DMake(location[1].doubleValue, location[0].doubleValue)

                                            coordinates.append(coordinate)

                                            let coordinate2 = CLLocationCoordinate2DMake(location[1].doubleValue + 0.00001 , location[0].doubleValue + 0.00001)
                                            coordinates.append(coordinate2)
                                            

                                            let line = MGLPolyline(coordinates: &coordinates, count: UInt(coordinates.count))
                                            
                                            line.title = "curbcut"

                                            line.subtitle = "curbcut"
                                            numFeatures++
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
    
    
    // draw the elevation liness
    func drawPolyline() {
        print("Called drawPolyline")
        // Parsing GeoJSON can be CPU intensive, do it on a background thread
        
        
        
        for i in 0..<self.elevationLines.count {
            self.map.removeAnnotation(self.elevationLines[i])
        }
        
        self.elevationLines.removeAll()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // Get the path for example.geojson in the app's bundle

            //let jsonPath = NSBundle.mainBundle().pathForResource("example", ofType: "geojson")
            //let jsonData = NSData(contentsOfFile: jsonPath!)
            
            
            let bounds = self.map.visibleCoordinateBounds
            let apiURL = "http://accessmap-api.azurewebsites.net/v2/sidewalks.geojson?bbox=" + String(bounds.sw.longitude) + "," + String(bounds.sw.latitude) + "," + String(bounds.ne.longitude) + "," + String(bounds.ne.latitude)
            print("apiURL = " + apiURL)
            //let nsURL = NSURL(string: "-122.32893347740172%2C47.60685023396842%2C-122.32033967971802%2C47.61254994698394")
            let nsURL = NSURL(string: apiURL)
            //let apiPath = NSBundle.mainBundle().pathForResource("sidewalks", ofType: "json")
            
            //let sidewalkData = NSData(contentsOfFile: apiPath!)
            let sidewalkData = NSData(contentsOfURL: nsURL!)

            if(sidewalkData == nil) {
                print("erro: can't get side walk data")
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
    
    
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    func showLabel() {
        /**let label = UILabel(frame: CGRectMake(0, 0, 200, 21))
        label.center = CGPointMake(160, 284)
        label.textAlignment = NSTextAlignment.Center
        label.text = "I'am a test label"
        self.view.addSubview(label)
        */
        
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
    
//    func showLegend(sender: UIButton) {
//        /**var alertView = UIAlertView(title: "showing legend",
//            message: "start route!",
//            delegate: nil,
//            cancelButtonTitle: "Got it!")
//        
//        var imageView = UIImageView(frame: CGRectMake(10, 10, 40, 40))
//        
//        imageView.image = UIImage(named: "map_legend")
//        alertView.addSubview(imageView)
//        alertView.show()*/
//        
//        
//        let image = UIImage(named: "map_legend.gif")!
//        
//        var imageView = UIImageView(frame: CGRectMake(80, 0, 200, 180))
//        imageView.image = image
//
//        let alert = UIAlertController(title: "Legend", message: "\n\n\n\n\n\n\n\n", preferredStyle: .ActionSheet)
//        alert.addAction(UIAlertAction(title: "Exit", style: UIAlertActionStyle.Cancel, handler: {(alertAction: UIAlertAction!) in alert.dismissViewControllerAnimated(true, completion: nil)
//        }))
//        alert.view.addSubview(imageView)
//        //imageView.center = alert.view.center
//        self.presentViewController(alert, animated: true, completion: nil)
//
//        /**
//        let legendViewController = UIAlertController(title: "Legend",
//            message: "show",
//            preferredStyle: .Alert)
//        legendViewController.view.addSubview(imageView)
//        legendViewController.modalPresentationStyle = .Popover
//        legendViewController.preferredContentSize = CGSizeMake(50, 100)
//        
//        presentViewController(
//            legendViewController,
//            animated: true,
//            completion: nil)
//        
//        let popoverMenuViewController = legendViewController.popoverPresentationController
//        popoverMenuViewController?.permittedArrowDirections = .Any
//        popoverMenuViewController?.delegate = self
//        popoverMenuViewController?.sourceView = sender
//        print(sender.center.x)
//        print(sender.center.y)
//        popoverMenuViewController?.sourceRect = CGRect(
//            x: sender.center.x,
//            y: sender.center.y,
//            width: 1,
//            height: 1)
//        */
//    }
    
    func changeStyle(longPress: UILongPressGestureRecognizer) {
        if longPress.state == .Began {
            let styleURLs = [
                MGLStyle.streetsStyleURL(),
                MGLStyle.emeraldStyleURL(),
                MGLStyle.lightStyleURL(),
                MGLStyle.darkStyleURL(),
                MGLStyle.satelliteStyleURL(),
                MGLStyle.hybridStyleURL()
            ]
            var index = 0
            for styleURL in styleURLs {
                if map.styleURL == styleURL {
                    index = styleURLs.indexOf(styleURL)!
                }
            }
            if index == styleURLs.endIndex - 1 {
                index = styleURLs.startIndex
            } else {
                index = index.advancedBy(1)
            }
            map.styleURL = styleURLs[index]
        }
    }
    
    func mapView(mapView: MGLMapView, regionDidChangeAnimated animated: Bool) -> Void {
        print("Region changed")
        //self.mapView = mapView
        if( firstTime ){
//            mapView.userTrackingMode = .Follow

//            self.map.setCenterCoordinate(mapView.centerCoordinate, zoomLevel: 16, animated: true)
            firstTime = false
        }


//        let start = CLLocationCoordinate2D(latitude: 47.663461, longitude: -122.320382)
//        let end = CLLocationCoordinate2D(latitude: 47.7081095, longitude: -122.3209438)
        
//        drawRouting(start, endCoordinates: end)
        
        if(mapView.zoomLevel > 15) {
            drawPolyline()
            drawCurbramps(mapView.zoomLevel)
            print("finished")
        }
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    
    
    
//    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
//        var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("Bluedot")
//        
//        if annotationImage == nil {
//            // Leaning Tower of Pisa by Stefan Spieler from the Noun Project
//            let image = UIImage(named: "Bluedot")
//            annotationImage = MGLAnnotationImage(image: image!, reuseIdentifier: "Bluedot")
//        }
//        
//        return annotationImage
//    }
//    
//    
    
    

    func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        //print("zoomlevel = " + String(mapView.zoomLevel))
        // Set line width for polyline annotations
        
        if(annotation.title == "curbcut" && annotation is MGLPolyline) {
            return 12;
        }
        
        if(annotation.title == "route" && annotation is MGLPolyline) {
            return 4;
        }

        if (mapView.zoomLevel < 12) {
            return 1.0
        }
        return 2.0
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

