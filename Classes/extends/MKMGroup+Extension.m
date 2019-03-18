//
//  MKMGroup+Extension.m
//  DIMCore
//
//  Created by Albert Moky on 2019/3/18.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMBarrack.h"

#import "MKMGroup+Extension.h"

@implementation MKMGroup (Extension)

- (BOOL)isFounder:(const MKMID *)ID {
    const DIMID *founder = self.founder;
    if (founder) {
        return [founder isEqual:ID];
    } else {
        const DIMMeta *meta = self.meta;
        const DIMPublicKey *PK = DIMPublicKeyForID(ID);
        return [meta matchPublicKey:PK];
    }
}

@end
