//
//  ContinueLayer.h
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MyPopupLayer.h"
#import "AdTapsy.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface ContinueLayer : MyPopupLayer <UIAlertViewDelegate, AdTapsyDelegate>{
    float livesTime;
    NSInteger livesTimeCounter;

    CCLabelTTF *timeToContinueLabel;
    
    NSInteger sceneType;
    bool m_postingInProgress;
}

@property NSInteger sceneType;
@property (nonatomic, strong)GADInterstitial *interstitial;

+(CCScene *) scene;

-(void) closeHandler;
-(void) facebookHandler;
-(void) packHandler;
-(void) buyHandler;
-(void) updateTime;
-(void) appRestored;


-(void)adtapsyDidEarnedReward:(BOOL)success andAmount:(int)amount;
-(void)adtapsyDidCachedInterstitialAd;
-(void)adtapsyDidCachedRewardedVideoAd;
-(void)adtapsyDidClickedInterstitialAd;
-(void)adtapsyDidClickedRewardedVideoAd;
-(void)adtapsyDidFailedToShowInterstitialAd;
-(void)adtapsyDidFailedToShowRewardedVideoAd;
-(void)adtapsyDidShowInterstitialAd;
-(void)adtapsyDidShowRewardedVideoAd;
-(void)adtapsyDidSkippedInterstitialAd;
-(void)adtapsyDidSkippedRewardedVideoAd;

-(void) postWithText: (NSString*) message
           ImageName: (NSString*) image
                 URL: (NSString*) url
             Caption: (NSString*) caption
                Name: (NSString*) name
      andDescription: (NSString*) description;
-(void) postToWall: (NSMutableDictionary*) params;


@end
