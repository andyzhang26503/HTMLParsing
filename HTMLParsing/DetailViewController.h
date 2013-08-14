//
//  DetailViewController.h
//  HTMLParsing
//
//  Created by andyzhang on 13-8-14.
//  Copyright (c) 2013年 andyzhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
