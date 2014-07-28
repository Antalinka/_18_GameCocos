//
//  JTEnemyTank.m
//  JustTanks
//
//  Created by Exo-terminal on 4/4/14.
//  Copyright 2014 Evgenia. All rights reserved.
//

#import "JTEnemyTank.h"
#import "JTGameScene.h"
#import "JTPlayerTank.h"
#import "JTBullet.h"

#define trace_delay 0.18


typedef enum{
    JTProbeLeft = -1,
    JTProbeCenter = 0,
    JTProbeRigtht = 1
    
}JTProbe;

@interface JTEnemyTank()
@property (nonatomic, assign) BOOL doChoose;
@property (nonatomic, assign) float shotDistance;
@property (nonatomic, assign) float dirX;
@property (nonatomic, assign) float dirY;
@property (nonatomic, assign) float traceCounter;
@end


@implementation JTEnemyTank

-(id) initWithSprite:(CCSprite *)sprt scene:(JTGameScene *)scene properties:(NSDictionary *)props{
    if (self = [super initWithSprite:sprt scene:scene properties:props]) {
        
        _doChoose = YES;
        
        _shotDistance = [[props objectForKey:key_shot_distance]floatValue];
        self.position = [[props objectForKey:key_position]CGPointValue];
        self.health = self.allHealth =  [[props objectForKey:key_health]intValue];
        
        _dirX = self.position.x;
        _dirY = self.position.y;
        
    }
   return self;
}


-(int) correctedRotation{
    int rot = (int)self.rotation%360;
    
    if (rot == -90) rot = 270;
    else if(rot == -270) rot = 90;
    else if (rot == -180) rot = 180;
    return rot;
}


-(CGRect) createProbe: (JTProbe) probe{
    float lengthX = 1;
    float lengthY = 1;
    
    if (probe == JTProbeCenter) {
        switch ([self correctedRotation]) {
            case 0: lengthY = _shotDistance; break;
            case 90: lengthX = _shotDistance; break;
            case 180: lengthY = -_shotDistance; break;
            case 270: lengthX = -_shotDistance; break;
            default: break;
        }
    }else{
        if ([self correctedRotation] == 0 || [self correctedRotation] == 180) {
            lengthY = _dirY - self.position.y;
        }else{
            lengthX = _dirX - self.position.x;
        }
        
    }
    
    CGPoint local = [self convertToWorldSpace:ccp(probe * self.sprite.contentSize.width/2, self.sprite.contentSize.height/2)];
    CGRect rect = CGRectMake(local.x, local.y, lengthX, lengthY);
    
    return rect;

}

-(BOOL) isFriendAheadForProbe: (JTProbe) probe{
    
    BOOL isFriend = NO;
    for (JTEnemyTank *tank in self.scene.enemiesArray) {
        if (![tank isEqual:self]) {
            CGPoint worldPoint = [tank convertToWorldSpace:tank.sprite.position];
            CGRect rect = CGRectMake(worldPoint.x - tank.sprite.contentSize.width/2 - 5, worldPoint.y - tank.sprite.contentSize.width/2 - 5,
                                     tank.sprite.contentSize.width +10, tank.sprite.contentSize.width +10);
            
            if (CGRectIntersectsRect(rect, [self createProbe:probe])) {
                float distToPlayer = ccpDistance(self.position, [self.scene getChildByTag:player_tag].position);
                float distToFriend = ccpDistance(self.position, tank.position);
                
                if (distToFriend < distToPlayer)
                    isFriend = YES;
            }
        }
    }
    
    return isFriend;
}

-(void) rotateWithAngle: (float) angle moveAndCallBlock: (void(^)()) block{
    
    [self stopAllActions];
    
    int differAngle = abs([self correctedRotation] - angle);
    if (differAngle == 270) differAngle = 90;
    
    float rotDuration = differAngle / rot_speed;
    float moveDuration = ccpDistance(self.position,ccp(_dirX, _dirY))/ move_speed;
    
    id rot = [CCRotateTo actionWithDuration:rotDuration angle:angle];
    id cal = [CCCallBlock actionWithBlock:^{
        BOOL doesLeftProbeHit = NO;
        BOOL doesRightProbeHit = NO;
        
        for (CCSprite *wall in self.scene.wallsArray) {
            if (CGRectIntersectsRect([self.scene getRectFromSprite:wall], [self createProbe:JTProbeLeft])) doesLeftProbeHit = YES;
            if (CGRectIntersectsRect([self.scene getRectFromSprite:wall], [self createProbe:JTProbeRigtht])) doesRightProbeHit = YES;
            }
        if (!doesLeftProbeHit && !doesRightProbeHit) {
            
            id seq = nil;
            id anAction = [CCMoveTo actionWithDuration:moveDuration position:ccp(_dirX, _dirY)];
            
            id cal = [CCCallBlock actionWithBlock:block];

            seq = [CCSequence actions:anAction,cal, nil];
            
            if ([self isFriendAheadForProbe:JTProbeLeft]  || [self isFriendAheadForProbe:JTProbeRigtht] ) anAction = [CCDelayTime actionWithDuration:1];
            else if(moveDuration > 0)[seq setTag:move_tag];
            
            [self runAction:seq];
            
        }else{
            
            if (doesLeftProbeHit) [self shootFromX: - self.sprite.contentSize.width/2];
            if (doesRightProbeHit) [self shootFromX: self.sprite.contentSize.width/2];
            
            id del = [CCDelayTime actionWithDuration:delay_after_shot];
            id cal = [CCCallBlock actionWithBlock:^{
                _doChoose = YES;
            }];
            [self runAction:[CCSequence actions:del,cal, nil]];
        }
    }];
    
    id seq = [CCSequence actions:rot,cal, nil];
    if (rotDuration > 0) [seq setTag:rot_tag];
    
    [self runAction:seq];
}

