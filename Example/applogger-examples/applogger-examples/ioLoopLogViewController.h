//
//  ioLoopLogViewController.h
//  ioApploggerExamples
//
//  Created by Mirko Olsiewicz on 15.03.14.
//  Copyright (c) 2014 Mirko Olsiewicz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ioBaseViewController.h"

#define maxSendLog 1000

@interface ioLoopLogViewController : ioBaseViewController{
    BOOL loggingCanceled;
}
@property (weak, nonatomic) IBOutlet UILabel *logCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;

- (IBAction)sendLoopLogClickHandler:(id)sender;
- (IBAction)cancelClicked:(id)sender;
@end
