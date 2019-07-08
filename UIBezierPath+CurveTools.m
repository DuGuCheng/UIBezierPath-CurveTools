//
//  UIBezierPath+CurveTools.m
//  ****
//
//  Created by LiuHaiLiang on 2019/7/8.
//  Copyright © 2019 ****. All rights reserved.
//

#import "UIBezierPath+CurveTools.h"

#define LHLTOOL_MiddlePoint(point1,point2) CGPointMake((point1.x+point2.x)/2.0, (point1.y+point2.y)/2.0)

@implementation UIBezierPath (CurveTools)

/**
 由一组坐标点生成贝塞尔曲线
 
 @param pointsArray 顺序坐标点
 @return 贝塞尔曲线
 */
+ (UIBezierPath *)getBezierPathFromPoints:(NSMutableArray *)pointsArray{
    
    CGPoint startPoint = [pointsArray[0] CGPointValue];
    
    CGPoint lastPoint = [pointsArray.lastObject CGPointValue];
    
    UIBezierPath *path = [[UIBezierPath alloc] init];
    
    [path moveToPoint:startPoint];
    
    for (NSInteger i = 2; i<pointsArray.count; i++) {
        
        CGPoint point1 = [pointsArray[i-1] CGPointValue];
        
        CGPoint point2 = [pointsArray[i] CGPointValue];
        
        CGPoint middlePoint = LHLTOOL_MiddlePoint(point1, point2);
        
        [path addQuadCurveToPoint:middlePoint controlPoint:point1];
    }
    
    [path addLineToPoint:lastPoint];
    
    return path;
}

/**
 生成贝塞尔曲线轨迹上的所有点，提高曲线点数据的密度
 
 @param pointsArray 可生成贝塞尔曲线的一组点
 @return 更高密度的曲线点数据
 */
+ (NSMutableArray *)remedyBezierPathPoints:(NSMutableArray *)pointsArray {
    
    CGFloat pointStep = 3;//点间距
    
    NSMutableArray *resultPointsArray = [NSMutableArray array];
    
    //头部处理
    
    [resultPointsArray addObject:pointsArray[0]];
    
    CGPoint point0 = [pointsArray[0] CGPointValue];
    
    CGPoint point1 = [pointsArray[1] CGPointValue];
    
    CGPoint middlePoint = LHLTOOL_MiddlePoint(point0, point1);
    
    NSInteger stepX = fabs(middlePoint.x - point0.x);
    
    NSInteger stepY = fabs(middlePoint.y - point0.y);
    
    NSInteger insertNum = 0;
    
    if (stepX > stepY) {
        
        insertNum  = stepX / pointStep;
    }else{
        
        insertNum = stepY / pointStep;
    }
    
    if (insertNum > 1) {
        
        CGFloat addValueX = (middlePoint.x - point0.x) / ((CGFloat)insertNum);
        
        CGFloat addValueY = (middlePoint.y - point0.y) / ((CGFloat)insertNum);
        
        for (NSInteger i = 1; i < insertNum; i ++) {
            
            CGFloat x = point0.x + addValueX * i;
            
            CGFloat y = point0.y + addValueY * i;
            
            CGPoint point = CGPointMake(x, y);
            
            [resultPointsArray addObject:@(point)];
        }
    }
    
    //中部处理
    
    for (NSInteger i = 2; i < pointsArray.count; i ++) {
        
        CGPoint point0 = [pointsArray[i - 2] CGPointValue];
        
        CGPoint point1 = [pointsArray[i - 1] CGPointValue];
        
        CGPoint point2 = [pointsArray[i] CGPointValue];
        
        CGPoint middlePoint1 = LHLTOOL_MiddlePoint(point0, point1);
        
        CGPoint middlePoint2 = LHLTOOL_MiddlePoint(point1, point2);
        
        NSInteger stepX = fabs(middlePoint2.x - middlePoint1.x) >= 1 ? fabs(middlePoint2.x - middlePoint1.x) : 1;
        
        NSInteger stepY = fabs(middlePoint2.y - middlePoint1.y) >= 1 ? fabs(middlePoint2.y - middlePoint1.y) : 1;
        
        NSInteger insertNum = 0;
        
        if (stepX > stepY) {
            
            insertNum  = stepX / pointStep;
        }else{
            
            insertNum = stepY / pointStep;
        }
        
        [resultPointsArray addObject:@(middlePoint1)];
        
        if (insertNum > 1) {
            
            for (NSInteger i = 1; i < insertNum; i ++) {
                
                CGFloat t = i / ((CGFloat)insertNum) ;
                
                CGFloat x = [self getValueForT:t position1:middlePoint1.x position2:middlePoint2.x controlValue:point1.x];
                
                CGFloat y = [self getValueForT:t position1:middlePoint1.y position2:middlePoint2.y controlValue:point1.y];
                
                CGPoint point = CGPointMake(x, y);
                
                [resultPointsArray addObject:@(point)];
            }
        }
    }
    
    //尾部处理
    
    CGPoint tailPoint0 = [pointsArray[pointsArray.count - 2] CGPointValue];
    
    CGPoint tailPoint1 = [pointsArray.lastObject CGPointValue];
    
    CGPoint middleTailPoint = LHLTOOL_MiddlePoint(tailPoint0, tailPoint1);
    
    NSInteger tailStepX = fabs(tailPoint1.x - middleTailPoint.x);
    
    NSInteger tailStepY = fabs(tailPoint1.y - middleTailPoint.y);
    
    NSInteger tailInsertNum = 0;
    
    if (tailStepX > tailStepY) {
        
        tailInsertNum  = tailStepX / pointStep;
    }else{
        
        tailInsertNum = tailStepY / pointStep;
    }
    
    [resultPointsArray addObject:@(middleTailPoint)];
    
    if (tailInsertNum > 1) {
        
        CGFloat addValueX = (tailPoint1.x - middleTailPoint.x) / ((CGFloat)tailInsertNum);
        
        CGFloat addValueY = (tailPoint1.y - middleTailPoint.y) / ((CGFloat)tailInsertNum);
        
        for (NSInteger i = 1; i < tailInsertNum; i ++) {
            
            CGFloat x = middleTailPoint.x + addValueX * i;
            
            CGFloat y = middleTailPoint.y + addValueY * i;
            
            CGPoint point = CGPointMake(x, y);
            
            [resultPointsArray addObject:@(point)];
        }
    }
    
    [resultPointsArray addObject:@(tailPoint1)];
    
    return resultPointsArray;
}

/**
 获取二次贝塞尔曲线上，任意位置的坐标
 
 @param t 所求点到原点的轨迹与整个轨迹长度的百分比
 @param position1 起点坐标的x值（或y值）
 @param position2 终点坐标的x值（或y值）
 @param controlValue 控制点坐标的x值（或y值）
 @return 所求点坐标的x值（或y值）
 */
+ (CGFloat)getValueForT:(CGFloat)t position1:(CGFloat)position1 position2:(CGFloat)position2 controlValue:(CGFloat)controlValue {
    
    return (1-t) * (1-t) * position1 + 2 * t * (1 - t) * controlValue + t * t * position2;
}

@end
