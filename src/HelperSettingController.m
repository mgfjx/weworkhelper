//
//  HelperSettingController.m
//  test
//
//  Created by mgfjx on 2019/3/17.
//  Copyright © 2019 mgfjx. All rights reserved.
//

#import "HelperSettingController.h"
#import <CoreLocation/CoreLocation.h>
#import "WWKLocationItem.h"
#import <objc/runtime.h>
#import <objc/message.h>

#define CellHeight 50
#define MainWidth [UIScreen mainScreen].bounds.size.width

@interface HelperSettingController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView ;

@end

@implementation HelperSettingController

#pragma mark - LifeCycle

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"助手设置";
    self.view.backgroundColor = [UIColor whiteColor];
    [self initViews];
    
}

- (void)initViews {
    
    UITableView *table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    
    [self.view addSubview:table];
    self.tableView = table;
    
    table.tableFooterView = [UIView new];
    
    CGFloat value = 0.95;
    table.backgroundColor = [UIColor colorWithRed:value green:value blue:value alpha:1.0];
    
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else if (section == 1){
        if ([MainKeyMananer manager].fakeLocation) {
            return 2;
        }else{
            return 1;
        }
    }else{
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellReuse = @"cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellReuse];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"总开关";
    }
    
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"虚拟定位";
        }else{
            cell.textLabel.text = @"设置虚拟定位";
        }
    }
    
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"从相册选择照片";
        }else{
            cell.textLabel.text = @"编辑照片";
        }
    }
    
    if (indexPath.section == 1 && indexPath.row == 1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        UISwitch *sw = [[UISwitch alloc] init];
        sw.frame = CGRectMake(MainWidth - sw.bounds.size.width - 10, 0, 0, 0);
        [cell.contentView addSubview:sw];
        sw.center = CGPointMake(sw.center.x, CellHeight/2);
        [sw addTarget:self action:@selector(switchValueChange:) forControlEvents:UIControlEventValueChanged];
        NSInteger tag = (indexPath.section + 1)*100 + indexPath.row;
        sw.tag = tag;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationVCLoad" object:[@(tag) stringValue]];
        if (tag == 100) {
            sw.on = [MainKeyMananer manager].on;
        }else if (tag == 200){
            sw.on = [MainKeyMananer manager].fakeLocation;
        }else if (tag == 300){
            sw.on = [MainKeyMananer manager].selectFromAlbum ;
        }else if (tag == 301){
            sw.on = [MainKeyMananer manager].photoEdit ;
        }

    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 1) {
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
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    CGFloat value = 0.95;
    view.backgroundColor = [UIColor colorWithRed:value green:value blue:value alpha:1.0];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CellHeight;
}

- (void)switchValueChange:(UISwitch *)sw {
    
    NSInteger tag = sw.tag;
    
    if (tag == 100) {
        [MainKeyMananer manager].on = sw.on;
    }else if (tag == 200){
        [MainKeyMananer manager].fakeLocation = sw.on;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else if (tag == 300){
        [MainKeyMananer manager].selectFromAlbum = sw.on;
    }else if (tag == 301){
        [MainKeyMananer manager].photoEdit = sw.on;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"kNotificationVCLoad" object:[@(tag) stringValue]];
    
}

@end
