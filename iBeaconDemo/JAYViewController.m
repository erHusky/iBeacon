//
//  ViewController.m
//  iBeaconDemo
//
//  Created by Smiley on 2019/4/17.
//  Copyright © 2019 Smiley. All rights reserved.
//

#import "JAYViewController.h"
#import "Masonry/Masonry.h"
#import "JAYBroadcastingViewController.h"
#import "JAYScanningViewController.h"

@interface JAYViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation JAYViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self jay_setupUserInterface];
}

- (void)jay_setupUserInterface {
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


#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"广播";
    } else {
        cell.textLabel.text = @"扫描";
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:{
            JAYBroadcastingViewController *broadcastingViewController = [[JAYBroadcastingViewController alloc] init];
            [self.navigationController pushViewController:broadcastingViewController animated:YES];
        }
            break;
        case 1: {
            JAYScanningViewController *scanningViewController = [[JAYScanningViewController alloc] init];
            [self.navigationController pushViewController:scanningViewController animated:YES];
        }
            break;
        default:
            break;
    }
}

@end
