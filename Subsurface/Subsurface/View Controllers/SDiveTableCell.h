//
//  SDiveTableCell.h
//  Subsurface
//
//  Created by Andrey Zhdanov on 24/05/14.
//  Copyright (c) 2014 Subsurface. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SDive;

@interface SDiveTableCell : UITableViewCell

- (void)setupDiveCell:(SDive *)dive;

@end
