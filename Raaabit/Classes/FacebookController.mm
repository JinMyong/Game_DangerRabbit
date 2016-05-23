//
//  FacebookController.m
//  Raaabit
//
//  Created by Dmitry Valov on 28.01.14.
//  Copyright Dmitry Valov 2013. All rights reserved.
//

#import "FacebookController.h"
#import "AppDelegate.h"
#import "Constants.h"
#include <Social/Social.h>
#import "MyFBUser.h"
#import "MyFBRequest.h"
#import "MyFBLevelScore.h"
#import "PW_SBJsonWriter.h"
#import "GameController.h"

@implementation FacebookController

@synthesize fbsession = fbsession_;
@synthesize listOfFriends = listOfFriends_;
@synthesize listOfRequests = listOfRequests_;
@synthesize friendCache = friendCache_;
@synthesize myFacebookID = myFacebookID_;
@synthesize listOfFBFriends = listOfFBFriends_;
@synthesize fbScoreLoaded = fbScoresLoaded_;
@synthesize fbUsersLoaded = fbUsersLoaded_;

static FacebookController *facebookControllerInstance;

+(FacebookController*) sharedFacebookCtrl {
	return facebookControllerInstance;
}

-(id) init {
	if ((self = [super init]) != nil) {
		facebookControllerInstance = self;
        self.friendCache = [[FBFrictionlessRecipientCache alloc] init];
        
        fbScoreLoaded_ = NO;
        fbUsersLoaded_ = NO;
        
        self.listOfFBFriends = [[NSMutableArray alloc] init];
        self.listOfFriends = [[NSMutableArray alloc] init];
        self.listOfRequests = [[NSMutableArray alloc] init];
        
        if (!self.fbsession.isOpen) {
            // create a fresh session object
            self.fbsession = [[FBSession alloc] init];
            
            // if we don't have a cached token, a call to open here would cause UX for login to
            // occur; we don't want that to happen unless the user clicks the login button, and so
            // we check here to make sure we have a token before calling open
            if (self.fbsession.state == FBSessionStateCreatedTokenLoaded) {
                // even though we had a cached token, we need to login to make the session usable
                [self.fbsession openWithCompletionHandler:^(FBSession *session,
                                                            FBSessionState status,
                                                            NSError *error) {
                    // we recurse here, in order to update buttons and labels
                    [FBSession setActiveSession:session];
                    self.fbsession = session;
                }];
            }
            [self loadParams];
        }
        else {
            [self loadParams];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(retriveAllScoresForFriends)
                                                     name:kUsersLoadedNotification
                                                   object:nil];
	}
	return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.listOfFriends release];
    self.listOfFriends = nil;
    [self.listOfRequests release];
    self.listOfRequests = nil;
    [self.friendCache release];
    self.friendCache = nil;
    [self.listOfFBFriends release];
    self.listOfFBFriends = nil;

	[super dealloc];
}

#pragma mark - FB Misk

-(void)storeAuthData:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

-(void) OnFBSuccess {
    
}

-(void) OnFBFailed : (NSError *)error {
    
}

#pragma mark - FBSessionDelegate Methods
/**
 * Called when the user has logged in successfully.
 */
-(void)fbDidLogin {
    //	AppController *appDelegate = (AppController *) [[UIApplication sharedApplication] delegate];
    //    [self storeAuthData:[[delegate facebook] accessToken] expiresAt:[[delegate facebook] expirationDate]];
}

-(void)fbDidExtendToken:(NSString *)accessToken expiresAt:(NSDate *)expiresAt {
    NSLog(@"token extended");
    [self storeAuthData:accessToken expiresAt:expiresAt];
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
}

/**
 * Called when the request logout has succeeded.
 */
-(void)fbDidLogout {
    // Remove saved authorization information if it exists and it is
    // ok to clear it (logout, session invalid, app unauthorized)
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

/**
 * Called when the session has expired.
 */
-(void)fbSessionInvalidated {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:@"Auth Exception"
                              message:@"Your session has expired."
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil,
                              nil];
    [alertView show];
    [alertView release];
    [self fbDidLogout];
}

