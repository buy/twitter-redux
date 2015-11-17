//
//  MenuCell.m
//  twitter
//
//  Created by Chang Liu on 11/16/15.
//  Copyright © 2015 Chang Liu. All rights reserved.
//

#import "MenuCell.h"

@implementation MenuCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setData:(NSDictionary *)data {
    _data = data;

    [self.iconImage setImage:[UIImage imageNamed:data[@"icon"]]];
    self.label.text = data[@"label"];
}

@end
