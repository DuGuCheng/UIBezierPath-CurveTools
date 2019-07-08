//
//  UIBezierPath+CurveTools.h
//  ****
//
//  Created by LiuHaiLiang on 2019/7/8.
//  Copyright © 2019 ****. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBezierPath (CurveTools)

/**
  由一组坐标点生成贝塞尔曲线
  
  @param pointsArray 顺序坐标点
  @return 贝塞尔曲线
  */
+ (UIBezierPath *)getBezierPathFromPoints:(NSMutableArray *)pointsArray;

/**
 生成贝塞尔曲线轨迹上的所有点，提高曲线点数据的密度
 
 @param pointsArray 可生成贝塞尔曲线的一组点
 @return 更高密度的曲线点数据
 */
+ (NSMutableArray *)remedyBezierPathPoints:(NSMutableArray *)pointsArray;

/**
 获取二次贝塞尔曲线上，任意位置的坐标
 
 @param t 所求点到原点的轨迹与整个轨迹长度的百分比
 @param position1 起点坐标的x值（或y值）
 @param position2 终点坐标的x值（或y值）
 @param controlValue 控制点坐标的x值（或y值）
 @return 所求点坐标的x值（或y值）
 */
+ (CGFloat)getValueForT:(CGFloat)t position1:(CGFloat)position1 position2:(CGFloat)position2 controlValue:(CGFloat)controlValue;

@end

NS_ASSUME_NONNULL_END
