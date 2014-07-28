//
//  JTBonus.h
//  JustTanks
//
//  Created by Exo-terminal on 4/5/14.
//  Copyright 2014 Evgenia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "JTObject.h"

typedef enum{
    JTBonusTypeAmmunition,
    JTBonusTypeHealth,
    JTBonusTypeLife
}JTBonusType;


@interface JTBonus : JTObject {
    
}
@property (assign, nonatomic)JTBonusType type;

-(id) initWithType: (JTBonusType) type scene: (JTGameScene*) scene;
@end
