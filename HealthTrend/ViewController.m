//
//  ViewController.m
//  Trendbox
//
//  Created by Moritz C. Türck on 23.11.13.
//  Copyright (c) 2013 Moritz C. Türck. All rights reserved.
//

#import "ViewController.h"
#import "OccurrenceCell.h"

@interface ViewController () 
@property (nonatomic, readonly) DBAccountManager *accountManager;
@property (nonatomic, readonly) DBAccount *account;
@property (nonatomic, retain) DBDatastore *store;
@property (nonatomic, retain) NSMutableArray *occurrences;

@property (weak,nonatomic) IBOutlet UITableView* occurrenceTableView;
- (IBAction)toogleOccurenceAddView;
- (IBAction)endEditMode;
- (BOOL)cellIsSelected:(NSIndexPath *)indexPath;

//@property (nonatomic,retain)

@end

@implementation ViewController

//@synthesize selectedIndexes = _selectedIndexes;

typedef NS_ENUM(NSUInteger, OccurenceType) {
    oOccurenceStandard,
    oOccurenceInjection,
    oOccurenceGastro
};

int currentSelection = -1;
NSMutableDictionary *selectedIndexes;

//@synthesize table = _table;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.occurrenceTableView.dataSource = self;
    self.occurrenceTableView.delegate = self;
    selectedIndexes = [[NSMutableDictionary alloc] init];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dealloc {
    [_store removeObserver:self];
}


- (void)viewWillAppear:(BOOL)animated {
    
    __weak ViewController *slf = self;
    [self.accountManager addObserver:self block:^(DBAccount *account) {
        [slf setupTasks];
    }];
    self.occurrenceTableView.rowHeight = 70;
    [self setupTasks];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [self.accountManager removeObserver:self];
    if (_store) {
        [_store removeObserver:self];
    }
    self.store = nil;
}



