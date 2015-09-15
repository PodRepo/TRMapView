//
//  ViewController.m
//  Example
//
//  Created by joshua li on 15/9/15.
//
//

#import "ViewController.h"

#import "MapView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)showmap:(id)sender {
    [MapView configGDAppKey:@"9185e92185d1bb1c7fd73bb6a8a768f6"];
    [MapView presentChooseMapView:^(NSDictionary *mapSiteDic) {
        NSLog(@" dict %@", mapSiteDic);
    } with:self];
}

@end
