//
//  MHTunnel.m
//  MongoHub
//
//  Created by Syd on 10-12-15.
//  Copyright 2010 ThePeppersStudio.COM. All rights reserved.
//

#import "MHTunnel.h"
#import <Security/Security.h>
#import "NSString+Extras.h"

#include <assert.h>
#include <errno.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <sys/sysctl.h>

typedef struct kinfo_proc kinfo_proc;

static int GetBSDProcessList(kinfo_proc **procList, size_t *procCount)
// Returns a list of all BSD processes on the system.  This routine
// allocates the list and puts it in *procList and a count of the
// number of entries in *procCount.  You are responsible for freeing
// this list (use "free" from System framework).
// On success, the function returns 0.
// On error, the function returns a BSD errno value.
{
    int                 err;
    kinfo_proc *        result;
    bool                done;
    static const int    name[] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0 };
    // Declaring name as const requires us to cast it when passing it to
    // sysctl because the prototype doesn't include the const modifier.
    size_t              length;
    
    assert( procList != NULL);
    assert(*procList == NULL);
    assert(procCount != NULL);
    
    *procCount = 0;
    
    // We start by calling sysctl with result == NULL and length == 0.
    // That will succeed, and set length to the appropriate length.
    // We then allocate a buffer of that size and call sysctl again
    // with that buffer.  If that succeeds, we're done.  If that fails
    // with ENOMEM, we have to throw away our buffer and loop.  Note
    // that the loop causes use to call sysctl with NULL again; this
    // is necessary because the ENOMEM failure case sets length to
    // the amount of data returned, not the amount of data that
    // could have been returned.
    
    result = NULL;
    done = false;
    do {
        assert(result == NULL);
        
        // Call sysctl with a NULL buffer.
        
        length = 0;
        err = sysctl( (int *) name, (sizeof(name) / sizeof(*name)) - 1,
                     NULL, &length,
                     NULL, 0);
        if (err == -1) {
            err = errno;
        }
        
        // Allocate an appropriately sized buffer based on the results
        // from the previous call.
        
        if (err == 0) {
            result = malloc(length);
            if (result == NULL) {
                err = ENOMEM;
            }
        }
        
        // Call sysctl again with the new buffer.  If we get an ENOMEM
        // error, toss away our buffer and start again.
        
        if (err == 0) {
            err = sysctl((int *) name, (sizeof(name) / sizeof(*name)) - 1,
                         result, &length,
                         NULL, 0);
            if (err == -1) {
                err = errno;
            }
            if (err == 0) {
                done = true;
            } else if (err == ENOMEM) {
                assert(result != NULL);
                free(result);
                result = NULL;
                err = 0;
            }
        }
    } while (err == 0 && ! done);
    
    // Clean up and establish post conditions.
    
    if (err != 0 && result != NULL) {
        free(result);
        result = NULL;
    }
    *procList = result;
    if (err == 0) {
        *procCount = length / sizeof(kinfo_proc);
    }
    
    assert( (err == 0) == (*procList != NULL) );
    
    return err;
}


static int GetFirstChildPID(int pid)
/*" Returns the parent process id 
 for the given process id (pid). "*/
{
    int pidFound = -1;
    
    kinfo_proc* plist = nil;
    size_t len = 0;
    GetBSDProcessList(&plist,&len);
    
    if (plist != nil) {
        for (int i = 0;i<len;i++) {
            if (plist[i].kp_eproc.e_ppid == pid) {
                pidFound = plist[i].kp_proc.p_pid;
                break;
            }
        }
        
        free(plist);
    }
    
    return pidFound;
}

@implementation MHTunnel

@synthesize uid;
@synthesize name;
@synthesize host;
@synthesize port;
@synthesize user;
@synthesize password;
@synthesize keyfile;
@synthesize aliveInterval;
@synthesize aliveCountMax;
@synthesize tcpKeepAlive;
@synthesize compression;
@synthesize additionalArgs;
@synthesize portForwardings;
@synthesize delegate;

