//
//  ExampleTableView.m
//
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//  Created by Martin Rehder on 06.05.13.
//

#import "IAPTable.h"
#import "ExampleCell.h"
#import "CommonValues.h"
#import "Constants.h"
#import "MyMenuItemSprite.h"
#import "Util.h"
#import "AppDelegate.h"
#import "GameController.h"
#import "NoCarrotsLayer.h"

@implementation IAPTable

//provide data to your table
//telling cell size to the table
-(Class)cellClassForTable:(SWTableView *)table {
    return [ExampleCell class];
}

-(CGSize)cellSizeForTable:(SWTableView *)table
{
    return [ExampleCell cellSize];
}

//providing CCNode object for a cell at a given index
-(SWTableViewCell *)table:(SWTableView *)table cellAtIndex:(NSUInteger)idx {
    SWTableViewCell *cell;
    cell = [table dequeueCell];
    
    _table = table;

    if(!cell) { //there is no recycled cells in the table
        cell = [[ExampleCell new] autorelease]; // create a new one
        cell.anchorPoint = CGPointZero;
    }
    else {
        [cell.children removeAllObjects];
    }

    NSArray *listOfPrices = [self getPrices];
    NSArray *listOfIcons = [self getIcon];
    NSArray *listOCaptions = [self getCaption];
    NSArray *listOfCarrots =[self getCarrot];
    
    indexForSwitch = 0;
    
    NSInteger iconX = 55 * kFactor;
    NSInteger iconY = 3 * kFactor;
    NSInteger captionX = 67 * kFactor;
    NSInteger captionY = 30 * kFactor;
    NSInteger dollarX = -50 * kFactor;
    NSInteger dollarY = 30 * kFactor;
    NSInteger carrotX = 17 * kFactor;
    NSInteger carrotY = -1 * kFactor;
    NSInteger priceX = 45 * kFactor;
    NSInteger priceY = 30 * kFactor;
    if([Util sharedUtil].isiPad) {
        iconX = 55 * kFactor;
        iconY = 3 * kFactor;
        captionX = 92 * kFactor;
        captionY = 20 * kFactor;
        dollarX = -40 * kFactor;
        dollarY = 20 * kFactor;
        carrotX = 37 * kFactor;
        carrotY = 5 * kFactor;
        priceX = 7 * kFactor;
        priceY = 20 * kFactor;

    }
    if ([Util sharedUtil].isiPhone5) {
        captionX = 92 * kFactor;
    }

    //configure the sprite.. do all kinds of super cool things you can do with cocos2d.
    CCSprite *item = [CCSprite spriteWithSpriteFrameName:@"sp_arrow.png"];

    CCSprite *coinsIcon = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@", (NSString *)[listOfIcons objectAtIndex:idx]]]; 
    [coinsIcon setPosition:ccp(iconX, item.contentSize.height / 2.0f + iconY)];
    [item addChild:coinsIcon z:1];
    
    NSString *caption =  [NSString stringWithFormat:@"%@", (NSString *)[listOCaptions objectAtIndex:idx]];
    
    CCLabelTTF *captionLabel = [CCLabelTTF labelWithString:caption fontName:@"BradyBunchRemastered" fontSize:17 * kFactor dimensions:CGSizeMake(160 * kFactor, 60 * kFactor) hAlignment:kCCTextAlignmentCenter vAlignment:kCCVerticalTextAlignmentCenter]; //
    captionLabel.color = ccc3(255, 102, 0);
    captionLabel.position = ccp(kScreenCenterX - captionX, item.contentSize.height / 2.0f + captionY);
    [cell addChild:captionLabel z:30];

    if (![[listOfCarrots objectAtIndex:idx] isEqual:@"carrot.png"]) {
        NSString *priceString = [[GameController sharedGameCtrl].listOfPrices objectForKey:[listOfCarrots objectAtIndex:idx]];
        if(!priceString || [priceString length] <= 0) {
            priceString = @"n/a";
        }
        
        [[Util sharedUtil] showLabel:priceString
                              atNode:cell
                          atPosition:ccp(kScreenCenterX + dollarX, item.contentSize.height / 2.0f + dollarY)
                            fontName:@"BradyBunchRemastered"
                            fontSize:17 * kFactor
                           fontColor:ccc3(255, 204, 102)
                         anchorPoint:ccp(0.0f, 0.5f)
                           isEnabled:YES
                                 tag:1
                          dimensions:CGSizeMake(200, 40)
                            rotation:0
                             bgColor:ccc3(51, 0, 0)];
    }
    else {
        CCSprite *carrot = [CCSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@", (NSString *)[listOfCarrots objectAtIndex:idx]]];
        [carrot setPosition:ccp(kScreenCenterX - carrotX, item.contentSize.height / 2.0f + carrotY)];
        [item addChild:carrot z:1];
        
        NSString *price =  [NSString stringWithFormat:@"%@", (NSString *)[listOfPrices objectAtIndex:idx]];
        [[Util sharedUtil] showLabel:price
                              atNode:cell
                          atPosition:ccp(kScreenCenterX + priceX, item.contentSize.height / 2.0f + priceY)
                            fontName:@"BradyBunchRemastered"
                            fontSize:24 * kFactor
                           fontColor:ccc3(255, 204, 102)
                         anchorPoint:ccp(0.5, 0.5)
                           isEnabled:YES
                                 tag:1
                          dimensions:CGSizeMake(200, 40)
                            rotation:0
                             bgColor:ccc3(51, 0, 0)];
    }

    item.anchorPoint = CGPointZero;
    item.position = ccp(30, 30);
    [cell addChild:item];
    
    return cell;
}

-(NSUInteger)numberOfCellsInTableView:(SWTableView *)table {
    //return a number
    return 9;       // Modified By Hans origin 11 For remove continue packs.
}

//touch detection here
-(void)table:(SWTableView *)table cellTouched:(SWTableViewCell *)cell
{
//        NSLog(@"IAP touched at index %d",cell.idx);
    [self buyHandler:cell.idx];
}

-(void)dealloc{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    [super dealloc];
}

- (void) buyHandler:(NSInteger)senderIdx {
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];

    switch (senderIdx) {
        case 0: {  // Unlock all worlds
            [appDelegate purchase:kShopID_UnlockAllLevels];
            break;
        }
        case 1: { // +3 super planks
            [appDelegate logEvent:@"Purshase 2 super planks"];
            [self showConfirmAlertWithPrice:@"100" forItem:@"2 super planks"];
            indexForSwitch = 1;
            break;
        }
        case 2: { //3 sticky planks
            [appDelegate logEvent:@"Purshase 2 sticky planks"];
            [self showConfirmAlertWithPrice:@"100" forItem:@"2 sticky planks"];
            indexForSwitch = 2;
            break;
        }
        case 3: { //5 planks
            [appDelegate logEvent:@"Purshase 5 regular planks"];
            [self showConfirmAlertWithPrice:@"100" forItem:@"5 planks"];
            indexForSwitch = 3;
            break;
        }
        case 4: //bomb
            [appDelegate logEvent:@"Purshase 1 bomb"];
            [self showConfirmAlertWithPrice:@"200" forItem:@"1 bomb"];
            indexForSwitch = 4;
            break;
        case 5: //level blaster
            [appDelegate logEvent:@"Purshase Level blaster"];
            [self showConfirmAlertWithPrice:@"500" forItem:@"Level blaster"];
            indexForSwitch = 5;
            break;
        case 6: //1000 carrots
            [appDelegate purchase:kShopID_1kCarrots];
            break;
        case 7: //2000 carrots
            [appDelegate purchase:kShopID_2kCarrots];
            break;
        case 8: //4000 carrots
            [appDelegate purchase:kShopID_4kCarrots];
            break;
        case 9: // 5 continues
            [appDelegate logEvent:@"Purshase 5 continues"];
            [self showConfirmAlertWithPrice:@"1200" forItem:@"5 Continues"];
            indexForSwitch = 11;
            break;
        case 10: // 15 continues
            [appDelegate logEvent:@"Purshase 15 continues"];
            [self showConfirmAlertWithPrice:@"3600" forItem:@"15 Continues"];
            indexForSwitch = 12;
            break;
        default:
            break;
    }
}