#pragma mark - Login Methods

-(bool) isLoggedIn {
    if (self.fbsession.isOpen) {
        return YES;
    }
    return NO;
}

-(void) login {
    if (!self.fbsession.isOpen) {
        if (self.fbsession.state != FBSessionStateCreated) {
            self.fbsession = [[FBSession alloc] init];
        }
        
//        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Connect on Facebook for 200 extra carrots!"
//                                                            message:@""
//                                                           delegate:self
//                                                  cancelButtonTitle:@"Cancel"
//                                                  otherButtonTitles:@"Confirm", nil];
//        [alertView show];
//        [alertView release];

        // if the session isn't open, let's open it now and present the login UX to the user
        [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"]
                                           defaultAudience:FBSessionDefaultAudienceFriends
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                             
                                             [[NSNotificationCenter defaultCenter] postNotificationName:kLoggedInNotification
                                                                                                 object:nil];
                                             
                                             [FBSession setActiveSession:session];
                                             self.fbsession = session;
//                                             [self loadScores];
//                                             [self retriveMyFacebookID];
//                                             [self retrieveFriendsDetails];
                                         }];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoggedInNotification
                                                            object:nil];

//        [self loadScores];
//        [self retriveMyFacebookID];
//        [self retrieveFriendsDetails];
    }
}

-(void) logout {
    [self.fbsession closeAndClearTokenInformation];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(buttonIndex == 1) {
        [self removeFromParentAndCleanup:YES];
        [[GameController sharedGameCtrl] spendCoins:150];
        [[NSNotificationCenter defaultCenter] postNotificationName:kAdd10PlanksNotification
                                                            object:nil];
	}
    else {
    }
}

#pragma mark - Scores Methods

-(void) loadParams {
    if (!self.fbsession.isOpen) {
        return;
    }
//    [self loadScores];
//    [self retriveMyFacebookID];
//    [self retrieveFriendsDetails];
}

-(void) postScore: (NSInteger) scoreValue {
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSString stringWithFormat:@"%ld", (long)scoreValue], @"score",
                                   nil];
    CCLOG(@"FBPostScore: %ld", (long)scoreValue);
    
    [FBRequestConnection startWithGraphPath:@"me/scores"
                                 parameters:params
                                 HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//                              [self loadScores];
                          }];
}

