//
//  ShopLayer.h
//  Raaabit
//
//  Created by Dmitry Valov on 02.04.13.
//  Copyright 2013 Dmitry Valov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MyPopupLayer.h"

@class IAPTable;
@class SWTableView;

@interface ShopLayer : MyPopupLayer {
    CCNode *containerNode;
    CCSprite *barSlider;
    CCNode *labelContainer;

    IAPTable *iapTableData;
    SWTableView *myIAPtable;

    bool isPopup;
}

@property bool isPopup;

+(CCScene *) scene;
-(void) addBackground;

@end
