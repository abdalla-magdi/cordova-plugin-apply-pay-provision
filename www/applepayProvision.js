var argscheck = require('cordova/argscheck'),
               exec = require('cordova/exec');

var applepayProvision = {
	checkDeviceEligibility: function(successCallback, errorCallback){
		exec(successCallback, errorCallback, "ApplePayProvision", "checkDeviceEligibility", []);
	},
	checkCardEligibility: function(primaryAccountIdentifier, successCallback, errorCallback) {
		exec(successCallback, errorCallback, "ApplePayProvision", "checkCardEligibility", [primaryAccountIdentifier]);
	},
	addCardToWallet: function(primaryAccountIdentifier, cardholderName, primaryAccountNumberSuffix, localizedDescription, paymentNetwork, successCallback, errorCallback) {
		exec(successCallback, errorCallback, "ApplePayProvision", "addCardToWallet", [primaryAccountIdentifier, cardholderName, primaryAccountNumberSuffix, localizedDescription, paymentNetwork]);
	},
	sendPassRequestData: function(encryptedPassData, activationData, wrappedKey, successCallback, errorCallback){
		exec(successCallback, errorCallback, "ApplePayProvision", "sendPassRequestData", [encryptedPassData, activationData, wrappedKey]);
	}
};

module.exports = applepayProvision;