#import "MonitorDataSource_CLI.h"
#import <IOKit/graphics/IOGraphicsLib.h>
#import <ApplicationServices/ApplicationServices.h>
#import "DisplayIDAndName.h"
#import "DisplayData.h"

extern CGDisplayErr CGSGetDisplayList(CGDisplayCount maxDisplays,
                                       CGDirectDisplayID * onlineDspys,
                                       CGDisplayCount * dspyCnt);

@implementation MonitorDataSource

@synthesize display;

- (id) initWithDisplay:(CGDirectDisplayID)aDisplay useEnableList:(BOOL)useEnableList
{
    self = [super init];
    if (self != nil)
    {
        display = aDisplay;
        listToUse = useEnableList ? @"listEnable" : @"listDisable";
        dataItems = [[NSMutableArray alloc] init];
    }
    return self;
}

+(NSString*) screenNameForDisplay:(CGDirectDisplayID)displayID
{
    NSString *screenName = nil;
    
    io_service_t service = IOServicePortFromCGDisplayID(displayID);
    if (service)
    {
        NSDictionary *deviceInfo = CFBridgingRelease(IODisplayCreateInfoDictionary(service, kIODisplayOnlyPreferredName));
        NSDictionary *localizedNames = [deviceInfo objectForKey:[NSString stringWithUTF8String:kDisplayProductName]];
        
        if ([localizedNames count] > 0) {
            NSString* screenName2 = [[localizedNames allValues] objectAtIndex:0];
            screenName = [NSString stringWithFormat:@"%@", screenName2];
        }
        
        IOObjectRelease(service);
    }
    else
    {
        screenName = @"Unknown";
    }
    
    return screenName;
}

+(NSMutableArray*) GetSortedDisplays
{
    return [MonitorDataSource GetSortedDisplays:0];
}

+(NSMutableArray*) GetSortedDisplays:(CGDirectDisplayID)skipDisplayID
{
    CGDirectDisplayID    displays[0x10];
    CGDisplayCount  nDisplays = 0;
    
    CGDisplayErr err = CGSGetDisplayList(0x10, displays, &nDisplays);
    
    NSMutableArray *_displays = nil;
    if (err == 0 && nDisplays > 0)
    {
        _displays = [[NSMutableArray alloc] init];
        for (int i = 0; i < nDisplays; i++)
        {
            if (displays[i] == skipDisplayID)
                continue;
            NSString* name = [MonitorDataSource screenNameForDisplay:displays[i]];
            DisplayIDAndName* idAndName = [[DisplayIDAndName alloc] init];
            idAndName.id = displays[i];
            idAndName.name = name;
            [_displays addObject:idAndName];
        }
        
        [_displays sortUsingComparator:^NSComparisonResult(DisplayIDAndName* obj1, DisplayIDAndName* obj2) {
            if ([obj1 id] < [obj2 id])
                return NSOrderedAscending;
            else if ([obj1 id] > [obj2 id])
                return NSOrderedDescending;
            else
                return NSOrderedSame;
        }];
    }
    
    return _displays;
}

@end