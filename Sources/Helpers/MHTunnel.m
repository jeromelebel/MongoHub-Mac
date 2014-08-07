//
//  MHTunnel.m
//  MongoHub
//
//  Created by Jerome Lebel on 07/08/2014.
//

#import "MHTunnel.h"
#import <assert.h>
#import <errno.h>
#import <stdbool.h>
#import <stdlib.h>
#import <stdio.h>
#import <sys/sysctl.h>
#import <netinet/in.h>

#define SSH_PATH                    @"/usr/bin/ssh"

@interface MHTunnel ()
@property(nonatomic, assign, readwrite) MHTunnelError tunnelError;
@property(nonatomic, assign, readwrite, getter = isRunning) BOOL running;
@property(nonatomic, assign, readwrite, getter = isConnected) BOOL connected;
@end

@implementation MHTunnel

@synthesize name = _name;
@synthesize host = _host;
@synthesize port = _port;
@synthesize user = _user;
@synthesize password = _password;
@synthesize keyfile = _keyfile;
@synthesize aliveInterval = _aliveInterval;
@synthesize aliveCountMax = _aliveCountMax;
@synthesize tcpKeepAlive = _tcpKeepAlive;
@synthesize compression = _compression;
@synthesize additionalArgs = _additionalArgs;
@synthesize portForwardings = _portForwardings;
@synthesize delegate = _delegate;
@synthesize running = _running;
@synthesize tunnelError = _tunnelError;
@synthesize connected = _connected;

static BOOL testLocalPortAvailable(unsigned short port)
{
    CFSocketRef socket;
    struct sockaddr_in addr4;
	CFDataRef addressData;
    BOOL freePort;
    
    CFSocketContext socketCtxt = {0, [MHTunnel class], (const void*(*)(const void*))&CFRetain, (void(*)(const void*))&CFRelease, (CFStringRef(*)(const void *))&CFCopyDescription };
    socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, kCFSocketAcceptCallBack, (CFSocketCallBack)NULL, &socketCtxt);
    
    memset(&addr4, 0, sizeof(addr4));
    addr4.sin_len = sizeof(addr4);
    addr4.sin_family = AF_INET;
    addr4.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    addr4.sin_port = htons(port);
    addressData = CFDataCreateWithBytesNoCopy(NULL, (const UInt8*)&addr4, sizeof(addr4), kCFAllocatorNull);
    freePort = CFSocketSetAddress(socket, addressData) == kCFSocketSuccess;
    CFRelease(addressData);

    if (socket) {
        CFSocketInvalidate(socket);
        CFRelease(socket);
    }
    
    return freePort;
}

+ (unsigned short)findFreeTCPPort
{
    static unsigned short port = 40000;
    BOOL freePort = NO;
    
    while (port != 0 && !freePort) {
        port++;
        freePort = testLocalPortAvailable(port);
    }
    return port;
}

+ (NSString *)errorMessageForTunnelError:(MHTunnelError)error
{
    NSString *result = nil;
    
    switch (error) {
        case MHNoTunnelError:
            result = @"No error";
            break;
        case MHConnectionRefusedTunnelError:
            result = @"The ssh server refused the connection";
            break;
        case MHBadHostnameTunnelError:
            result = @"The host name cannot be resolved";
            break;
        case MHConnectionTimedOutTunnelError:
            result = @"The ssh server did not answer";
            break;
        case MHUnknownErrorTunnelError:
            result = @"Unknown error";
            break;
        case MHHostKeyErrorTunnelError:
            result = @"Host key verification failed";
            break;
        case MHWrongPasswordTunnelError:
            result = @"Wrong password";
            break;
        case MHHostIdentificationChangedTunnelError:
            result = @"REMOTE HOST IDENTIFICATION HAS CHANGED";
    }
    return result;
}

- (id)init
{
    if (self = [super init]) {
        self.portForwardings = [NSMutableArray array];
    }
    
    return (self);
}

- (void)dealloc
{
    [self stop];
    self.name = nil;
    self.host = nil;
    self.user = nil;
    self.password = nil;
    self.keyfile = nil;
    self.additionalArgs = nil;
    self.portForwardings = nil;
    [super dealloc];
}

