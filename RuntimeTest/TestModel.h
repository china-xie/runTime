//
//  TestModel.h
//  RuntimeTest
//
//  Created by appleimac on 2017/7/19.
//  Copyright © 2017年 appleimac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestModel : NSObject
@property(nonatomic,copy)NSString * name;
@property(nonatomic,copy)NSString * address;
@property(nonatomic,assign)NSInteger age;

-(void)getNam1;

-(void)getAge1;
@end