- (id)init
{
    if (self = [super init]) {
        uid = [[NSString UUIDString] retain];
        
        portForwardings = [[NSMutableArray alloc] init];
        isRunning = NO;
    }
    
    return (self);
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [self init]) {
        uid = [coder decodeObjectForKey:@"uid"];
        name = [coder decodeObjectForKey:@"name"];
        host = [coder decodeObjectForKey:@"host"];
        port = [coder decodeIntForKey:@"port"];
        user = [coder decodeObjectForKey:@"user"];
        password = [coder decodeObjectForKey:@"password"];
        keyfile = [coder decodeObjectForKey:@"keyfile"];
        aliveInterval = [coder decodeIntForKey:@"aliveInterval"];
        aliveCountMax = [coder decodeIntForKey:@"aliveCountMax"];
        tcpKeepAlive = [coder decodeBoolForKey:@"tcpKeepAlive"];
        compression = [coder decodeBoolForKey:@"compression"];
        additionalArgs = [coder decodeObjectForKey:@"additionalArgs"];
        portForwardings = [coder decodeObjectForKey:@"portForwardings"];
        
        [self tunnelLoaded];
    }
    
    return (self);
}

- (void)dealloc
{
    [self stop];
    self.uid = nil;
    self.name = nil;
    self.host = nil;
    self.user = nil;
    self.password = nil;
    self.keyfile = nil;
    self.additionalArgs = nil;
    self.portForwardings = nil;
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:uid forKey:@"uid"];
    [coder encodeObject:name forKey:@"name"];
    [coder encodeObject:host forKey:@"host"];
    [coder encodeInt:port forKey:@"port"];
    [coder encodeObject:user forKey:@"user"];
    [coder encodeObject:password forKey:@"password"];
    [coder encodeObject:keyfile forKey:@"keyfile"];
    [coder encodeInt:aliveInterval forKey:@"aliveInterval"];
    [coder encodeInt:aliveCountMax forKey:@"aliveCountMax"];
    [coder encodeBool:tcpKeepAlive forKey:@"tcpKeepAlive"];
    [coder encodeBool:compression forKey:@"compression"];
    [coder encodeObject:additionalArgs forKey:@"additionalArgs"];
    [coder encodeObject:portForwardings forKey:@"portForwardings"];
    
    [self tunnelSaved];
}

- (void)start
{
    @synchronized(self) {
        NSPipe *pipe;
        isRunning = YES;
        
        _task = [[NSTask alloc] init];
        pipe = [NSPipe pipe];
        
        _fileHandle = [[pipe fileHandleForReading] retain];
        [_task setLaunchPath:[[NSBundle bundleForClass:[self class]] pathForResource:@"SSHCommand" ofType:@"sh"]];
        [_task setArguments:[self prepareSSHCommandArgs] ];
        [_task setStandardOutput:pipe];
        //The magic line that keeps your log where it belongs
        [_task setStandardInput:[NSPipe pipe]];
        
        [_task launch];
        /*NSData *output = [[pipe fileHandleForReading] readDataToEndOfFile];
        NSString *string = [[[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding] autorelease];
        
        NSLog(@"\n%@\n", string);*/
        pipeData = [[NSMutableString alloc] init];
        retStatus = @"";
        [delegate tunnelStatusChanged:self status:@"START"];
    }
}

- (void)stop
{
    @synchronized(self) {
        isRunning = NO;
        
        if ([_task isRunning]) {
            int chpid = GetFirstChildPID([_task processIdentifier]);
            if(chpid != -1) {
                kill(chpid,  SIGTERM);
            }
            [_task terminate];
            [_task release];
            _task = nil;
            [_fileHandle release];
            _fileHandle = nil;
            [pipeData release];
            pipeData = nil;
        }
        [delegate tunnelStatusChanged:self status:@"STOP"];
    }
}

- (BOOL)running
{
    return isRunning;
}