- (void)_connected
{
    if (!_connected) {
        self.connected = YES;
        if ([_delegate respondsToSelector:@selector(tunnelDidConnect:)]) [_delegate tunnelDidConnect:self];
    }
}

- (NSDictionary *)environment
{
    NSMutableDictionary *result;
    
    result = [[NSMutableDictionary alloc] init];
    if (![_password isEqualToString:@""]) {
        [result setObject:[[NSBundle mainBundle] pathForResource:@"SSHCommand" ofType:@"sh"] forKey:@"SSH_ASKPASS"];
        [result setObject:_password forKey:@"SSHPASSWORD"];
    }
    [result setObject:@":0" forKey:@"DISPLAY"];
    [result setObject:[[[NSProcessInfo processInfo] environment] objectForKey:@"SSH_AUTH_SOCK"] forKey:@"SSH_AUTH_SOCK"];
    return [result autorelease];
}

- (void)start
{
    if (!self.isRunning) {
        NSPipe *errorPipe = [NSPipe pipe];
        
        self.tunnelError = MHNoTunnelError;
        self.running = YES;
        
        _task = [[NSTask alloc] init];
        _errorFileHandle = [[errorPipe fileHandleForReading] retain];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileHandleNotification:) name:NSFileHandleDataAvailableNotification object:_errorFileHandle];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(taskNotification:) name:NSTaskDidTerminateNotification object:_task];
        [_errorFileHandle waitForDataInBackgroundAndNotify];
        [_task setLaunchPath:SSH_PATH];
        [_task setArguments:[self prepareSSHCommandArgs]];
        [_task setEnvironment:[self environment]];
        [_task setStandardError:errorPipe];
        
        NSLog(@"%@ %@", _task.launchPath, [_task.arguments componentsJoinedByString:@" "]);
        
        [_task launch];
        if ([_delegate respondsToSelector:@selector(tunnelDidStart:)]) [_delegate tunnelDidStart:self];
    }
}

- (void)_releaseFileHandleAndTask
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSTaskDidTerminateNotification object:_task];
    [_task release];
    _task = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:_errorFileHandle];
    [_errorFileHandle release];
    _errorFileHandle = nil;
    if (self.running) {
        self.running = NO;
        self.connected = NO;
        if ([_delegate respondsToSelector:@selector(tunnelDidStop:)]) [_delegate tunnelDidStop:self];
    }
}

- (void)stop
{
    [_task terminate];
    [self _releaseFileHandleAndTask];
}

- (void)fileHandleNotification:(NSNotification *)notification
{
    if ([notification.name isEqualToString:NSFileHandleDataAvailableNotification] && notification.object == _errorFileHandle) {
        [self readStatusFromErrorPipe];
        [_errorFileHandle waitForDataInBackgroundAndNotify];
    }
}

- (void)taskNotification:(NSNotification *)notification
{
    [self readStatusFromErrorPipe];
    [self stop];
}

- (void)readStatusFromErrorPipe
{
    if (_running && self.tunnelError == MHNoTunnelError) {
        NSString *string = [[NSString alloc] initWithData:_errorFileHandle.availableData encoding:NSASCIIStringEncoding];
        if ([string rangeOfString:@"Entering interactive session"].location != NSNotFound) {
            [self _connected];
            return;
        } else if ([string rangeOfString:@"Host key verification failed"].location != NSNotFound) {
            self.tunnelError = MHHostKeyErrorTunnelError;
        } else if ([string rangeOfString:@"Connection refused"].location != NSNotFound) {
            self.tunnelError = MHConnectionRefusedTunnelError;
        } else if ([string rangeOfString:@"Operation timed out"].location != NSNotFound) {
            self.tunnelError = MHConnectionTimedOutTunnelError;
        } else if ([string rangeOfString:@"Could not resolve hostname"].location != NSNotFound) {
            self.tunnelError = MHBadHostnameTunnelError;
        } else if ([string rangeOfString:@"Permission denied"].location != NSNotFound) {
            self.tunnelError = MHWrongPasswordTunnelError;
        } else if ([string rangeOfString:@"REMOTE HOST IDENTIFICATION HAS CHANGED"].location != NSNotFound) {
            self.tunnelError = MHHostIdentificationChangedTunnelError;
        }
        NSLog(@"%@", string);
        if (self.tunnelError != MHNoTunnelError) {
            if ([_delegate respondsToSelector:@selector(tunnelDidFailToConnect:withError:)]) {
                [_delegate tunnelDidFailToConnect:self withError:[NSError errorWithDomain:MHTunnelDomain code:self.tunnelError userInfo:@{ NSLocalizedDescriptionKey: [self.class errorMessageForTunnelError:self.tunnelError] }]];
            }
        }
        [string release];
    }
}

