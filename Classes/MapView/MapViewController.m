//
//  MapViewController.m
//  AnjukeBroker_New
//
//  Created by shan xu on 14-3-18.
//  Copyright (c) 2014年 Wu sicong. All rights reserved.
//

#import "MapViewController.h"
#import "RegionAnnotation.h"
#import "MapView.h"

#define SYSTEM_NAVIBAR_COLOR [UIColor colorWithRed:0 green:0 blue:0 alpha:1]
#define ISIOS7 ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=7)
#define ISIOS6 ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] intValue]>=6)
#define STATUS_BAR_H 20
#define NAV_BAT_H 44
#define HISTORY_TableViewHight 200


#define kNavSize 500

@interface MapViewController ()


@property(nonatomic,strong) UITableView *nearByTableView;
@property(nonatomic,assign) NSInteger selectIndex;
@property(nonatomic,strong) AMapSearchAPI *search;
@property(nonatomic,strong) AMapPlaceSearchResponse *searchRes;

//导航目的地2d,高德
@property(nonatomic,assign) CLLocationCoordinate2D naviCoordsGd;
//user最新2d
@property(nonatomic,assign) CLLocationCoordinate2D userCoords;

//userRegion 地图中心点定位参数
@property(nonatomic,assign) MKCoordinateRegion userRegion;
@property(nonatomic,assign) MKCoordinateRegion naviRegion;
@property(nonatomic, assign) BOOL clickedNearByTable;

//最近一次请求的中心2d
@property(nonatomic,assign) CLLocationCoordinate2D chooseLocation;
@property(nonatomic,strong) NSString *addressName;
@property(nonatomic,strong) NSString *addressStr;

@property(nonatomic,assign) CLLocationCoordinate2D originalChooseLoc;
@property(nonatomic,strong) NSString *originalAddressName;
@property(nonatomic,strong) NSString *originalAddressStr;

@property(nonatomic,strong) MKMapView *regionMapView;
@property(nonatomic,strong) CLLocationManager *locationManager;
//定位参数信息
@property(nonatomic,strong) RegionAnnotation *regionAnnotation;
//定位状态，包括6种状态
@property(nonatomic, assign) AnnotationStatus loadStatus;
//用户位置初始化
@property(nonatomic, assign) BOOL isUserLocationInited;
@end

@implementation MapViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.loadStatus = Loading;
        self.isUserLocationInited = NO;
        self.navDic = [[NSDictionary alloc] init];
    }
    return self;
}
- (NSInteger)windowWidth {
    return [[[[UIApplication sharedApplication] windows] objectAtIndex:0] frame].size.width;
}
- (NSInteger)windowHeight {
    return [[[[UIApplication sharedApplication] windows] objectAtIndex:0] frame].size.height;
}
- (void)viewDidDisappear:(BOOL)animated{
    self.regionMapView.delegate = nil;
    //    self.locationManager.delegate = nil;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (ISIOS7) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
    [self addBackButton];
    NSString *titStr;
    if (self.mapType == RegionNavi) {
        titStr = @"查看地理位置";
    }else{
        titStr = @"位置";
        [self addRightButton];
    }
    
    UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 31)];
//    lb.backgroundColor = [UIColor clearColor];
    lb.font = [UIFont systemFontOfSize:19];
    lb.textAlignment = NSTextAlignmentCenter;
