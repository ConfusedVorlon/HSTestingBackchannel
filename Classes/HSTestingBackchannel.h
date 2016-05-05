//
//  HSSnapshotChat.h
//  VLCRemote2
//
//  Created by Rob Jonson on 05/06/2015.
//
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    HSTestingDocuments,
    HSTestingResources
} HSTestingDestination;

@interface HSTestingBackchannel : NSObject

/** Installs the receiver in your main app
 Call this in your appDidFinishLaunching... **/
+(void)installReceiver;

/** Copies the contents of directoryPath (including any folders) to destination in the app running on the simulator. **/
+(void)installFilesFrom:(NSString*)directoryPath to:(HSTestingDestination)destination;

/** sends a notification from your testing class. Register to receive a notification with this name in your main app **/
+(void)sendNotification:(NSString*)notification;

/** sends a notification from your testing class. Sends the dictionary as userInfo 
 @param notification the name of the broadcast notification
 @param dictionary dictionary to send in userInfo. Keys and values must be strings;
 **/
+(void)sendNotification:(NSString*)notification withDictionary:(NSDictionary*)dictionary;

/** wait for a bit
 @param delay Seconds to wait
 **/
+(void)wait:(NSTimeInterval)delay;

@end