-(void)loadScores {
    // if we have a valid session, then we post the action to the users wall, else noop
    if (self.fbsession.isOpen) {
        // if we don't have permission to post, let's first address that
        if ([self.fbsession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        }
        else {
            NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
            NSString *kuFBAppID = [info objectForKey:@"FacebookAppID"];
            [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/scores?fields=score,user", kuFBAppID]
                                         parameters:nil
                                         HTTPMethod:@"GET"
                                  completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                      if (result && !error) {
                                          
                                          dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                                              NSArray *listFromFacebook = [result objectForKey:@"data"];
                                              if([listFromFacebook count] > 0) {
                                                  [self.listOfFBFriends removeAllObjects];
                                                  fbScoresLoaded_ = YES;
                                              }
                                              for (NSDictionary *dict in listFromFacebook) {
                                                  
                                                  NSInteger sizeValue = 80;
                                                  //iPad
                                                  if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                                                      //Retina Display
                                                      if( CC_CONTENT_SCALE_FACTOR() == 2 ) {
                                                          sizeValue = 212;
                                                      }
                                                      else {
                                                          sizeValue = 106;
                                                      }
                                                  }
                                                  //iPhone
                                                  else {
                                                      //Retina Display
                                                      if( CC_CONTENT_SCALE_FACTOR() == 2 ) {
                                                          sizeValue = 80;
                                                      }
                                                      else {
                                                          sizeValue = 40;
                                                      }
                                                  }
                                                  
                                                  NSInteger width = sizeValue;
                                                  NSInteger height = sizeValue;
                                                  NSString *userID = [[dict objectForKey:@"user"] objectForKey:@"id"];
                                                  NSString *name = [[dict objectForKey:@"user"] objectForKey:@"name"];
                                                  NSRange end = [name rangeOfString:@" "];
                                                  NSString *firstName = @"User";
                                                  if (end.location != NSNotFound) {
                                                      firstName = [name substringToIndex:end.location];
                                                  }
                                                  NSString *strScore = [dict objectForKey:@"score"];
                                                  
                                                  MyFBUser *user = [[MyFBUser alloc] init];
                                                  user.userID = userID;
                                                  user.userName = name;
                                                  user.userFirstName = firstName;
                                                  user.score = strScore;
                                                  [self.listOfFBFriends addObject:user];
                                                  [user release];
                                                  
                                                  NSFileManager *fileManager = [NSFileManager defaultManager];
                                                  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                                                  NSString *cachesDirectory = [paths objectAtIndex:0];
                                                  
                                                  NSString *imagePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"fb%@.png", userID]];
                                                  
                                                  if(![fileManager fileExistsAtPath:imagePath]) {
                                                      
                                                      NSString *url  = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%ld&height=%ld", userID, (long)width, (long)height];
                                                      UIImage *pic = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url] options:NSDataReadingMappedIfSafe error:nil]];
                                                      
                                                      CGSize requiredSize = CGSizeMake(width, height);
                                                      if (fabsf(requiredSize.width - pic.size.width) >= 2.f)
                                                          pic = [self imageWithImage:pic scaledToSize:requiredSize];
                                                      
                                                      NSData *data = UIImagePNGRepresentation(pic);
                                                      [fileManager createFileAtPath:imagePath contents:data attributes:nil];
                                                  }
                                              }
                                              dispatch_async(dispatch_get_main_queue(), ^(void) {
                                                  fbUsersLoaded_ = YES;
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:kPicturesNotification
                                                                                                      object:nil];
                                              });
                                              
                                          });
                                      }
                                  }];
        }
    }
}

-(UIImage *) imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void) retrieveFriendsDetails {
    if(!self.fbsession.isOpen) {
        return;
    }
    [FBRequestConnection startWithGraphPath:@"me?fields=friends.fields(id,name,first_name,middle_name,last_name,link,installed,og.posts.limit(99999))"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
         [self requestForMyFriendsCompletionHanlder: connection result:result error:error];
     }];
}

-(void) retriveMyFacebookID {
    if(!self.fbsession.isOpen) {
        return;
    }
    [FBRequestConnection startWithGraphPath:@"me?fields=id"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              self.myFacebookID = [result objectForKey:@"id"];
                              [self.myFacebookID retain];
                              CCLOG(@"My ID is: %@", self.myFacebookID);
                              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                                  NSString *myID = [result objectForKey:@"id"];
                                  
                                  NSInteger sizeValue = 80;
                                  //iPad
                                  if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                                      //Retina Display
                                      if( CC_CONTENT_SCALE_FACTOR() == 2 ) {
                                          sizeValue = 212;
                                      }
                                      else {
                                          sizeValue = 106;
                                      }
                                  }
                                  //iPhone
                                  else {
                                      //Retina Display
                                      if( CC_CONTENT_SCALE_FACTOR() == 2 ) {
                                          sizeValue = 80;
                                      }
                                      else {
                                          sizeValue = 40;
                                      }
                                  }
                                  
                                  NSInteger width = sizeValue;
                                  NSInteger height = sizeValue;
                                  
                                  NSFileManager *fileManager = [NSFileManager defaultManager];
                                  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                                  NSString *cachesDirectory = [paths objectAtIndex:0];
                                  
                                  NSString *imagePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"fb%@.png", myID]];
                                  
                                  if(![fileManager fileExistsAtPath:imagePath]) {
                                      
                                      NSString *url  = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%ld&height=%ld", myID, (long)width, (long)height];
                                      UIImage *pic = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url] options:NSDataReadingMappedIfSafe error:nil]];
                                      
                                      CGSize requiredSize = CGSizeMake(width, height);
                                      if (fabsf(requiredSize.width - pic.size.width) >= 2.f)
                                          pic = [self imageWithImage:pic scaledToSize:requiredSize];
                                      
                                      NSData *data = UIImagePNGRepresentation(pic);
                                      [fileManager createFileAtPath:imagePath contents:data attributes:nil];
                                  }
                                  dispatch_async(dispatch_get_main_queue(), ^(void) {
                                      [[NSNotificationCenter defaultCenter] postNotificationName:kPicturesNotification
                                                                                          object:nil];
                                  });
                                  
                              });

                          }];
}

