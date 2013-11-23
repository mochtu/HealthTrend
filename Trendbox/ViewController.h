//
//  ViewController.h
//  Trendbox
//
//  Created by Moritz C. Türck on 23.11.13.
//  Copyright (c) 2013 Moritz C. Türck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Dropbox/Dropbox.h>

@interface ViewController : UIViewController

@property (strong,nonatomic) IBOutlet UITableView* table;

- (IBAction)didPressLink;
- (IBAction)addItemToTable;

@end
