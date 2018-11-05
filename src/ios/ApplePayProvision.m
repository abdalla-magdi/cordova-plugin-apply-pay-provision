//
//  ApplePayProvision.m
//  Copyright (c) 2018 Abdalla Magdi Soliman
//

#import "Cordova/CDV.h"
#import "Cordova/CDVViewController.h"
#import "ApplePayProvision.h"

@implementation ApplePayProvision

// Plugin Method - checkDeviceEligibility
- (void) checkDeviceEligibility:(CDVInvokedUrlCommand*)command  {
    CDVPluginResult *pluginResult;    
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[PKAddPaymentPassViewController canAddPaymentPass]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// Plugin Method - checkCardEligibility
- (void) checkCardEligibility:(CDVInvokedUrlCommand*)command {
    NSString * cardIdentifier = [command.arguments objectAtIndex:0];
    Boolean cardEligible = true;
    Boolean cardAddedtoPasses = false;
    Boolean cardAddedtoRemotePasses = false;
    
    PKPassLibrary *passLibrary = [[PKPassLibrary alloc] init];
    NSArray<PKPass *> *paymentPasses = [passLibrary passesOfType:PKPassTypePayment];
    for (PKPass *pass in paymentPasses) {
         PKPaymentPass * paymentPass = [pass paymentPass];
        if([paymentPass primaryAccountIdentifier] == cardIdentifier)
            cardAddedtoPasses = true;
    }
    
    if (WCSession.isSupported) { // check if the device support to handle an Apple Watch
        WCSession *session = [WCSession defaultSession];
        [session setDelegate:self.appDelegate];
        [session activateSession];
        
        if ([session isPaired]) { // Check if the iPhone is paired with the Apple Watch
            paymentPasses = [passLibrary remotePaymentPasses];
            for (PKPass *pass in paymentPasses) {
                PKPaymentPass * paymentPass = [pass paymentPass];
                if([paymentPass primaryAccountIdentifier] == cardIdentifier)
                    cardAddedtoRemotePasses = true;
            }
        }
        else
            cardAddedtoRemotePasses = true;
    }
    else
        cardAddedtoRemotePasses = true;

    cardEligible = !cardAddedtoPasses || !cardAddedtoRemotePasses;
    
    CDVPluginResult *pluginResult;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:cardEligible];
    //pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:[passLibrary canAddPaymentPassWithPrimaryAccountIdentifier:cardIdentifier]];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// Plugin Method - checkCardEligibilityBySuffix
- (void) checkCardEligibilityBySuffix:(CDVInvokedUrlCommand*)command {
    NSString * cardSuffix = [command.arguments objectAtIndex:0];
    Boolean cardEligible = true;
    Boolean cardAddedtoPasses = false;
    Boolean cardAddedtoRemotePasses = false;
    
    PKPassLibrary *passLibrary = [[PKPassLibrary alloc] init];
    NSArray<PKPass *> *paymentPasses = [passLibrary passesOfType:PKPassTypePayment];
    for (PKPass *pass in paymentPasses) {
        PKPaymentPass * paymentPass = [pass paymentPass];
        if([paymentPass primaryAccountNumberSuffix] == cardSuffix)
            cardAddedtoPasses = true;
    }
    
    if (WCSession.isSupported) { // check if the device support to handle an Apple Watch
        WCSession *session = [WCSession defaultSession];
        [session setDelegate:self.appDelegate];
        [session activateSession];
        
        if ([session isPaired]) { // Check if the iPhone is paired with the Apple Watch
            paymentPasses = [passLibrary remotePaymentPasses];
            for (PKPass *pass in paymentPasses) {
                PKPaymentPass * paymentPass = [pass paymentPass];
                if([paymentPass primaryAccountNumberSuffix] == cardSuffix)
                    cardAddedtoRemotePasses = true;
            }
        }
        else
            cardAddedtoRemotePasses = true;
    }
    else
        cardAddedtoRemotePasses = true;
    
    cardEligible = !cardAddedtoPasses || !cardAddedtoRemotePasses;
    
    CDVPluginResult *pluginResult;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:cardEligible];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// Plugin Method - addCardToWallet
- (void) addCardToWallet:(CDVInvokedUrlCommand*)command {
    
    // cache call back id value till we get response from Apple with Cryptography Info
    self.cachedCallbackId =  command.callbackId;
    
    NSString * primaryAccountIdentifier = [command.arguments objectAtIndex:0];
    NSString * cardholderName = [command.arguments objectAtIndex:1];
    NSString * primaryAccountNumberSuffix = [command.arguments objectAtIndex:2];
    NSString * localizedDescription = [command.arguments objectAtIndex:3];
    NSString * paymentNetwork = [command.arguments objectAtIndex:4];
    
    PKAddPaymentPassRequestConfiguration *addPaymentPassRequestConfiguration = [PKAddPaymentPassRequestConfiguration alloc];
    addPaymentPassRequestConfiguration = [addPaymentPassRequestConfiguration initWithEncryptionScheme:PKEncryptionSchemeRSA_V2];
    [addPaymentPassRequestConfiguration setCardholderName:cardholderName];
    [addPaymentPassRequestConfiguration setPrimaryAccountSuffix:primaryAccountNumberSuffix];
    [addPaymentPassRequestConfiguration setLocalizedDescription:localizedDescription];
    if(![primaryAccountIdentifier isEqualToString:@""])
        [addPaymentPassRequestConfiguration setPrimaryAccountIdentifier:primaryAccountIdentifier];
    [addPaymentPassRequestConfiguration setPaymentNetwork:paymentNetwork];
    
    PKAddPaymentPassViewController * paymentPassViewController = [PKAddPaymentPassViewController alloc];
    paymentPassViewController = [paymentPassViewController initWithRequestConfiguration:addPaymentPassRequestConfiguration delegate:self];
    [self.viewController presentViewController:paymentPassViewController animated:true completion:nil];
    
}

// PKAddPaymentPassViewControllerDelegate implmentation
- (void)addPaymentPassViewController:(PKAddPaymentPassViewController *)controller
 generateRequestWithCertificateChain:(NSArray<NSData *> *)certificates
                               nonce:(NSData *)nonce
                      nonceSignature:(NSData *)nonceSignature
                   completionHandler:(void (^)(PKAddPaymentPassRequest *request))handler{
    
    //NSString* nonceString = [nonce base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];
    //NSString* nonceSignatureString = [nonceSignature base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn];

    NSString* nonceString = [self dataToHexString:nonce];
    NSString* nonceSignatureString = [self dataToHexString:nonceSignature];
    
    NSMutableArray *certificatesArray = [[NSMutableArray alloc] init];
    NSMutableArray *cryptographyInfo = [[NSMutableArray alloc] init];
    [cryptographyInfo addObject:nonceString];
    [cryptographyInfo addObject:nonceSignatureString];
    
    for (NSData* certificate in certificates)
    {
        [certificatesArray addObject:[certificate base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithCarriageReturn]];
    }
    
    [cryptographyInfo addObject:certificatesArray];

    self.addPaymentRequestCallback = handler;
    
    CDVPluginResult *pluginResult;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsMultipart:cryptographyInfo];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.cachedCallbackId];
    // Call Backend service send to it certificates, nonce, nonceSignature
    // Backedend service should response with encrypted data object, activation OTP and Wrappedkey and call sendPassRequestData to create PKAddPaymentPassRequest object

}

