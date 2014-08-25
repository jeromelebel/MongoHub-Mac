//
//  Tunnel.h
//  MongoHub
//
//  Created by Jerome Lebel on 07/08/2014.
//

#import <Foundation/Foundation.h>

@class MHTunnel;

#define MHTunnelDomain @"MHTunnelDomain"

typedef enum {
    MHNoTunnelError = 0,
    MHConnectionRefusedTunnelError,
    MHConnectionTimedOutTunnelError,
    MHUnknownErrorTunnelError,
    MHBadHostnameTunnelError,
    MHHostKeyErrorTunnelError,
    MHWrongPasswordTunnelError,
    MHHostIdentificationChangedTunnelError,
} MHTunnelError;

@protocol MHTunnelDelegate<NSObject>
@optional
- (void)tunnelDidStart:(MHTunnel *)tunnel;
- (void)tunnelDidConnect:(MHTunnel *)tunnel;
- (void)tunnelDidStop:(MHTunnel *)tunnel;
- (void)tunnelDidFailToConnect:(MHTunnel *)tunnel withError:(NSError *)error;
@end

@interface MHTunnel : NSObject
{
	id<MHTunnelDelegate>            _delegate;
	
	NSTask                          *_task;
	NSFileHandle                    *_errorFileHandle;
	MHTunnelError                   _tunnelError;
	BOOL                            _running;
	BOOL                            _connected;
    BOOL                            _verbose;
	
	NSString                        *_name;
	NSString                        *_host;
	int                             _port;
	NSString                        *_user;
	NSString                        *_password;
	NSString                        *_keyfile;
	int                             _aliveInterval;
	int                             _aliveCountMax;
	BOOL                            _tcpKeepAlive;
	BOOL                            _compression;
	NSArray                         *_additionalArgs;
	NSMutableArray                  *_portForwardings;
}

@property (nonatomic, retain, readwrite) NSString* name;
@property (nonatomic, retain, readwrite) NSString* host;
@property (nonatomic, assign, readwrite) int port;
@property (nonatomic, retain, readwrite) NSString* user;
@property (nonatomic, retain, readwrite) NSString* password;
@property (nonatomic, retain, readwrite) NSString* keyfile;
@property (nonatomic, assign, readwrite) int aliveInterval;
@property (nonatomic, assign, readwrite) int aliveCountMax;
@property (nonatomic, assign, readwrite) BOOL tcpKeepAlive;
@property (nonatomic, assign, readwrite) BOOL compression;
@property (nonatomic, retain, readwrite) NSArray* additionalArgs;
@property (nonatomic, retain, readwrite) NSMutableArray* portForwardings;
@property (nonatomic, assign, readwrite) id<MHTunnelDelegate> delegate;
@property (nonatomic, assign, readonly, getter = isRunning) BOOL running;
@property (nonatomic, assign, readonly, getter = isConnected) BOOL connected;
@property (nonatomic, assign, readwrite) BOOL verbose;
@property (nonatomic, assign, readonly) MHTunnelError tunnelError;

+ (unsigned short)findFreeTCPPort;
+ (NSString *)errorMessageForTunnelError:(MHTunnelError)error;

- (void)start;
- (void)stop;

- (void)addForwardingPortWithBindAddress:(NSString *)bindAddress bindPort:(unsigned short)bindPort hostAddress:(NSString *)hostAddress hostPort:(unsigned short)hostPort reverseForwarding:(BOOL)reverseForwarding;

@end
