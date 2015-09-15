//
//  MapView.m
//  TRPet
//
//  Created by lijinchao on 15/7/21.
//  Copyright (c) 2015年 taro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapView.h"
#import "MapViewController.h"

@implementation MapView

static NSString *GDAppKey;
+(void)configGDAppKey:(NSString*)key{
    GDAppKey = key;
}

+(NSString*)gdAppKey{
    return GDAppKey;
}

+(void)presentNavMapView:(NSDictionary*)dic with:(UIViewController*)vc{
    MapViewController *mapvc = [[MapViewController alloc] init];
    mapvc.navDic = dic;
    mapvc.mapType = RegionNavi;
    if (vc) {
        [vc.navigationController pushViewController:mapvc animated:YES];
    }
}


+(void)presentChooseMapView:(MapChooseLocationBlock)block with:(UIViewController*)vc{
    
    MapViewController *mapvc = [[MapViewController alloc] init];
    mapvc.chooseBlock = block;
    mapvc.mapType = RegionChoose;
    if (vc) {
        [vc.navigationController pushViewController:mapvc animated:YES];
    }
}

@end