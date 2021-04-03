#import <UIKit/UIKit.h>
#include <sys/sysctl.h>
#include <sys/utsname.h>
#define CGRectSetY(rect, y) CGRectMake(rect.origin.x, y, rect.size.width, rect.size.height)

NSInteger statusBarStyle, keyboardSpacing;
BOOL enabled, wantsKeyboardDock,wants11Camera, wantsbottomInset;
BOOL disableGestures = NO, wantsGesturesDisabledWhenKeyboard, wantsiPadMultitasking;
BOOL wantsDeviceSpoofing, wantsCompatabilityMode;

%group ForceDefaultKeyboard

%hook UIKeyboardImpl
+(UIEdgeInsets)deviceSpecificPaddingForInterfaceOrientation:(NSInteger)orientation inputMode:(id)mode {
	UIEdgeInsets orig = %orig;
	orig.left =  0;
	orig.right = 0;
    orig.bottom = 0;
	return orig;
}
%end
%end

%group StatusBarX
%hook UIScrollView
- (UIEdgeInsets)adjustedContentInset {
	UIEdgeInsets orig = %orig;

    if (orig.top == 64) orig.top = 88; 
    else if (orig.top == 32) orig.top = 0;
    else if (orig.top == 128) orig.top = 152;

    return orig;
}
%end
%end

%group KeyboardDock
%hook UIKeyboardImpl
+(UIEdgeInsets)deviceSpecificPaddingForInterfaceOrientation:(NSInteger)orientation inputMode:(id)mode {
    UIEdgeInsets orig = %orig;
    if (!(%c(BarmojiCollectionView) || %c(DockXServer)))
         orig.bottom = keyboardSpacing;
    return orig;
}
%end

%hook UIKeyboardDockView
- (CGRect)bounds {
    CGRect bounds = %orig;
    return bounds;
}
%end
%end

%group iPhone11Cam
%hook CAMCaptureCapabilities 
-(BOOL)isCTMSupported {
    return YES;
}
%end

%hook CAMViewfinderViewController 
-(BOOL)_wantsHDRControlsVisible{
    return NO;
}
%end

%hook CAMViewfinderViewController 
-(BOOL)_shouldUseZoomControlInsteadOfSlider {
    return YES;
}
%end
%end

// Adds a bottom inset to the camera app.
%group CameraFix
%hook CAMBottomBar 
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, frame.origin.y -40));
}
%end

%hook CAMZoomControl
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, frame.origin.y -30));
}
%end
%end

%group disableGesturesWhenKeyboard // iOS 13.4 and up
%hook SBFluidSwitcherGestureManager
- (void)grabberTongueBeganPulling:(id)arg1 withDistance:(double)arg2 andVelocity:(double)arg3 andGesture:(id)arg4  {
    if (!disableGestures)
        %orig;
}
%end
%end

%group UIKitiPadMultitasking
%hook UITraitCollection
+(UITraitCollection *)traitCollectionWithHorizontalSizeClass:(UIUserInterfaceSizeClass)arg1 {
    if(UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
        return %orig(2);
    return %orig;
}
%end
%end

%group BoundsHack
%hookf(int, sysctl, const int *name, u_int namelen, void *oldp, size_t *oldlenp, const void *newp, size_t newlen) {
	if (namelen == 2 && name[0] == CTL_HW && name[1] == HW_MACHINE && oldp) {
        int const ret = %orig;
        const char *mechine1 = "iPhone12,1";
        strncpy((char*)oldp, mechine1, strlen(mechine1));
        return ret;
    } else {
        return %orig;
    }
}

%hookf(int, sysctlbyname, const char *name, void *oldp, size_t *oldlenp, void *newp, size_t newlen) {
	if (strcmp(name, "hw.machine") == 0) {
        int ret = %orig;
        const char *mechine1 = "iPhone12,1";
        if (oldp) {
            strcpy((char *)oldp, mechine1);
        }
        *oldlenp = sizeof(mechine1);
        return ret;
    } else {
        return %orig;
    }
}

%hookf(int, uname, struct utsname *value) {
	int const ret = %orig;
	NSString *utsmachine = @"iPhone12,1";
    const char *utsnameCh = utsmachine.UTF8String; 
    strcpy(value->machine, utsnameCh);
    return ret;
}
%end

%group CompatabilityMode
%hook UIScreen
- (CGRect)bounds {
	CGRect bounds = %orig;
    bounds.size.height > bounds.size.width ? bounds.size.height = 812 : bounds.size.width = 812;
	return bounds;
}
%end
%end 

%hook UIWindow
- (UIEdgeInsets)safeAreaInsets {
    UIEdgeInsets orig = %orig;
    orig.bottom = wantsbottomInset ? 20 : 0;
    return orig;
}
%end

%group InstagramFix
%end

%group bottominsetfix // AWE = TikTok, TFN = Twitter, YT = Youtube
%hook AWETabBar
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, frame.origin.y + 40));
}
%end

%hook AWEFeedTableView
- (void)setFrame:(CGRect)frame {
	%orig(CGRectMake(frame.origin.x,frame.origin.y,frame.size.width,frame.size.height + 40));
}
%end

%hook TFNNavigationBarOverlayView  
- (void)setFrame:(CGRect)frame {
    %orig(CGRectMake(frame.origin.x,frame.origin.y,frame.size.width,frame.size.height + 6));
}
%end

%hook T1SuggestsModuleHeaderView
- (void)setFrame:(CGRect)frame {
   %orig(CGRectSetY(frame, frame.origin.y - 22));
}
%end

