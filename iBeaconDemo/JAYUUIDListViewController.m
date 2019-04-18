//
//  JAYUUIDListViewController.m
//  iBeaconDemo
//
//  Created by Smiley on 2019/4/17.
//  Copyright © 2019 Smiley. All rights reserved.
//

#import "JAYUUIDListViewController.h"
#import "Masonry/Masonry.h"

@interface JAYUUIDListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *UUIDArray;

@end

@implementation JAYUUIDListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self jay_setupUserInterface];
}

#pragma mark - Private Methods
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

#pragma mark - Getter
- (NSArray *)UUIDArray {
    if (!_UUIDArray) {
        _UUIDArray = @[@{@"Title": @"宿舍 A", @"UUID": @"CA54D516-60F4-11E9-8647-D663BD873D93"},
                       @{@"Title": @"宿舍 B", @"UUID": @"D2A331FB-5634-4D25-99F8-82BA547B0000"},
                       @{@"Title": @"宿舍 C", @"UUID": @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"},
                       @{@"Title": @"宿舍 D", @"UUID": @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"},
                       @{@"Title": @"宿舍 E", @"UUID": @"5B635E08-60C6-11E9-8647-D663BD873D93"}];
    }
    return _UUIDArray;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.UUIDArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    NSDictionary *dic = self.UUIDArray[indexPath.row];
    cell.textLabel.text = dic[@"Title"];
    cell.detailTextLabel.text = dic[@"UUID"];
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = self.UUIDArray[indexPath.row];
    if (_selectUUIDFinished) {
        _selectUUIDFinished(dic[@"Title"], dic[@"UUID"]);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
