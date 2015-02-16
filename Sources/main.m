//
//  main.m
//  MongoHub
//
//  Created by Syd on 10-4-24.
//  Copyright MusicPeace.ORG 2010. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#if MAC_OS_X_VERSION_MIN_REQUIRED != MAC_OS_X_VERSION_10_8
#error You need to set <OS X Deployment Target> to <10.8>
#endif

int main(int argc, char *argv[])
{
    return NSApplicationMain(argc,  (const char **) argv);
}
