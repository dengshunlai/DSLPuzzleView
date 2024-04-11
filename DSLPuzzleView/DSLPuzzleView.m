//
//  DSLPuzzleView.m
//
//
//  Created by dengshunlai on 2017/12/11.
//  Copyright © 2017年 邓顺来. All rights reserved.
//

#import "DSLPuzzleView.h"
#import <objc/runtime.h>

#define RESET_NUM (200 + arc4random_uniform(200))
#define COMPLETION_POINT CGPointMake(-1, -1)

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

typedef NS_ENUM(NSUInteger, DSLPuzzleMoveDirection) {
    DSLPuzzleMoveDirectionNone,
    DSLPuzzleMoveDirectionTop,
    DSLPuzzleMoveDirectionBottom,
    DSLPuzzleMoveDirectionLeft,
    DSLPuzzleMoveDirectionRight
};

@interface UIImageView (DSLPuzzleView)

@property (assign, nonatomic) CGPoint dsl_puzzle_loc;

@property (assign, nonatomic) CGPoint dsl_puzzle_original_loc;

@end


@interface DSLPuzzleView ()

@property (strong, nonatomic) NSMutableArray<UIImageView *> *puzzles;
@property (assign, nonatomic) CGPoint blankLoc;
@property (strong, nonatomic) UIImageView *blankPuzzle;

@end

@implementation DSLPuzzleView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialization];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
    }
    return self;
}

+ (instancetype)puzzleWithImage:(UIImage *)image {
    DSLPuzzleView *puzzle = [[DSLPuzzleView alloc] init];
    puzzle.image = image;
    return puzzle;
}

- (void)initialization {
    self.backgroundColor = [UIColor whiteColor];
    _puzzles = [NSMutableArray array];
    _n = 3;
    _puzzleBorderColor = UIColorFromRGB(0xe4e4e4);
    _puzzleBorderWidth = 1;
    _gap = DSLPuzzleGapBottomRight;
    _puzzleMoveDuration = 0.2;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat puzzleSize = self.frame.size.width / _n;
    for (NSInteger i = 0; i < _puzzles.count; i++) {
        UIImageView *iv = _puzzles[i];
        iv.frame = CGRectMake(iv.dsl_puzzle_loc.x * puzzleSize,
                              iv.dsl_puzzle_loc.y * puzzleSize,
                              puzzleSize, puzzleSize);
    }
}

#pragma mark - API

- (void)startUp {
    [self divideWithImage:_image];
    [self reset];
}

