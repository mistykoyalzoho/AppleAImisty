#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>

@implementation NSWindow (Swizzle)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class windowClass = [self class];
        Method originalWindowMethod = class_getInstanceMethod(windowClass, @selector(initWithContentRect:styleMask:backing:defer:));
        Method swizzledWindowMethod = class_getInstanceMethod(windowClass, @selector(swizzled_initWithContentRect:styleMask:backing:defer:));
        method_exchangeImplementations(originalWindowMethod, swizzledWindowMethod);
        
        Class webViewClass = [WKWebView class];
        Method originalLoad = class_getInstanceMethod(webViewClass, @selector(loadRequest:));
        Method swizzledLoad = class_getInstanceMethod(webViewClass, @selector(swizzled_loadRequest:));
        method_exchangeImplementations(originalLoad, swizzledLoad);
        
        Class workspaceClass = [NSWorkspace class];
        Method originalOpen = class_getInstanceMethod(workspaceClass, @selector(openURL:));
        Method swizzledOpen = class_getInstanceMethod(workspaceClass, @selector(swizzled_openURL:));
        method_exchangeImplementations(originalOpen, swizzledOpen);
        
        Class defaultsClass = [NSUserDefaults class];
        Method originalBool = class_getInstanceMethod(defaultsClass, @selector(boolForKey:));
        Method swizzledBool = class_getInstanceMethod(defaultsClass, @selector(swizzled_boolForKey:));
        method_exchangeImplementations(originalBool, swizzledBool);
    });
}

- (instancetype)swizzled_initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag {
    style |= NSWindowStyleMaskResizable;
    return [self swizzled_initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag];
}
@end

@implementation WKWebView (Swizzle)
- (WKNavigation *)swizzled_loadRequest:(NSURLRequest *)request {
    if ([request.URL.host containsString:@"gemini.google.com"]) {
        self.customUserAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15";
    } else {
        self.customUserAgent = nil; // Revert to default for DeepSeek and others to avoid Cloudflare fingerprint mismatch
    }

    if ([request.URL.absoluteString containsString:@"macbunny"]) {
        NSLog(@"[AntiGravity] Blocked macbunny redirect inside WKWebView: %@", request.URL.absoluteString);
        return nil; // Just block it without infinite loop
    }
    return [self swizzled_loadRequest:request];
}
@end

@interface NSWorkspace (Swizzle)
@end

@implementation NSWorkspace (Swizzle)
- (BOOL)swizzled_openURL:(NSURL *)url {
    if ([url.absoluteString containsString:@"macbunny"]) {
        NSLog(@"[AntiGravity] Blocked macbunny external redirect: %@", url.absoluteString);
        return YES; // Pretend we opened it successfully
    }
    return [self swizzled_openURL:url];
}
@end

@interface NSUserDefaults (Swizzle)
@end

@implementation NSUserDefaults (Swizzle)
- (BOOL)swizzled_boolForKey:(NSString *)defaultName {
    if ([defaultName isEqualToString:@"isProUser"]) {
        return YES;
    }
    return [self swizzled_boolForKey:defaultName];
}
@end
