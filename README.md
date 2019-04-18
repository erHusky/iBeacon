# iBeacon


## 依赖及必要配置 

- iBeacon 用到了 `CLLocation.framework` 和 `CLBluetooth.framework`，使用时需导入。此外，需要在 `Info.plist` 文件中添加 `Privacy - Location Usage Description` 描述信息。
- 使用时需开启定位及蓝牙，Demo 中未对蓝牙开启进行判断。
- 信号发射方与接收方的 UUID **必须保持一致**。


## 手机作为信号发射器

使用 `CBPeripheralManager` 创建并广播信号。

**创建 `_peripheraManager` 对象：**

```objc
_peripheraManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
```

**广播信号：**

```objc
NSDictionary *peripheralData = nil;
CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:UUID major:0 minor:1 identifier:@"identifier"];
// 设置信号强度，值为负数，约接近 0 信号越强
peripheralData = [region peripheralDataWithMeasuredPower:[NSNumber numberWithInteger:self.measuredPower]];
if (peripheralData) {
    [self.peripheraManager startAdvertising:peripheralData];
}
```


- `proximityUUID`: 是一个 NSUUID，用来作为唯一标识。每个单位、组织使用的 Beacon 应该拥有同样的 proximityUUID。
- `major`: 主要值，用来识别一组相关联的 Beacon。例如在连锁超市的场景中，每个分店的 Beacon 应该拥有同样的 major。
- `minor`: 次要值，则用来区分某个特定的 Beacon。

`proximityUUID`、`major`、`minor` 这三个属性组成 iBeacon 的唯一标识符。

**停止广播信号：**

```objc
[_peripheralManager stopAdvertising];
```



## 手机作为信号接收器

手机作为信号接收器，有两种模式来接收 iBeacon 信号：`Monitoring`、`Ranging`。本 Demo 由于尚未实现 `Monitoring` 模式，因此请暂时忽略。

- `Monitoring`: 可以用来在设备**进入/退出**某个地理区域时获得通知，使用这种方法可以在应用程序的后台运行时检测 iBeacon，但是只能同时检测 20 个 region 区域，并且不能够推测设备与 iBeacon 的距离。
- `Ranging`: iOS 7 之后提供的 API，用于确定设备的近似距离 iBeacon 技术，可以用来检测某区域内的**所有** iBeacons，并且可以精度估计发射者与接收者的距离，这个使用如下四中接近状态来表示:

```objc
typedef NS_ENUM(NSInteger, CLProximity) {
	CLProximityUnknown,    // 无效
	CLProximityImmediate,  // 极其接近（几厘米范围内）
	CLProximityNear,       // 较近（几米范围内）
	CLProximityFar         // 较远（10米以外）
} API_AVAILABLE(ios(7.0)) API_UNAVAILABLE(watchos, tvos);
```

**创建 `CLLocationManager` 对象:**

```objc
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}
```
不要忘记添加 `<CLLocationManagerDelegate>`

**创建 `CLBeaconRegion` 对象:**

```objc
- (CLBeaconRegion *)beaconRegion {
    if (!_beaconRegion) {
        _beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:UUIDString] identifier:@"identifier"];
        _beaconRegion.notifyEntryStateOnDisplay = YES;
        _beaconRegion.notifyOnExit = YES;
        _beaconRegion.notifyOnEntry = YES;
    }
    return _beaconRegion;
}
```

**`CLBeaconRegion` 提供了 3 种初始化方法，可根据实际业务进行选择:**

```objc
// 监听该 UUID 下的所有 Beacon 设备
- (instancetype)initWithProximityUUID:(NSUUID *)proximityUUID identifier:(NSString *)identifier;
// 监听该 UUID，major 下的所有 Beacon 设备
- (instancetype)initWithProximityUUID:(NSUUID *)proximityUUID major:(CLBeaconMajorValue)major identifier:(NSString *)identifier;
// 监听唯一的 Beacon 设备
- (instancetype)initWithProximityUUID:(NSUUID *)proximityUUID major:(CLBeaconMajorValue)major minor:(CLBeaconMinorValue)minor identifier:(NSString *)identifier;

```

在开始监控之前，我们需要使用 `isMonitoringAvailableForClass` 判断设备是否支持，是否允许访问地理位置。

```objc
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
        case kCLAuthorizationStatusAuthorizedWhenInUse: {
            // 使用 Ranging 模式
            [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];
            // 使用 Monitoring 模式 
            // [self.locationManager startMonitoringForRegion:self.beaconRegion];
        }
        break;
    }
} else {
    NSLog(@"该设备不支持 CLBeaconRegion 区域检测");
}
```

**使用 `Monitoring` 模式监听**

```objc
// 开始检测区域
[self.locationManager startMonitoringForRegion:beaconRegion]; 
// 停止检测区域
[self.locationManager stopMonitoringForRegion:beaconRegion]; 
```

CLLocationManagerDelegate:

```objc
// Monitoring 成功对应回调函数
- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region;
// 设备进入该区域时的回调
- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region;
// 设备退出该区域时的回调
- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region;
// Monitoring 有错误产生时的回调
- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(nullable CLRegion *)region withError:(NSError *)error;

```


**使用 `Ranging` 模式监听**

```objc
// 开始检测区域
[self.locationManager startRangingBeaconsInRegion:beaconRegion];
// 停止检测区域
[self.locationManager stopRangingBeaconsInRegion:beaconRegion];
```

CLLocationManagerDelegate:

```objc
// Ranging成功对应回调函数
// 此处的 beacons 即为监听到的所有 Beacon 设备
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray<clbeacon *> *)beacons inRegion:(CLBeaconRegion *)region;
// Ranging有错误产生时的回调
- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error;

```

**`CLBeacon` 重要属性:**

- `proximityUUID`: 是一个 NSUUID，用来作为唯一标识。每个单位、组织使用的 Beacon 应该拥有同样的 proximityUUID。
- `major`: 主要值，用来识别一组相关联的 Beacon。例如在连锁超市的场景中，每个分店的 Beacon 应该拥有同样的 major。
- `minor`: 次要值，则用来区分某个特定的 Beacon。
- `proximity`: 远近范围，一个 CLProximity 枚举值。
- `accuracy`: 与 iBeacon 设备的距离。
- `rssi`: 信号强度，为负值，越接近 0 信号越强，等于 0 时无法获取信号强度。

```objc
typedef NS_ENUM(NSInteger, CLProximity) {
	CLProximityUnknown,    // 无效
	CLProximityImmediate,  // 极其接近（几厘米范围内）
	CLProximityNear,       // 较近（几米范围内）
	CLProximityFar         // 较远（10米以外）
} API_AVAILABLE(ios(7.0)) API_UNAVAILABLE(watchos, tvos);
```



## 应用举例

以宿舍签到为例：

1. 舍长与舍友成员向服务端发起请求，获取签到必要信息：`proximityUUID`,`major`,`minor`
2. 舍长使用手机作为信号发射器
3. 舍友使用手机作为信号接收器进行扫描
4. 舍友扫描到舍长的设备，向服务器发送签到请求
5. 完成签到

