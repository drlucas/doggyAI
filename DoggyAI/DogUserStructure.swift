//
//  DogStructure.swift
//  DoggyAI
//
//  Created by ryan on 2016-04-02.
//  Copyright © 2016 D Ryan Lucas. All rights reserved.
//

import UIKit

struct Dog {
    var birth = String();
    var gender = String();
    var weight = Int()
    var name = String();
    var slug = String();
    var image = String(); //this is an uuencoded file 
   
}

struct User {
    var name = String();
    var slug = String();
    var image = String(); //this is an uuencoded file 
    var fname = String();
    var lname = String();
    var email = String();
    var pichash = String();
    
    init(name: String, slug: String, image:String, fname:String, lname:String, email:String, pichash:String) {
        self.name = name
        self.slug = slug
        self.image = image
        self.fname = fname
        self.lname = lname
        self.email = email
        self.pichash = pichash
    }
    
}
