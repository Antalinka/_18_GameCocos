//
//  JTBonus.m
//  JustTanks
//
//  Created by Exo-terminal on 4/5/14.
//  Copyright 2014 Evgenia. All rights reserved.
//

#import "JTBonus.h"
#import "JTGameScene.h"
#import "JTPlayerTank.h"
#import "SimpleAudioEngine.h"


@implementation JTBonus
-(id) initWithType: (JTBonusType) type scene: (JTGameScene*) scene{
    
    NSString* name = nil;
    switch (type) {
        case JTBonusTypeAmmunition:  name = @"ammunition_icon.png";  break;
        case JTBonusTypeHealth:      name = @"helth_icon.png";  break;
        case JTBonusTypeLife:        name = @"life_icon.png";  break;
       }
    if (self = [super initWithSprite:[CCSprite spriteWithFile:name] scene:self.scene properties:nil]) {
//        self.scene = scene;
        _type = type;
        
        id jump = [CCJumpBy actionWithDuration:0.5 position:ccp(0, 0) height:5 jumps:1];
        [self.sprite runAction:[CCRepeatForever actionWithAction:jump]];
        
        id del = [CCDelayTime actionWithDuration:bonus_duration];
        id blink = [CCBlink actionWithDuration:3 blinks:5];
        id cal = [CCCallBlock actionWithBlock:^{
            [self removeFromParentAndCleanup:YES];
        }];
        [self runAction:[CCSequence actions:del,blink,cal, nil]];
        
    }
    return self;
}
-(void) update:(float)dt{
    
    for (JTObject *enemy in self.scene.enemiesArray) {
        if(CGRectIntersectsRect([self.scene getRectFromObject:enemy], [self.scene getRectFromObject:self])){
//        NSLog(@"enemy!");

            [self removeFromParentAndCleanup:YES];
            [[SimpleAudioEngine sharedEngine]playEffect:@"regular.wav"];
         }
    }
    if(CGRectIntersectsRect([self.scene getRectFromObject:self.scene.playerTank], [self.scene getRectFromObject:self])){
        
        NSLog(@"wow!");
        [self removeFromParentAndCleanup:YES];
        [[SimpleAudioEngine sharedEngine]playEffect:@"regular.wav"];

        
        switch (_type) {
            case JTBonusTypeAmmunition: {
                self.scene.playerTank.bullets = max_bullets;
                [self.scene updateBulletsIcons];
            }break;
                
            case JTBonusTypeHealth: {
                
                float percentage = (self.scene.playerTank.health / (float)self.scene.playerTank.allHealth) * 100;
                self.scene.playerTank.health = self.scene.playerTank.allHealth;
                if (percentage < 100) {
                    CCProgressTimer* timeBar = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"circle.png"]];
                    timeBar.type = kCCProgressTimerTypeRadial;
                    timeBar.reverseDirection = YES;
                    timeBar.opacity = 160;
                    timeBar.color = ccc3(0, 255, 255);
                    timeBar.position = self.scene.playerTank.position;
                    timeBar.percentage = percentage;
                    [self.scene addChild:timeBar z:100];
                    
                    id progress = [CCProgressTo actionWithDuration:(100/percentage) * 0.2 percent:100];
                    id fade = [CCFadeOut actionWithDuration:0.5];
                    id cal = [CCCallBlock actionWithBlock:^{
                        [timeBar removeFromParentAndCleanup:YES];
                    }];
                    
                    [timeBar runAction:[CCSequence actions:progress, fade, cal, nil]];
                }
                
                
                [self.scene updateBulletsIcons];
            }break;
                
            case JTBonusTypeLife: {
                self.scene.lives = max_lives;
                [self.scene updateLifeIcons];
            }break;
      
        }
    }
}
@end