//    lb.textColor = SYSTEM_NAVIBAR_COLOR;
    lb.textColor = [UIColor whiteColor];
    lb.text = titStr;
    self.navigationItem.titleView = lb;
    
    if (self.mapType == RegionChoose) {
        self.regionMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 64, [self windowWidth], [self windowHeight] - STATUS_BAR_H - NAV_BAT_H - HISTORY_TableViewHight)];

    }else{
        self.regionMapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 64, [self windowWidth], [self windowHeight] - STATUS_BAR_H - NAV_BAT_H)];
    }
    self.regionMapView.delegate = self;
    self.regionMapView.showsUserLocation = YES;
    [self.view addSubview:self.regionMapView];
    
    self.locationManager = [CLLocationManager new];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager setDistanceFilter:kCLDistanceFilterNone];
    if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
        [self.locationManager requestWhenInUseAuthorization];
    }else{
        [self.locationManager startUpdatingLocation];
    }
    
    
    UIButton *goUserLocBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (self.mapType == RegionChoose) {
        goUserLocBtn.frame = CGRectMake(8, [self windowHeight] - STATUS_BAR_H - NAV_BAT_H-58+64 - HISTORY_TableViewHight, 40, 40);
    }else{
        goUserLocBtn.frame = CGRectMake(8, [self windowHeight] - STATUS_BAR_H - NAV_BAT_H-58+64, 40, 40);
    }
    [goUserLocBtn addTarget:self action:@selector(goUserLoc:) forControlEvents:UIControlEventTouchUpInside];
    [goUserLocBtn setImage:[UIImage imageNamed:@"MapView.bundle/wl_map_icon_position.png"] forState:UIControlStateNormal];
    [goUserLocBtn setImage:[UIImage imageNamed:@"MapView.bundle/wl_map_icon_position_press.png"] forState:UIControlStateHighlighted];
    goUserLocBtn.backgroundColor = [UIColor clearColor];
    [self.view addSubview:goUserLocBtn];
    
    if (self.mapType == RegionChoose) {
        CGRect center = CGRectMake([self windowWidth]/2-8, ([self windowHeight] - STATUS_BAR_H - NAV_BAT_H - HISTORY_TableViewHight)/2-25+64, 16, 33);
        UIImageView *certerIcon = [[UIImageView alloc] initWithFrame:center];
        certerIcon.image = [UIImage imageNamed:@"MapView.bundle/anjuke_icon_itis_position.png"];
        [self.view addSubview:certerIcon];
        
        //        CLLocationCoordinate2D a;
        //        a.latitude = 24.48;
        //        a.longitude = 118.18;
        //        MKCoordinateRegion history = MKCoordinateRegionMakeWithDistance(a, kNavSize, kNavSize);
        //        self.isUserLocationInited = YES;
        //        [self.regionMapView setRegion:history animated:NO];
        
        // add history
        _nearByTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, [self windowHeight] - HISTORY_TableViewHight, [self windowWidth], HISTORY_TableViewHight)];
        _nearByTableView.dataSource = self;
        _nearByTableView.delegate = self;
        [self.view addSubview:_nearByTableView];
        _search = [[AMapSearchAPI alloc] initWithSearchKey:[MapView gdAppKey] Delegate:self];
        
//        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"MapView.bundle/anjuke_icon_itis_position"]];
//        image.frame = CGRectMake(160.0, 100.0, CGRectGetWidth(image.frame), CGRectGetHeight(image.frame));
//        [self.view addSubview:image];
        
    }else{
        _naviCoordsGd.latitude = [[self.navDic objectForKey:@"latitude"] doubleValue];
        _naviCoordsGd.longitude = [[self.navDic objectForKey:@"longitude"] doubleValue];
        
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:_naviCoordsGd.latitude longitude:_naviCoordsGd.longitude];
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(_naviCoordsGd, kNavSize, kNavSize);
        self.naviRegion = [self.regionMapView regionThatFits:viewRegion];
        
        [self.regionMapView setRegion:self.naviRegion animated:NO];
        [self showAnnotation:loc];
        
        if (!ISIOS6) {
            [self performSelector:@selector(setRegionAgain) withObject:nil afterDelay:2.0];
        }
    }
}

-(void)searchNearBy:(CGFloat)latitude longitude:(CGFloat)longitude{
    if (!_search){
        return;
    }
    AMapPlaceSearchRequest *poiRequest = [[AMapPlaceSearchRequest alloc] init];
    poiRequest.searchType = AMapSearchType_PlaceAround;
    poiRequest.location = [AMapGeoPoint locationWithLatitude:latitude longitude:longitude];
    poiRequest.radius  = 250;
    poiRequest.sortrule = 1;
    poiRequest.requireExtension = YES;
    [_search AMapPlaceSearch: poiRequest];
}



-(void)setRegionAgain{
    MKCoordinateRegion viewRegion1 = MKCoordinateRegionMakeWithDistance(_naviCoordsGd, kNavSize, kNavSize);
    self.naviRegion = [self.regionMapView regionThatFits:viewRegion1];
    [self.regionMapView setRegion:self.naviRegion animated:NO];
}

