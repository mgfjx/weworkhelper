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
    self.allowsEditing = YES;
    %orig;
}


%end

%hook WWKMessageListController

- (void)viewDidAppear:(BOOL)animated {
    %orig;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"设置定位" style:UIBarButtonItemStylePlain target:self action:@selector(xl_setLocationClicked:)];

}

void p_send(id self, SEL _cmd, id arg1) {
    Ivar ivar = class_getInstanceVariable([self class], "_selectionItem");
    // 返回名为test的ivar变量的值
    WWKLocationItem *item = (WWKLocationItem *)object_getIvar(self, ivar);

    CLLocationCoordinate2D coor = item.coordinate;

    NSString *string = [NSString stringWithFormat:@"%lf,%lf", coor.latitude, coor.longitude];

    [[NSUserDefaults standardUserDefaults] setObject:@(coor.latitude) forKey:@"kXLLatitude"];
    [[NSUserDefaults standardUserDefaults] setObject:@(coor.longitude) forKey:@"kXLLongitude"];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationVCLoad" object:string];

    UIViewController *vc = (UIViewController *)self;
    [vc.navigationController popViewControllerAnimated:YES];
}

void viewDidLoad(id self, SEL _cmd) {
    SEL superSel = _cmd;
    Method sm = class_getInstanceMethod([self superclass], superSel);
    IMP imp = method_getImplementation(sm);
    imp(self, superSel);

    UIViewController *vc = (UIViewController *)self;

    vc.title = @"虚拟定位";

    vc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(p_send:)];
}

%new
- (void)xl_setLocationClicked:(id)sender {
    
    //runtime添加继承类
    Class LocationSelectViewController = objc_allocateClassPair(NSClassFromString(@"WWKConversationLBSViewController"), "LocationSelectViewController", 0);
    
    BOOL success = class_addMethod(LocationSelectViewController, @selector(p_send:), (IMP)p_send, "V@:");
    if (success) {
        NSLog(@"添加方法成功");
    }

    {
        BOOL success = class_addMethod(LocationSelectViewController, @selector(viewDidLoad), (IMP)viewDidLoad, "V@:");
        if (success) {
            NSLog(@"添加方法成功");
        }
    }
    
    id vc = [LocationSelectViewController new];
    [self.navigationController pushViewController:(UIViewController *)vc animated:YES];

    /*
    UIViewController *vc = (UIViewController *)[NSClassFromString(@"WWKConversationLBSViewController") new];
    [self.navigationController pushViewController:vc animated:YES];
    */

    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationVCLoad" object:@"run了aaa"];
    
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

/* 改为写继承类，以免对聊天发送位置产生影响
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
*/