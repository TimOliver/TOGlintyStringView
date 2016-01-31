//
//  ViewController.m
//  TOGlintyStringView
//
//  Created by Tim Oliver on 30/01/2016.
//  Copyright © 2016 Tim Oliver. All rights reserved.
//

#import "ViewController.h"
#import "TOGlintyStringView.h"

@interface ViewController ()

@property (nonatomic, strong) IBOutlet TOGlintyStringView *stringView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.stringView.text = @"github.com/timoliver";
    self.stringView.chevronImage = [TOGlintyStringView defaultChevronImage];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
