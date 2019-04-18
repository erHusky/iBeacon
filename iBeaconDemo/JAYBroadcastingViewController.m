//
//  JAYBroadcastingViewController.m
//  iBeaconDemo
//
//  Created by Smiley on 2019/4/17.
//  Copyright © 2019 Smiley. All rights reserved.
//

#import "JAYBroadcastingViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "Masonry/Masonry.h"
#import "JAYUUIDListViewController.h"

@interface JAYBroadcastingViewController () <CBPeripheralManagerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic, strong) CBPeripheralManager *peripheralManager;

@property (nonatomic, strong) UIBarButtonItem *doneButton;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *titleArray;

/** 广播开关 */
@property (nonatomic, strong) UISwitch *broadcastSwitch;
@property (nonatomic, assign) BOOL broadcastSwitchIsOn;

@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, copy) NSString *UUID;

@property (nonatomic, strong) UITextField *majorTextField;
@property (nonatomic, assign) NSInteger major;

@property (nonatomic, strong) UITextField *minorTextField;
@property (nonatomic, assign) NSInteger minor;

@property (nonatomic, strong) UITextField *measuredPowerTextField;
@property (nonatomic, assign) NSInteger measuredPower;

@end

@implementation JAYBroadcastingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self jay_setupUserInterface];
    [self jay_startBroadcast];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self jay_stopBroadcast];
}


#pragma mark - Private Methods
- (void)jay_setupUserInterface {
    self.title = @"广播";
    
    __weak __typeof(self) weakSelf = self;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
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

- (void)jay_startBroadcast {
    if (!_peripheralManager) {
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    } else {
        _peripheralManager.delegate = self;
    }
    [self jay_updateEmitterForDesiredState];
}

- (void)jay_updateEmitterForDesiredState {
    if (_peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        if (_broadcastSwitchIsOn) {
            CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:self.UUID]
                                                                              major:self.major
                                                                              minor:self.minor
                                                                         identifier:@"com.antlinker.iBeacon"];
            NSDictionary *peripheralData = [region peripheralDataWithMeasuredPower:[NSNumber numberWithInteger:self.measuredPower]];
            if(peripheralData) {
                [_peripheralManager startAdvertising:peripheralData];
            }
        } else {
            [_peripheralManager stopAdvertising];
        }
    }
}

- (void)jay_stopBroadcast {
    [_peripheralManager stopAdvertising];
    _peripheralManager.delegate = nil;
}

- (UITextField *)jay_createTextFieldWithDefaultValue:(NSInteger)defaultValue isNegativeNumber:(BOOL)isNegativeNumber {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 100.0, 44.0)];
    if (isNegativeNumber) {
        textField.text = [NSString stringWithFormat:@"-%@", @(defaultValue)];
    } else {
        textField.text = [NSString stringWithFormat:@"%@", @(defaultValue)];
    }
    textField.textAlignment = NSTextAlignmentRight;
    textField.keyboardType = UIKeyboardTypeNumberPad;
    textField.delegate = self;
    return textField;
}


#pragma mark - Actions
- (void)jay_navDoneButtonClicked {
    [self.majorTextField endEditing:YES];
    [self.minorTextField endEditing:YES];
    [self.measuredPowerTextField endEditing:YES];
}

- (void)jay_broadcastingSwitchChangeState:(UISwitch *)sender {
    if (sender.isOn) {
        _broadcastSwitchIsOn = YES;
    } else {
        _broadcastSwitchIsOn = NO;
    }
    [self jay_updateEmitterForDesiredState];
}


#pragma mark - Getter
- (UIBarButtonItem *)doneButton {
    if (!_doneButton) {
        _doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(jay_navDoneButtonClicked)];
    }
    return _doneButton;
}

- (UISwitch *)broadcastSwitch {
    if (!_broadcastSwitch) {
        _broadcastSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 64.0, 44.0)];
        _broadcastSwitch.on = NO;
        _broadcastSwitchIsOn = NO;
        [_broadcastSwitch addTarget:self action:@selector(jay_broadcastingSwitchChangeState:) forControlEvents:UIControlEventValueChanged];
    }
    return _broadcastSwitch;
}

- (NSArray *)titleArray {
    if (!_titleArray) {
        _titleArray = @[@"广播开关", @"UUID", @"Major", @"Minor", @"信号强度"];
    }
    return _titleArray;
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

- (UITextField *)majorTextField {
    if (!_majorTextField) {
        _majorTextField = [self jay_createTextFieldWithDefaultValue:0 isNegativeNumber:NO];
    }
    return _majorTextField;
}

- (UITextField *)minorTextField {
    if (!_minorTextField) {
        _minorTextField = [self jay_createTextFieldWithDefaultValue:0 isNegativeNumber:NO];
    }
    return _minorTextField;
}

- (UITextField *)measuredPowerTextField {
    if (!_measuredPowerTextField) {
        _measuredPowerTextField = [self jay_createTextFieldWithDefaultValue:59 isNegativeNumber:YES];
    }
    return _measuredPowerTextField;
}


#pragma mark - CBPeripheralManagerDelegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral {
    [self jay_updateEmitterForDesiredState];
}


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
    }
    cell.textLabel.text = self.titleArray[indexPath.row];
    switch (indexPath.row) {
        case 0:
            cell.accessoryView = self.broadcastSwitch;
            break;
        case 1:
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@-%@", self.titleStr, self.UUID];
            break;
        case 2:
            cell.accessoryView = self.majorTextField;
            break;
        case 3:
            cell.accessoryView = self.minorTextField;
            break;
        case 4:
            cell.accessoryView = self.measuredPowerTextField;
            break;
        default:
            break;
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 1) {
        JAYUUIDListViewController *UUIDListViewController = [[JAYUUIDListViewController alloc] init];
        UUIDListViewController.selectUUIDFinished = ^(NSString * _Nonnull titleStr, NSString * _Nonnull UUID) {
            self.titleStr = titleStr;
            self.UUID = UUID;
            [self.tableView reloadData];
            [self jay_startBroadcast];
        };
        [self.navigationController pushViewController:UUIDListViewController animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}


#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.navigationItem.rightBarButtonItem = self.doneButton;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.majorTextField) {
        self.major = [self.majorTextField.text integerValue];
    } else if (textField == self.minorTextField) {
        self.minor = [self.minorTextField.text integerValue];
    } else if (textField == self.measuredPowerTextField) {
        self.measuredPower = [self.measuredPowerTextField.text integerValue];
    }
    
    self.navigationItem.rightBarButtonItem = nil;
    [self jay_updateEmitterForDesiredState];
}

@end