- (void)readStatus
{
    @synchronized(self) {
        if (isRunning && [retStatus isEqualToString:@""]) {
            NSString *pipeStr = [[NSString alloc] initWithData:[_fileHandle availableData] encoding:NSASCIIStringEncoding];
            //NSLog(@"%@", pipeStr);
            [pipeData appendString:pipeStr];
            [pipeStr release];
            NSRange r = [pipeData rangeOfString:@"CONNECTED"];
            if (r.location != NSNotFound) {
                retStatus = @"CONNECTED";
                
                [delegate tunnelStatusChanged:self status:retStatus];
                return;
            }
            
            r = [pipeData rangeOfString:@"CONNECTION_ERROR"];
            if (r.location != NSNotFound) {
                retStatus = @"CONNECTION_ERROR";
                
                [delegate tunnelStatusChanged:self status:retStatus];
                return;
            }
            
            r = [pipeData rangeOfString:@"CONNECTION_REFUSED"];
            if (r.location != NSNotFound) {
                retStatus = @"CONNECTION_REFUSED";
                
                [delegate tunnelStatusChanged:self status:retStatus];
                return;
            }
            
            r = [pipeData rangeOfString:@"WRONG_PASSWORD"];
            if (r.location != NSNotFound) {
                retStatus = @"WRONG_PASSWORD";
                
                [delegate tunnelStatusChanged:self status:retStatus];
                return;
            }
            /*if( [[NSDate date] timeIntervalSinceDate:startDate] > 30 ){
                retStatus = @"TIME_OUT";
                
                [delegate tunnelStatusChanged:self status:retStatus];
                
                return;
            }*/
        }
    }
}

- (BOOL)checkProcess
{
    BOOL ret = NO;
    @synchronized(self) {
        ret = isRunning;
        if (ret) {
            ret = GetFirstChildPID([_task processIdentifier]) != -1;
        }
    }
    
    return ret;
}

- (NSArray *)prepareSSHCommandArgs
{
    NSMutableString *pfs = [[NSMutableString alloc] init];
    NSArray *result;
    
    for (NSString *pf in portForwardings) {
        NSArray* pfa = [pf componentsSeparatedByString:@":"];
        if ([[pfa objectAtIndex:1] isEqualToString:@"127.0.0.1"]) {
            [pfs appendFormat:@"%@ -%@ %@:%@:%@", pfs, [pfa objectAtIndex:0], [pfa objectAtIndex:2], [pfa objectAtIndex:3], [pfa objectAtIndex:4]];
        } else {
            [pfs appendFormat:@"%@ -%@ %@:%@:%@:%@", pfs, [pfa objectAtIndex:0], [pfa objectAtIndex:1], [pfa objectAtIndex:2], [pfa objectAtIndex:3], [pfa objectAtIndex:4]];
        }
    }
    
    NSString* cmd;
    if ([password isNotEqualTo:@""]|| [keyfile isEqualToString:@""]) {
        cmd = [[NSString alloc] initWithFormat:@"ssh -N -o ConnectTimeout=28 %@%@%@%@%@%@-p %d %@@%@",
               [additionalArgs length] > 0 ? [NSString stringWithFormat:@"%@ ", additionalArgs] :@"",
               [pfs length] > 0 ? [NSString stringWithFormat:@"%@ ",pfs] : @"",
               aliveInterval > 0 ? [NSString stringWithFormat:@"-o ServerAliveInterval=%d ",aliveInterval] : @"",
               aliveCountMax > 0 ? [NSString stringWithFormat:@"-o ServerAliveCountMax=%d ",aliveCountMax] : @"",
               tcpKeepAlive == YES ? @"-o TCPKeepAlive=yes " : @"",
               compression == YES ? @"-C " : @"",
               port,user,host];
    } else {
        cmd = [[NSString alloc] initWithFormat:@"ssh -N -o ConnectTimeout=28 %@%@%@%@%@%@-p %d -i %@ %@@%@",
               [additionalArgs length] > 0 ? [NSString stringWithFormat:@"%@ ", additionalArgs] : @"",
               [pfs length] > 0 ? [NSString stringWithFormat:@"%@ ",pfs] : @"",
               aliveInterval > 0 ? [NSString stringWithFormat:@"-o ServerAliveInterval=%d ",aliveInterval] : @"",
               aliveCountMax > 0 ? [NSString stringWithFormat:@"-o ServerAliveCountMax=%d ",aliveCountMax] : @"",
               tcpKeepAlive == YES ? @"-o TCPKeepAlive=yes " : @"",
               compression == YES ? @"-C " : @"",
               port,keyfile,user,host];
    }

    
    NSLog(@"cmd: %@", cmd);
    result = [NSArray arrayWithObjects:cmd, password, nil];
    [pfs release];
    [cmd release];
    return result;
}

- (void)tunnelLoaded
{
    if (uid == nil || [uid length] == 0) {
        CFUUIDRef uidref = CFUUIDCreate(nil);
        uid = (NSString *)CFUUIDCreateString(nil, uidref);
        CFRelease(uidref);
    }
    
    if ([self keychainItemExists]) {
        password = [self keychainGetPassword];
    } else {
        password = @"";
    }
}

