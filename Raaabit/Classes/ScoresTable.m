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

#import "ScoresTable.h"
#import "ScoresCell.h"
#import "CommonValues.h"
#import "Constants.h"
#import "MyMenuItemSprite.h"
#import "Util.h"
#import "AppDelegate.h"
#import "GameController.h"
#import "MyFBLevelScore.h"

@implementation ScoresTable

//provide data to your table
//telling cell size to the table
-(Class)cellClassForTable:(SWTableView *)table {
    return [ScoresTable class];
}

-(CGSize)cellSizeForTable:(SWTableView *)table
{
    return [ScoresCell cellSize];
}

//providing CCNode object for a cell at a given index
-(SWTableViewCell *)table:(SWTableView *)table cellAtIndex:(NSUInteger)idx {
    SWTableViewCell *cell;
    cell = [table dequeueCell];
    
    if(!cell) { //there is no recycled cells in the table
        cell = [[ScoresCell new] autorelease]; // create a new one
        cell.anchorPoint = CGPointZero;
    }
    else {
        [cell.children removeAllObjects];
    }
    
    //configure the sprite.. do all kinds of super cool things you can do with cocos2d.
    CCSprite *item = [CCSprite spriteWithSpriteFrameName:@"lc_border.png"];
    [item setAnchorPoint:ccp(0.5f, 0.5f)];
    item.position = ccp(item.contentSize.width / 2.0f, item.contentSize.height / 2.0f + 10 * kFactor);
    [cell addChild:item];
    
    MyFBLevelScore *fbScore = (MyFBLevelScore *)[[GameController sharedGameCtrl].listOfScoresForLevel objectAtIndex:idx];
    
    CCLabelBMFont *captionLabel = [[CCLabelBMFont alloc] initWithString:[NSString stringWithFormat:@"%d", fbScore.score]
                                  fntFile:@"font_lc_planks.fnt"];
    captionLabel.position = ccp(item.contentSize.width / 2.0f, item.position.y - item.contentSize.height / 2 - 8 * kFactor);
    [cell addChild:captionLabel z:30];
    
    
    NSString *fileName = [NSString stringWithFormat:@"fb%@.png", fbScore.userID];
    CCTexture2D *texture = [[CCTextureCache sharedTextureCache] textureForKey:fileName];
    if (texture == nil) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesDirectory = [paths objectAtIndex:0];
        NSString *imagePath = [cachesDirectory stringByAppendingPathComponent:fileName];
        UIImage *facebookPicImage = [UIImage imageWithContentsOfFile:imagePath];
        [[CCTextureCache sharedTextureCache] addCGImage:[facebookPicImage CGImage] forKey:fileName];
        texture = [[CCTextureCache sharedTextureCache] textureForKey:fileName];
    }
    CCSprite * userPic = [CCSprite spriteWithTexture:texture];
    [userPic setAnchorPoint:ccp(0.5f, 0.5f)];
    userPic.position = ccp(item.contentSize.width / 2.0f, item.contentSize.height / 2.0f + 10 * kFactor);
    [cell addChild:userPic];

    return cell;
}

-(NSUInteger)numberOfCellsInTableView:(SWTableView *)table {
    //return a number
    return [[GameController sharedGameCtrl].listOfScoresForLevel count];
}

//touch detection here
-(void)table:(SWTableView *)table cellTouched:(SWTableViewCell *)cell
{
    //        NSLog(@"IAP touched at index %d",cell.idx);
}

-(void)dealloc{
    CCLOG(@"%@: %@", NSStringFromSelector(_cmd), self);
    
    [super dealloc];
}

@end
