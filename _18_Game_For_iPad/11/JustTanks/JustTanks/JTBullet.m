//
//  JTBullet.m
//  JustTanks
//
//  Created by Exo-terminal on 4/2/14.
//  Copyright 2014 Evgenia. All rights reserved.
//

#import "JTBullet.h"
#import "JTGameScene.h"
#import "SimpleAudioEngine.h"
#import "JTPlayerTank.h"
#import "JTEnemyTank.h"




@interface JTBullet()

@property (nonatomic, assign) int damage;
-(void) animateExplosionWithScale: (float) scale position: (CGPoint) pos;


@end


@implementation JTBullet

-(void) animateExplosionWithScale: (float) scale position: (CGPoint) pos {
    
   [[SimpleAudioEngine sharedEngine] playEffect:@"Explosion1.mp3"];
    NSMutableArray* animFrames = [NSMutableArray array];
    
    for (int i = 1; i < 16; i++) {
        CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"expl_%d.png", i]];
        [animFrames addObject:frame];
    }
    
    CCSprite* expl = [CCSprite spriteWithSpriteFrameName:@"expl_1.png"];
    expl.position = pos;
    expl.scale = scale;
    [self.scene addChild:expl z:55];
    
    CCAnimation* animation = [CCAnimation animationWithSpriteFrames:animFrames delay:0.05f];
    
    id anim = [CCAnimate actionWithAnimation:animation];
    
    id call = [CCCallBlock actionWithBlock:^{
        [expl removeFromParentAndCleanup:YES];
    }];
    [expl runAction:[CCSequence actions:anim, call, nil]];
    
}
-(id)initWithSprite:(CCSprite *)sprt scene:(JTGameScene *)scene properties:(NSDictionary *)props{
    if (self = [super initWithSprite:sprt scene:scene properties:props ]) {
        
        [[SimpleAudioEngine sharedEngine] playEffect:@"shot.wav"];
        
        _distance = 500;
        
        self.rotation = [[props objectForKey:key_rotation] floatValue];
        self.position = [[props objectForKey:key_position]CGPointValue];
        _damage = [[props objectForKey:key_damage]intValue];
        
        float rad = self.rotation * (M_PI / 180);
        
        CGPoint aimPos = ccpAdd(self.position, ccp(sin(rad) * _distance, cos(rad) * _distance));
        
        id mov = [CCMoveTo actionWithDuration:0.5 position:aimPos];
        id cal =[CCCallBlock actionWithBlock:^{
            
            [self animateExplosionWithScale:2 position:self.position];
            [self removeFromParentAndCleanup:YES];

        }];
        [self runAction:[CCSequence actions:mov,cal,nil]];
    }
    return self;
}

-(void) checkForCollisionWithObject: (JTObject*) object{
    CGPoint wPoint = [object convertToWorldSpace:object.sprite.position];
    float width = object.sprite.contentSize.height - 10;
    CGRect rect = CGRectMake(wPoint.x - width/2, wPoint.y - width/2, width, width);
    if (CGRectContainsPoint(rect, self.position)) {
        
        object.health -=self.damage;
        
        float percentage = (object.health / (float)object.allHealth) * 100;
        
        ccColor3B color = ccGREEN;
        BOOL isDeath = NO;
        
        
        if (percentage <= 0) {
            isDeath = YES;
            [self animateExplosionWithScale:4 position: object.position];
            
            id del = [CCDelayTime actionWithDuration:0.04];
            id cal = [CCCallBlock actionWithBlock:^{
                
                NSString* name = nil;
                if ([object isKindOfClass:[JTPlayerTank class]]){
                    
                    name = @"Tank1Crashed.png";
                    self.scene.lives--;
                    [self.scene createPlayer];
                    
                    
//                    [self.scene.enemiesArray removeObject:object];

                    }
                else if([object isKindOfClass:[JTEnemyTank class]]){
                    
                    name = @"Tank2Crashed.png";
                    [self.scene.enemiesArray removeObject:object];
                        
                    }
                
                if (name) {
                    CCSprite* spriteCrashed = [CCSprite spriteWithFile:name];
                    spriteCrashed.position = object.position;
                    spriteCrashed.rotation = object.rotation;
                    [self.scene addChild:spriteCrashed z:50];
                    
                    id fade = [CCFadeOut actionWithDuration:kFadingTime];
                    id cal = [CCCallBlock actionWithBlock:^{
                        [spriteCrashed removeFromParentAndCleanup:YES];
                    }];
                    [spriteCrashed runAction:[CCSequence actions:fade,cal, nil]];
                }
                [object removeFromParentAndCleanup:YES];

            }];
            [self.scene runAction:[CCSequence actionOne:del two:cal]];
            
            
        }else if(percentage <= 25) color = ccRED;
        else if (percentage <=50) color = ccYELLOW;

        
        CCProgressTimer* timeBar = [CCProgressTimer progressWithSprite:[CCSprite spriteWithFile:@"circle.png"]];
        timeBar.type = kCCProgressTimerTypeRadial;
        timeBar.reverseDirection = YES;
        timeBar.opacity = 160;
        timeBar.color = color;
        timeBar.position = object.position;
        timeBar.percentage = percentage;
        [self.scene addChild:timeBar z:100];

        float time = 4;
       
        id fade = [CCFadeTo actionWithDuration:time opacity:0];
        id move = [CCMoveBy actionWithDuration:time position:ccp(0, 200)];
        id spawn = [CCSpawn actionOne:fade two:move];
        id cal = [CCCallBlock actionWithBlock:^{
            [timeBar removeFromParentAndCleanup:YES];
        }];
        [timeBar runAction:[CCSequence actionOne:spawn two:cal]];
        
        
        if (!isDeath) {
            [self animateExplosionWithScale:2 position:self.position];

        }
    
        [self removeFromParentAndCleanup:YES];        }
    }
    


-(void)update:(float)dt{
    
    NSMutableArray* deleteArray = [[NSMutableArray alloc]init];
    
    for (CCSprite *wall in self.scene.wallsArray) {
        if (CGRectContainsPoint([self.scene getRectFromSprite:wall], self.position)) {
            
            [deleteArray addObject:wall];
            [wall removeFromParentAndCleanup:YES];
            [self animateExplosionWithScale:2 position:self.position];
            [self removeFromParentAndCleanup:YES];
        }
    }
    
    for (CCSprite *wall in deleteArray) {
        [self.scene.wallsArray removeObject:wall];
    }
    [deleteArray removeAllObjects];
    
    for (JTObject *tank in self.scene.enemiesArray) {
        [self checkForCollisionWithObject:tank];
    }
    
    [self checkForCollisionWithObject:(JTObject*)self.scene.playerTank];
}
@end