-(void) shootFromX: (float) x{
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:self.rotation],key_rotation,
                          [NSValue valueWithCGPoint:[self convertToWorldSpace:ccp(x, 55)]], key_position ,
                          [NSNumber numberWithInt:40],key_damage,nil];
    
    JTBullet* bullet = [[JTBullet alloc]initWithSprite:[CCSprite spriteWithFile:@"shot.png"] scene:self.scene properties:dict];
    [self.scene addChild:bullet z:55];
}

-(void) update:(float)dt{
    if (_doChoose) {
        _doChoose = NO;
        
        JTPlayerTank* playerTank = (JTPlayerTank*)[self.scene getChildByTag:player_tag];
        
        float differX = abs(self.position.x - playerTank.position.x);
        float differY = abs(self.position.y - playerTank.position.y);
        
        float angle = 0;
        
        BOOL inZoneY = differX < playerTank.sprite.contentSize.width/2;
        BOOL inZoneX = differY < playerTank.sprite.contentSize.width/2;
        
        if (inZoneX || inZoneY) {
            if (ccpDistance(self.position, playerTank.position) <= _shotDistance) {
                _dirX = self.position.x;
                _dirY = self.position.y;
            }
            if (inZoneY) {
                angle = self.position.y < playerTank.position.y ? 0 : 180;
            }else if (inZoneX){
                angle = self.position.x < playerTank.position.x ? 90 : 270;

                
            }
            
            [self rotateWithAngle:angle moveAndCallBlock:^{
                if (ccpDistance(self.position, playerTank.position) > _shotDistance) {
                    if (inZoneY) {
                        
                        int sign = self.position.y - playerTank.position.y < 0 ? 1 : -1;
                        
                        _dirX = self.position.x;
                        _dirY = playerTank.position.y - _shotDistance * 0.9 * sign;
                        
                    }else if (inZoneX){
                        int sign = self.position.x - playerTank.position.x < 0 ? 1  : -1;
                        
                        _dirY = self.position.y;
                        _dirX = playerTank.position.x - _shotDistance * 0.9 * sign;
                    }
                    _doChoose = YES;
                }else{
                    if (![self isFriendAheadForProbe:JTProbeCenter]) [self shootFromX:0];
                    
                    id del = [CCDelayTime actionWithDuration:delay_after_shot];
                    id cal = [CCCallBlock actionWithBlock:^{
                        _doChoose = YES;
                    }];
                    [self runAction:[CCSequence actions:del, cal, nil]];
                   
                }
            }];
        }else{
            if (differY < differX) {
                
                _dirX = self.position.x;
                _dirY = playerTank.position.y;
                
                angle = self.position.y < playerTank.position.y ? 0:180;
                
            }else if (differY > differX){
                
                _dirY = self.position.y;
                _dirX = playerTank.position.x;
                
                angle = self.position.x < playerTank.position.x ? 90 :270;
            }
            [self rotateWithAngle:angle moveAndCallBlock:^{
                _doChoose = YES;
            }];
        }
    }
    
    if ([self getActionByTag:move_tag] || [self getActionByTag:rot_tag]) {
        
        _traceCounter += dt;
        
        if (_traceCounter > trace_delay) {
            
            float offseY = 0;
            
            if ([self getActionByTag:move_tag]) offseY = -self.sprite.contentSize.height/2 +5;
            _traceCounter = 0;
            
            CCSprite* traces = [CCSprite spriteWithFile:@"traces.png"];
            traces.position = [self convertToWorldSpace:ccp(0, offseY)];
            traces.rotation = self.rotation;
            [self.scene addChild:traces];
            
            id fade = [CCFadeOut actionWithDuration:trace_duration];
            id cal = [CCCallBlock actionWithBlock:^{
                [traces removeFromParentAndCleanup:YES];
            }];
            [traces runAction:[CCSequence actions:fade, cal, nil]];
        }
    }
}


















@end
