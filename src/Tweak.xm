#import "WindowInfoManager.h"
#import "AppDelegate.h"
#import "WWKAttendanceRamdonCheckViewController.h"
#import "SuspensionView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "WWKAttendanceBinaryCheckViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "WWKConversationLBSViewController.h"
#import "WWKMessageListController.h"
#import "HelperSettingController.h"

%hook AppDelegate

- (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2 {
	//[[WindowInfoManager manager] addToWindow:self.window];
 	return %orig;
}


%end

%hook UIImagePickerController

- (void)setSourceType:(UIImagePickerControllerSourceType)sourceType {
    if ([MainKeyMananer manager].on && [MainKeyMananer manager].selectFromAlbum) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self.mediaTypes = @[(NSString*)kUTTypeImage];
    }
    %orig;
}

- (void)setAllowsEditing:(BOOL)allowsEditing {
    if ([MainKeyMananer manager].on && [MainKeyMananer manager].photoEdit) {
	   allowsEditing = YES;
    }
	%orig;
}


%end

%hook WWKMessageListController

- (void)viewDidAppear:(BOOL)animated {
    %orig;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"助手设置" style:UIBarButtonItemStylePlain target:self action:@selector(xl_setLocationClicked:)];

}

%new
- (void)xl_setLocationClicked:(id)sender {
    
	HelperSettingController *vc = [%c(HelperSettingController) new];
	[self.navigationController pushViewController:(UIViewController *)vc animated:YES];
}

%end 

%hook CLLocation

- (CLLocationCoordinate2D)coordinate {

    if ([MainKeyMananer manager].on && [MainKeyMananer manager].fakeLocation) {
        NSNumber *latitudeObj = [[NSUserDefaults standardUserDefaults] objectForKey:@"kXLLatitude"];
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
    }else {
        return %orig;
    }
}

%end