-(void)openGPSTips{
    UIAlertView *alet = [[UIAlertView alloc] initWithTitle:@"当前定位服务不可用" message:@"请到“设置->隐私->定位服务”中开启定位" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alet show];
}
#pragma UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (self.mapType == RegionChoose) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)addRightButton{
    UIBarButtonItem *rBtn = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonAction:)];
    if (!ISIOS7) {
        self.navigationItem.rightBarButtonItem = rBtn;
    }
    else {
//        [self.navigationController.navigationBar setTintColor:SYSTEM_NAVIBAR_COLOR];
        self.navigationItem.rightBarButtonItem = rBtn;
    }
}
- (void)addBackButton {
    // 设置返回btn
    UIImage *image = [UIImage imageNamed:@"MapView.bundle/anjuke_icon_back.png"];
    UIImage *highlighted = [UIImage imageNamed:@"MapView.bundle/anjuke_icon_back.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, image.size.width + 40 , 44);
    [button addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:highlighted forState:UIControlStateHighlighted];
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 40)];
    [button setTitle:@"返回" forState:UIControlStateNormal];
    [button setTitle:@"返回" forState:UIControlStateHighlighted];
//    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    button.titleLabel.textAlignment = NSTextAlignmentLeft;
    button.titleLabel.backgroundColor = [UIColor clearColor];
    button.backgroundColor = [UIColor clearColor];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}
-(void)doBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)rightButtonAction:(id)sender{
    if (_chooseLocation.latitude && _chooseLocation.longitude) {
        if (self.chooseBlock){
            NSMutableDictionary *locationDic = [[NSMutableDictionary alloc] init];
            [locationDic setValue:_addressStr forKey:@"address"];
            [locationDic setValue:[NSNumber numberWithFloat:_chooseLocation.latitude] forKey:@"latitude"];
            [locationDic setValue:[NSNumber numberWithFloat:_chooseLocation.longitude] forKey:@"longitude"];
            NSNumber *number = [NSNumber numberWithInt:LocationTypeGCJ];
            [locationDic setValue:number forKey:@"from_map_type"];
            
            self.chooseBlock(locationDic);
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)goUserLoc:(id)sender{
    [self.regionMapView setRegion:self.userRegion animated:YES];
}



- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if (status == kCLAuthorizationStatusAuthorized || status == kCLAuthorizationStatusAuthorizedWhenInUse){
        [manager startUpdatingLocation];
        NSLog(@" kCLAuthorizationStatusAuthorized status %d", status);
    }else if (status == kCLAuthorizationStatusDenied){
        [self openGPSTips];
        NSLog(@" kCLAuthorizationStatusDenied status %d", status);
    }else {
        if ([[[UIDevice currentDevice] systemVersion] intValue] >= 8) {
            [manager requestWhenInUseAuthorization];
        }else{
            [manager startUpdatingLocation];
            [self.locationManager startUpdatingLocation];
        }
        NSLog(@"status %d", status);
    }
}

#pragma mark MKMapViewDelegate -user location定位变化
-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    self.userCoords = [userLocation coordinate];
    NSLog(@"nowlocation %f, %f status %d", self.userCoords.longitude, self.userCoords.latitude, self.loadStatus);
    //放大地图到自身的经纬度位置。
    self.userRegion = MKCoordinateRegionMakeWithDistance(self.userCoords, kNavSize, kNavSize);
    
    if (self.mapType == RegionChoose) {
        if (self.self.isUserLocationInited != YES) {
            self.isUserLocationInited = YES;
            [self.regionMapView setRegion:self.userRegion animated:NO];
        }
        if (self.loadStatus == Success) {
            return;
        }
    }
}


-(void)showSelectRegionAnnotation{
    
    if(_selectIndex == 0){
        _chooseLocation = _originalChooseLoc;
        _addressStr = _originalAddressStr;
        _addressName = _originalAddressName;
        [self addAnnotationView:self.originalChooseLoc region:self.originalAddressName address:self.originalAddressStr];
    }else{
        AMapPOI *obj = _searchRes.pois[_selectIndex - 1];
        CLLocationCoordinate2D l;
        l.latitude = obj.location.latitude;
        l.longitude = obj.location.longitude;
        _chooseLocation = l;
        _addressName = obj.name;
        _addressStr = obj.address;
        [self addAnnotationView:l region:obj.name address:obj.address];
    }
}

