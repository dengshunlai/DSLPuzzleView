//
//  ViewController.m
//  DSLPuzzleViewDemo
//
//  Created by 邓顺来 on 2017/12/19.
//  Copyright © 2017年 邓顺来. All rights reserved.
//

#import "ViewController.h"
#import "DSLPuzzleView.h"

@interface ViewController ()

@property (strong, nonatomic) DSLPuzzleView *puzzle;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _puzzle = [DSLPuzzleView puzzleWithImage:[UIImage imageNamed:@"image"]];
    [_puzzle startUp];
    [self.view addSubview:_puzzle];
    
    [_puzzle setCompletionBlock:^{
        NSLog(@"拼图完成");
    }];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat screenShorter = CGRectGetWidth([UIScreen mainScreen].bounds) < CGRectGetHeight([UIScreen mainScreen].bounds) ? CGRectGetWidth([UIScreen mainScreen].bounds) : CGRectGetHeight([UIScreen mainScreen].bounds);
    
    _puzzle.frame = CGRectMake(0, 0, screenShorter - 65, screenShorter - 65);
    _puzzle.center = self.view.center;
}

- (IBAction)reset:(id)sender {
    [_puzzle reset];
}

- (IBAction)n3:(id)sender {
    _puzzle.n = 3;
    [_puzzle startUp];
}

- (IBAction)n4:(id)sender {
    _puzzle.n = 4;
    [_puzzle startUp];
}

- (IBAction)n5:(id)sender {
    _puzzle.n = 5;
    [_puzzle startUp];
}

@end
