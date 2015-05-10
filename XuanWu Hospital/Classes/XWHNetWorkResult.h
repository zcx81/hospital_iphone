//
//  XWHNetWorkResult.h
//  XuanWu Hospital
//
//  Created by Mingyang on 14/9/3.
//  Copyright (c) 2014年 XuanWu. All rights reserved.
//

typedef enum {
    NetworkResultSuccess = 0,
    NetworkResultFailedNoConnection = 1,
    NetworkResultFailedTimeout = 2,
    NetworkResultFailedAPIError = 3,
    NetworkResultFailedUnknown = 4,
} NetworkResult;

