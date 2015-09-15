//
//  MapViewController.h
//  AnjukeBroker_New
//
//  Created by shan xu on 14-3-18.
//  Copyright (c) 2014年 Wu sicong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AMapSearchKit/AMapSearchAPI.h>
#import "RegionAnnotationView.h"
#import "MapDefine.h"


@protocol MapViewControllerDelegate <NSObject>
@required
-(void)loadMapSiteMessage:(NSDictionary *)mapSiteDic;
@end


@interface MapViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate,UIAlertViewDelegate,doAcSheetDelegate, UITableViewDataSource, UITableViewDelegate, AMapSearchDelegate>{
//    CLLocationManager *locationManager;
}

@property(nonatomic,copy) MapChooseLocationBlock chooseBlock;
@property(nonatomic,assign) AnnotationMapType mapType;
@property(nonatomic,strong) NSDictionary *navDic;
@end
