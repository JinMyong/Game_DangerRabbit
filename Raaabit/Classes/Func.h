//
//  Created by Korpan Grigory on 24.02.11.
//

#define IS_IPAD() ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))

static inline NSString * filePathInDocumentDir(NSString * file) {
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentDirectory = [paths objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:file];
}

#pragma mark - Math

#define ARC4RANDOM_MAX 0x100000000 //0xFFFFFFFFu

// Needs some testing?
static inline float randInRangef(float low, float high) {
    assert(low <= high);
    return (((float) arc4random() / ARC4RANDOM_MAX) * (high - low)) + low;
}

// Needs some testing?
static inline int randInRangei(int low, int high) {
    assert(low <= high);
    return arc4random() % (high - low + 1) + low;
}

// Needs some testing?
static inline uint randInRangeui(uint low, uint high) {
    assert(low <= high);
    return arc4random() % (high - low + 1) + low;
}