- (void)tunnelSaved
{
    if ([self keychainItemExists]) {
        [self keychainModifyItem];
    } else {
        [self keychainAddItem];
    }
}

- (void)tunnelRemoved
{
    if([self keychainItemExists]) {
        [self keychainDeleteItem];
    }
}

- (BOOL)keychainItemExists
{
    SecKeychainSearchRef search;
    SecKeychainAttributeList list;
    SecKeychainAttribute attributes[3];
    
    NSString *keychainItemName = [NSString stringWithFormat:@"SSHTunnel <%@>", uid];
    NSString *keychainItemKind = @"application password";
    
    attributes[0].tag = kSecAccountItemAttr;
    attributes[0].data = (void *)[uid UTF8String];
    attributes[0].length = [uid length];
    
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[1].data = (void *)[keychainItemKind UTF8String];
    attributes[1].length = [keychainItemKind length];
    
    attributes[2].tag = kSecLabelItemAttr;
    attributes[2].data = (void *)[keychainItemName UTF8String];
    attributes[2].length = [keychainItemName length];
    
    list.count = 3;
    list.attr = attributes;
    
    OSErr result = SecKeychainSearchCreateFromAttributes(NULL, kSecGenericPasswordItemClass, &list, &search);
    
    if (result != noErr) {
        NSLog (@"Error status %d from SecKeychainSearchCreateFromAttributes\n", result);
        return FALSE;
    }
    
    uint itemsFound = 0;
    SecKeychainItemRef item;
    
    while (SecKeychainSearchCopyNext(search, &item) == noErr) {
        CFRelease (item);
        itemsFound++;
    }
    
    CFRelease (search);
    return itemsFound > 0;
}

- (BOOL)keychainAddItem
{
    SecKeychainItemRef item;
    SecKeychainAttributeList list;
    SecKeychainAttribute attributes[3];
    
    NSString *keychainItemName = [NSString stringWithFormat:@"SSHTunnel <%@>", uid];
    NSString *keychainItemKind = @"application password";
    
    attributes[0].tag = kSecAccountItemAttr;
    attributes[0].data = (void *)[uid UTF8String];
    attributes[0].length = [uid length];
    
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[1].data = (void *)[keychainItemKind UTF8String];
    attributes[1].length = [keychainItemKind length];
    
    attributes[2].tag = kSecLabelItemAttr;
    attributes[2].data = (void *)[keychainItemName UTF8String];
    attributes[2].length = [keychainItemName length];    
    
    list.count = 3;
    list.attr = attributes;
    
    OSStatus status = SecKeychainItemCreateFromContent(kSecGenericPasswordItemClass, &list, [password length], [password UTF8String], NULL,NULL,&item);
    if (status != 0) {
        NSLog(@"Error creating new item: %d for %@\n", (int)status, keychainItemName);
    }
    
    return !status;
}

- (BOOL)keychainModifyItem
{
    SecKeychainItemRef item;
    SecKeychainSearchRef search;
    OSStatus status;
    OSErr result;
    SecKeychainAttributeList list;
    SecKeychainAttribute attributes[3];
    
    NSString *keychainItemName = [NSString stringWithFormat:@"SSHTunnel <%@>", uid];
    NSString *keychainItemKind = @"application password";
    
    attributes[0].tag = kSecAccountItemAttr;
    attributes[0].data = (void *)[uid UTF8String];
    attributes[0].length = [uid length];
    
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[1].data = (void *)[keychainItemKind UTF8String];
    attributes[1].length = [keychainItemKind length];
    
    attributes[2].tag = kSecLabelItemAttr;
    attributes[2].data = (void *)[keychainItemName UTF8String];
    attributes[2].length = [keychainItemName length];
    
    list.count = 3;
    list.attr = attributes;
    
    result = SecKeychainSearchCreateFromAttributes(NULL, kSecGenericPasswordItemClass, &list, &search);
    NSLog(@"%@", result);
    SecKeychainSearchCopyNext (search, &item);
    status = SecKeychainItemModifyContent(item, &list, [password length], [password UTF8String]);
    
    if (status != 0) {
        NSLog(@"Error modifying item: %d", (int)status);
    }
    
    CFRelease (item);
    CFRelease(search);
    
    return !status;
}

