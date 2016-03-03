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
    
    @IBOutlet weak var HereButton: UIButton!
    var map: MGLMapView!

    
    var mapView: MGLMapView!
    
    var firstTime = true;
    
    var elevationLines = [MGLPolyline]()
    
    var busStops = [MGLPointAnnotation]()
    
    var curbLines = [MGLPolyline]()
    
    var startEndMarkers = [MGLPointAnnotation]()
    
    
    var routingLines = [MGLPolyline]()
    
    var elevationTileStyleURL = NSURL(string: "mapbox-raster-v8.json")
    
    var elevationStyleURL = NSURL(string: "mapbox://styles/wangx23/cilbmjh95000u9jm1jlg1wb26")
    
    var start : UITextField!
    var end : UITextField!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        map = MGLMapView(frame: view.bounds)
        
        map.autoresizingMask = UIViewAutoresizing.init()
        map.autoresizingMask.insert(UIViewAutoresizing.FlexibleHeight)
        map.autoresizingMask.insert(UIViewAutoresizing.FlexibleWidth)
        
        print("UIViewAutoresizing.contains(FlexibleHeight) = " + String(map.autoresizingMask.contains(UIViewAutoresizing.FlexibleHeight)))
        print("UIViewAutoresizing.contains(FlexibleWidth) = " + String(map.autoresizingMask.contains(UIViewAutoresizing.FlexibleWidth)))
        // seattle 47.6062 -122.332
        
        // new york latitude 40.712791, -73.997848
        map.setCenterCoordinate(CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.332),
            zoomLevel: 16,
            animated: false)
        view.addSubview(map)
        map.delegate = self
        map.styleURL = elevationStyleURL
        //map.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: "changeStyle:"))
            
        showLabel()


        
        map.addGestureRecognizer(UITapGestureRecognizer(target: self,
            action: "showInputField:"))
    
        
