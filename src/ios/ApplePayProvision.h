//
//  ApplePayProvision.h
//  Copyright (c) 2018 Abdalla Magdi Soliman
//

#import "Foundation/Foundation.h"
#import "Cordova/CDV.h"
#import <PassKit/PassKit.h>

typedef void (^ AddPaymentRequestCallbackType)(PKAddPaymentPassRequest *request);

@interface ApplePayProvision : CDVPlugin<PKAddPaymentPassViewControllerDelegate>

- (void) checkDeviceEligibility:(CDVInvokedUrlCommand*)command;
- (void) checkCardEligibility:(CDVInvokedUrlCommand*)command;
- (void) addCardToWallet:(CDVInvokedUrlCommand*)command;
- (void) sendPassRequestData:(CDVInvokedUrlCommand*)command;

@property (nonatomic, strong) NSString* cachedCallbackId;
@property (nonatomic) AddPaymentRequestCallbackType addPaymentRequestCallback;

@end
