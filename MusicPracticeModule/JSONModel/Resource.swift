//
//  Resource.swift
//  MusicPracticeModule
//
//  Created by kingcyk on 6/1/21.
//

import Foundation
import SwiftyJSON


class Resource : NSObject, NSCoding{
    
    var practiceList : [PracticeList]!
    var sheetResource : [SheetResource]!
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        practiceList = [PracticeList]()
        let practiceListArray = json["practiceList"].arrayValue
        for practiceListJson in practiceListArray{
            let value = PracticeList(fromJson: practiceListJson)
            practiceList.append(value)
        }
        sheetResource = [SheetResource]()
        let sheetResourceArray = json["sheetResource"].arrayValue
        for sheetResourceJson in sheetResourceArray{
            let value = SheetResource(fromJson: sheetResourceJson)
            sheetResource.append(value)
        }
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if practiceList != nil{
            var dictionaryElements = [[String:Any]]()
            for practiceListElement in practiceList {
                dictionaryElements.append(practiceListElement.toDictionary())
            }
            dictionary["practiceList"] = dictionaryElements
        }
        if sheetResource != nil{
            var dictionaryElements = [[String:Any]]()
            for sheetResourceElement in sheetResource {
                dictionaryElements.append(sheetResourceElement.toDictionary())
            }
            dictionary["sheetResource"] = dictionaryElements
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        practiceList = aDecoder.decodeObject(forKey: "practiceList") as? [PracticeList]
        sheetResource = aDecoder.decodeObject(forKey: "sheetResource") as? [SheetResource]
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if practiceList != nil{
            aCoder.encode(practiceList, forKey: "practiceList")
        }
        if sheetResource != nil{
            aCoder.encode(sheetResource, forKey: "sheetResource")
        }
        
    }
    
}
