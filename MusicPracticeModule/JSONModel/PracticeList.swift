//
//  PracticeList.swift
//  MusicPracticeModule
//
//  Created by kingcyk on 6/1/21.
//

import Foundation
import SwiftyJSON


class PracticeList : NSObject, NSCoding{
    
    var demoVideo : DemoVideo?
    var endBar : Int!
    var hand : Int!
    var mode : Int!
    var practiceTime : Int!
    var sectionName : String!
    var sheetName : String!
    var startBar : Int!
    var type : String!
    var url : String!
    var uuid : String!
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        let demoVideoJson = json["demoVideo"]
        if !demoVideoJson.isEmpty{
            demoVideo = DemoVideo(fromJson: demoVideoJson)
        } else {
            demoVideo = nil
        }
        endBar = json["endBar"].intValue
        hand = json["hand"].intValue
        mode = json["mode"].intValue
        practiceTime = json["practiceTime"].intValue
        sectionName = json["sectionName"].stringValue
        sheetName = json["sheetName"].stringValue
        startBar = json["startBar"].intValue
        type = json["type"].stringValue
        url = json["url"].stringValue
        uuid = json["uuid"].stringValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if demoVideo != nil {
            dictionary["demoVideo"] = demoVideo!.toDictionary()
        }
        if endBar != nil{
            dictionary["endBar"] = endBar
        }
        if hand != nil{
            dictionary["hand"] = hand
        }
        if mode != nil{
            dictionary["mode"] = mode
        }
        if practiceTime != nil{
            dictionary["practiceTime"] = practiceTime
        }
        if sectionName != nil{
            dictionary["sectionName"] = sectionName
        }
        if sheetName != nil{
            dictionary["sheetName"] = sheetName
        }
        if startBar != nil{
            dictionary["startBar"] = startBar
        }
        if type != nil{
            dictionary["type"] = type
        }
        if url != nil{
            dictionary["url"] = url
        }
        if uuid != nil{
            dictionary["uuid"] = uuid
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        demoVideo = aDecoder.decodeObject(forKey: "demoVideo") as? DemoVideo
        endBar = aDecoder.decodeObject(forKey: "endBar") as? Int
        hand = aDecoder.decodeObject(forKey: "hand") as? Int
        mode = aDecoder.decodeObject(forKey: "mode") as? Int
        practiceTime = aDecoder.decodeObject(forKey: "practiceTime") as? Int
        sectionName = aDecoder.decodeObject(forKey: "sectionName") as? String
        sheetName = aDecoder.decodeObject(forKey: "sheetName") as? String
        startBar = aDecoder.decodeObject(forKey: "startBar") as? Int
        type = aDecoder.decodeObject(forKey: "type") as? String
        url = aDecoder.decodeObject(forKey: "url") as? String
        uuid = aDecoder.decodeObject(forKey: "uuid") as? String
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if demoVideo != nil{
            aCoder.encode(demoVideo, forKey: "demoVideo")
        }
        if endBar != nil{
            aCoder.encode(endBar, forKey: "endBar")
        }
        if hand != nil{
            aCoder.encode(hand, forKey: "hand")
        }
        if mode != nil{
            aCoder.encode(mode, forKey: "mode")
        }
        if practiceTime != nil{
            aCoder.encode(practiceTime, forKey: "practiceTime")
        }
        if sectionName != nil{
            aCoder.encode(sectionName, forKey: "sectionName")
        }
        if sheetName != nil{
            aCoder.encode(sheetName, forKey: "sheetName")
        }
        if startBar != nil{
            aCoder.encode(startBar, forKey: "startBar")
        }
        if type != nil{
            aCoder.encode(type, forKey: "type")
        }
        if url != nil{
            aCoder.encode(url, forKey: "url")
        }
        if uuid != nil{
            aCoder.encode(uuid, forKey: "uuid")
        }
        
    }
    
}
