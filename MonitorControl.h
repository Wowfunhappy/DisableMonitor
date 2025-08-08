#ifndef MonitorControl_h
#define MonitorControl_h

#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

void toggleMonitor(CGDirectDisplayID displayID, Boolean enabled);
bool isDisplayEnabled(CGDirectDisplayID displayID);

#endif /* MonitorControl_h */