- (NSString *)dataToHexString:(NSData *)data {
    const unsigned char *bytes = (const unsigned char *)data.bytes;
    NSMutableString *hex = [NSMutableString new];
    for (NSInteger i = 0; i < data.length; i++) {
        [hex appendFormat:@"%02x", bytes[i]];
    }
    return [hex copy];
}

// Plugin Method - addCardToWallet
- (void) sendPassRequestData:(CDVInvokedUrlCommand*)command {
    
    NSData * encryptedPassData = [[NSData alloc] initWithBase64EncodedString:[command.arguments objectAtIndex:0] options:0];
    NSData * activationData = [[NSData alloc] initWithBase64EncodedString:[command.arguments objectAtIndex:1] options:0];
    NSData * wrappedKey = [[NSData alloc] initWithBase64EncodedString:[command.arguments objectAtIndex:2] options:0];
    
    PKAddPaymentPassRequest * addPaymentPassRequest = [[PKAddPaymentPassRequest alloc] init];
    [addPaymentPassRequest setEncryptedPassData:encryptedPassData];
    [addPaymentPassRequest setActivationData:activationData];
    [addPaymentPassRequest setWrappedKey:wrappedKey];
    self.addPaymentRequestCallback(addPaymentPassRequest);
    
    // cache call back id value till we get response from Apple with Payment Pass status
    self.cachedCallbackId =  command.callbackId;
    
}

- (void)addPaymentPassViewController:(nonnull PKAddPaymentPassViewController *)controller
          didFinishAddingPaymentPass:(nullable PKPaymentPass *)pass
                               error:(nullable NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    CDVPluginResult *pluginResult;
    if(pass == nil)
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsBool:false];
    else
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:true];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.cachedCallbackId];
}

@end
