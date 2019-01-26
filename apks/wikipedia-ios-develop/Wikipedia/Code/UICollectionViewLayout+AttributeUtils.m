#import "UICollectionViewLayout+AttributeUtils.h"
@import WMF.Swift;

@implementation UICollectionViewLayout (AttributeUtils)

- (NSIndexPath *)wmf_indexPathHorizontallyClosestToContentOffset {
    return [[[self wmf_layoutAttributesByDistanceToPoint:self.collectionView.contentOffset] firstObject] indexPath];
}

- (NSArray *)wmf_sortAttributesByLeadingEdgeDistance:(NSArray *)attributes toPoint:(CGPoint)point {
    return [attributes sortedArrayUsingComparator:^NSComparisonResult(UICollectionViewLayoutAttributes *attr1,
                                                                      UICollectionViewLayoutAttributes *attr2) {
        float leadingEdgeDistance1 = fabs(point.x - CGRectGetMinX(attr1.frame));
        float leadingEdgeDistance2 = fabs(point.x - CGRectGetMinX(attr2.frame));
        return leadingEdgeDistance1 - leadingEdgeDistance2;
    }];
}

- (NSArray *)wmf_layoutAttributesByDistanceToPoint:(CGPoint)point {
    return [self wmf_sortAttributesByLeadingEdgeDistance:[self wmf_layoutAttributesForVisibleIndexPaths] toPoint:point];
}

- (NSArray *)wmf_layoutAttributesForVisibleIndexPaths {
    return [self.collectionView.indexPathsForVisibleItems wmf_map:^(NSIndexPath *path) {
        return [self layoutAttributesForItemAtIndexPath:path];
    }];
}

@end
