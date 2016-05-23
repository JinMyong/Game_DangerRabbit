//
//  StoreObserver.m
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import "StoreObserver.h"
#import "GameKit/GKScore.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "GameController.h"
#import "Constants.h"

@implementation StoreObserver
@synthesize delegate;

- (void) failedTransaction: (SKPaymentTransaction *)transaction {
    if (transaction.error.code != SKErrorPaymentCancelled) {
		NSLog(@"transaction.error: %@", [transaction.error localizedDescription]);
        [delegate transactionDidError:transaction.error];
    }
    else {
        AppController *appDelegate = (AppController *) [[UIApplication sharedApplication] delegate];
        [appDelegate cancelLoadingAlert];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction  {
	
}

- (void)provideContent:(NSString *)identifier {
	
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction {
    AppController *appDelegate = (AppController *) [[UIApplication sharedApplication] delegate];
    GameController *gC = [GameController sharedGameCtrl];
    if([transaction.payment.productIdentifier isEqualToString:kAppleID_UnlockAllLevels]) {
        [appDelegate logEvent:@"Purshase Unlock All Levels"];
        gC.wasPurchase = YES;
        [gC unlockAllWorlds];
        
        [appDelegate.kochavaTracker trackEvent:@"inAppPurchase" :@"Unlock All Levels"];
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Enjoy"
                                                            message:@"You have got Unlock all worlds!"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
        [alertView release];
	}
    else if([transaction.payment.productIdentifier isEqualToString:kAppleID_1kCarrots]) {
        [appDelegate logEvent:@"Purshase 1000 carrots"];
        gC.wasPurchase = YES;
        [gC addCoins:1000];
        [appDelegate.kochavaTracker trackEvent:@"inAppPurchase" :@"1000 carrots"];
	}
    else if([transaction.payment.productIdentifier isEqualToString:kAppleID_2kCarrots]) {
        [appDelegate logEvent:@"Purshase 2000 carrots"];
        gC.wasPurchase = YES;
        [gC addCoins:2000];
        [appDelegate.kochavaTracker trackEvent:@"inAppPurchase" :@"2000 carrots"];
	}
    else if([transaction.payment.productIdentifier isEqualToString:kAppleID_4kCarrots]) {
        [appDelegate logEvent:@"Purshase 4000 carrots"];
        gC.wasPurchase = YES;
        [gC addCoins:4000];
        [appDelegate.kochavaTracker trackEvent:@"inAppPurchase" :@"4000 carrots"];
	}
    else if([transaction.payment.productIdentifier isEqualToString:kAppleID_5Continues]) {
        [appDelegate logEvent:@"Purshase 5 continues"];
        gC.wasPurchase = YES;
        [appDelegate addLives:kLivesBonus * 5];
        [appDelegate.kochavaTracker trackEvent:@"inAppPurchase" :@"5 continues"];
	}
    else if([transaction.payment.productIdentifier isEqualToString:kAppleID_15Continues]) {
        [appDelegate logEvent:@"Purshase 15 continues"];
        gC.wasPurchase = YES;
        [appDelegate addLives:kLivesBonus * 15];
        [appDelegate.kochavaTracker trackEvent:@"inAppPurchase" :@"15 continues"];
	}
    else if([transaction.payment.productIdentifier isEqualToString:kAppleID_30Continues]) {
        [appDelegate logEvent:@"Purshase 30 continues"];
        gC.wasPurchase = YES;
        [appDelegate addLives:kLivesBonus * 30];
        [appDelegate.kochavaTracker trackEvent:@"inAppPurchase" :@"30 continues"];
	}
    else if([transaction.payment.productIdentifier isEqualToString:kAppleID_NextWorld]) {
        [appDelegate logEvent:@"Purshase unlock next world"];
        gC.wasPurchase = YES;
        [gC unlockNextWorld];
        [[NSNotificationCenter defaultCenter] postNotificationName:kWorldUnlockedNotification
                                                            object:nil];
        [appDelegate.kochavaTracker trackEvent:@"inAppPurchase" :@"Unlock next world"];
    }else if([transaction.payment.productIdentifier isEqualToString:kAppleID_UnlimitedLife]) {
        [appDelegate logEvent:@"Purshase Unlimit Lives"];
        gC.wasPurchase = YES;
        gC.isUnlimitedLife = true;
        gC.timeContinue = [NSDate dateWithTimeIntervalSince1970:0];
        [appDelegate addLives:kLivesBonus];
        [gC save];
        [appDelegate.kochavaTracker trackEvent:@"inAppPurchase" :@"15 continues"];
    }

    [self recordTransaction: transaction];
    [self provideContent: transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    [delegate transactionDidFinish:transaction.payment.productIdentifier];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction {
    [self recordTransaction: transaction];
    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    AppController *appDelegate = (AppController *) [[UIApplication sharedApplication] delegate];
    NSArray *ar = queue.transactions;
    for(NSInteger i = 0; i < [ar count]; ++i) {
        SKPaymentTransaction *transaction = (SKPaymentTransaction*)[ar objectAtIndex:i];

        GameController *gC = [GameController sharedGameCtrl];
        if([transaction.payment.productIdentifier isEqualToString:kAppleID_UnlockAllLevels]) {
            gC.wasPurchase = YES;
            [gC unlockAllWorlds];
            
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Enjoy"
                                                                message:@"You have got Unlock all worlds!"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
            [alertView release];
        }
        [delegate transactionDidFinish:transaction.payment.productIdentifier];
    }
    if([ar count] <= 0) {
        [appDelegate cancelLoadingAlert];
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    [delegate transactionDidError:error];
}

// SKProductsRequestDelegate
- (void)requestProUpgradeProductData: (NSString *) productID {
    NSSet *productIdentifiers = [NSSet setWithObject:productID];
    productsRequest = [[[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers] autorelease];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *products = response.products;
    proUpgradeProduct = [products count] == 1 ? [[products objectAtIndex:0] retain] : nil;
 
    if (proUpgradeProduct) {
        [[GameController sharedGameCtrl].listOfPrices setObject:proUpgradeProduct.localizedPrice forKey:proUpgradeProduct.productIdentifier];
        
        NSLog(@"Product price: %@" , proUpgradeProduct.localizedPrice);
        NSLog(@"Product id: %@" , proUpgradeProduct.productIdentifier);
    }
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers) {
        NSLog(@"Invalid product id: %@" , invalidProductId);
    }
    
    [[GameController sharedGameCtrl] save];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdatePrceNotification object:self userInfo:nil];
}

@end

@implementation SKProduct (LocalizedPrice)

- (NSString *)localizedPrice {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:self.price];
    [numberFormatter release];
    return formattedString;
}

@end