-(NSArray *) getIcon {
    NSMutableArray *prices = [[NSMutableArray alloc] init];
    [prices addObject:@"unlockallworlds.png"];
    [prices addObject:@"superplank3.png"];
    [prices addObject:@"3stickyplank.png"];
    [prices addObject:@"5planks.png"];
    [prices addObject:@"bomb.png"];
    [prices addObject:@"levelblaster.png"];
    [prices addObject:@"1kcarrots.png"];
    [prices addObject:@"2kcarrots.png"];
    [prices addObject:@"4kcarrots.png"];
//    [prices addObject:@"s_5pack.png"];        // Remarked By Hans
//    [prices addObject:@"s_15pack.png"];       // Remarked By Hans
    return prices;
}

-(NSArray *) getCaption {
    NSMutableArray *captions = [[NSMutableArray alloc] init];
    [captions addObject:@"Unlock All Worlds"];
    [captions addObject:@"2 super planks"];
    [captions addObject:@"2 sticky planks"];
    [captions addObject:@"5 planks"];
    [captions addObject:@"Bomb"];
    [captions addObject:@"Level Blaster"];
    [captions addObject:@"1,000 carrots"];
    [captions addObject:@"2,000 carrots"];
    [captions addObject:@"4,000 carrots"];
//    [captions addObject:@"5 continues"];      // Remarked By Hans
//    [captions addObject:@"15 Continues"];     // Remarked By Hans
    return captions;
}