-(void)setChooseLocation:(CLLocationCoordinate2D)location withAddr:(NSString*)addr withName:(NSString*)name{
    _chooseLocation = location;
    _addressStr = addr;
    _addressName = name;
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if (self.mapType == RegionNavi) {
        return;
    }
    if (ISIOS7) {
        if ([mapView.annotations count]) {
            [mapView removeAnnotations:mapView.annotations];
        }
    }
    
    [self showSelectRegionAnnotation];
    if(_clickedNearByTable){
        _clickedNearByTable = NO;
    }else{
        CLLocationCoordinate2D coordinate = mapView.region.center;
        //    self.naviRegion = mapView.region;
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        [self showAnnotation:loc];
        [self searchNearBy:coordinate.latitude longitude:coordinate.longitude];
    }

}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
    if (self.mapType == RegionNavi) {
        return;
    }
    if (ISIOS7) {
        if ([mapView.annotations count]) {
            [mapView removeAnnotations:mapView.annotations];
        }
    }
}
#pragma mark- 获取位置信息，并判断是否显示，block方法支持ios6及以上
-(void)showAnnotation:(CLLocation *)location{
    CLLocationCoordinate2D coords = location.coordinate;
    self.originalAddressStr = @"";
    self.originalAddressName = @"";
    _loadStatus = Loading;
    
    if (self.mapType == RegionNavi && ![[self.navDic objectForKey:@"region"] isEqualToString:@""]) {
        _loadStatus = Success;
        [self addAnnotationView:coords region:[self.navDic objectForKey:@"region"]  address:[self.navDic objectForKey:@"address"]];
        return;
    }
    
    [self addAnnotationView:coords region:@"加载地址中..." address:nil];
    //CLGeocoder ios5之后支持
    NSLog(@"chooseLocation %f %f", coords.longitude, coords.latitude);
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *array, NSError *error) {
//        if (location.coordinate.latitude != self.chooseLocation.latitude){
//            return;
//        }
        if (array.count > 0) {
            CLPlacemark *placemark = [array objectAtIndex:0];
            
            NSString *region = [placemark.addressDictionary objectForKey:@"SubLocality"];
            NSString *address = [placemark.addressDictionary objectForKey:@"Name"];
            self.addressName = region;
            self.originalAddressStr = address;
            self.originalChooseLoc = location.coordinate;
            _loadStatus = Success;
            [self addAnnotationView:location.coordinate region:region address:address];
            [_nearByTableView reloadData];
        }else{
            self.originalAddressName = @"";
            self.originalAddressStr = @"";
             self.originalChooseLoc = location.coordinate;
            _loadStatus = Fail;
            [self addAnnotationView:location.coordinate region:@"没有找到有效地址" address:nil];
        }
    }];
}
#pragma mark- 添加大头针的标注
-(void)addAnnotationView:(CLLocationCoordinate2D)coords region:(NSString *)region address:(NSString *)address{
    [self setChooseLocation:coords withAddr:address withName:region];
    if ([self.regionMapView.annotations count]) {
        [self.regionMapView removeAnnotations:self.regionMapView.annotations];
    }
    
    if (!self.regionAnnotation) {
        self.regionAnnotation = [[RegionAnnotation alloc] init];
    }
    
    self.regionAnnotation.coordinate = coords;
    self.regionAnnotation.title = region;
    self.regionAnnotation.subtitle  = address;
    self.regionAnnotation.annotationStatus = _loadStatus;
    self.regionAnnotation.annotationType = self.mapType;
    
    [self.regionMapView addAnnotation:self.regionAnnotation];
    [self.regionMapView selectAnnotation:self.regionAnnotation animated:YES];
    
//    RegionAnnotation *r = [[RegionAnnotation alloc] init];
//    r.coordinate = self.userCoords;
//    r.title = @"当前位置";
//    r.subtitle  = @"";
//    r.annotationStatus = Success;
//    r.annotationType = self.mapType;
//    
//    [self.regionMapView addAnnotation:r];
}

