#import <UIKit/UIKit.h>

@protocol OccurrenceCellDelegate
@optional
- (void)medicatedSwitchChangedOnTableCell:(id)sender;
- (void)strengthValueChangedOnTableCell:(id)sender;
@end

@interface OccurrenceCell : UITableViewCell
@property (nonatomic, strong) id  delegate;
@property (nonatomic, retain) IBOutlet UILabel *labelDetails;
@property (nonatomic, retain) IBOutlet UILabel *labelDate;
@property (nonatomic, retain) IBOutlet UILabel *labelStrength;
@property (nonatomic, retain) IBOutlet UILabel *labelDescriptorStrength;
@property (nonatomic, retain) IBOutlet UISwitch *switchMedicated;
@property (nonatomic, retain) IBOutlet UIStepper *stepperStrength;
@property (retain, nonatomic) IBOutlet UIImageView *typeImageView;

@end
