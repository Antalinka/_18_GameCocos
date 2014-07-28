//
//  JTPlayerTank.h
//  JustTanks
//
//  Created by Exo-terminal on 4/1/14.
//  Copyright 2014 Evgenia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "JTObject.h"

@interface JTPlayerTank : JTObject {
    
}
@property (assign, nonatomic) int bullets;

-(void) shoot;

@end
