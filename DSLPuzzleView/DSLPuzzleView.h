//
//  DSLPuzzleView.h
//  
//
//  Created by dengshunlai on 2017/12/11.
//  Copyright © 2017年 邓顺来. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DSLPuzzleGap) {
    DSLPuzzleGapBottomRight,
    DSLPuzzleGapBottomLeft,
    DSLPuzzleGapTopRight,
    DSLPuzzleGapTopLeft,
};

@interface DSLPuzzleView : UIView

/**
 原图，请尽量保证是正方形
 */
@property (strong, nonatomic) UIImage *image;

/**
 阶数，默认 3
 */
@property (assign, nonatomic) NSUInteger n;

/**
 拼图的缺口，默认 DSLPuzzleGapBottomRight 右下角
 */
@property (assign, nonatomic) DSLPuzzleGap gap;

/**
 小拼图的边颜色，默认 0xe4e4e4
 */
@property (strong, nonatomic) UIColor *puzzleBorderColor;

/**
 小拼图的边宽，默认 1
 */
@property (assign, nonatomic) CGFloat puzzleBorderWidth;

/**
 小拼图移动的动画时长(s)，默认 0.2
 */
@property (assign, nonatomic) CGFloat puzzleMoveDuration;

/**
 拼图游戏完成后调用
 */
@property (copy, nonatomic) void (^completionBlock)(void);


/**
 便利构造器
 */
+ (instancetype)puzzleWithImage:(UIImage *)image;

/**
 设置完成后调用，必要调用这个方法
 */
- (void)startUp;

/**
 重新打乱拼图
 */
- (void)upset;

@end

