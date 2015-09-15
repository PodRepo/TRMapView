//
//  MapView.h
//  TRPet
//
//  Created by lijinchao on 15/7/21.
//  Copyright (c) 2015年 taro. All rights reserved.
//

#ifndef TRPet_MapView_h
#define TRPet_MapView_h

#import <UIKit/UIKit.h>
#import "MapDefine.h"

@interface MapView : NSObject
+(void)configGDAppKey:(NSString*)key;
+(NSString*)gdAppKey;
+(void)presentNavMapView:(NSDictionary*)dic with:(UIViewController*)vc;
+(void)presentChooseMapView:(MapChooseLocationBlock)block with:(UIViewController*)vc;
@end



#endif