%hook YTPivotBarView
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, frame.origin.y - 40));
}
%end
%hook YTAppView
- (void)setFrame:(CGRect)frame {
    %orig(CGRectMake(frame.origin.x,frame.origin.y,frame.size.width,frame.size.height + 40));
}
%end

%hook YTNGWatchLayerView
-(CGRect)miniBarFrame {
    CGRect const frame = %orig;
	return CGRectSetY(frame, frame.origin.y - 40);
}
%end
%end

%group YoutubeStatusBarXSpacingFix
%hook YTHeaderContentComboView
- (void)setFrame:(CGRect)frame {
    %orig(CGRectSetY(frame, frame.origin.y - 20));
}
%end
%end

// Preferences.
void loadPrefs() {
     @autoreleasepool {
        
        NSDictionary const *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.ryannair05.little12.plist"];

        if (prefs) {
            enabled = [[prefs objectForKey:@"enabled"] boolValue];
            statusBarStyle = [[prefs objectForKey:@"statusBarStyle"] integerValue];
            wantsGesturesDisabledWhenKeyboard = [[prefs objectForKey:@"noGesturesForKeyboard"] boolValue];
            wants11Camera = [[prefs objectForKey:@"11Camera"] boolValue];
            keyboardSpacing = [[prefs objectForKey:@"keyboardSpacing"]?:@45 integerValue];
            wantsiPadMultitasking = [[prefs objectForKey:@"iPadDock"] boolValue] ? [[prefs objectForKey:@"iPadMultitasking"] boolValue] : NO;
            
            NSString const *mainIdentifier = [NSBundle mainBundle].bundleIdentifier;
            NSDictionary const *appSettings = [prefs objectForKey:mainIdentifier];
    
            if (appSettings) {
                wantsKeyboardDock = [appSettings objectForKey:@"keyboardDock"] ? [[appSettings objectForKey:@"keyboardDock"] boolValue] : [[prefs objectForKey:@"keyboardDock"] boolValue];
                wantsbottomInset = [appSettings objectForKey:@"bottomInset"] ? [[appSettings objectForKey:@"bottomInset"] boolValue] : [[prefs objectForKey:@"bottomInset"] boolValue];
                wantsDeviceSpoofing = [appSettings objectForKey:@"deviceSpoofing"] ? [[appSettings objectForKey:@"deviceSpoofing"] boolValue] : [[prefs objectForKey:@"deviceSpoofing"] boolValue];
                wantsCompatabilityMode = [appSettings objectForKey:@"compatabilityMode"] ? [[appSettings objectForKey:@"compatabilityMode"] boolValue] : [[prefs objectForKey:@"compatabilityMode"] boolValue];
            } else {
                wantsKeyboardDock =  [[prefs objectForKey:@"keyboardDock"] boolValue];
                wantsbottomInset = [[prefs objectForKey:@"bottomInset"] boolValue];
                wantsDeviceSpoofing = [[prefs objectForKey:@"deviceSpoofing"] boolValue];
                wantsCompatabilityMode = [[prefs objectForKey:@"compatabilityMode"] boolValue];
            }
        }
    }
}

%ctor {
    @autoreleasepool {

        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.ryannair05.little12prefs/prefsupdated"), NULL, CFNotificationSuspensionBehaviorCoalesce);
        loadPrefs();

        if (enabled) {

            bool const isApp = [[[[NSProcessInfo processInfo] arguments] objectAtIndex:0] containsString:@"/Application"];

            if (wantsiPadMultitasking) %init(UIKitiPadMultitasking);

            if (isApp) {

                NSString* const bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];

                if ([bundleIdentifier containsString:@"com.apple"]) {
                    if ([bundleIdentifier isEqualToString:@"com.apple.camera"]) {
                        if (wants11Camera) %init(iPhone11Cam);
                        else if (wantsbottomInset) %init(CameraFix);
                    }
                }
                else if (wantsbottomInset || statusBarStyle > 1) {
                    
                    if ([bundleIdentifier isEqualToString:@"com.google.ios.youtube"]) {
                        if (wantsbottomInset || statusBarStyle == 2)
                            wantsCompatabilityMode = YES;
                        else
                            %init(YoutubeStatusBarXSpacingFix);
                    }
                    else if ([bundleIdentifier isEqualToString:@"com.burbn.instagram"]) {
                        wantsCompatabilityMode = NO;
                        wantsDeviceSpoofing = statusBarStyle == 2;
                        %init(InstagramFix)
                    }
                    else if ([bundleIdentifier isEqualToString:@"com.zhiliaoapp.musically"]) {
                        wantsCompatabilityMode = NO;
                        wantsDeviceSpoofing = YES;
                        statusBarStyle = 2;
                    }

                    if (statusBarStyle == 2) {
                        %init(StatusBarX);
                        if (!wantsbottomInset)
                            %init(bottominsetfix);
                    }

                    if (wantsCompatabilityMode) %init(CompatabilityMode);
                    if (wantsDeviceSpoofing) %init(BoundsHack);
                }
            }

            if (![[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/KeyboardPlus.dylib"]) {

                if (wantsKeyboardDock) %init(KeyboardDock);
                else %init(ForceDefaultKeyboard);

                if (wantsGesturesDisabledWhenKeyboard) {
                    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardDidShowNotification object:nil queue:nil usingBlock:^(NSNotification *n){
                            disableGestures = true;
                        }];
                    [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *n){
                            disableGestures = false;
                        }];
                        %init(disableGesturesWhenKeyboard);
                }
            }

            %init;
        }
    }
}