//
//  ViewController.h
//  Trendbox
//
//  Created by Moritz C. Türck on 23.11.13.
//  Copyright (c) 2013 Moritz C. Türck. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Dropbox/Dropbox.h>
#import "OccurrenceTable.h"
#import "OccurrenceCell.h"

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, OccurrenceCellDelegate>

@property (strong,nonatomic) IBOutlet OccurrenceTable* table;



@end
