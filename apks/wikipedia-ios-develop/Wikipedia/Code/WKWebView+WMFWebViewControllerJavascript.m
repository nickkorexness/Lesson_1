#import "WKWebView+WMFWebViewControllerJavascript.h"
@import WMF;
#import "Wikipedia-Swift.h"
#import "WMFProxyServer.h"
#import <WMF/NSURL+WMFLinkParsing.h>

// Some dialects have complex characters, so we use 2 instead of 10
static int const kMinimumTextSelectionLength = 2;

@implementation WKWebView (WMFWebViewControllerJavascript)

- (void)wmf_setTextSize:(NSInteger)textSize {
    [self evaluateJavaScript:[NSString stringWithFormat:@"document.querySelector('body').style['-webkit-text-size-adjust'] = '%ld%%';", (long)textSize] completionHandler:NULL];
}

- (void)wmf_scrollToFragment:(NSString *)fragment {
    [self evaluateJavaScript:[NSString stringWithFormat:@"window.wmf.utilities.scrollToFragment('%@')", fragment] completionHandler:nil];
}

- (void)wmf_accessibilityCursorToFragment:(NSString *)fragment {
    if (UIAccessibilityIsVoiceOverRunning()) {
        [self evaluateJavaScript:[NSString stringWithFormat:@"window.wmf.utilities.accessibilityCursorToFragment('%@')", fragment] completionHandler:nil];
    }
}

- (void)wmf_highlightLinkID:(NSString *)linkID {
    [self evaluateJavaScript:[NSString stringWithFormat:@"document.getElementById('%@').classList.add('reference_highlight');", linkID]
           completionHandler:NULL];
}

- (void)wmf_unHighlightLinkID:(NSString *)linkID {
    [self evaluateJavaScript:[NSString stringWithFormat:@"document.getElementById('%@').classList.remove('reference_highlight');", linkID]
           completionHandler:NULL];
}

- (void)wmf_getSelectedText:(void (^)(NSString *text))completion {
    [self evaluateJavaScript:@"window.getSelection().toString()"
           completionHandler:^(id _Nullable obj, NSError *_Nullable error) {
               if ([obj isKindOfClass:[NSString class]]) {
                   NSString *selectedText = [(NSString *)obj wmf_shareSnippetFromText];
                   selectedText = selectedText.length < kMinimumTextSelectionLength ? @"" : selectedText;
                   completion(selectedText);
               } else {
                   completion(@"");
               }
           }];
}

@end
