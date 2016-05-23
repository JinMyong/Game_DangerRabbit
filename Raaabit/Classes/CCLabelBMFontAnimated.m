//
//  Created by Korpan Grigory on 23.11.11.
//

#import "CCLabelBMFontAnimated.h"
#import "Constants.h"
#import "SimpleAudioEngine.h"


#define kCCLabelBMFontAnimatedDefaultFormat @"%ld"
#define kCCLabelBMFontAnimationTime 1.0f
#define kCCLabelBMFontAnimationsPerSecond 10
#define kCCLabelBMFontAnimationInterval (kCCLabelBMFontAnimationTime / kCCLabelBMFontAnimationsPerSecond)

@interface CCLabelBMFontAnimated ()
- (void)animateUpdate:(ccTime)dt;

@end

@implementation CCLabelBMFontAnimated
@synthesize valueFormat = valueFormat_;
@synthesize effect = effect_;
@synthesize loopSound = loopSound_;

-(id)init
{
    if ( (self != [super init]) )
        return nil;
    
    next_ = 0;
    current_ = 0.0f;
    interval_ = 0.0f;
    isAnimating_ = NO;
    valueFormat_ = @"%ld";
    effect_ = @"TotalPoints.mp3";
    return self;
}

- (void)dealloc
{
    [self.loopSound stop];
    self.loopSound = nil;
    [valueFormat_ release];
    [effect_ release];
    [super dealloc];
}

- (id)initWithValue:(long)value format:(NSString *)format fntFile:(NSString *)fnt
{
    current_ = value;
    valueFormat_ = format;
    effect_ = @"TotalPoints.mp3";
    return [self initWithString:[NSString stringWithFormat:valueFormat_, value] fntFile:fnt];
}

+ (id)labelWithValue:(long)value fntFile:(NSString *)fnt
{
    return [[[self alloc] initWithValue:value format:kCCLabelBMFontAnimatedDefaultFormat fntFile:fnt] autorelease];
}

+ (id)labelWithValue:(long)value format:(NSString *)format fntFile:(NSString *)fnt
{
    return [[[self alloc] initWithValue:value format:format fntFile:fnt] autorelease];
}

-(void)updateValue:(long)newValue animated:(BOOL)animated
{
    if (animated)
    {
        self.loopSound = [[SimpleAudioEngine sharedEngine] soundSourceForFile:@"TotalPoints.mp3"];
        self.loopSound.looping = YES;
        [self.loopSound play];

        next_ = newValue;
        interval_ = (next_ - current_) / kCCLabelBMFontAnimationTime / kCCLabelBMFontAnimationsPerSecond;

        if( NO == isAnimating_ )
        {
            [self animateUpdate:0.001f];
            [self schedule:@selector(animateUpdate:) interval:kCCLabelBMFontAnimationInterval];

            isAnimating_ = YES;
        }
    }
    else
    {
        current_ = newValue;
        [self setString:[NSString stringWithFormat:valueFormat_, (long)(current_)]];

        if (isAnimating_)
        {
            isAnimating_ = NO;
            [self unschedule:@selector(animateUpdate:)];
        }
    }
}

- (void) animateUpdate:(ccTime)dt
{
	if((interval_ > 0 && next_ > current_ + interval_) ||
	   (interval_ < 0 && next_ < current_ + interval_))
	{
     	current_ += interval_;
    }
	else
	{
        [self.loopSound stop];

		current_ = next_;
		isAnimating_ = NO;
        [self unschedule:_cmd];
    }	
        
	[self setString:[NSString stringWithFormat:valueFormat_, (long)(current_)]];
}

@end