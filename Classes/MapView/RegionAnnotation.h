//
//  RegionAnnotation.h
//  AnjukeBroker_New
//
//  Created by shan xu on 14-3-18.
//  Copyright (c) 2014年 Wu sicong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "MapDefine.h"



@interface RegionAnnotation : NSObject<MKAnnotation>
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic,assign) AnnotationMapType annotationType;
@property (nonatomic, assign) AnnotationStatus annotationStatus;
@end
