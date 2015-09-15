//
//  RegionAnnotation.h
//  AnjukeBroker_New
//
//  Created by shan xu on 14-3-18.
//  Copyright (c) 2014年 Wu sicong. All rights reserved.
//

#import <Foundation/Foundation.h>

//typedef enum
//{
//    WGS = 0, //国际标准，GPS坐标
//    GCJ, //中国坐标偏移标准，Google Map、高德、腾讯
//    BD //百度坐标偏移标准
//}LocationType;

typedef NS_ENUM(NSInteger, LocationType) {
    LocationTypeWGS,//默认从0开始
    LocationTypeGCJ,
    LocationTypeBD,
};
                
typedef enum
{
    Loading = 0,
    Success,
    Fail
}AnnotationStatus;


typedef enum{
    RegionChoose = 0,
    RegionNavi
}AnnotationMapType;

typedef void(^MapChooseLocationBlock)(NSDictionary *mapSiteDic);