//        UIAlertView(title: "Change Map Styles",
//            message: "Press and hold anywhere on the map to change its style. And make your own styles with Mapbox Studio!",
//            delegate: nil,
//            cancelButtonTitle: "Got it!").show()
        


    }
    
    
    func showInputField(tap: UITapGestureRecognizer) {
//        let label = UILabel(frame: CGRectMake(0, 0, 200, 21))
//        label.center = CGPointMake(160, 284)
//        label.textAlignment = NSTextAlignment.Center
//        label.text = "I'am a test label"
//        self.view.addSubview(label)
     
        start = drawTextField(30, y:22, width:300, height:40)
        end = drawTextField(30, y:65, width:300, height:40)
        drawButton(275, y: 620, width: 100, height: 50, title: "route", actionSelector : "routeAction:")
        drawButton(140, y: 620, width: 100, height: 50, title: "here", actionSelector : "locationAction:")

        
        drawTop()
    }
    
    
    // draw the top bar on the app
    func drawTop() {
        let button   = UIButton(type: UIButtonType.System) as UIButton
        button.frame = CGRectMake(0, 0, 400, 20)
        button.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(button)
    }
    
    
    // draw the start route button base on the position and size
    func drawButton(x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat, title:String, actionSelector:Selector)->UIButton {
        let button   = UIButton(type: UIButtonType.System) as UIButton
        button.frame = CGRectMake(x, y, width, height)
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.blueColor().CGColor
        
        
        
        button.backgroundColor = UIColor.whiteColor()
        button.setTitle(title, forState: UIControlState.Normal)
        
        button.addTarget(self, action: actionSelector, forControlEvents: UIControlEvents.TouchUpInside)
        
        
//        button.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        self.view.addSubview(button)
        return button
    }
    
    
    func locationAction(sender:UIButton!) {
        
        map.userTrackingMode = .Follow
    }

    
    
    // draw the textField based on the position and size
    func drawTextField(x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat) -> UITextField {
        let sampleTextField = UITextField(frame: CGRectMake(x, y, width, height))
        sampleTextField.placeholder = "enter address"
        sampleTextField.font = UIFont.systemFontOfSize(15)
        sampleTextField.borderStyle = UITextBorderStyle.RoundedRect
        sampleTextField.autocorrectionType = UITextAutocorrectionType.No
        sampleTextField.keyboardType = UIKeyboardType.Default
        sampleTextField.returnKeyType = UIReturnKeyType.Done
        sampleTextField.clearButtonMode = UITextFieldViewMode.WhileEditing;
        sampleTextField.contentVerticalAlignment = UIControlContentVerticalAlignment.Center
        sampleTextField.delegate = self
        sampleTextField.resignFirstResponder()
        self.view.addSubview(sampleTextField)
        return sampleTextField
        
    }
    


    //listenr when editing the text
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        print("TextField should begin editing method called")
        return true;
    }
    
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        print("TextField should clear method called")
        return true;
    }
    
    
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        print("TextField should snd editing method called")
        return true;
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("TextField should return method called")
        textField.resignFirstResponder();
        return true;
    }
    
    
    func routeAction(sender:UIButton!) {
        // make keyboards disappear;
        start.resignFirstResponder()
        end.resignFirstResponder()
        
        let startAddress = start.text!
        let endAddress = end.text!
        
        let geocoder = CLGeocoder()
        
        
        geocoder.geocodeAddressString(startAddress, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                print("Error", error)
            }
            
            
            if let placemark = placemarks?.first {
                let startCoordinates:CLLocationCoordinate2D = placemark.location!.coordinate
                
                
                geocoder.geocodeAddressString(endAddress, completionHandler: {(placemarks, error) -> Void in
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
                        
                        print(log(maxC))

                        self.map.setCenterCoordinate(center, zoomLevel: log(maxC) + 3, animated: true)
                        
                        self.drawStartEndMarker(startCoordinates, endCoordinates: endCoordinates)
                        self.drawRouting(startCoordinates, endCoordinates: endCoordinates)
                        
                    }
                })
            }
        })
    }
    
    
    
    //placing marker at the start point and end point to start route
    func drawStartEndMarker(startCoordinnates: CLLocationCoordinate2D, endCoordinates:CLLocationCoordinate2D) {
        print("draw start and end markers")
        
        for i in 0..<self.startEndMarkers.count {
            map.removeAnnotation(self.startEndMarkers[i])
            
            
        }
        
        
        var start = drawMarker(startCoordinnates, title: "start")
        var end = drawMarker(endCoordinates, title: "end")
        self.startEndMarkers.append(start);
        self.startEndMarkers.append(end);
        
        
    }
    
    
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
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {


            let bounds = self.map.visibleCoordinateBounds

            let apiURL = "http://accessmap-api.azurewebsites.net/v1/curbramps.geojson?bbox=" + String(bounds.sw.longitude) + "," + String(bounds.sw.latitude) + "," + String(bounds.ne.longitude) + "," + String(bounds.ne.latitude)
            let nsURL = NSURL(string: apiURL)

            let curbrampsData = NSData(contentsOfURL: nsURL!)
            
//            var allCurbsCordinates: [CLLocationCoordinate2D] = []
            
            
            
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
                                    if geometry["type"] as? String == "Point" {
                                        // Create an array to hold the formatted coordinates for our line
                                        var coordinates: [CLLocationCoordinate2D] = []
                                        
                                        if let location = geometry["coordinates"] as? NSArray {
                                            // Iterate over line coordinates, stored in GeoJSON as many lng, lat arrays
                                            // Make a CLLocationCoordinate2D with the lat, lng
                                            let coordinate = CLLocationCoordinate2DMake(location[1].doubleValue, location[0].doubleValue)
//                                            print("one  value")
//                                            print(location[0].doubleValue)
//                                            print("second value")
//                                            print(location[1].doubleValue)
//
                                            // Add coordinate to coordinates array
                                            coordinates.append(coordinate)
//                                            allCurbsCordinates.append(coordinate)
                                             let coordinate2 = CLLocationCoordinate2DMake(location[1].doubleValue + 0.00001 , location[0].doubleValue + 0.00001)
                                            coordinates.append(coordinate2)
                                            
                                            
                                            // Add the annotation on the main thread
//                                            dispatch_async(dispatch_get_main_queue(), {
//                                                
//                                                let marker = MGLPointAnnotation()
//                                                
////                                                print(self.map.centerCoordinate)
//                                                marker.coordinate = coordinate
//                                                
//                                                marker.title = "hello seattle"
//                                                marker.subtitle = "It's pretty great"
//                                                self.map.addAnnotation(marker)
//                                                self.map.selectAnnotation(marker, animated: true)
//
//                                            })
                                            
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
//                    allCurbsCordinates.sortInPlace($0.longitude.compare($1.longitude) == .OrderedAscending)
//                    allCurbsCordinates.sortInPlace({ (e1, e2) -> Bool in
//                        return e1.longitude < e2.longitude
//                    })
//                    print (allCurbsCordinates)
//                    let size = allCurbsCordinates.count
//                    for j in 1..<size {
//                        print(allCurbsCordinates[j].longitude)
//                        if(allCurbsCordinates[j].longitude - allCurbsCordinates[j - 1].longitude < 0.0001
//                            && allCurbsCordinates[j].latitude - allCurbsCordinates[j - 1].latitude > 0.0001) {
//                        }
//
//                    }

                }
            }
            catch
            {
                print("GeoJSON parsing failed")
            }

        })
        
    }
    
    
    
    func drawBusStops(zoomLevel: Double) {
        print("Called drawBusStops")

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

            if (zoomLevel > 14) {
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
                                    point.title = "OBA"
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
            }
        })
        
    }
    
    func drawElevationData() {
        print("Called drawElevationData")
        // Parsing GeoJSON can be CPU intensive, do it on a background thread
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
    
    
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    
//        
//        // make a polygon there.
//        var points = [
//            CLLocationCoordinate2D(latitude: 40.729437724412420, longitude: -74.00527954101562),
//            CLLocationCoordinate2D(latitude: 40.718249486603604, longitude: -74.00725364685059),
//            CLLocationCoordinate2D(latitude: 40.720656417464404, longitude: -74.00545120239258),
//            CLLocationCoordinate2D(latitude: 40.718379593199494, longitude: -74.00519371032715),
//            CLLocationCoordinate2D(latitude: 40.717273679029205, longitude: -74.00639533996582),
//            CLLocationCoordinate2D(latitude: 40.713435363794270, longitude: -73.99841308593750),
//            CLLocationCoordinate2D(latitude: 40.714150998671556, longitude: -73.99755477905273),
//            CLLocationCoordinate2D(latitude: 40.716037635568070, longitude: -73.99643898010254),
//            CLLocationCoordinate2D(latitude: 40.728201906826750, longitude: -73.99137496948242),
//            CLLocationCoordinate2D(latitude: 40.743810548166270, longitude: -73.97961616516113),
//            CLLocationCoordinate2D(latitude: 40.746671735171680, longitude: -73.98613929748535),
//            CLLocationCoordinate2D(latitude: 40.735941649217736, longitude: -73.99377822875977),
//            CLLocationCoordinate2D(latitude: 40.738673108048920, longitude: -73.99970054626465),
//            CLLocationCoordinate2D(latitude: 40.729437724412420, longitude: -74.00527954101562)
//        ]
//        let polygon = MGLPolygon(coordinates: &points, count: UInt(points.count))
//        map.addOverlay(polygon)
//        
//        
        
        // make marker
        //show several markers in the map;
//        for i in 0...4 {
//      
//            print(i)
//            
//            let marker = MGLPointAnnotation()
//            
//            marker.coordinate = map.centerCoordinate
//            
//            print("1111111111!!1111111111")
//            print(map.centerCoordinate)
//            marker.coordinate = CLLocationCoordinate2D(latitude: 47.6064 - Double(i)/100, longitude: -122.333 - Double(i)/100)
//            
//            marker.title = "hello seattle"
//            marker.subtitle = "It's pretty great"
//            map.addAnnotation(marker)
//            map.selectAnnotation(marker, animated: true)
//        
//
//        }
//        let marker = MGLPointAnnotation()
//
//        marker.coordinate = map.centerCoordinate
//        
//        print("1111111111!!1111111111")
//        print(map.centerCoordinate)
//        marker.coordinate = CLLocationCoordinate2D(latitude: 47.6063, longitude: -122.333)
//
//        marker.title = "hello seattle"
//        marker.subtitle = "It's pretty great"
//        map.addAnnotation(marker)
//        map.selectAnnotation(marker, animated: true)
//        

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
//        button.center = CGPointMake(50, 50);
        button.addTarget(self, action: "showLegend:", forControlEvents: UIControlEvents.TouchUpInside)
        //button.setTitle(_, title: "Click me!", forState: UIControlState.Normal)
        self.view.addSubview(button)
    }
    
    func prepareForPopoverPresentation(popoverPresentationController: UIPopoverPresentationController) {
        print("Preparing for popover presentation!")
    }
    
    func showLegend(sender: UIButton) {
        /**var alertView = UIAlertView(title: "showing legend",
            message: "start route!",
            delegate: nil,
            cancelButtonTitle: "Got it!")
        
        var imageView = UIImageView(frame: CGRectMake(10, 10, 40, 40))
        
        imageView.image = UIImage(named: "map_legend")
        alertView.addSubview(imageView)
        alertView.show()*/
        
        
        let image = UIImage(named: "Legend-01.png")!
        
        var imageView = UIImageView(frame: CGRectMake(25, 10, 300, 350))
        imageView.image = image

        let alert = UIAlertController(title: "Legend", message: "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n", preferredStyle: .ActionSheet)
        alert.addAction(UIAlertAction(title: "Exit", style: UIAlertActionStyle.Cancel, handler: {(alertAction: UIAlertAction!) in alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        alert.view.addSubview(imageView)
        //imageView.center = alert.view.center
        self.presentViewController(alert, animated: true, completion: nil)

        /**
        let legendViewController = UIAlertController(title: "Legend",
            message: "show",
            preferredStyle: .Alert)
        legendViewController.view.addSubview(imageView)
        legendViewController.modalPresentationStyle = .Popover
        legendViewController.preferredContentSize = CGSizeMake(50, 100)
        
        presentViewController(
            legendViewController,
            animated: true,
            completion: nil)
        
        let popoverMenuViewController = legendViewController.popoverPresentationController
        popoverMenuViewController?.permittedArrowDirections = .Any
        popoverMenuViewController?.delegate = self
        popoverMenuViewController?.sourceView = sender
        print(sender.center.x)
        print(sender.center.y)
        popoverMenuViewController?.sourceRect = CGRect(
            x: sender.center.x,
            y: sender.center.y,
            width: 1,
            height: 1)
        */
    }
    
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
        //self.mapView = mapView


        if( firstTime ){
//            mapView.userTrackingMode = .Follow

//            self.map.setCenterCoordinate(mapView.centerCoordinate, zoomLevel: 16, animated: true)
            firstTime = false
        }


//        let start = CLLocationCoordinate2D(latitude: 47.663461, longitude: -122.320382)
//        let end = CLLocationCoordinate2D(latitude: 47.7081095, longitude: -122.3209438)
        
//        drawRouting(start, endCoordinates: end)
        clearAnnotations()
        if (mapView.zoomLevel > 14) {
            drawElevationData()
            drawCurbramps(mapView.zoomLevel)
            if (mapView.zoomLevel > 15) {
                // Prevent bus stop icons from cluttering up map; make bus stop icon smaller?
                drawBusStops(mapView.zoomLevel)
            }
            //map.styleURL = MGLStyle.streetsStyleURL()
        } else {
            //map.styleURL = elevationTileStyleURL
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
   
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        print("Getting image for annotation!")
        var annotationImage = mapView.dequeueReusableAnnotationImageWithIdentifier("busStop")
    
        if annotationImage == nil {
            // Leaning Tower of Pisa by Stefan Spieler from the Noun Project
            var image = UIImage(named: "busstop5.png")!
            //image = image.imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, image.size.height/2, 0))
            annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "busStop")
            print("created new image")
        }
        print("Returning image!")
        return annotationImage
    }
    
    
    

    func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        //print("zoomlevel = " + String(mapView.zoomLevel))
        // Set line width for polyline annotations
        
        if(annotation.title == "curbcut" && annotation is MGLPolyline) {
            return 12;
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

