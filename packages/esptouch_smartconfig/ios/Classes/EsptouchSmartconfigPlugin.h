#import <Flutter/Flutter.h>
#import <Foundation/Foundation.h>
#import "ESPViewController.h"
#import "ESPTouchTask.h"
#import "ESPTouchResult.h"
#import "ESP_NetUtil.h"
#import "ESPTouchDelegate.h"
#import "ESPAES.h"
#import "ESPTouchTaskParameter.h"

@interface EsptouchSmartconfigPlugin : NSObject<FlutterPlugin>

@end


@interface EspTouchSmartConfig : NSObject <ESPTouchDelegate>

@property(nonatomic, strong) NSCondition *_condition;
@property(atomic, strong) ESPTouchTask *_esptouchTask;
@property NSString *bssid;
@property NSString *ssid;
@property NSString *password;
@property int deviceCount;
@property BOOL isBroad;

- (id)initWithSSID:(NSString *)ssid
            andBSSID:(NSString *)bssid
        andPassword:(NSString *)password
  andDeviceCount:(NSString *)deviceCount
      withBroadcast:(NSString *)isBroad;

- (void)listen:(FlutterEventSink)sink;

- (void)cancel;

@end

@interface FlutterEventChannelHandler : NSObject <FlutterStreamHandler>

@property EspTouchSmartConfig *smartConfig;

@end