- (BOOL)keychainDeleteItem
{
    SecKeychainItemRef item;
    SecKeychainSearchRef search;
    OSStatus status = 0;
    OSErr result;
    SecKeychainAttributeList list;
    SecKeychainAttribute attributes[3];
    uint itemsFound = 0;
    
    NSString *keychainItemName = [NSString stringWithFormat:@"SSHTunnel <%@>", uid];
    NSString *keychainItemKind = @"application password";
    
    attributes[0].tag = kSecAccountItemAttr;
    attributes[0].data = (void *)[uid UTF8String];
    attributes[0].length = [uid length];
    
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[1].data = (void *)[keychainItemKind UTF8String];
    attributes[1].length = [keychainItemKind length];
    
    attributes[2].tag = kSecLabelItemAttr;
    attributes[2].data = (void *)[keychainItemName UTF8String];
    attributes[2].length = [keychainItemName length];
    
    list.count = 3;
    list.attr = attributes;
    
    result = SecKeychainSearchCreateFromAttributes(NULL, kSecGenericPasswordItemClass, &list, &search);
    NSLog(@"%@", result);
    while (SecKeychainSearchCopyNext (search, &item) == noErr) {
        itemsFound++;
    }
    if (itemsFound) {
        status = SecKeychainItemDelete(item);
    }
    
    if (status != 0) {
        NSLog(@"Error deleting item: %d\n", (int)status);
    }
    CFRelease (item);
    CFRelease (search);
    
    return !status;
}

- (NSString *)keychainGetPassword
{
    SecKeychainItemRef item;
    SecKeychainSearchRef search;
    OSErr result;
    SecKeychainAttributeList list;
    SecKeychainAttribute attributes[3];
    
    NSString *keychainItemName = [NSString stringWithFormat:@"SSHTunnel <%@>", uid];
    NSString *keychainItemKind = @"application password";
    
    attributes[0].tag = kSecAccountItemAttr;
    attributes[0].data = (void *)[uid UTF8String];
    attributes[0].length = [uid length];
    
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[1].data = (void *)[keychainItemKind UTF8String];
    attributes[1].length = [keychainItemKind length];
    
    attributes[2].tag = kSecLabelItemAttr;
    attributes[2].data = (void *)[keychainItemName UTF8String];
    attributes[2].length = [keychainItemName length];
    
    
    list.count = 3;
    list.attr = attributes;
    
    result = SecKeychainSearchCreateFromAttributes(NULL, kSecGenericPasswordItemClass, &list, &search);
    
    if (result != noErr) {
        NSLog(@"status %d from SecKeychainSearchCreateFromAttributes\n", result);
    }
    
    NSString *pass = @"";
    if (SecKeychainSearchCopyNext (search, &item) == noErr) {
        pass = [self keychainGetPasswordFromItemRef:item];
        if(!pass) {
            pass = @"";
        }
        CFRelease (item);
        CFRelease (search);
    }
    
    return pass;
}

- (NSString *)keychainGetPasswordFromItemRef:(SecKeychainItemRef)item
{
    NSString *retPass = nil;
    
    UInt32 length;
    char *pass;
    SecKeychainAttribute attributes[8];
    SecKeychainAttributeList list;
    OSStatus status;
    
    attributes[0].tag = kSecAccountItemAttr;
    attributes[1].tag = kSecDescriptionItemAttr;
    attributes[2].tag = kSecLabelItemAttr;
    attributes[3].tag = kSecModDateItemAttr;
    
    list.count = 4;
    list.attr = attributes;
    
    status = SecKeychainItemCopyContent (item, NULL, &list, &length, (void **)&pass);
    
    if (status == noErr) {
        if (pass != NULL) {
            
            // copy the password into a buffer so we can attach a
            // trailing zero byte in order to be able to print
            // it out with printf
            char passwordBuffer[1024];
            
            if (length > 1023) {
                length = 1023; // save room for trailing \0
            }
            strncpy (passwordBuffer, pass, length);
            
            passwordBuffer[length] = '\0';
            
            retPass = [NSString stringWithUTF8String:passwordBuffer];
        }
        
        SecKeychainItemFreeContent (&list, pass);
        
        return retPass;
    } else {
        printf("Error getting password = %d\n", (int)status);
        return @"";
    }
}

@end