-(MyFBUser *) getMyFBUser {
    for(NSUInteger i = 0; i < [listOfFriends_ count]; ++i) {
        MyFBUser *fbUser = (MyFBUser *)[listOfFriends_ objectAtIndex:i];
        if([fbUser.userID isEqualToString:self.myFacebookID]) {
            return fbUser;
        }
    }
    return nil;
}

-(void)inviteFriends {
    if(!self.fbsession.isOpen) {
        [self login];
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   kMSGTypeInvite, @"data",
                                   nil];
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:@"Check out this awesome app."
                                                    title:@"Check out this awesome app."
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      NSString *urlString = [NSString stringWithFormat:@"%@", resultURL];
                                                      NSString *cancelPattern = @"canceled";
                                                      NSRange range = [urlString rangeOfString:cancelPattern];
                                                      if(!error && result == FBWebDialogResultDialogCompleted && range.length == 0) {
                                                          CCLOG(@"Friend invited");
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:kFBFriendInvitedNotification
                                                                                                              object:nil];

                                                      }
                                                  }
     ];
}

-(void) requestForMyFriendsCompletionHanlder:(FBRequestConnection*) connection
                                      result:(id) result
                                       error:(NSError*) error {
    if (!error) {
        CCLOG(@"requestForMyFriendsCompletionHanlder");
        NSArray *friends = [[result objectForKey:@"friends"] objectForKey:@"data"];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            [self.listOfFriends removeAllObjects];

            for (NSDictionary<FBGraphUser> *user in friends) {
                if([user objectForKey:@"installed"] != nil && [[user objectForKey:@"installed"] boolValue]) {
                    CCLOG(@"%s", [user.name UTF8String]);
                    
                    MyFBUser *fbUser = [[MyFBUser alloc] init];
                    fbUser.userID = [NSString stringWithFormat:@"%@", [user objectForKey:@"id"]];
                    fbUser.userName = [NSString stringWithFormat:@"%@", user.name];
                    [self.listOfFriends addObject:fbUser];
                    [fbUser release];
                    
                    // Get scores for levels
                    NSArray *scores = [[user objectForKey:@"og.posts"] objectForKey:@"data"];
                    for(NSUInteger j = 0; j < [scores count]; ++j) {
                        NSDictionary *score = [[[scores objectAtIndex:j] objectForKey:@"data"] objectForKey:@"object"];
                        MyFBLevelScore *levelScore = [[[MyFBLevelScore alloc] init] autorelease];
                        levelScore.scoreID = [score objectForKey:@"id"];
                        levelScore.userID = fbUser.userID;
                        CCLOG(@"%@", levelScore.scoreID);
                        
                        [fbUser addScore:levelScore];
                    }
                    
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                    NSString *cachesDirectory = [paths objectAtIndex:0];
                    
                    NSString *imagePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"fb%@.png", fbUser.userID]];
                    
                    if(![fileManager fileExistsAtPath:imagePath]) {
                        NSInteger sizeValue = 80;
                        if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { //iPad
                            if( CC_CONTENT_SCALE_FACTOR() == 2 ) { //Retina Display
                                sizeValue = 212;
                            }
                            else {
                                sizeValue = 106;
                            }
                        }
                        else { //iPhone
                            if( CC_CONTENT_SCALE_FACTOR() == 2 ) { //Retina Display
                                sizeValue = 80;
                            }
                            else {
                                sizeValue = 40;
                            }
                        }
                        
                        NSInteger width = sizeValue;
                        NSInteger height = sizeValue;

                        NSString *url  = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%ld&height=%ld", fbUser.userID, (long)width, (long)height];
                        UIImage *pic = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url] options:NSDataReadingMappedIfSafe error:nil]];
                        
                        CGSize requiredSize = CGSizeMake(width, height);
                        if (fabsf(requiredSize.width - pic.size.width) >= 2.f)
                            pic = [self imageWithImage:pic scaledToSize:requiredSize];
                        
                        NSData *data = UIImagePNGRepresentation(pic);
                        [fileManager createFileAtPath:imagePath contents:data attributes:nil];
                    }
                }
            }
            
            MyFBUser *fbUser = [[MyFBUser alloc] init];
            fbUser.userID = self.myFacebookID;
            fbUser.userName = @"You";
            [self.listOfFriends addObject:fbUser];
            [fbUser release];
            CCLOG(@"You");

            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
            NSString *cachesDirectory = [paths objectAtIndex:0];
            
            NSString *imagePath = [cachesDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"fb%@.png", fbUser.userID]];
            
            if(![fileManager fileExistsAtPath:imagePath]) {
                NSInteger sizeValue = 80;
                if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { //iPad
                    if( CC_CONTENT_SCALE_FACTOR() == 2 ) { //Retina Display
                        sizeValue = 212;
                    }
                    else {
                        sizeValue = 106;
                    }
                }
                else { //iPhone
                    if( CC_CONTENT_SCALE_FACTOR() == 2 ) { //Retina Display
                        sizeValue = 80;
                    }
                    else {
                        sizeValue = 40;
                    }
                }
                
                NSInteger width = sizeValue;
                NSInteger height = sizeValue;
                
                NSString *url  = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=%ld&height=%ld", fbUser.userID, (long)width, (long)height];
                UIImage *pic = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url] options:NSDataReadingMappedIfSafe error:nil]];
                
                CGSize requiredSize = CGSizeMake(width, height);
                if (fabsf(requiredSize.width - pic.size.width) >= 2.f)
                    pic = [self imageWithImage:pic scaledToSize:requiredSize];
                
                NSData *data = UIImagePNGRepresentation(pic);
                [fileManager createFileAtPath:imagePath contents:data attributes:nil];
            }
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kUsersLoadedNotification
                                                                    object:nil];
            });
            
        });
    }
    else {
        CCLOG(@"requestForMyFriedsCompletionHanlder An error occured");
    }
}

