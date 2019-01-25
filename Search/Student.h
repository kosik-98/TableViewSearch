//
//  Student.h
//  Search
//
//  Created by Admin on 21.01.19.
//  Copyright © 2019 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Student : NSObject

@property (strong, nonatomic) NSString* firstName;
@property (strong, nonatomic) NSString* lastName;
@property (strong, nonatomic) NSString* dateOfBirth;

+(Student*) randomStudent;

@end
