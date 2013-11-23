#import "OccurrenceCell.h"

@implementation OccurrenceCell

-(IBAction) switchTapped{
    [self.delegate medicatedSwitchChangedOnTableCell:self];
}

-(IBAction) stepperChangedValue{
    [self.delegate strengthValueChangedOnTableCell:self];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    
    if (editing) {
        [self.stepperStrength setHidden:NO];
        [self.switchMedicated setHidden:NO];
        [self.labelDetails setHidden:YES];
    }else{
        [self.labelDetails setHidden:NO];
        [self.stepperStrength setHidden:YES];
        [self.switchMedicated setHidden:YES];
    }
}


@end
