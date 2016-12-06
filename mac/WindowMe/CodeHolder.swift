//
//  CodeHolder.swift
//  WindowMe
//
//  Created by Bradley May on 4/30/16.
//  Copyright © 2016 Bamapp. All rights reserved.
//

import Foundation
class CodeHolder:NSObject, NSCoding{
    var code1:String
    var code2:String
    init(code1:String, code2:String){
        self.code1=code1
        self.code2=code2
    }
    required init?(coder aDecoder: NSCoder) {
        self.code1=aDecoder.decodeObjectForKey("code1") as! String
        self.code2=aDecoder.decodeObjectForKey("code2") as! String
    }
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(code1, forKey: "code1")
        aCoder.encodeObject(code2, forKey: "code2")
    }
    static func saveHolder(holder:CodeHolder){
    
        let defaults=NSUserDefaults.standardUserDefaults()
        let key="Holder"
        
        defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(holder), forKey: key)
        
    }
    static func loadHolder()->CodeHolder{
        let defaults=NSUserDefaults.standardUserDefaults()
        let key="Holder"
        let unarchivedData = defaults.dataForKey(key)
        if(unarchivedData==nil){
            return CodeHolder(code1: "0", code2: "0")
        }else{
        return(NSKeyedUnarchiver.unarchiveObjectWithData(unarchivedData!) as! CodeHolder)
        }
    }
}