- (NSArray *)prepareSSHCommandArgs
{
    NSMutableArray *result;
    
    result = [NSMutableArray array];
    for (NSString *pf in self.portForwardings) {
        NSArray* pfa = [pf componentsSeparatedByString:@":"];

        [result addObject:[NSString stringWithFormat:@"-%@", [pfa objectAtIndex:0]]];
        if (pfa.count == 4) {
            [result addObject:[NSString stringWithFormat:@"%@:%@:%@", [pfa objectAtIndex:1], [pfa objectAtIndex:2], [pfa objectAtIndex:3]]];
        } else if ([[pfa objectAtIndex:1] length] == 0) {
            [result addObject:[NSString stringWithFormat:@"%@:%@:%@", [pfa objectAtIndex:2], [pfa objectAtIndex:3], [pfa objectAtIndex:4]]];
        } else {
            [result addObject:[NSString stringWithFormat:@"%@:%@:%@:%@", [pfa objectAtIndex:1], [pfa objectAtIndex:2], [pfa objectAtIndex:3], [pfa objectAtIndex:4]]];
        }
    }
    
    [result addObject:@"-v"];
    [result addObject:@"-N"];
    [result addObject:@"-o"];
    [result addObject:@"ConnectTimeout=28"];
    [result addObject:@"-o"];
    [result addObject:@"NumberOfPasswordPrompts=1"];
	[result addObject:@"-o"];
    [result addObject:@"ConnectionAttempts=1"];
	[result addObject:@"-o"];
    [result addObject:@"ExitOnForwardFailure=yes"];
	[result addObject:@"-o"];
    [result addObject:@"StrictHostKeyChecking=no"];
    if (self.additionalArgs) {
        [result addObjectsFromArray:self.additionalArgs];
    }
    if (_aliveInterval > 0) {
        [result addObject:@"-o"];
        [result addObject:[NSString stringWithFormat:@"ServerAliveInterval=%d",_aliveInterval]];
    }
    if (_aliveCountMax > 0) {
        [result addObject:@"-o"];
        [result addObject:[NSString stringWithFormat:@"ServerAliveCountMax=%d",_aliveCountMax]];
    }
    if (self.tcpKeepAlive) {
        [result addObject:@"-o"];
        [result addObject:@"TCPKeepAlive=yes"];
    }
    if (self.compression) {
        [result addObject:@"-C"];
    }
    if (_port > 0) {
        [result addObject:@"-p"];
        [result addObject:[NSString stringWithFormat:@"%d", _port]];
    }
    if (_user.length > 0) {
        [result addObject:@"-l"];
        [result addObject:_user];
    }
    [result addObject:[NSString stringWithFormat:@"%@", _host]];
    if (![_keyfile isEqualToString:@""]) {
        [result addObject:@"-i"];
        [result addObject:_keyfile];
    }

    return result;
}

- (void)addForwardingPortWithBindAddress:(NSString *)bindAddress bindPort:(unsigned short)bindPort hostAddress:(NSString *)hostAddress hostPort:(unsigned short)hostPort reverseForwarding:(BOOL)reverseForwarding
{
    NSString *forwardPort;
    
    forwardPort = [[NSString alloc] initWithFormat:@"%@%@%@:%d:%@:%d", reverseForwarding?@"R":@"L", bindAddress?bindAddress:@"", bindAddress?@":":@"", (int)bindPort, hostAddress, (int)hostPort];
    [self.portForwardings addObject:forwardPort];
    [forwardPort release];
}

@end
