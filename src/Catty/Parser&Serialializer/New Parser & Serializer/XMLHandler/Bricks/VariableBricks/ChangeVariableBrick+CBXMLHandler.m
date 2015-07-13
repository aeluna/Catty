/**
 *  Copyright (C) 2010-2015 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

#import "ChangeVariableBrick+CBXMLHandler.h"
#import "CBXMLValidator.h"
#import "GDataXMLElement+CustomExtensions.h"
#import "GDataXMLNode+CustomExtensions.h"
#import "Formula+CBXMLHandler.h"
#import "UserVariable+CBXMLHandler.h"
#import "CBXMLParser.h"
#import "CBXMLParserContext.h"
#import "CBXMLSerializerContext.h"
#import "CBXMLParserHelper.h"
#import "CBXMLSerializerHelper.h"
#import "VariablesContainer.h"
#import "OrderedMapTable.h"

@implementation ChangeVariableBrick (CBXMLHandler)

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContextForLanguageVersion093:(CBXMLParserContext*)context
{
    NSUInteger childCount = [xmlElement.childrenWithoutComments count];
    if (childCount == 3) {
        [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:3 AndFormulaListWithTotalNumberOfFormulas:1];
        
        // optional
        GDataXMLElement *inUserBrickElement = [xmlElement childWithElementName:@"inUserBrick"];
        [XMLError exceptionIfNil:inUserBrickElement message:@"No inUserBrickElement element found..."];

        // TODO: handle inUserBrick here...

    } else if (childCount == 2) {
        [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:2 AndFormulaListWithTotalNumberOfFormulas:1];
    } else if (childCount == 1) {
        [CBXMLParserHelper validateXMLElement:xmlElement forNumberOfChildNodes:1 AndFormulaListWithTotalNumberOfFormulas:1];
    } else {
        [XMLError exceptionWithMessage:@"Too many or too less child elements..."];
    }

    Formula *formula = [CBXMLParserHelper formulaInXMLElement:xmlElement forCategoryName:@"VARIABLE_CHANGE" withContext:context];
    ChangeVariableBrick *changeVariableBrick = [self new];
    changeVariableBrick.variableFormula = formula;
    
    if(childCount > 1) {
        GDataXMLElement *userVariableElement = [xmlElement childWithElementName:@"userVariable"];
        [XMLError exceptionIfNil:userVariableElement message:@"No userVariableElement element found..."];
        
        UserVariable *userVariable = [context parseFromElement:userVariableElement withClass:[UserVariable class]];
        [XMLError exceptionIfNil:userVariable message:@"Unable to parse userVariable..."];
        
        changeVariableBrick.userVariable = userVariable;
    }
    return changeVariableBrick;
}

+ (instancetype)parseFromElement:(GDataXMLElement*)xmlElement withContextForLanguageVersion095:(CBXMLParserContext*)context
{
    return [self parseFromElement:xmlElement withContextForLanguageVersion093:context];
}

- (GDataXMLElement*)xmlElementWithContext:(CBXMLSerializerContext*)context
{
    NSUInteger indexOfBrick = [CBXMLSerializerHelper indexOfElement:self inArray:context.brickList];
    GDataXMLElement *brick = [GDataXMLElement elementWithName:@"brick" xPathIndex:(indexOfBrick+1) context:context];
    [brick addAttribute:[GDataXMLElement attributeWithName:@"type" escapedStringValue:@"ChangeVariableBrick"]];
    GDataXMLElement *formulaList = [GDataXMLElement elementWithName:@"formulaList" context:context];
    GDataXMLElement *formula = [self.variableFormula xmlElementWithContext:context];
    [formula addAttribute:[GDataXMLElement attributeWithName:@"category" escapedStringValue:@"VARIABLE_CHANGE"]];
    [formulaList addChild:formula context:context];
    [brick addChild:formulaList context:context];

    //  Unused at the moment => TODO: implement this after Catroid has decided to officially use this feature!
    //    [brick addChild:[GDataXMLElement elementWithName:@"inUserBrick" stringValue:@"false"
    //                                             context:context] context:context];

    if(self.userVariable)
        [brick addChild:[self.userVariable xmlElementWithContext:context] context:context];
    return brick;
}

@end
