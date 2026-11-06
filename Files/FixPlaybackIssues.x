// Playback diagnostics for the iPhone 15, based on YouMod's existing playback hook.
// This does not intercept or alter YouTube network requests.
#import "Headers.h"

static NSString * const YMPlaybackErrorDomainKey = @"YouModLastPlaybackErrorDomain";
static NSString * const YMPlaybackErrorCodeKey = @"YouModLastPlaybackErrorCode";
static NSString * const YMPlaybackErrorDateKey = @"YouModLastPlaybackErrorDate";

// Rate-limit the existing error-14 recovery so that a broken stream cannot
// trigger a tight reload loop. The user can still retry manually.
static NSTimeInterval gYMLastAutomaticPlaybackReload = 0;
static const NSTimeInterval kYMPlaybackReloadCooldown = 60.0;

%hook YTMainAppVideoPlayerOverlayViewController

- (void)handleError:(NSError *)error {
    if (error) {
        // Keep only troubleshooting metadata. Never store a video URL, account,
        // HTTP headers, NSError.userInfo or other potentially sensitive values.
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:(error.domain ?: @"(unknown)") forKey:YMPlaybackErrorDomainKey];
        [defaults setInteger:error.code forKey:YMPlaybackErrorCodeKey];
        [defaults setObject:[NSDate date] forKey:YMPlaybackErrorDateKey];
        NSLog(@"[YouMod Playback] error domain=%@ code=%ld",
              error.domain, (long)error.code);
    }

    // The on-screen "Something went wrong" text does not identify an NSError
    // code. Only attempt automatic recovery for the old, known code-14 case.
    if (IS_ENABLED(FixPlaybackIssues) &&
        error &&
        [error.domain isEqualToString:@"com.google.ios.youtube.ErrorDomain.playback"] &&
        error.code == 14) {

        UIViewController *parent = self.parentViewController;
        if ([parent isKindOfClass:%c(YTPlayerViewController)]) {
            YTPlayerViewController *player = (YTPlayerViewController *)parent;
            id delegate = player.UIDelegate;
            if ([delegate isKindOfClass:%c(YTWatchController)]) {
                BOOL mayRetry = NO;
                NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];

                @synchronized([NSUserDefaults standardUserDefaults]) {
                    if (now - gYMLastAutomaticPlaybackReload >= kYMPlaybackReloadCooldown) {
                        gYMLastAutomaticPlaybackReload = now;
                        mayRetry = YES;
                    }
                }

                if (mayRetry) {
                    YTWatchController *watchController = (YTWatchController *)delegate;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [watchController reload];
                    });
                    // Suppress the overlay only while an actual retry is queued.
                    return;
                }
            }
        }
    }

    // For any other error, missing delegate or exhausted retry allowance,
    // preserve YouTube's original error UI rather than hiding the failure.
    %orig;
}

%end

%ctor {
    // Always observe playback failures, even when the recovery toggle is off.
    // The recovery toggle is checked dynamically, not just at launch.
    %init;
}
