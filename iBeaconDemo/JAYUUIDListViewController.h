//
//  JAYUUIDListViewController.h
//  iBeaconDemo
//
//  Created by Smiley on 2019/4/17.
//  Copyright © 2019 Smiley. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SelectUUIDFinished)(NSString *titleStr, NSString *UUID);

@interface JAYUUIDListViewController : UIViewController

@property (nonatomic, copy) SelectUUIDFinished selectUUIDFinished;

@end

NS_ASSUME_NONNULL_END
