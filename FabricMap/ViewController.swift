//
//  ViewController.swift
//  FabricMap
//
//  Created by Xiaobo Wang on 1/27/16.
//  Copyright © 2016 Xiaobo Wang. All rights reserved.
//

import UIKit
import Mapbox


class ViewController: UIViewController, MGLMapViewDelegate {
    
    var map: MGLMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        map = MGLMapView(frame: view.bounds)
        
        // seattle 47.6062 -122.332
        
        // new york latitude 40.712791, -73.997848
        map.setCenterCoordinate(CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.332),
            zoomLevel: 12,
            animated: false)
        view.addSubview(map)
        map.delegate = self
        map.addGestureRecognizer(UILongPressGestureRecognizer(target: self,
            action: "changeStyle:"))
        
        UIAlertView(title: "Change Map Styles",
            message: "Press and hold anywhere on the map to change its style. And make your own styles with Mapbox Studio!",
            delegate: nil,
            cancelButtonTitle: "Got it!").show()
        drawPolyline()


    }
    
    func drawPolyline() {
        
        // Parsing GeoJSON can be CPU intensive, do it on a background thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // Get the path for example.geojson in the app's bundle
            let jsonPath = NSBundle.mainBundle().pathForResource("example", ofType: "geojson")
            let jsonData = NSData(contentsOfFile: jsonPath!)
            
            //let apiURL = NSURL(string: "http://dssg-db.cloudapp.net/api/data/v1/sidewalks.geojson?bbox=-122.32893347740172%2C47.60685023396842%2C-122.32033967971802%2C47.61254994698394")
            
            let apiPath = NSBundle.mainBundle().pathForResource("sidewalks", ofType: "json")
            
            let sidewalkData = NSData(contentsOfFile: apiPath!)
            //let sidewalkData = NSData(contentsOfURL: apiURL!)
            //print(sidewalkData)
            
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
    
        
        // make a polygon there.
        var points = [
            CLLocationCoordinate2D(latitude: 40.729437724412420, longitude: -74.00527954101562),
            CLLocationCoordinate2D(latitude: 40.718249486603604, longitude: -74.00725364685059),
            CLLocationCoordinate2D(latitude: 40.720656417464404, longitude: -74.00545120239258),
            CLLocationCoordinate2D(latitude: 40.718379593199494, longitude: -74.00519371032715),
            CLLocationCoordinate2D(latitude: 40.717273679029205, longitude: -74.00639533996582),
            CLLocationCoordinate2D(latitude: 40.713435363794270, longitude: -73.99841308593750),
            CLLocationCoordinate2D(latitude: 40.714150998671556, longitude: -73.99755477905273),
            CLLocationCoordinate2D(latitude: 40.716037635568070, longitude: -73.99643898010254),
            CLLocationCoordinate2D(latitude: 40.728201906826750, longitude: -73.99137496948242),
            CLLocationCoordinate2D(latitude: 40.743810548166270, longitude: -73.97961616516113),
            CLLocationCoordinate2D(latitude: 40.746671735171680, longitude: -73.98613929748535),
            CLLocationCoordinate2D(latitude: 40.735941649217736, longitude: -73.99377822875977),
            CLLocationCoordinate2D(latitude: 40.738673108048920, longitude: -73.99970054626465),
            CLLocationCoordinate2D(latitude: 40.729437724412420, longitude: -74.00527954101562)
        ]
        let polygon = MGLPolygon(coordinates: &points, count: UInt(points.count))
        map.addOverlay(polygon)
        
        
        
        
        // make marker
        //show several markers in the map;
        for i in 0...4 {
      
            print(i)
            
            let marker = MGLPointAnnotation()
            
            marker.coordinate = map.centerCoordinate
            
            print("1111111111!!1111111111")
            print(map.centerCoordinate)
            marker.coordinate = CLLocationCoordinate2D(latitude: 47.6064 - Double(i)/100, longitude: -122.333 - Double(i)/100)
            
            marker.title = "hello seattle"
            marker.subtitle = "It's pretty great"
            map.addAnnotation(marker)
            map.selectAnnotation(marker, animated: true)
        

        }
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
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }

    func mapView(mapView: MGLMapView, lineWidthForPolylineAnnotation annotation: MGLPolyline) -> CGFloat {
        print("zoomlevel = " + String(mapView.zoomLevel))
        // Set line width for polyline annotations
        if (mapView.zoomLevel < 12) {
            return 1.0
        }
        return 2.0
    }
    
    func mapView(mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return 0.5
    }
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
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

