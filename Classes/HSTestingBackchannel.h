//
//  HSSnapshotChat.h
//  VLCRemote2
//
//  Created by Rob Jonson on 05/06/2015.
//
//

#import <Foundation/Foundation.h>

@interface HSTestingBackchannel : NSObject

/** Installs the receiver in your main app
 Call this in your appDidFinishLaunching... **/
+(void)installReceiver;

/** sends a notification from your testing class. Register to receive a notification with this name in your main app **/
+(void)sendNotification:(NSString*)notification;

@end

