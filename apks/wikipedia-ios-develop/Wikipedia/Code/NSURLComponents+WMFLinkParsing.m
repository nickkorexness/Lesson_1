#import <WMF/NSURLComponents+WMFLinkParsing.h>
#import <WMF/NSString+WMFPageUtilities.h>
#import <WMF/NSCharacterSet+WMFLinkParsing.h>

@implementation NSURLComponents (WMFLinkParsing)

+ (NSURLComponents *)wmf_componentsWithDomain:(NSString *)domain
                                     language:(NSString *)language {
    return [self wmf_componentsWithDomain:domain language:language isMobile:NO];
}

+ (NSURLComponents *)wmf_componentsWithDomain:(NSString *)domain
                                     language:(NSString *)language
                                     isMobile:(BOOL)isMobile {
    return [self wmf_componentsWithDomain:domain language:language title:nil fragment:nil isMobile:isMobile];
}

+ (NSURLComponents *)wmf_componentsWithDomain:(NSString *)domain
                                     language:(NSString *)language
                                        title:(NSString *)title {
    return [self wmf_componentsWithDomain:domain language:language title:title fragment:nil];
}

+ (NSURLComponents *)wmf_componentsWithDomain:(NSString *)domain
                                     language:(NSString *)language
                                        title:(NSString *)title
                                     fragment:(NSString *)fragment {
    return [self wmf_componentsWithDomain:domain language:language title:title fragment:fragment isMobile:NO];
}

+ (NSURLComponents *)wmf_componentsWithDomain:(NSString *)domain
                                     language:(NSString *)language
                                        title:(NSString *)title
                                     fragment:(NSString *)fragment
                                     isMobile:(BOOL)isMobile {
    NSURLComponents *URLComponents = [[NSURLComponents alloc] init];
    URLComponents.scheme = @"https";
    URLComponents.host = [NSURLComponents wmf_hostWithDomain:domain language:language isMobile:isMobile];
    if (fragment != nil) {
        URLComponents.wmf_fragment = fragment;
    }
    if (title != nil) {
        URLComponents.wmf_title = title;
    }
    return URLComponents;
}

+ (NSString *)wmf_hostWithDomain:(NSString *)domain
                        language:(NSString *)language
                        isMobile:(BOOL)isMobile {
    return [self wmf_hostWithDomain:domain subDomain:language isMobile:isMobile];
}

+ (NSString *)wmf_hostWithDomain:(NSString *)domain
                       subDomain:(NSString *)subDomain
                        isMobile:(BOOL)isMobile {
    NSMutableArray *hostComponents = [NSMutableArray array];
    if (subDomain) {
        [hostComponents addObject:subDomain];
    }
    if (isMobile) {
        [hostComponents addObject:@"m"];
    }
    if (domain) {
        [hostComponents addObject:domain];
    }
    return [hostComponents componentsJoinedByString:@"."];
}

- (void)setWmf_titleWithUnderscores:(NSString *_Nullable)titleWithUnderscores {
    NSString *path = [titleWithUnderscores stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet wmf_URLPathComponentAllowedCharacterSet]];
    if (path != nil && path.length > 0) {
        NSArray *pathComponents = @[@"/wiki/", path];
        self.percentEncodedPath = [NSString pathWithComponents:pathComponents];
    } else {
        self.percentEncodedPath = nil;
    }
}

- (void)setWmf_title:(NSString *)wmf_title {
    self.wmf_titleWithUnderscores = [wmf_title wmf_denormalizedPageTitle];
}

- (NSString *)wmf_title {
    NSString *title = [[self.path wmf_pathWithoutWikiPrefix] wmf_normalizedPageTitle];
    if (title == nil) {
        title = @"";
    }
    return title;
}

- (NSString *)wmf_titleWithUnderscores {
    NSString *title = [[self.path wmf_pathWithoutWikiPrefix] wmf_denormalizedPageTitle];
    if (title == nil) {
        title = @"";
    }
    return title;
}

- (void)setWmf_fragment:(NSString *)wmf_fragment {
    self.fragment = [wmf_fragment precomposedStringWithCanonicalMapping];
}

- (NSString *)wmf_fragment {
    return [self.fragment precomposedStringWithCanonicalMapping];
}

@end