-(void) retriveAllScoresForFriends {
    for(NSUInteger i = 0; i < [listOfFriends_ count]; ++i) {
        MyFBUser *fbUser = (MyFBUser *)[listOfFriends_ objectAtIndex:i];
        for(NSUInteger j = 0; j < [fbUser.listOfScores count]; ++j) {
            MyFBLevelScore *fbScore = (MyFBLevelScore *)[fbUser.listOfScores objectAtIndex:j];
            fbScore.userID = fbUser.userID;

            [FBRequestConnection startWithGraphPath:fbScore.scoreID
                                  completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                      NSDictionary *data = [result objectForKey:@"data"];
                                      fbScore.score = [[data objectForKey:@"level_score"] intValue];
                                      fbScore.level = [[data objectForKey:@"level_id"] intValue];
                                  }];
        }
    }
    
    NSString *path = [NSString stringWithFormat:@"me/objects/%@:level", kFBNameSpace];
    [FBRequestConnection startWithGraphPath:path
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              
                              NSDictionary *scores = [result objectForKey:@"data"];
                              for (NSDictionary<FBGraphObject> *score in scores) {
                                  MyFBLevelScore *levelScore = [[[MyFBLevelScore alloc] init] autorelease];
                                  levelScore.scoreID = [score objectForKey:@"id"];
                                  levelScore.userID = self.myFacebookID;
                                  levelScore.score = [[[score objectForKey:@"data"] objectForKey:@"level_score"] intValue];
                                  levelScore.level = [[[score objectForKey:@"data"] objectForKey:@"level_id"] intValue];
                                  CCLOG(@"%@", levelScore.scoreID);
                                  [[self getMyFBUser] addScore:levelScore];                                  
                              }
                          }];
}

