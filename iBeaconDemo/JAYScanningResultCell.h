//
//  JAYScanningResultCell.h
//  iBeaconDemo
//
//  Created by Smiley on 2019/4/17.
//  Copyright © 2019 Smiley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

static CGFloat const JAYScanningResultCell_CellHeight = 192.0;

NS_ASSUME_NONNULL_BEGIN

@interface JAYScanningResultCell : UITableViewCell

@property (nonatomic, strong) CLBeacon *beacon;

@end

NS_ASSUME_NONNULL_END
