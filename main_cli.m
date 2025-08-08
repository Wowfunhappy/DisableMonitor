#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>
#import "MonitorDataSource_CLI.h"
#import "MonitorControl.h"
#import "DisplayIDAndName.h"
#import "DisplayData.h"

int cmd_list(void)
{
    NSMutableArray *dict = [MonitorDataSource GetSortedDisplays];
    if (dict == nil)
    {
        printf("No Displays found\n");
    }
    else
    {
        printf(" ID         Name\n");
        printf("----------- -----------------\n");
        for (DisplayIDAndName* idAndName in dict)
        {
            printf(" %-10u %s\n", [idAndName id], [[idAndName name] UTF8String]);
        }
        printf("----------- -----------------\n");
    }
    return 0;
}

int cmd_disable(CGDirectDisplayID displayID)
{
    CGDisplayCount nDisplays = 0;
    CGDirectDisplayID displayList[0x10];
    CGDisplayErr err = CGSGetDisplayList(0x10, displayList, &nDisplays);
    
    if (err == 0 && nDisplays > 0)
    {
        for (int i = 0; i < nDisplays; i++)
        {
            if (displayList[i] == displayID)
            {
                if (CGDisplayIsOnline(displayID) && CGDisplayIsActive(displayID))
                {
                    toggleMonitor(displayID, NO);
                    printf("Display %u disabled.\n", displayID);
                    return 0;
                }
                else
                {
                    printf("Display %u is already disabled or offline.\n", displayID);
                    return 1;
                }
            }
        }
    }
    printf("Could not find display %u!\n", displayID);
    return 1;
}

int cmd_enable(CGDirectDisplayID displayID)
{
    CGDisplayCount nDisplays = 0;
    CGDirectDisplayID displayList[0x10];
    CGDisplayErr err = CGSGetDisplayList(0x10, displayList, &nDisplays);
    
    if (err == 0 && nDisplays > 0)
    {
        for (int i = 0; i < nDisplays; i++)
        {
            if (displayList[i] == displayID)
            {
                if (CGDisplayIsOnline(displayID) && !CGDisplayIsActive(displayID))
                {
                    toggleMonitor(displayID, YES);
                    printf("Display %u enabled.\n", displayID);
                    return 0;
                }
                else
                {
                    printf("Display %u is already enabled or offline.\n", displayID);
                    return 1;
                }
            }
        }
    }
    printf("Could not find display %u!\n", displayID);
    return 1;
}

int cmd_help(void)
{
    printf(
           "usage: disablemonitor [options]\n"
           "Options:\n"
           "  -l, --list         List all attached monitors\n"
           "  -d, --disable ID   Disable monitor with specified ID\n"
           "  -e, --enable ID    Enable monitor with specified ID\n"
           "  -h, --help         Show this help\n\n"
           "Examples:\n"
           "  disablemonitor -l              # List all monitors\n"
           "  disablemonitor -d 69734662     # Disable monitor with ID 69734662\n"
           "  disablemonitor -e 69734662     # Enable monitor with ID 69734662\n"
    );
    return 0;
}

int main(int argc, char *argv[])
{
    @autoreleasepool {
        if (argc < 2) {
            cmd_help();
            return 1;
        }
        
        NSString *command = [NSString stringWithUTF8String:argv[1]];
        
        if ([command isEqualToString:@"--list"] ||
            [command isEqualToString:@"-l"])
        {
            return cmd_list();
        }
        else if ([command isEqualToString:@"--disable"] ||
                 [command isEqualToString:@"-d"])
        {
            if (argc < 3) {
                fprintf(stderr, "Error: Display ID required for disable command\n");
                cmd_help();
                return 1;
            }
            CGDirectDisplayID displayID = (CGDirectDisplayID)atoi(argv[2]);
            return cmd_disable(displayID);
        }
        else if ([command isEqualToString:@"--enable"] ||
                 [command isEqualToString:@"-e"])
        {
            if (argc < 3) {
                fprintf(stderr, "Error: Display ID required for enable command\n");
                cmd_help();
                return 1;
            }
            CGDirectDisplayID displayID = (CGDirectDisplayID)atoi(argv[2]);
            return cmd_enable(displayID);
        }
        else if ([command isEqualToString:@"--help"] ||
                 [command isEqualToString:@"-h"])
        {
            return cmd_help();
        }
        else
        {
            fprintf(stderr, "Unknown command: %s\n", argv[1]);
            cmd_help();
            return 1;
        }
    }
    
    return 0;
}