-(void) createRequestTo: (NSString*) userID withType: (NSString*) type withText: (NSString*) text {
    if(!self.fbsession.isOpen) {
        return;
    }
    NSMutableDictionary *params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     userID, @"to",
                                     type, @"data",
                                     nil];
    
    [self.friendCache prefetchAndCacheForSession:nil];

    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:text
                                                    title:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                      if(!error) {
                                                      }
                                                  }
                                              friendCache:self.friendCache
    ];
}

-(void) createRequestTo: (NSString*) userID withType: (NSString*) type withText: (NSString*) text withRequestID: (NSString*) requestID {
    if(!self.fbsession.isOpen) {
        return;
    }
     NSMutableDictionary *params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     userID, @"to",
                                     type, @"data",
                                     nil];
    lastRequestID = requestID;
    
    [self.friendCache prefetchAndCacheForSession:nil];

    [FBWebDialogs
     presentRequestsDialogModallyWithSession:nil
     message:text
     title:nil
     parameters:params
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         NSString *urlString = [NSString stringWithFormat:@"%@", resultURL];
         NSString *cancelPattern = @"canceled";
         NSRange range = [urlString rangeOfString:cancelPattern];
         if(!error && result == FBWebDialogResultDialogCompleted && range.length == 0) {
             if(lastRequestID) {
                 [self deleteRequest:lastRequestID];
                 lastRequestID = nil;
             }
         }
     }
     friendCache:self.friendCache
     ];
}

-(void) retrieveIncomingRequests {
    if(!self.fbsession.isOpen) {
        return;
    }
    [FBRequestConnection startWithGraphPath:@"me/apprequests"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  CCLOG(@"Incoming requests retrieve success");
                                  [self retrieveIncomingRequestsCompletionHandler:connection result:result error:error];
                              }
                              else {
                                  CCLOG(@"Incoming requests retrieve failed");
                              }
                          }
     ];
}

-(void) retrieveIncomingRequestsCompletionHandler:(FBRequestConnection*) connection
                                           result:(id) result
                                            error:(NSError*) error {
    NSArray* requests = [result objectForKey:@"data"];
    if (requests) {
        [self.listOfRequests removeAllObjects];
        for (int i = 0; i < [requests count]; ++i) {
            id request = [requests objectAtIndex:i];
            
            NSString *dataString = [request objectForKey:@"data"];
            if([dataString isEqualToString:kMSGTypeInvite]) {
            }
            else {
                MyFBRequest *fbRequest = [[MyFBRequest alloc] init];
                fbRequest.requestID  = [request objectForKey:@"id"];
                fbRequest.senderID   = [[request objectForKey:@"from"] objectForKey:@"id"];
                fbRequest.senderName = [[request objectForKey:@"from"] objectForKey:@"name"];
                fbRequest.data       = [request objectForKey:@"data"];
                fbRequest.message    = [request objectForKey:@"message"];
                [self.listOfRequests addObject:fbRequest];
                [fbRequest release];
                CCLOG(@"My request with data: %@ and message: %@", fbRequest.data, fbRequest.message);
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kRequestsNotification
                                                            object:nil];
    }
    else {
    }
}

-(void) deleteRequest: (NSString*) requestid {
    if (!requestid) {
        return;
    }
    [FBRequestConnection startWithGraphPath:requestid
                                 parameters:nil
                                 HTTPMethod:@"DELETE"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
         if(!error) {
             CCLOG(@"Request deleted");
             [self retrieveIncomingRequests];
         }
         else {
             CCLOG(@"Failed to delete request");
         }
     }];
}

-(void) deleteAllRequests {
    [FBRequestConnection startWithGraphPath:@"me/apprequests"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             NSLog(@"Incoming requests retrieve success");
             [self retrieveIncomingRequestsCompletionHandler:connection result:result error:error];
             
             NSArray* requests = [result objectForKey:@"data"];
             if (!requests) return;
             
             for (int i = 0; i < [requests count]; ++i) {
                 id request = [requests objectAtIndex:i];
                 [self deleteRequest:[request objectForKey:@"id"]];
             }
         }
     }];
}

