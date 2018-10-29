# cordova-plugin-apply-pay-provision
==========================================

This plugin provide required functionality to provision your cards into iOS Wallet for Apple Pay in-app provisioning.

---------------
## Installation

    $ cordova plugin add https://github.com/abdalla-magdi/cordova-plugin-apply-pay-provision.git

----------------------
## Supported Platforms

- iOS

-----------
### Methods

- checkDeviceEligibility
- checkCardEligibility
- checkCardEligibilityBySuffix
- addCardToWallet
- sendPassRequestData

--------------------------------------------------------
#### checkDeviceEligibility(callback)

Check if your iOS device has secure elements to be eligible for card in-app provisioning.

##### Parameters

- __callback__ (Function) A callback method to receive the boolean result asynchronously from the native plugin

##### Usage

```javascript
    function isDeviceEligibleCallback(boolean) {
        if (boolean) {
            console.log("Device is Eligible for Apple Pay");
        } else {
            console.log("Device is not Eligible for Apply Pay");
        }
    }

    ApplePayProvision.checkDeviceEligibility(isDeviceEligibleCallback, errorCallback);
```

##### Supported Platforms

- iOS

-----------------------------------------------------
#### checkCardEligibility(primaryAccountIdentifier, callback)

Check if your card already added to all of your connected iOS for ex: your iPhone or the Apple Watch connected to this iPhone.

##### Parameters
- __primaryAccountIdentifier__ (String) Your card unique identifier that used in card in-app provisioning
- __callback__ (Function) A callback method to receive the boolean result asynchronously from the native plugin

##### Usage

```javascript
function isCardEligibleCallback(boolean) {
    if (boolean) {
        console.log("Card is Eligible for Apple Pay");
    } else {
        console.log("Card Already provisioned in Apply Pay or not supported");
    }
}

ApplePayProvision.checkCardEligibility(primaryAccountIdentifier, isCardEligibleCallback, errorCallback);
```

##### Supported Platforms

- iOS

-----------------------------------------------------
#### checkCardEligibilityBySuffix(cardSuffix, callback)

Check if your card already added to all of your connected iOS for ex: your iPhone or the Apple Watch connected to this iPhone.

##### Parameters
- __cardSuffix__ (String) The card number suffix ex: last 4 or 6 digits
- __callback__ (Function) A callback method to receive the boolean result asynchronously from the native plugin

##### Usage

```javascript
function isCardEligibleCallbackBySuffix(boolean) {
if (boolean) {
console.log("Card is Eligible for Apple Pay");
} else {
console.log("Card Already provisioned in Apply Pay or not supported");
}
}

ApplePayProvision.checkCardEligibility(cardSuffix, isCardEligibleCallback, errorCallback);
```

##### Supported Platforms

- iOS

-----------------------------------------------------
#### addCardToWallet(primaryAccountIdentifier, cardholderName, primaryAccountNumberSuffix, localizedDescription, paymentNetwork, callback)

Send Request to device Wallet to add this card to Apple Pay payment system and get Cryptography Info form Apple, the callback for this function will be called when nonce, nonceSignature and certificates retrived from Apple.

##### Parameters
- __primaryAccountIdentifier__ (String) Your card unique identifier that used in card in-app provisioning, can be sent as empty value if this info is not available
- __cardholderName__ (String) The name of the person the card is issued to
- __primaryAccountNumberSuffix__ (String) The last four or five digits of the PAN. Presented to the user with dots prepended to indicate that it is a suffix, This must not be the entire PAN
- __localizedDescription__ (String) A short description of the card
- __paymentNetwork__ (String) Filters the networks shown in the introduction view to this single network
- __callback__ (Function) A callback method to receive the array result of Cryptography Info asynchronously from the native plugin, the cryptographyInfo is an contains following three values: nonce, nonceSignature and certificates array

##### Usage

```javascript
function addCardToWalletCallback(nonce, nonceSignature, ...certificates) {
    console.log("Got card cryptographyInfo successfully from Wallet");
    // Send those values (nonce, nonceSignature, certificates[] to your Issuer server to preprate the pass data requested in method sendPassRequestData

}

ApplePayProvision.addCardToWallet(primaryAccountIdentifier, cardholderName, primaryAccountNumberSuffix, localizedDescription, paymentNetwork, addCardToWalletCallback, errorCallback);
```

##### Supported Platforms

- iOS

-----------------------------------------------------
#### sendPassRequestData(encryptedPassData, activationData, wrappedKey, callback)

Send Request to device Wallet to add this card to Apple Pay payment system, the callback for this function will be called when result of card provisiong got from Apple.

##### Parameters
- __encryptedPassData__ (String) The ciphertext containing the card data, nonce, and nonce signature generated by the Issuer Server
- __activationData__ (String) The cryptographic OTP required to activate the card by the Network
- __wrappedKey__ (String) Randomly generated AES-256 bit key encrypted with decryptor's public key
- __callback__ (Function) A callback method to receive the boolean result asynchronously from the native plugin

##### Usage

```javascript
function sendPassRequestDataCallback(boolean) {
    if (boolean) {
        console.log("Card Pass Data Added successfully to Wallet");
    } else {
        console.log("Card failed to be added to Wallet");
    }
}

ApplePayProvision.sendPassRequestData(encryptedPassData, activationData, wrappedKey, sendPassRequestDataCallback, errorCallback);
```

##### Supported Platforms

- iOS

-----------------------------------------------------
