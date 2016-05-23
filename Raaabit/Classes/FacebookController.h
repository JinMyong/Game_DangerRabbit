//
//  FacebookController.h
//  Raaabit
//
//  Created by Dmitry Valov on 28.01.14.
//  Copyright Dmitry Valov 2014. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Constants.h"
#import <FacebookSDK/FacebookSDK.h>


#define kPicturesNotification           @"PicturesNotification"
#define kRequestsNotification           @"RequestsNotification"
#define kFriendsNotification            @"FriendsNotification"
#define kUsersLoadedNotification        @"UsersLoadedNotification"
#define kLoggedInNotification           @"LoggedInNotification"
#define kFBFriendInvitedNotification    @"FBFriendInvitedNotification"

#define kFBNameSpace                    @"dangerrabbit"
#define kMSGTypeInvite                  @"invite"
#define kMSGTypeLifeRequest             @"life_request"
#define kMSGTypeLifeResponse            @"life_response"
#define kMSGTypeLifeSend                @"life_send"

#define kAppURL             @"https://itunes.apple.com/app/id847953640"
#define kFBAppID            @"237915279688936"
#define kFBIcon             @"http://oi59.tinypic.com/ny74zk.jpg"

@class MyFBUser;

@protocol FBLoginDelegate <NSObject>

@required

-(void) OnFBSuccess;
-(void) OnFBFailed : (NSError *)error;

@end

@interface FacebookController : CCNode <FBLoginDelegate, UIAlertViewDelegate> {
    FBSession               *fbsession_;
    FBFrictionlessRecipientCache *friendCache_;
    
    NSMutableArray          *listOfFriends_;
    NSMutableArray          *listOfRequests_;
    
    NSString                *lastRequestID;
    
    NSString                *myFacebookID_;
    NSMutableArray          *listOfFBFriends_;
    bool                    fbScoreLoaded_;
    bool                    fbUsersLoaded_;
}

@property (strong, nonatomic) FBSession *fbsession;
@property (strong, nonatomic) FBFrictionlessRecipientCache *friendCache;
@property (nonatomic, assign) id <FBLoginDelegate> fbDelegate;
@property (nonatomic, assign) NSMutableArray *listOfFriends;
@property (nonatomic, assign) NSMutableArray *listOfRequests;
@property (nonatomic, assign) NSString *myFacebookID;
@property (nonatomic, retain) NSMutableArray  *listOfFBFriends;
@property bool fbScoreLoaded;
@property bool fbUsersLoaded;

+ (FacebookController*) sharedFacebookCtrl;

-(bool) isLoggedIn;
-(void) login;
-(void) logout;
-(void) loadParams;
-(void) loadScores;
-(void) postScore: (NSInteger) score;
-(void) retrieveFriendsDetails;
-(void) retriveMyFacebookID;
-(MyFBUser *) getMyFBUser;
-(void) inviteFriends;
-(void) retriveAllScoresForFriends;

-(void) createRequestTo: (NSString*) userID withType: (NSString*) type withText: (NSString*) text;
-(void) createRequestTo: (NSString*) userID withType: (NSString*) type withText: (NSString*) text withRequestID: (NSString*) requestID;
-(void) retrieveIncomingRequests;
-(void) deleteRequest: (NSString*) requestid;
-(void) deleteAllRequests;

-(void) postPassMessageWithFriendID: (NSString*) friendID
                         friendName: (NSString*) friendName
                        friendScore: (NSInteger) friendScore
                          yourScore: (NSInteger) yourScore;
-(void) postNewHighScoreMessageWithScore: (NSInteger) score;
-(void) postNewLevelMessageWithScore: (NSInteger) level;

-(void) postOpenGraphObject:(NSString*) fbUserID
					   path:(NSString*) path
					  title:(NSString*) title
					   data:(NSDictionary*) data;
-(void) retrieveOpenGraphObject:(NSString*) fbUserID
                       graphPath:(NSString*) graphPath;
-(void) deleteOpenGraphObject:(NSString*) fbUserID
                    graphPath:(NSString*) graphPath;
-(void) postScore: (NSInteger) score
         forLevel: (NSInteger) level;
-(NSArray *) getListOfScoresForLevel: (NSInteger) level;

@end
