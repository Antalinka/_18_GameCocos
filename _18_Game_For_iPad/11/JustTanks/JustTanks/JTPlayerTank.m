//
//  JTPlayerTank.m
//  JustTanks
//
//  Created by Exo-terminal on 4/1/14.
//  Copyright 2014 Evgenia. All rights reserved.
//

#import "JTPlayerTank.h"
#import "JTGameScene.h"
#import "JTBullet.h"
#import "JTEnemyTank.h"


#define trace_delay 0.08


@interface JTPlayerTank ()
@property (assign, nonatomic) float speed;
@property (assign, nonatomic) float traceCounter;
@property (strong, nonatomic) CCNode* pretender;

@end


@implementation JTPlayerTank

-(id) initWithSprite:(CCSprite *)sprt scene:(JTGameScene *)scene properties:(NSDictionary *)props{
    if (self = [super initWithSprite:sprt scene:scene properties:props]) {
        
        _speed = 160;
        _bullets = max_bullets;
        
        self.health = self.allHealth = 150;
        _pretender = [CCNode node];
        
    }
    return self;
}

-(void) check:(NSArray*) array forBool:(BOOL*)b andRect:(CGRect)rect{
    for (NSValue *val in array) {
        if (CGRectContainsPoint(rect, [val CGPointValue])) {
            *b = NO;
        }
    }
}

-(void)update:(float)dt{
    
    //переводим угол танка в радианы
    float rad = self.rotation * (M_PI / 180);
    
    //pretendPoint - точка, на которую танк сместится в случае отсуствия припятствия
    CGPoint deltaPoint = CGPointZero;
    
    //вычисления pretendPoint в зависимости от угла танка и направления движения
    if (self.scene.isMovingForward) deltaPoint = ccp(sin(rad) * dt * _speed,cos(rad) * dt * _speed);
    else if(self.scene.isMovingBack) deltaPoint = ccp(-sin(rad) * dt * _speed,-cos(rad) * dt * _speed);

    //претенденту присваевается предпологаемая новая позиция танка
    _pretender.position = ccpAdd(self.position, deltaPoint);
    
    //претенденту присваевается предпологаемый новый угол танка
    if (self.scene.isRotatingLeft)_pretender.rotation = self.rotation - 1 * dt * (_speed/2);
    else if(self.scene.isRotatingRight)_pretender.rotation = self.rotation +1 *dt * (_speed/2);
    
    //новые булевые для проверки конкретного движение и присваивается им положительное значение;
    BOOL canMoveForward = YES;
    BOOL canMoveBack = YES;
    BOOL canRotLeft = YES;
    BOOL canRotRight = YES;
    
    //на претенденте, который имеет и позицию, и угол, как у танка строятся 2 линии из точеек( вверху и внизу)
    //потом эти точки конвертируются в мировое пространство и к ним прибавляется deltaPoint
    //создаются 2 массива из верхней и нижней линии
    // точки верхней блинии будут проверятся на столкновение при движении вперед, точки нижней при движении назад
    
    float muzzleOffset = 6;
    
    NSMutableArray* topArray = [NSMutableArray array];
    NSMutableArray* bottomArray = [NSMutableArray array];
    
    
    for (int x = - self.sprite.contentSize.width/2; x <= self.sprite.contentSize.width/2; x += self.sprite.contentSize.width/4){
        for (int y = self.sprite.contentSize.height/2 - muzzleOffset; y >= -self.sprite.contentSize.height/2; y -= (self.sprite.contentSize.height - muzzleOffset)) {
            
            CGPoint p1 = ccpAdd(deltaPoint, [_pretender convertToWorldSpace:ccp(x, y)]);
            
            if (y == self.sprite.contentSize.height/2 - muzzleOffset) [topArray addObject:[NSValue valueWithCGPoint:p1]];
            else                                                      [bottomArray addObject:[NSValue valueWithCGPoint:p1]];
        }
    }
    
    NSMutableArray* array = [NSMutableArray arrayWithArray:self.scene.wallsArray];
    [array addObjectsFromArray:self.scene.enemiesArray];
    
    for (CCNode* wall in array) {
        
        CGRect rect = CGRectZero;
        if ([wall isKindOfClass:[JTEnemyTank class]]) {
            
            JTEnemyTank* tank = (JTEnemyTank*)wall;
            float width = tank.sprite.contentSize.height;
            CGPoint pos = [tank convertToWorldSpace:tank.sprite.position];
            rect = CGRectMake(pos.x - width/2, pos.y - width/2, width, width);
            
        }else if([wall isKindOfClass:[CCSprite class]]){
            rect = [self.scene getRectFromSprite:(CCSprite*)wall];
           
        }
        
        
            if (self.scene.isMovingForward)   [self check:topArray forBool:&canMoveForward andRect:rect];
            else if (self.scene.isMovingBack) [self check:bottomArray forBool:&canMoveBack andRect:rect];
            else if (self.scene.isRotatingLeft){
                
                [topArray addObjectsFromArray:bottomArray];
                [self check:topArray forBool:&canRotLeft andRect:rect];
            }else if (self.scene.isRotatingRight){
                
                [topArray addObjectsFromArray:bottomArray];
                [self check:topArray forBool:&canRotRight andRect:rect];
            }
        }
    
    [array removeAllObjects];
    topArray = nil;
    bottomArray = nil;
    
    if (_pretender.position.x - self.sprite.contentSize.width/2 > 0 && _pretender.position.x + self.sprite.contentSize.width/2 < self.winSize.width &&
        _pretender.position.y - self.sprite.contentSize.height/2 > 0 && _pretender.position.y + self.sprite.contentSize.height/2 < self.winSize.height) {
        
        if ((self.scene.isMovingForward && canMoveForward) || (self.scene.isMovingBack && canMoveBack))
            self.position = _pretender.position;
        
        if ((self.scene.isRotatingLeft && canRotLeft) || (self.scene.isRotatingRight && canRotRight))
            self.rotation = _pretender.rotation;
    
        float offseY = 0;
        
        if (self.scene.isMovingForward) offseY = -self.sprite.contentSize.height/2;
        else if (self.scene.isMovingBack) offseY = self.sprite.contentSize.height/2 - muzzleOffset;
        
        _traceCounter += dt;
        
            if (_traceCounter > trace_delay) {
                
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

    
//        if (self.scene.isRotatingLeft)self.rotation -= 1 * dt * (_speed/2);
//        else if  (self.scene.isRotatingRight)self.rotation += 1 * dt * (_speed/2);
//



-(void) shoot{
    
    if (![self.scene getChildByTag:bullet_tag] && _bullets > 0) {
        
        _bullets--;
        [self.scene updateBulletsIcons];
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:self.rotation],key_rotation,
                              [NSValue valueWithCGPoint:[self convertToWorldSpace:ccp(0, 55) ]] ,key_position,
                              [NSNumber numberWithInt:20],key_damage,nil];
        
        JTBullet* bullet = [[JTBullet alloc]initWithSprite: [CCSprite spriteWithFile:@"shot.png"] scene:self.scene properties:dict];
        bullet.tag = bullet_tag;
        [self.scene addChild:bullet z:55];
    }
}

@end

