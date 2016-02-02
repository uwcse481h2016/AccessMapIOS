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
        
        map.addGestureRecognizer(UILongPressGestureRecognizer(target: self,
            action: "changeStyle:"))
        
        UIAlertView(title: "Change Map Styles",
            message: "Press and hold anywhere on the map to change its style. And make your own styles with Mapbox Studio!",
            delegate: nil,
            cancelButtonTitle: "Got it!").show()


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

    
    func mapView(mapView: MGLMapView, alphaForShapeAnnotation annotation: MGLShape) -> CGFloat {
        return 0.5
    }
    
    func mapView(mapView: MGLMapView, strokeColorForShapeAnnotation annotation: MGLShape) -> UIColor {
        return UIColor.purpleColor()
    }
    
    func mapView(mapView: MGLMapView, fillColorForPolygonAnnotation annotation: MGLPolygon) -> UIColor {
        return UIColor.purpleColor()
    }


}

