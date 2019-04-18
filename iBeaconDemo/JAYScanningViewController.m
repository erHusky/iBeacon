//
//  JAYScaningViewController.m
//  iBeaconDemo
//
//  Created by Smiley on 2019/4/17.
//  Copyright © 2019 Smiley. All rights reserved.
//

#import "JAYScanningViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Masonry/Masonry.h"
#import "JAYScanningResultCell.h"
#import "JAYUUIDListViewController.h"

@interface JAYScanningViewController () <CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeaconRegion *beaconRegion;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) UISwitch *scanningSwitch;

@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, copy) NSString *UUID;

@end

@implementation JAYScanningViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self jay_setupUserInterface];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self jay_stopScan];
}

- (void)dealloc {
    [self jay_stopScan];
}


#pragma mark - Private Methods
- (void)jay_setupUserInterface {
    self.title = @"扫描";
    __weak __typeof(self) weakSelf = self;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.estimatedRowHeight = 50.0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.edges.mas_equalTo(weakSelf.view.mas_safeAreaLayoutGuide);
        } else {
            make.edges.equalTo(weakSelf.view);
        }
    }];
}

- (void)jay_startScan {
    BOOL availableMonitor = [CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]];
    if (availableMonitor) {
        CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
        switch (authorizationStatus) {
            case kCLAuthorizationStatusNotDetermined:
                [self.locationManager requestAlwaysAuthorization];
                break;
            case kCLAuthorizationStatusRestricted:
            case kCLAuthorizationStatusDenied:
                NSLog(@"受限制或者拒绝");
                break;
            case kCLAuthorizationStatusAuthorizedAlways:
            case kCLAuthorizationStatusAuthorizedWhenInUse:{
                self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:self.UUID] identifier:@"com.antlinker.iBeacon"];
                self.beaconRegion.notifyEntryStateOnDisplay = YES;
                self.beaconRegion.notifyOnExit = YES;
                self.beaconRegion.notifyOnEntry = YES;
                [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
//                [self.locationManager startMonitoringForRegion:self.beaconRegion];
            }
                break;
        }
    } else {
        NSLog(@"该设备不支持 CLBeaconRegion 区域检测");
    }
}

- (void)jay_stopScan {
    [self.locationManager stopMonitoringForRegion:self.beaconRegion];
}


#pragma mark - Actions
- (void)jay_scanningSwitchValueChanged:(UISwitch *)sender {
    if (sender.isOn) {
        [self jay_startScan];
    } else {
        [self jay_stopScan];
    }
}


#pragma mark - Getter
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (UISwitch *)scanningSwitch {
    if (!_scanningSwitch) {
        _scanningSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 64.0, 44.0)];
        _scanningSwitch.on = NO;
        [_scanningSwitch addTarget:self action:@selector(jay_scanningSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _scanningSwitch;
}

- (NSString *)titleStr {
    if (!_titleStr) {
        _titleStr = @"宿舍 A";
    }
    return _titleStr;
}

- (NSString *)UUID {
    if (!_UUID) {
        _UUID = @"CA54D516-60F4-11E9-8647-D663BD873D93";
    }
    return _UUID;
}



//- (CLBeaconRegion *)beaconRegion {
//    if (!_beaconRegion) {
//        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:self.UUID] identifier:@"com.antlinker.iBeacon"];
//        _beaconRegion.notifyEntryStateOnDisplay = YES;
//        // 监听该UUID下的所有Beacon设备
//        //- (instancetype)initWithProximityUUID:(NSUUID *)proximityUUID identifier:(NSString *)identifier;
//        // 监听该UUID，major下的所有Beacon设备
//        //- (instancetype)initWithProximityUUID:(NSUUID *)proximityUUID major:(CLBeaconMajorValue)major identifier:(NSString *)identifier;
//        // 监听唯一的Beacon设备
//        //- (instancetype)initWithProximityUUID:(NSUUID *)proximityUUID major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor identifier:(NSString *)identifier;
//
//    }
//    return _beaconRegion;
//}


#pragma mark - CLLocationManagerDelegate

//// Monitoring成功对应回调函数
//- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
//    NSLog(@"Monitoring成功对应回调函数");
//}
//// 设备进入该区域时的回调
//- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
//    NSLog(@"设备进入该区域时的回调");
//}
//// 设备退出该区域时的回调
//- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
//    NSLog(@"设备退出该区域时的回调");
//}
//// Monitoring有错误产生时的回调
//- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(nullable CLRegion *)region withError:(NSError *)error {
//    NSLog(@"Monitoring有错误产生时的回调");
//}


// 检测到区域内的iBeacons的回调函数,包含监测到的所有 iBeacon 的信息
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<CLBeacon *> *)beacons inRegion:(CLBeaconRegion *)region {
    self.dataSource = [[NSMutableArray alloc] initWithArray:beacons];
    [self.tableView reloadData];
}
// 有错误产生时的回调
- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    NSLog(@"有错误产生时的回调");
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
        }
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"扫描开关";
                cell.accessoryView = self.scanningSwitch;
                break;
            case 1:
                cell.textLabel.text = @"UUID";
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%@-%@", self.titleStr, self.UUID];
                break;
            default:
                break;
        }
        return cell;
    }
    JAYScanningResultCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JAYScanningResultCell"];
    if (!cell) {
        cell = [[JAYScanningResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"JAYScanningResultCell"];
    }
    cell.beacon = self.dataSource[indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 50.0;
    }
    return JAYScanningResultCell_CellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return 20.0;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 1) {
        JAYUUIDListViewController *UUIDListViewController = [[JAYUUIDListViewController alloc] init];
        UUIDListViewController.selectUUIDFinished = ^(NSString * _Nonnull titleStr, NSString * _Nonnull UUID) {
            self.titleStr = titleStr;
            self.UUID = UUID;
            [self.tableView reloadData];
            if (self.scanningSwitch.isOn) {
                [self jay_startScan];
            }
        };
        [self.navigationController pushViewController:UUIDListViewController animated:YES];
    }
}

@end