-(void) postPassMessageWithFriendID: (NSString*) friendID
                          friendName: (NSString*) friendName
                         friendScore: (NSInteger) friendScore
                           yourScore: (NSInteger) yourScore {
    if(!self.fbsession.isOpen) {
        [self login];
    }
    else {
        PW_SBJsonWriter *jsonWriter = [[PW_SBJsonWriter alloc] init];

        NSString *name = [NSString stringWithFormat:@"%@, I beat your score!", friendName];
        NSString *caption = [NSString stringWithFormat:@"I got %ld points… %ld points more than you!", (long)yourScore, yourScore - friendScore];
        NSString *description = @"Click on the image to challenge me!";
        
        
        NSArray *actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          @"Click here to Play CombiCats", @"name",
                                                          kAppURL, @"link",
                                                          nil],
                                nil];
        NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];

        NSMutableDictionary *params =
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
         kFBAppID, @"app_id",
         name, @"name",
         caption, @"caption",
         description, @"description",
         actionLinksStr, @"actions",
         kAppURL, @"link",
         kFBIcon, @"picture",
         friendID, @"to",
         nil];
        
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                  }
         ];
    }
}

-(void) postNewHighScoreMessageWithScore: (NSInteger) score {
    if(!self.fbsession.isOpen) {
        [self login];
    }
    else {
        PW_SBJsonWriter *jsonWriter = [[PW_SBJsonWriter alloc] init];
        
        NSString *name = [NSString stringWithFormat:@"Don’t mind me, I just scored %ld on Combi Cats!", (long)score];
        NSString *caption = @"Think you can outshine me and score more?";
        NSString *description = @"Play Combi Cats and earn your own golden fish coins!";
        
        NSArray *actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          @"Click here to Play Combi Cats", @"name",
                                                          kAppURL, @"link",
                                                          nil],
                                nil];
        NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
        
        NSMutableDictionary *params =
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
         kFBAppID, @"app_id",
         name, @"name",
         caption, @"caption",
         description, @"description",
         actionLinksStr, @"actions",
         kAppURL, @"link",
         kFBIcon, @"picture",
         nil];
        
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                  }
         ];
    }
}

-(void) postNewLevelMessageWithScore: (NSInteger) level {
    if(!self.fbsession.isOpen) {
        [self login];
    }
    else {
        PW_SBJsonWriter *jsonWriter = [[PW_SBJsonWriter alloc] init];
        
        NSString *name = [NSString stringWithFormat:@"Don’t mind me, I just scored %ld on Combi Cats!", (long)level];
        NSString *caption = @"Think you can outshine me and score more?";
        NSString *description = @"Play Combi Cats and earn your own golden fish coins!";
        
        NSArray *actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          @"Click here to Play Combi Cats", @"name",
                                                          kAppURL, @"link",
                                                          nil],
                                nil];
        NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
        
        NSMutableDictionary *params =
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
         kFBAppID, @"app_id",
         name, @"name",
         caption, @"caption",
         description, @"description",
         actionLinksStr, @"actions",
         kAppURL, @"link",
         kFBIcon, @"picture",
         nil];
        
        [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                               parameters:params
                                                  handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                  }
         ];
    }
}

#pragma mark - Open Graph

-(void) postOpenGraphObject:(NSString*) fbUserID
					   path:(NSString*) path
					  title:(NSString*) title
					   data:(NSDictionary*) data {
    if(!self.fbsession.isOpen) {
        return;
    }
    NSMutableDictionary<FBGraphObject>* object = [FBGraphObject graphObject];
    
    object[@"title"] = title;
	object[@"data"] = data;
    
    PW_SBJsonWriter *jsonWriter = [[PW_SBJsonWriter alloc] init];
    
    NSMutableDictionary<FBGraphObject> *ogo = [FBGraphObject graphObject];
	ogo[@"object"] = [jsonWriter stringWithObject:object];
	[jsonWriter release];
    
    [FBRequestConnection startForPostWithGraphPath:path
                                       graphObject:ogo
                                 completionHandler:^(FBRequestConnection *connection,
                                                     id result,
                                                     NSError *error) {
                                     if (!error) {
                                         CCLOG(@"Posted OG action, id: %@", [result objectForKey:@"id"]);
                                         NSString *openGraphObjectID = [result objectForKey:@"id"];
                                         [self retrieveOpenGraphObject:fbUserID graphPath:openGraphObjectID];
                                     }
                                     else {
                                         // An error occurred, we need to handle the error
                                         // See: https://developers.facebook.com/docs/ios/errors
                                     }
                                 }
     ];
}

