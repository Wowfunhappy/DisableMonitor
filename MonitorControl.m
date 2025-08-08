#import "MonitorControl.h"
#import <IOKit/IOKitLib.h>
#import "DisplayData.h"

extern CGError CGSConfigureDisplayEnabled(CGDisplayConfigRef config, CGDirectDisplayID display, bool enabled);

bool isDisplayEnabled(CGDirectDisplayID displayID)
{
    if (!CGDisplayIsOnline(displayID))
        return NO;
    if (CGDisplayIsActive(displayID) == NO)
    {
        if (CGDisplayIsInMirrorSet(displayID))
            return YES;
        else
            return NO;
    }
    return YES;
}

void toggleMonitor(CGDirectDisplayID displayID, Boolean enabled)
{
    CGError err;
    CGDisplayConfigRef config;
    @try {
        usleep(1000*1000); // sleep 1000 ms
        
        err = CGBeginDisplayConfiguration(&config);
        if (err != 0)
        {
            fprintf(stderr, "Error in CGBeginDisplayConfiguration: %d\n", err);
            return;
        }
        
        bool mirror = CGDisplayIsInMirrorSet(displayID);
        if (enabled == false && mirror)
        {
            CGConfigureDisplayMirrorOfDisplay(config, displayID, kCGNullDirectDisplay);
        }
        
        err = CGSConfigureDisplayEnabled(config, displayID, enabled);
        if (err != 0)
        {
            fprintf(stderr, "Error in CGSConfigureDisplayEnabled: %d\n", err);
            return;
        }
        
        if (!mirror)
        {
            CGConfigureDisplayFadeEffect(config, 0, 0, 0, 0, 0);
            
            io_registry_entry_t entry = IORegistryEntryFromPath(kIOMasterPortDefault, "IOService:/IOResources/IODisplayWrangler");
            if (entry)
            {
                IORegistryEntrySetCFProperty(entry, CFSTR("IORequestIdle"), kCFBooleanTrue);
                usleep(100*1000); // sleep 100 ms
                IORegistryEntrySetCFProperty(entry, CFSTR("IORequestIdle"), kCFBooleanFalse);
                IOObjectRelease(entry);
            }
        }
        
        err = CGCompleteDisplayConfiguration(config, kCGConfigurePermanently);
        if (err != 0)
        {
            fprintf(stderr, "Error in CGCompleteDisplayConfiguration: %d\n", err);
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception:");
        NSLog(@"Name: %@", exception.name);
        NSLog(@"Reason: %@", exception.reason);
    }
}