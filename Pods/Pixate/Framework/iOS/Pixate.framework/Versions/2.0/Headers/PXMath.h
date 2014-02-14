//
//  PXMath.h
//  Pixate
//
//  Created by Kevin Lindsey on 7/28/12.
//  Copyright (c) 2012 Pixate, Inc. All rights reserved.
//

#ifndef PXShapeKit_PXMath_h
#define PXShapeKit_PXMath_h

#define DEGREES_TO_RADIANS(angle)   ( (angle)  / 180.0 * M_PI)
#define RADIANS_TO_DEGREES(radians) ((radians) * 180.0 / M_PI)
#define TWO_PI (2.0 * M_PI)

#if CGFLOAT_IS_DOUBLE
#define SIN(t) sin(t)
#define COS(t) cos(t)
#define TAN(t) tan(t)
#define ATAN2(y,x) atan2(y,x)
#define SQRT(n) sqrt(n)
#define EXP(n) exp(n)
#define FLOOR(n) floor(n)
#else
#define SIN(t) sinf(t)
#define COS(t) cosf(t)
#define TAN(t) tanf(t)
#define ATAN2(y,x) atan2f(y,x)
#define SQRT(n) sqrtf(n)
#define EXP(n) expf(n)
#define FLOOR(n) floorf(n)
#endif

#endif
