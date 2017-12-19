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
    
    _puzzle.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 40, [UIScreen mainScreen].bounds.size.width - 40);
    _puzzle.center = self.view.center;
    
    [_puzzle setCompletionBlock:^{
        NSLog(@"拼图完成");
    }];
}

- (IBAction)upset:(id)sender {
    [_puzzle upset];
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
