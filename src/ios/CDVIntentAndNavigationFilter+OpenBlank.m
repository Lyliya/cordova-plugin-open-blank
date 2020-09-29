/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "CDVIntentAndNavigationFilter+OpenBlank.h"
#import <Cordova/CDV.h>
#import "CDVWKInAppBrowser.h"

@implementation CDVIntentAndNavigationFilter (OpenBlank)

#define CDVWebViewNavigationType int
#define CDVWebViewNavigationTypeLinkClicked 0
#define CDVWebViewNavigationTypeReload -1

#pragma mark CDVPlugin

- (void)pluginInitialize
{
    if ([self.viewController isKindOfClass:[CDVViewController class]]) {
        [(CDVViewController*)self.viewController parseSettingsWithParser:self];
    }
}

- (BOOL)shouldOverrideLoadWithRequest:(NSURLRequest*)request navigationType:(CDVWebViewNavigationType)navigationType
{
    BOOL allowNavigationsPass = YES;

    NSString *urlNavigationTarget = request.URL.absoluteString;

    // NSLog(@"UrlNavigation: %@", urlNavigationTarget);

    if(![urlNavigationTarget hasPrefix:@"http"]) {
        // NSLog(@"dont have http prefix");
        return YES;
    }
    NSString *urlMainDocument = request.mainDocumentURL.absoluteString;
    NSRange rangeMainDocument = [ urlMainDocument rangeOfString:@"ionic://"];
    urlMainDocument = [urlMainDocument stringByReplacingOccurrencesOfString:@"ionic://" withString:@""];
    
    NSRange rangeNavigationTarget = [ urlNavigationTarget rangeOfString:urlMainDocument];
    bool navigateTargetOutside = rangeNavigationTarget.location == NSNotFound;

    // NSLog(@"UrlMainDocument: %@", urlMainDocument);
    
    bool mainDocumentOutside = rangeMainDocument.location == NSNotFound;
    bool isLinkClick = navigationType  == CDVWebViewNavigationTypeLinkClicked;
    bool isReload = (navigationType & CDVWebViewNavigationTypeReload) == CDVWebViewNavigationTypeReload;
    
    NSLog(@"Navigate TargetOutside: %d, isLinkClick: %d, isReload: %d, mainDocumentOutside: %d", navigateTargetOutside, isLinkClick, isReload, mainDocumentOutside);
    if (navigateTargetOutside && isLinkClick && (!isReload || mainDocumentOutside)) {
        // [self.commandDelegate evalJs:@"console.log('no')"];
        allowNavigationsPass = NO;
       // [[UIApplication sharedApplication] openURL:request.URL options:@{} completionHandler:nil];
        NSString *jsString = [NSString stringWithFormat:@"cordova.InAppBrowser.open('%@','_system');",urlNavigationTarget];
        //
        // NSString *jsString = [NSString stringWithFormat:@"SafariViewController.show({url:\"%@\"});",urlNavigationTarget];
        [self.commandDelegate evalJs:jsString];
    }

    return allowNavigationsPass;
}

@end
