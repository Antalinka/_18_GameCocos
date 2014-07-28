//
//  JTEnemyTank.h
//  JustTanks
//
//  Created by Exo-terminal on 4/4/14.
//  Copyright 2014 Evgenia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "JTObject.h"

@interface JTEnemyTank : JTObject {
    
}

@property (assign, nonatomic)int damage;
@property (assign, nonatomic)int moveSpeed;
@property (assign, nonatomic)int rotSpeed;
@property (assign, nonatomic)float shotDistance;
@property (assign, nonatomic)float appearingDelay;
@property (assign, nonatomic)CGPoint startPos;
@property (assign, nonatomic)float startRotation;

@end