-(void) retrieveOpenGraphObject:(NSString*) fbUserID
                      graphPath:(NSString*) graphPath {
    if(!self.fbsession.isOpen) {
        return;
    }

    [FBRequestConnection startWithGraphPath:graphPath
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  NSDictionary *data = [result objectForKey:@"data"];
                                  MyFBLevelScore *levelScore = [[[MyFBLevelScore alloc] init] autorelease];
                                  levelScore.scoreID = [result objectForKey:@"id"];
                                  levelScore.userID = self.myFacebookID;
                                  levelScore.score = [[data objectForKey:@"level_score"] intValue];
                                  levelScore.level = [[data objectForKey:@"level_id"] intValue];
                                  CCLOG(@"%@", levelScore.scoreID);
                                  [[self getMyFBUser] addScore:levelScore];
                              }
                          }];
}


-(void) deleteOpenGraphObject:(NSString*) fbUserID
                    graphPath:(NSString*) graphPath {
	if (!graphPath) {
        return;
    }
	[FBRequestConnection startWithGraphPath:graphPath
								 parameters:nil
								 HTTPMethod:@"DELETE"
						  completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              CCLOG(@"Graph object removed");
                          }
     ];
	return;
}

-(void) postScore: (NSInteger) score forLevel: (NSInteger) level {
    NSDictionary* data =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithFormat:@"%ld", (long)level], @"level_id",
                            [NSString stringWithFormat:@"%ld", (long)score], @"level_score",
                            nil];
    NSString *path = [NSString stringWithFormat:@"me/objects/%@:level", kFBNameSpace];
    NSString *title = @"Score for level";
    
    MyFBUser *fbUser = [self getMyFBUser];
    MyFBLevelScore *currScore = [fbUser getScoreForLevel:level];
    if(currScore.score < score) {
        [self postOpenGraphObject:self.myFacebookID
                             path:path
                            title:title
                             data:data];
        [self deleteOpenGraphObject:self.myFacebookID graphPath:currScore.scoreID];
        
        [fbUser removeScoreWithID:currScore.scoreID];
        
        MyFBLevelScore *newScore = [[[MyFBLevelScore alloc] init] autorelease];
        newScore.scoreID = nil;
        newScore.userID = self.myFacebookID;
        newScore.score = score;
        newScore.level = level;
        [fbUser addScore:newScore];
    }
}

-(NSArray *) getListOfScoresForLevel: (NSInteger) level {
    NSMutableArray *scores = [[[NSMutableArray alloc] init] autorelease];
    for(NSUInteger i = 0; i < [listOfFriends_ count]; ++i) {
        MyFBUser *fbUser = (MyFBUser *)[listOfFriends_ objectAtIndex:i];
        for(NSUInteger j = 0; j < [fbUser.listOfScores count]; ++j) {
            MyFBLevelScore *fbScore = (MyFBLevelScore *)[fbUser.listOfScores objectAtIndex:j];
            if(fbScore.level == level) {
                if([scores count] <= 0) {
                    [scores addObject:fbScore];
                }
                else {
                    for(NSUInteger k = 0; k < [scores count]; ++k) {
                        MyFBLevelScore *currScore = (MyFBLevelScore *)[scores objectAtIndex:k];
                        if(fbScore.score > currScore.score) {
                            [scores insertObject:fbScore atIndex:k];
                            break;
                        }
                        else if(k >= [scores count] - 1) {
                            [scores addObject:fbScore];
                            break;
                        }
                    }
                }
                break;
            }
        }
    }
    return scores;
}

@end