- (NSArray *) getCarrot {
    NSMutableArray *prices = [[NSMutableArray alloc] init];
    [prices addObject:kAppleID_UnlockAllLevels];
    [prices addObject:@"carrot.png"];	
    [prices addObject:@"carrot.png"];	
    [prices addObject:@"carrot.png"];	
    [prices addObject:@"carrot.png"];	
    [prices addObject:@"carrot.png"];	
    [prices addObject:kAppleID_1kCarrots];
    [prices addObject:kAppleID_2kCarrots];
    [prices addObject:kAppleID_4kCarrots];
//    [prices addObject:@"carrot.png"];         // Remarked By Hans
//    [prices addObject:@"carrot.png"];         // Remarked By Hans
    return prices;
}

- (NSArray *) getPrices {
    NSMutableArray *prices = [[NSMutableArray alloc] init];
    [prices addObject:@"_"];
    [prices addObject:@"100"];	
    [prices addObject:@"100"];	
    [prices addObject:@"100"];	
    [prices addObject:@"200"];	
    [prices addObject:@"500"];
    [prices addObject:@"_"];
    [prices addObject:@"_"];
    [prices addObject:@"_"];
//    [prices addObject:@"1200"];               // Remarked By Hans
//    [prices addObject:@"3600"];               // Remarked By Hans
    return prices;
}

- (void) showNotEnoughCarrots {
    NoCarrotsLayer *ncl = [NoCarrotsLayer node];
    [_table.parent addChild:ncl z:1000];
}

- (void) showEnjoyAlert:(NSString*) caption {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Enjoy"
                                                        message:[NSString stringWithFormat:@"You have got %@!", caption]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

- (void) showEnjoyAlert2:(NSString*) caption {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Enjoy"
                                                        message:[NSString stringWithFormat:@"%@ will be active next level", caption]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}

-(void) showConfirmAlertWithPrice:(NSString*) price forItem: (NSString*) item {
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Confirm"
                                                        message:[NSString stringWithFormat:@"Spend %@ carrots to buy %@?", price, item]
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:@"Cancel", nil];
    [alertView setTag:1];
    [alertView show];
    [alertView release];
}

-(void) alertView: (UIAlertView *) alertView clickedButtonAtIndex: (NSInteger) buttonIndex{
    GameController *gC = [GameController sharedGameCtrl];
    AppController *appDelegate = (AppController *)[[UIApplication sharedApplication] delegate];
    
    if (buttonIndex == 0 && alertView.tag == 1) {
        switch (indexForSwitch) {
            case 1:
                if([gC spendCoins:100]) {
                    gC.superPlanksCount += 2;
                    [gC save];
                    [self showEnjoyAlert2:@"2 SUPER PLANKS"];
                }
                else {
                    [self showNotEnoughCarrots];
                }
                break;
            case 2:
                if([gC spendCoins:100]) {
                    gC.stickyPlanksCount += 2;
                    [gC save];
                    [self showEnjoyAlert2:@"2 STICKY PLANKS"];
                }
                else {
                    [self showNotEnoughCarrots];
                }            
                break;
            case 3:
                if([gC spendCoins:100]) {
                    gC.planksCount += 5;
                    [gC save];
                    [self showEnjoyAlert2:@"5 PLANKS"];
                }
                else {
                    [self showNotEnoughCarrots];
                }            
                break;
            case 4:
                if([gC spendCoins:200]) {
                    gC.bombsCount += 1;
                    [gC save];
                    [self showEnjoyAlert2:@"1 BOMB"];
                }
                else {
                    [self showNotEnoughCarrots];
                }            
                break;
            case 5:
                if([gC spendCoins:500]) {
                    //level blaster Clears any level.
                    NSInteger levelNum = [gC unlockNextLevel];
                    [self showEnjoyAlert:[NSString stringWithFormat:@"Level blaster!\nLevel %ld unlocked", (long)levelNum]];
                }
                else {
                    [self showNotEnoughCarrots];
                }            
                break;
            case 11:
                if([gC spendCoins:1200]) {
                    //5 continues
                    [appDelegate addLives:kLivesBonus * 5];
                    [self showEnjoyAlert:@"5 Continues"];
                }
                else {
                    [self showNotEnoughCarrots];
                }
                break;
            case 12:
                if([gC spendCoins:3600]) {
                    //15 continues
                    [appDelegate addLives:kLivesBonus * 15];
                    [self showEnjoyAlert:@"15 Continues"];
                }
                else {
                    [self showNotEnoughCarrots];
                }
                break;
            case 13:
                if([gC spendCoins:3000]) {
                    //30 continues
                    [appDelegate addLives:kLivesBonus * 30];
                    [self showEnjoyAlert:@"30 Continues"];
                }
                else {
                    [self showNotEnoughCarrots];
                }
                break;
            default:
                break;
        }
    }
}


@end
