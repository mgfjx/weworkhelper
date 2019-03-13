#import "WindowInfoManager.h"
#import "AppDelegate.h"
#import "WWKAttendanceRamdonCheckViewController.h"
#import "SuspensionView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "WWKAttendanceBinaryCheckViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "WWKConversationLBSViewController.h"

%hook AppDelegate

- (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2 {
	[[WindowInfoManager manager] addToWindow:self.window];
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

%hook WWKAttendanceRamdonCheckViewController

- (void)viewDidLoad {
    %orig;

    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat viewSize = 40.0;
    CGFloat viewOffset = 5.0;
    SuspensionView *view = [[SuspensionView alloc] init];
    view.tag = 10010;
    view.backgroundColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.6];
    view.frame = CGRectMake(width - viewSize - viewOffset, height - viewSize - viewOffset, viewSize, viewSize);
    view.layer.cornerRadius = view.bounds.size.width/2;
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeMake(1, 2);
    view.layer.shadowRadius = viewSize/10;
    view.layer.shadowOpacity = 0.9;
    [self.view addSubview:view];
    [self.view bringSubviewToFront:view];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    [view addGestureRecognizer:tap]; 

    
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择照片" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIViewController *vc = (UIViewController *)[NSClassFromString(@"WWKConversationLBSViewController") new];
        [self.navigationController pushViewController:vc animated:YES];
    }];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:action];
    [alert addAction:action1];
    [self presentViewController:alert animated:YES completion:nil];

    
}

- (void)viewWillDisappear:(BOOL)animated{
    %orig;
    UIView *view = [self.view viewWithTag:10010];
    if (view) {
        [view removeFromSuperview];
    }
}

%new
- (void)tapHandler:(UITapGestureRecognizer *)tap{
    

    
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
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(32.034218, 118.722409);
    return coor;
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationVCLoad" object:string];
    %orig;
}

%end