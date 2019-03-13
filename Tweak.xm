#import "WindowInfoManager.h"
#import "AppDelegate.h"
#import "WWKAttendanceRamdonCheckViewController.h"
#import "SuspensionView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "WWKAttendanceBinaryCheckViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "WWKConversationLBSViewController.h"
#import "WWKMessageListController.h"

%hook AppDelegate

- (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2 {
	//[[WindowInfoManager manager] addToWindow:self.window];
 	return %orig;
}


%end

%hook UIImagePickerController

- (void)setSourceType:(UIImagePickerControllerSourceType)sourceType {
    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.mediaTypes = @[(NSString*)kUTTypeImage];
    %orig;
}


%end

%hook WWKMessageListController

- (void)viewDidAppear:(BOOL)animated {
    %orig;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设置定位" style:UIBarButtonItemStylePlain target:self action:@selector(xl_setLocationClicked:)];

}

%new
- (void)xl_setLocationClicked:(id)sender {
    
    UIViewController *vc = (UIViewController *)[NSClassFromString(@"WWKConversationLBSViewController") new];
    [self.navigationController pushViewController:vc animated:YES];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationVCLoad" object:@"run了aaa"];
    
}

%end 

//修改定位信息
%hook QMapView
- (void)locationManager:(id)arg1 didUpdateToLocation:(CLLocation *)arg2 fromLocation:(id)arg3 {
    /*
    NSString *latitudeStr = [[NSUserDefaults standardUserDefaults] stringForKey:@"pilgrimLatitude"];
    NSString *longitudeStr = [[NSUserDefaults standardUserDefaults] stringForKey:@"pilgrimLongitude"];
    //32.034218, 118.722409
    latitudeStr = @"32.034358";
    longitudeStr = @"118.722043";
    if (latitudeStr == nil) {
        latitudeStr = @"32.034358";
    }
    if (longitudeStr == nil) {
        longitudeStr = @"118.722043";
    }
    //double myLatitude = [latitudeStr doubleValue];
    //double myLongitude = [longitudeStr doubleValue];
    //CLLocation * newLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(32.034218, 118.722409) altitude:32.034218 horizontalAccuracy:arg2.horizontalAccuracy verticalAccuracy:arg2.verticalAccuracy course:arg2.course speed:arg2.speed timestamp:arg2.timestamp];

    CLLocation * newLocation = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(32.034218, 118.722409) altitude:32.034218 horizontalAccuracy:arg2.horizontalAccuracy verticalAccuracy:arg2.verticalAccuracy timestamp:arg2.timestamp];
    
    arg2 = newLocation;
    */

    %orig(arg1, arg2, arg3);
}
%end

%hook CLLocation

- (CLLocationCoordinate2D)coordinate {

    NSNumber *latitudeObj = [[NSUserDefaults standardUserDefaults] 
    objectForKey:@"kXLLatitude"];
    NSNumber *longitudeObj = [[NSUserDefaults standardUserDefaults] 
    objectForKey:@"kXLLongitude"];

    if(!latitudeObj || !longitudeObj){
        return %orig;
    }else {
        CGFloat latitude = [latitudeObj floatValue];
        CGFloat longitude = [longitudeObj floatValue];
        CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(latitude, longitude);
        return coor;
    }
}

%end

%hook WWKConversationLBSViewController

- (void)viewDidLoad {
    %orig;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(p_send:)];
}

- (void)p_send:(id)arg1 {
    WWKLocationItem *item = self.selectionItem;
    CLLocationCoordinate2D coor = item.coordinate;

    NSString *string = [NSString stringWithFormat:@"%lf,%lf", coor.latitude, coor.longitude];

    [[NSUserDefaults standardUserDefaults] setObject:@(coor.latitude) forKey:@"kXLLatitude"];
    [[NSUserDefaults standardUserDefaults] setObject:@(coor.longitude) forKey:@"kXLLongitude"];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationVCLoad" object:string];
    %orig;
}

%end