//
//  ManagerData.swift
//  Weather
//
//  Created by Den on 01.03.17.
//  Copyright © 2017 Den. All rights reserved.
//

//import Foundation/
//import Alamofire
//import SwiftyJSON
//import RealmSwift


//import UserNotifications

//import Firebase
//import FirebaseCore


import Alamofire
import AEXML


class PodCast {
    var title = ""
    var subtitle = ""
    var description = ""
    var cover = ""
    var episodes: [Dictionary<String,String>] = []
}

let concurrentQueue = DispatchQueue(label: "concurrent_queue", attributes: .concurrent)



private let _sharedManager = ManagerData()

class ManagerData {
    

    class var sharedManager: ManagerData {
        return _sharedManager
    }
    
    
    
    
    //var podcast = PodCast()
    
    
    fileprivate var _podcast = PodCast()
    //thread security array
    var podcast: PodCast {
        
        var podcastDataCopy = PodCast()
        concurrentQueue.sync {
            podcastDataCopy = self._podcast
        }
        return podcastDataCopy
    }
    
    
    
    func getRSS()  {
        
        let url = "http://feeds.rucast.net/radio-t"
        
        Alamofire.request(url).responseData(queue: DispatchQueue.global(qos: .utility)) { [unowned self] response in
            switch response.result {
            case .success(let value):
                
                var options = AEXMLOptions()
                options.parserSettings.shouldProcessNamespaces = false
                options.parserSettings.shouldReportNamespacePrefixes = false
                options.parserSettings.shouldResolveExternalEntities = false
                let xmlDoc = try! AEXMLDocument(xml: value, options: options)
                
              // print(xmlDoc.xml)
                // prints the same XML structure as original
                print("ttttt=",xmlDoc.root["channel"]["itunes:subtitle"].value)
                
                
                if let title = xmlDoc.root["channel"]["title"].value {
                    self.podcast.title = title
                }
                
                if let subtitle = xmlDoc.root["channel"]["itunes:subtitle"].value {
                    self.podcast.subtitle = subtitle
                }
                
                if let description = xmlDoc.root["channel"]["description"].value {
                    self.podcast.description = description
                }
                
                
                if let items = xmlDoc.root["channel"]["item"].all {
        
                    for item in items {
                        var tempEp =  [String:String]()
                        
                       // print(item["title"].value)
                        
                        tempEp.updateValue(item["title"].value!, forKey: "ep_title")
                        tempEp.updateValue(item["description"].value!, forKey: "ep_description")
                        tempEp.updateValue(item["link"].value!, forKey: "ep_link")
                        tempEp.updateValue(item["pubDate"].value!, forKey: "ep_pubDate")
                        tempEp.updateValue(item["itunes:image"].attributes["href"]!, forKey: "ep_image")
                        tempEp.updateValue(item["pubDate"].value!, forKey: "ep_pubDate")
                        tempEp.updateValue(item["enclosure"].attributes["url"]!, forKey: "ep_mp3_url")
                        tempEp.updateValue(item["enclosure"].attributes["length"]!, forKey: "ep_second_length")
                        tempEp.updateValue(item["media:content"].attributes["fileSize"]!, forKey: "ep_mp3_fileSize")
                        
                        self.podcast.episodes.append(tempEp)
                    }
                }
                
                NotificationCenter.default.post(name: Notification.Name("get_rss"), object: nil)
                
                
                
            case .failure(let error):
                
                print("Netwirc error:", error)
            }
        }
 
       
        
    }
    
    
    
    
    
    
}
