//
//  Created by robertino on 23.11.11.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import "cocos2d.h"
#import "SimpleAudioEngine.h"

/** @brief Label that sets it's value animated
 */

@interface CCLabelBMFontAnimated : CCLabelBMFont
{
@private
    CDSoundSource   *loopSound_;
    bool isAnimating_;
    long next_;
    double current_;
    double interval_;
    NSString* valueFormat_;
    NSString* effect_;
    
}
/** @warning Format string token should be for long value ( @"%..ld" ) */
@property (nonatomic, copy) NSString* valueFormat;
@property (nonatomic, copy) NSString* effect;
@property (nonatomic, retain) CDSoundSource   *loopSound;


/** Custom init method that specifies value and output format */
- (id)initWithValue:(long)value format:(NSString *)format fntFile:(NSString *)fnt;
+ (id)labelWithValue:(long)value format:(NSString *)format fntFile:(NSString *)fnt;

/** Short init. Only value is specified */
+ (id)labelWithValue:(long)value fntFile:(NSString *)fnt;

/** Set value animated */
- (void)updateValue:(long)newValue animated:(BOOL)animated;

@end