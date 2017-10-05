//
//  Client.swift
//  VirtualTourist
//
//  Created by Gustavo on 9/26/17.
//  Copyright © 2017 Carlos Lozano. All rights reserved.
//

import Foundation
import UIKit
import CoreData
class Client {
    
    private init(){}
    
    static let shared = Client()
    
    
    
    func getImageByLocation(pin:Pin, completionHandler: @escaping ([String]?)->Void){
        
        let parameters: [String: AnyObject] = [
            Client.FlickrParameterKeys.Method: Client.FlickrParameterValues.SearchMethod as AnyObject,
            Client.FlickrParameterKeys.APIKey: Client.FlickrParameterValues.APIKey as AnyObject,
            Client.FlickrParameterKeys.Extras: Client.FlickrParameterValues.MediumURL as AnyObject,
            Client.FlickrParameterKeys.Format: Client.FlickrParameterValues.ResponseFormat as AnyObject,
            Client.FlickrParameterKeys.NoJSONCallback: 1 as AnyObject,
            Client.FlickrParameterKeys.SafeSearch: 1 as AnyObject,
            Client.FlickrParameterKeys.BoundingBox : bboxString(lat: pin.latitude, long:pin.longitude) as AnyObject,
            Client.FlickrParameterKeys.Page : "\(pin.page)" as AnyObject,
            Client.FlickrParameterKeys.PerPage: "10" as AnyObject
        ]
        
        
        
        let session = URLSession.shared
        let request = URLRequest(url: prepareParameters(parameters))
        
        let task = session.dataTask(with: request){
            (data,response,error) in
            
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode>=200 && statusCode<299 else{
                print("there is an error in your request")
                return
            }
            
            if error != nil {
                completionHandler(nil)
                return
            }
            
            do {
                let responseData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: AnyObject]
                let photos = responseData?["photos"] as? [String: AnyObject]
                let photo = photos?["photo"] as? [[String:AnyObject]]
                var photosInfo:[String] = [String]()
                for photoDict in photo! {
                   photosInfo.append(photoDict["url_m"] as! String)
                }
                completionHandler(photosInfo)
            }catch{
                print( "error parsing response")
            }
            
            
            
            
        }
        task.resume()
        
        
        
    }
    
    
    
    func getPhotoData(photo:Photo, context: NSManagedObjectContext, completionHandler: @escaping()->Void){
        let url = URL(string:photo.url!)
        let request = URLRequest(url: url!)
        
        let task = URLSession.shared.dataTask(with: request){
            (data,response,error) in
            guard let httpStatus: Int = (response as! HTTPURLResponse).statusCode, httpStatus>199 && httpStatus<=299 else{
                completionHandler()
               return
            }
            DispatchQueue.main.async {
                do{
                    photo.data = data
                    try context.save()
                    completionHandler()
                }catch{
                    completionHandler()
                }
           
            }
            
        }
        task.resume()
    }
    
    
    
    
    private func prepareParameters(_ parameters: [String: AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Client.Flickr.APIScheme
        components.host = Client.Flickr.APIHost
        components.path = Client.Flickr.APIPath
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    
    
    private func bboxString(lat: Double, long: Double) -> String{
        
        
        let minLat = max(lat-Client.Flickr.SearchBBoxHalfWidth, Client.Flickr.SearchLatRange.0)
        let maxLat = min(lat+Client.Flickr.SearchBBoxHalfWidth, Client.Flickr.SearchLatRange.1)
        let minLong = max(long-Client.Flickr.SearchBBoxHalfHeight, Client.Flickr.SearchLonRange.0)
        let maxLong = min(long+Client.Flickr.SearchBBoxHalfHeight, Client.Flickr.SearchLonRange.1)
        
        return "\(minLong),\(minLat),\(maxLong),\(maxLat)"
    }
    
}
