#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

@interface MonitorDataSource : NSObject
{
    NSMutableArray *dataItems;
    NSString *listToUse;
}
@property CGDirectDisplayID display;
- (id) initWithDisplay:(CGDirectDisplayID)aDisplay useEnableList:(BOOL)useEnableList;
+(NSString*) screenNameForDisplay:(CGDirectDisplayID)displayID;
+(NSMutableArray*) GetSortedDisplays;
+(NSMutableArray*) GetSortedDisplays:(CGDirectDisplayID)skipDisplayID;
@end