- (void)reset {
    if (CGPointEqualToPoint(_blankLoc, COMPLETION_POINT)) {
        [self startUp];
    }
    for (NSInteger i = 0; i < RESET_NUM; i++) {
        NSMutableArray *ivs = [self puzzlesCanMove];
        NSUInteger idx = arc4random_uniform((uint32_t)ivs.count);
        [self moveLoc:ivs[idx]];
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - Action

- (void)tap:(UITapGestureRecognizer *)tap {
    [self movePuzzle:(UIImageView *)tap.view];
}

#pragma mark - Other

- (void)divideWithImage:(UIImage *)image {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    [_puzzles removeAllObjects];
    for (NSInteger x = 0; x < _n; x++) {
        for (NSInteger y = 0; y < _n; y++) {
            CGFloat size = image.size.width * image.scale / _n;
            CGRect rect = CGRectMake(x * size, y * size, size, size);
            CGImageRef cgImg = CGImageCreateWithImageInRect(image.CGImage, rect);
            UIImage *img = [UIImage imageWithCGImage:cgImg];
            CGImageRelease(cgImg);
            UIImageView *iv = [[UIImageView alloc] initWithImage:img];
            iv.contentMode = UIViewContentModeScaleToFill;
            iv.layer.borderWidth = _puzzleBorderWidth;
            iv.layer.borderColor = _puzzleBorderColor.CGColor;
            iv.dsl_puzzle_loc = CGPointMake(x, y);
            iv.dsl_puzzle_original_loc = CGPointMake(x, y);
            [_puzzles addObject:iv];
        }
    }
    switch (_gap) {
        case DSLPuzzleGapBottomRight:
            _blankLoc = CGPointMake(_n - 1, _n - 1);
            _blankPuzzle = _puzzles.lastObject;
            [_puzzles removeLastObject];
            break;
        case DSLPuzzleGapBottomLeft:
            _blankLoc = CGPointMake(0, _n - 1);
            _blankPuzzle = [_puzzles objectAtIndex:_n - 1];
            [_puzzles removeObjectAtIndex:_n - 1];
            break;
        case DSLPuzzleGapTopRight:
            _blankLoc = CGPointMake(_n - 1, 0);
            _blankPuzzle = [_puzzles objectAtIndex:_n * (_n - 1)];
            [_puzzles removeObjectAtIndex:_n * (_n - 1)];
            break;
        case DSLPuzzleGapTopLeft:
            _blankLoc = CGPointMake(0, 0);
            _blankPuzzle = [_puzzles objectAtIndex:0];
            [_puzzles removeObjectAtIndex:0];
            break;
        default:
            break;
    }
    for (UIImageView *iv in _puzzles) {
        iv.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [iv addGestureRecognizer:tap];
        [self addSubview:iv];
    }
}

- (void)movePuzzle:(UIImageView *)iv {
    DSLPuzzleMoveDirection direction = [self moveLoc:iv];
    if (direction != DSLPuzzleMoveDirectionNone) {
        [self setNeedsLayout];
        [UIView animateWithDuration:_puzzleMoveDuration animations:^{
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            if ([self isCompletion]) {
                _blankLoc = COMPLETION_POINT;
                [self showBlankPuzzle];
                if (self.completionBlock) {
                    self.completionBlock();
                }
            }
        }];
    }
}

- (DSLPuzzleMoveDirection)moveLoc:(UIImageView *)iv {
    DSLPuzzleMoveDirection direction = [self locTest:iv];
    switch (direction) {
        case DSLPuzzleMoveDirectionTop: {
            _blankLoc = iv.dsl_puzzle_loc;
            iv.dsl_puzzle_loc = CGPointMake(iv.dsl_puzzle_loc.x, iv.dsl_puzzle_loc.y + 1);
        }
            break;
        case DSLPuzzleMoveDirectionBottom: {
            _blankLoc = iv.dsl_puzzle_loc;
            iv.dsl_puzzle_loc = CGPointMake(iv.dsl_puzzle_loc.x, iv.dsl_puzzle_loc.y - 1);
        }
            break;
        case DSLPuzzleMoveDirectionLeft: {
            _blankLoc = iv.dsl_puzzle_loc;
            iv.dsl_puzzle_loc = CGPointMake(iv.dsl_puzzle_loc.x - 1, iv.dsl_puzzle_loc.y);
        }
            break;
        case DSLPuzzleMoveDirectionRight: {
            _blankLoc = iv.dsl_puzzle_loc;
            iv.dsl_puzzle_loc = CGPointMake(iv.dsl_puzzle_loc.x + 1, iv.dsl_puzzle_loc.y);
        }
            break;
        default:
            break;
    }
    return direction;
}

- (DSLPuzzleMoveDirection)locTest:(UIImageView *)iv {
    if (iv.dsl_puzzle_loc.x == _blankLoc.x && iv.dsl_puzzle_loc.y + 1 == _blankLoc.y) {
        return DSLPuzzleMoveDirectionTop;
    } else if (iv.dsl_puzzle_loc.x == _blankLoc.x && iv.dsl_puzzle_loc.y - 1 == _blankLoc.y) {
        return DSLPuzzleMoveDirectionBottom;
    } else if (iv.dsl_puzzle_loc.x - 1 == _blankLoc.x && iv.dsl_puzzle_loc.y == _blankLoc.y) {
        return DSLPuzzleMoveDirectionLeft;
    } else if (iv.dsl_puzzle_loc.x + 1 == _blankLoc.x && iv.dsl_puzzle_loc.y == _blankLoc.y) {
        return DSLPuzzleMoveDirectionRight;
    }
    return DSLPuzzleMoveDirectionNone;
}

- (NSMutableArray<UIImageView *> *)puzzlesCanMove {
    NSMutableArray *puzzles = [NSMutableArray array];
    CGPoint top = CGPointMake(_blankLoc.x, _blankLoc.y + 1);
    CGPoint bottom = CGPointMake(_blankLoc.x, _blankLoc.y - 1);
    CGPoint left = CGPointMake(_blankLoc.x - 1, _blankLoc.y);
    CGPoint right = CGPointMake(_blankLoc.x + 1, _blankLoc.y);
    for (UIImageView *iv in _puzzles) {
        if (CGPointEqualToPoint(iv.dsl_puzzle_loc, top) || CGPointEqualToPoint(iv.dsl_puzzle_loc, bottom) ||
            CGPointEqualToPoint(iv.dsl_puzzle_loc, left) || CGPointEqualToPoint(iv.dsl_puzzle_loc, right)) {
            [puzzles addObject:iv];
        }
    }
    return puzzles;
}

- (BOOL)isCompletion {
    for (UIImageView *puzzle in _puzzles) {
        if (!CGPointEqualToPoint(puzzle.dsl_puzzle_loc, puzzle.dsl_puzzle_original_loc)) {
            return NO;
        }
    }
    return YES;
}

- (void)showBlankPuzzle {
    [_puzzles addObject:_blankPuzzle];
    _blankPuzzle.alpha = 0;
    [self addSubview:_blankPuzzle];
    [UIView animateWithDuration:0.25 animations:^{
        _blankPuzzle.alpha = 1;
    }];
}

@end


@implementation UIImageView (DSLPuzzleView)

- (void)setDsl_puzzle_loc:(CGPoint)dsl_puzzle_loc {
    objc_setAssociatedObject(self, @selector(dsl_puzzle_loc), [NSValue valueWithCGPoint:dsl_puzzle_loc], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPoint)dsl_puzzle_loc {
    NSValue *value = objc_getAssociatedObject(self, @selector(dsl_puzzle_loc));
    return [value CGPointValue];
}

- (void)setDsl_puzzle_original_loc:(CGPoint)dsl_puzzle_original_loc {
    objc_setAssociatedObject(self, @selector(dsl_puzzle_original_loc), [NSValue valueWithCGPoint:dsl_puzzle_original_loc], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPoint)dsl_puzzle_original_loc {
    NSValue *value = objc_getAssociatedObject(self, @selector(dsl_puzzle_original_loc));
    return [value CGPointValue];
}

@end