#pragma mark UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.account) {
        return 0;
    } else {
        return [_occurrences count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (self.occurrenceTableView.editing)
//        return 90;
//    else
//        return 70;
    if([self cellIsSelected:indexPath]) {
        return 90;
    }
    else{
        return 70;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (![DBAccountManager sharedManager].linkedAccount) {
         NSLog(@"LinkCell deadlock");
        return [tableView dequeueReusableCellWithIdentifier:@"OccurrenceCell"];
        //    } else if ([indexPath row] == [_occurrences count]+1) {
        //        return [tableView dequeueReusableCellWithIdentifier:@"UnlinkCell"];
       
    } else {
        OccurrenceCell *taskCell = [tableView dequeueReusableCellWithIdentifier:@"OccurrenceCell"];
        taskCell.delegate = self;
        DBRecord *occurrence = _occurrences[[indexPath row]];
        NSDate *date = occurrence[@"date"];
        NSDateFormatter *formater = [[NSDateFormatter alloc ] init];
                                      [formater setDateStyle:NSDateFormatterMediumStyle];
        [formater setDateFormat: @"E d MMM`yy\nHH:mm 'Uhr'"];
        NSString *dateString =[formater stringFromDate:date];
        NSLog(@"Datestring of rendered cell: %@",dateString);
        int type = [occurrence[@"type"] intValue];
        switch (type) {
            case oOccurenceInjection:
                [taskCell.typeImageView setImage:[UIImage imageNamed:@"syringe"]];
//                CGRect newFrame = CGRectMake(oldFrame.origin.x, oldFrame.origin.y, oldFrame.size.width, oldFrame.size.height);
//                taskCell.imageView.frame = newFrame;
                break;
            
            case oOccurenceGastro:
                [taskCell.typeImageView setImage:[UIImage imageNamed:@"toilet"]];
                break;
                
            default: //= oOccurenceStandard
                [taskCell.typeImageView setImage:[UIImage imageNamed:@"headache"]];
                //show head icon
                //show standard stuff
                break;
        }

        taskCell.labelDate.text = dateString;
        [taskCell.switchMedicated setOn:[occurrence[@"medicated"] boolValue]];
        taskCell.labelDetails.text = [NSString stringWithFormat:@"%@",([occurrence[@"medicated"] boolValue]?@"behandelt":@"")];
        taskCell.stepperStrength.value = [occurrence[@"strength"] doubleValue];
        taskCell.labelStrength.text = [NSString stringWithFormat:@"%@",occurrence[@"strength"]];
        //        UIView *checkmark = taskCell.taskCompletedView;
        //        if ([task[@"completed"] boolValue]) {
        //            checkmark.hidden = NO;
        //        } else {
        //            checkmark.hidden = YES;
        //        }
        if([self cellIsSelected:indexPath]) {
            [taskCell.stepperStrength setHidden:NO];
            switch (type) {
                case oOccurenceInjection:
                    [taskCell.switchMedicated setHidden:YES];
                    break;
                default:
                    [taskCell.switchMedicated setHidden:NO];
                    break;
            }
        }else{
            [taskCell.stepperStrength setHidden:YES];
            [taskCell.switchMedicated setHidden:YES];
        }

        return taskCell;
    }
}

#pragma mark - OccurrenceCellDelegate

-(void)medicatedSwitchChangedOnTableCell:(id)sender{
    if (self.account) {
        NSIndexPath *indexPath = [self.occurrenceTableView indexPathForCell:sender];
        DBRecord *task = [_occurrences objectAtIndex:[indexPath row]];
        task[@"medicated"] = [task[@"medicated"] boolValue] ? @NO : @YES;
        [self.occurrenceTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void)strengthValueChangedOnTableCell:(id)sender{
    if (self.account) {
        NSIndexPath *indexPath = [self.occurrenceTableView indexPathForCell:sender];
        DBRecord *task = [_occurrences objectAtIndex:[indexPath row]];
        OccurrenceCell *cell = sender;
        task[@"strength"] = [NSNumber numberWithDouble:cell.stepperStrength.value];
        [self.occurrenceTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}


#pragma mark - UITableViewDelegate

- (BOOL)cellIsSelected:(NSIndexPath *)indexPath {
	// Return whether the cell at the specified index path is selected or not
	NSNumber *selectedIndex = [selectedIndexes objectForKey:[NSNumber numberWithLong:[indexPath row]]];
	return selectedIndex == nil ? FALSE : [selectedIndex boolValue];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (self.account) {
//        DBRecord *task = [_occurrences objectAtIndex:[indexPath row]];
//        task[@"medicated"] = [task[@"medicated"] boolValue] ? @NO : @YES;
//        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    }
    [self.table deselectRowAtIndexPath:indexPath animated:YES];
//    NSLog(@"cellIsSelectedBeforeSettingMade: %@ forIndexPathRow: %li", [NSNumber numberWithBool:[self cellIsSelected:indexPath]], (long)[indexPath row]);
    [selectedIndexes setObject:[NSNumber numberWithBool:!((BOOL)[self cellIsSelected:indexPath])] forKey:[NSNumber numberWithLong:[indexPath row]]];
//    NSLog(@"cellIsSelected: %@ forIndexPathRow: %li", [NSNumber numberWithBool:[self cellIsSelected:indexPath]], (long)[indexPath row]);
    [tableView beginUpdates];
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    [tableView endUpdates];
    
//    [tableView beginUpdates];
//    [tableView endUpdates];
    
}

//-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
//
//
//}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.account && [indexPath row] < [_occurrences count];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DBRecord *record = [_occurrences objectAtIndex:[indexPath row]];
    [record deleteRecord];
    [_occurrences removeObjectAtIndex:[indexPath row]];
    [self.occurrenceTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}



#pragma mark - UITextFieldDelegate methods

- (void)addItemToTableWithType: (OccurenceType)oType {
    if(self.account)
    {
        NSLog(@"found account");
        DBTable *tasksTbl = [self.store getTable:@"occurrences"];
        DBRecord *task = [tasksTbl insert:@{ @"strength": [NSNumber numberWithInt:0], @"medicated": @NO, @"date": [NSDate date], @"type": [NSNumber numberWithInt:oType]} ];
        NSLog(@"task1: %@",(NSNumber*)task[@"strength"]);
        [_occurrences insertObject:task atIndex:0];
        NSLog(@"anzahl occurrences: %lu",(unsigned long)[_occurrences count]);
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(0) inSection:0];
        [self.occurrenceTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else{
        [[DBAccountManager sharedManager] linkFromController:self];
    }
}

- (IBAction)addOccurenceStandard {
    [self toogleOccurenceAddView];
    [self addItemToTableWithType:oOccurenceStandard];
}

- (IBAction)addOccurenceInjection {
    [self toogleOccurenceAddView];
    [self addItemToTableWithType:oOccurenceInjection];
}

- (IBAction)addOccurenceGastro {
    [self toogleOccurenceAddView];
    [self addItemToTableWithType:oOccurenceGastro];

}

- (IBAction)toogleOccurenceAddView{
    [self endEditMode];
    [selectedIndexes setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInt:0]];
    [self.addOccurenceSelectorView setHidden:!self.addOccurenceSelectorView.hidden];
}

#pragma mark - private methods

- (DBAccount *)account {
    return [DBAccountManager sharedManager].linkedAccount;
}

- (DBAccountManager *)accountManager {
    return [DBAccountManager sharedManager];
}

- (DBDatastore *)store {
    if (!_store) {
        _store = [DBDatastore openDefaultStoreForAccount:self.account error:nil];
    }
    return _store;
}

- (void)setupTasks {
    NSLog(@"starting setup");
    if (self.account) {
        __weak ViewController *slf = self;
        [self.store addObserver:self block:^ {
            if (slf.store.status & (DBDatastoreIncoming | DBDatastoreOutgoing)) {
                [slf syncTasks];
            }
        }];
        _occurrences = [NSMutableArray arrayWithArray:[[self.store getTable:@"occurrences"] query:nil error:nil]];
        NSLog(@"anzahl occurrences nach initial setup: %i",[_occurrences count]);
        [_occurrences sortUsingComparator:^NSComparisonResult(id a, id b) {
            NSDate *first =  ((DBRecord*)a)[@"date"];
            NSDate *second = ((DBRecord*)b)[@"date"];
            return [second compare:first];
        }];
        
    } else {
        _store = nil;
        _occurrences = nil;
    }
    [self.occurrenceTableView reloadData];
    [self syncTasks];
}

- (void)syncTasks {
    if (self.account) {
        NSLog(@"Starting sync");
        NSDictionary *changed = [self.store sync:nil];
//        [self update:changed];
    }
}

- (void)update:(NSDictionary *)changedDict {
    NSMutableArray *deleted = [NSMutableArray array];
    for (int i = [_occurrences count] - 1; i >=0; i--) {
        DBRecord *task = _occurrences[i];
        if (task.deleted) {
            [deleted addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            [_occurrences removeObjectAtIndex:i];
        }
    }
    [self.occurrenceTableView deleteRowsAtIndexPaths:deleted withRowAnimation:UITableViewRowAnimationAutomatic];
    
    NSMutableArray *changed = [NSMutableArray arrayWithArray:[changedDict[@"occurrences"] allObjects]];
    NSMutableArray *updates = [NSMutableArray array];
    for (int i = [changed count] - 1; i >=0; i--) {
        DBRecord *record = changed[i];
        if (record.deleted) {
            [changed removeObjectAtIndex:i];
        } else {
            NSUInteger idx = [_occurrences indexOfObject:record];
            if (idx != NSNotFound) {
                [updates addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
                [changed removeObjectAtIndex:i];
            }
        }
    }
    [self.occurrenceTableView reloadRowsAtIndexPaths:updates withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [_occurrences addObjectsFromArray:changed];
    [_occurrences sortedArrayUsingComparator: ^(DBRecord *obj1, DBRecord *obj2) {
        return [obj1[@"date"] compare:obj2[@"date"]];
    }];
    NSMutableArray *inserts = [NSMutableArray array];
    for (DBRecord *record in changed) {
        int idx = [_occurrences indexOfObject:record];
        [inserts addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
    }
    [self.occurrenceTableView insertRowsAtIndexPaths:inserts withRowAnimation:UITableViewRowAnimationAutomatic];
}




//- (IBAction)didPressLink {
//    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
//    if (account) {
//        NSLog(@"App already linked");
//        [self syncTasks];
//    } else {
//        [[DBAccountManager sharedManager] linkFromController:self];
//    }
//}

-(IBAction)endEditMode{
//    if([_occurrences count] > 0)
//    {
//        [self.occurrenceTableView setEditing:!self.occurrenceTableView.editing animated:YES];
//        self.occurrenceTableView.rowHeight = self.occurrenceTableView.editing?90:70;
//        [self.occurrenceTableView reloadData];
//    }
//    [self.doneButton setEnabled:NO];
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    for(id key in selectedIndexes) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:[key integerValue]  inSection:0]];
    }
    [selectedIndexes removeAllObjects];
    [self.table beginUpdates];
    [self.table reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationRight];
    [self.table endUpdates];
}

@end