#pragma mark MKMapViewDelegate -显示大头针标注
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    if ([annotation isKindOfClass:[RegionAnnotation class]]) {
        
        static NSString* identifier = @"MKAnnotationView";
        RegionAnnotationView *annotationView;
        
        annotationView = (RegionAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (!annotationView) {
            annotationView = [[RegionAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            annotationView.acSheetDelegate = self;
        }
        
        annotationView.backgroundColor = [UIColor clearColor];
        annotationView.annotation = annotation;
        [annotationView layoutSubviews];
        [annotationView setCanShowCallout:NO];
        
        return annotationView;
    }else{
        return nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_searchRes){
        return _searchRes.pois.count + 1;
    }else{
        return 1;
    }
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifierText = @"TextCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierText];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifierText];
    }
   
    cell.imageView.image = nil;
    cell.detailTextLabel.text = nil;
    cell.textLabel.text = nil;
    if (indexPath.row == 0){
        cell.detailTextLabel.text = self.originalAddressStr;
        cell.textLabel.text = @"位置";
    }else{
        if(_searchRes){
            AMapPOI *obj = _searchRes.pois[indexPath.row - 1];
            cell.detailTextLabel.text = obj.address;
            cell.textLabel.text = obj.name;
        }
    }
    if(indexPath.row == _selectIndex){
        cell.imageView.image = [UIImage imageNamed:@"MapView.bundle/anjuke_icon_itis_position"];
    }
    return cell;
}


#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(_selectIndex == indexPath.row){
        return;
    }
    _selectIndex = indexPath.row;
    _clickedNearByTable = YES;
    
    [self showSelectRegionAnnotation];
    if(indexPath.row == 0){
        MKCoordinateRegion viewRegion1 = MKCoordinateRegionMakeWithDistance(self.originalChooseLoc, kNavSize, kNavSize);
        self.naviRegion = [self.regionMapView regionThatFits:viewRegion1];
        [self.regionMapView setRegion:self.naviRegion animated:YES];
    }else{
        if(_searchRes){
            AMapPOI *obj = _searchRes.pois[indexPath.row - 1];
            CLLocationCoordinate2D l;
            l.latitude = obj.location.latitude;
            l.longitude = obj.location.longitude;
            
            MKCoordinateRegion viewRegion1 = MKCoordinateRegionMakeWithDistance(l, kNavSize, kNavSize);
            self.naviRegion = [self.regionMapView regionThatFits:viewRegion1];
            [self.regionMapView setRegion:self.naviRegion animated:YES];
        }
    }
    [tableView reloadData];
}



#pragma mark AMapSearchDelegate 

/*!
 当请求发生错误时，会调用代理的此方法.
 @param request 发生错误的请求.
 @param error   返回的错误.
 */
- (void)searchRequest:(id)request didFailWithError:(NSError *)error{
    if (error){
        NSLog(@"search error %@", error);
    }
}


/*!
 @brief POI查询回调函数
 @param request 发起查询的查询选项(具体字段参考AMapPlaceSearchRequest类中的定义)
 @param response 查询结果(具体字段参考AMapPlaceSearchResponse类中的定义)
 */
- (void)onPlaceSearchDone:(AMapPlaceSearchRequest *)request response:(AMapPlaceSearchResponse *)respons{
    _searchRes = respons;
//    NSLog(@"response %@", respons);
    [_nearByTableView reloadData];
//    if (respons.pois.count == 0)
//    {
//        return;
//    }
//    
//    NSMutableArray *poiAnnotations = [NSMutableArray arrayWithCapacity:respons.pois.count];
//    
//    [respons.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
//        RegionAnnotation *a = [[RegionAnnotation alloc] init];
//        
//        CLLocationCoordinate2D l;
//        l.latitude = obj.location.latitude;
//        l.longitude = obj.location.longitude;
//        a.coordinate = l;
//        
//        a.title = obj.name;
//        a.subtitle  = obj.address;
//        a.annotationStatus = Success;
//        a.annotationType = RegionChoose;
//        
//        [poiAnnotations addObject:a];
//        
//    }];
//    
//    /* 将结果以annotation的形式加载到地图上. */
//    [self.regionMapView addAnnotations:poiAnnotations];
//    
//    /* 如果只有一个结果，设置其为中心点. */
//    if (poiAnnotations.count == 1)
//    {
//        self.regionMapView.centerCoordinate = [poiAnnotations[0] coordinate];
//    }
//    /* 如果有多个结果, 设置地图使所有的annotation都可见. */
//    else
//    {
//        [self.regionMapView showAnnotations:poiAnnotations animated:NO];
//    }

    
    
}


@end
