//
//  ioFirstViewController.h
//  ioApploggerExamples
//
//  Created by Mirko Olsiewicz on 15.03.14.
//  Copyright (c) 2014 Mirko Olsiewicz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ioBaseViewController.h"
@interface ioSingleLogViewController : ioBaseViewController

@property (nonatomic, weak) IBOutlet UITextView *registerLinkTextView;

- (IBAction)sendSingleLogClickHandler:(id)sender;
@end
