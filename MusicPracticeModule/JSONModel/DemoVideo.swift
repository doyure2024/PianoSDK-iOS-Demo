//
//  DemoVideo.swift
//  MusicPracticeModule
//
//  Created by kingcyk on 6/1/21.
//

import Foundation
import SwiftyJSON


class DemoVideo : NSObject, NSCoding{
    
    var url : String!
    var uuid : String!
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        url = json["url"].stringValue
        uuid = json["uuid"].stringValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
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
        url = aDecoder.decodeObject(forKey: "url") as? String
        uuid = aDecoder.decodeObject(forKey: "uuid") as? String
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if url != nil{
            aCoder.encode(url, forKey: "url")
        }
        if uuid != nil{
            aCoder.encode(uuid, forKey: "uuid")
        }
        
    }
    
}
