//
//  CreateRequest.swift
//  ReacToThat
//
//  Created by Bradley May on 4/25/15.
//  Copyright (c) 2015 BamApp LLC. All rights reserved.
//

import Foundation
var number=0;

func createRequest(data:[[AnyObject]])->NSMutableURLRequest{
    //data goes 
    //0:Content-Type This is a string
    //1:name This is a string
    //2:filename This is a string
    //3:Data This is in NSData form
    //REMEMBER TO SET URL
    var request=NSMutableURLRequest(URL: NSURL(string: "https://bamapp.net")!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 60)
    request.timeoutInterval=NSTimeInterval(60)
    request.HTTPMethod="POST";
    var end="This12@";

    request.addValue("multipart/form-data; boundary="+end, forHTTPHeaderField: "Content-Type")
    request.setValue("*/*" , forHTTPHeaderField: "Accept")
    request.setValue("close" , forHTTPHeaderField: "Connection")
    request.setValue("100-continue", forHTTPHeaderField: "Expect")
    request.setValue("ReacToThat/1.0", forHTTPHeaderField: "User-Agent")
    var body=NSMutableData()
    
    body.appendData(("\r\n--"+end+"\r\n").dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)!)
    var first=true
    for object in data{
        if !(first){
            body.appendData(("\r\n--"+end+"\r\n").dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)!)
        }
        first=false
        if((object[0] as! String)=="text/plain"){
        body.appendData(("Content-Disposition: form-data; name="+(object[1] as! String)+"\r\n\r\n"+(object[3] as! String)).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)!)
        }else{
            var part1="Content-Disposition: attatchment; name="+(object[1] as! String)
            var part2="; filename="+(object[2] as! String)+";\r\nContent-Type: "
            body.appendData((part1+part2+(object[0] as! String)+"\r\n\r\n").dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)!)
            body.appendData(object[3] as! NSData);
            
        }
        
        
        
    }
    body.appendData(("\r\n--"+end+"--\r\n").dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)!)
    request.HTTPBody=body
    return request
}