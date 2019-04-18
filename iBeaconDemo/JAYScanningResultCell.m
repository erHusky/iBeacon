//
//  JAYScanningResultCell.m
//  iBeaconDemo
//
//  Created by Smiley on 2019/4/17.
//  Copyright © 2019 Smiley. All rights reserved.
//

#import "JAYScanningResultCell.h"

@interface JAYScanningResultCell ()

@property (nonatomic, strong) UILabel *proximityUUIDLabel;
@property (nonatomic, strong) UILabel *majorLabel;
@property (nonatomic, strong) UILabel *minorLabel;
@property (nonatomic, strong) UILabel *proximityLabel;
@property (nonatomic, strong) UILabel *accuracyLabel;
@property (nonatomic, strong) UILabel *rssiLabel;

@end

@implementation JAYScanningResultCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.proximityUUIDLabel = [self jay_createLabel];
        [self.contentView addSubview:self.proximityUUIDLabel];
        self.majorLabel = [self jay_createLabel];
        [self.contentView addSubview:self.majorLabel];
        self.minorLabel = [self jay_createLabel];
        [self.contentView addSubview:self.minorLabel];
        self.proximityLabel = [self jay_createLabel];
        [self.contentView addSubview:self.proximityLabel];
        self.accuracyLabel = [self jay_createLabel];
        [self.contentView addSubview:self.accuracyLabel];
        self.rssiLabel = [self jay_createLabel];
        [self.contentView addSubview:self.rssiLabel];
    }
    return self;
}

- (void)setBeacon:(CLBeacon *)beacon {
    _beacon = beacon;
    self.proximityUUIDLabel.text = [NSString stringWithFormat:@"ProximityUUID: %@", beacon.proximityUUID.UUIDString];
    self.majorLabel.text = [NSString stringWithFormat:@"Major: %@", beacon.major];
    self.minorLabel.text = [NSString stringWithFormat:@"Minor: %@", beacon.minor];
    switch (beacon.proximity) {
        case CLProximityUnknown:
            self.proximityLabel.text = [NSString stringWithFormat:@"Proximity: CLProximityUnknown(未知距离)"];
            break;
        case CLProximityImmediate:
            self.proximityLabel.text = [NSString stringWithFormat:@"Proximity: CLProximityImmediate(极度接近)"];
            break;
        case CLProximityNear:
            self.proximityLabel.text = [NSString stringWithFormat:@"Proximity: CLProximityNear(距离较近)"];
            break;
        case CLProximityFar:
            self.proximityLabel.text = [NSString stringWithFormat:@"Proximity: CLProximityFar(距离较近)"];
            break;
        default:
            break;
    }
    self.accuracyLabel.text = [NSString stringWithFormat:@"Accuracy: %@", @(beacon.accuracy)];
    self.rssiLabel.text = [NSString stringWithFormat:@"RSSI: %@", @(beacon.rssi)];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat labelHeight = JAYScanningResultCell_CellHeight / 6;
    CGFloat labelWidth = [UIScreen mainScreen].bounds.size.width - 30.0;
    self.proximityUUIDLabel.frame = CGRectMake(15.0, 0, labelWidth, labelHeight);
    self.majorLabel.frame = CGRectMake(15.0, labelHeight, labelWidth, labelHeight);
    self.minorLabel.frame = CGRectMake(15.0, labelHeight * 2, labelWidth, labelHeight);
    self.proximityLabel.frame = CGRectMake(15.0, labelHeight * 3, labelWidth, labelHeight);
    self.accuracyLabel.frame = CGRectMake(15.0, labelHeight * 4, labelWidth, labelHeight);
    self.rssiLabel.frame = CGRectMake(15.0, labelHeight * 5, labelWidth, labelHeight);
}

- (UILabel *)jay_createLabel {
    UILabel *label = [[UILabel alloc] init];
    return label;
}

@end
