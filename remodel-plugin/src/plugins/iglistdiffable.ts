/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

import Code = require('../code');
import Error = require('../error');
import FileWriter = require('../file-writer');
import FunctionUtils = require('../function-utils');
import Maybe = require('../maybe');
import ObjC = require('../objc');
import ObjCTypeUtils = require('../objc-type-utils');
import ObjectSpec = require('../object-spec');
import ObjectSpecUtils = require('../object-spec-utils');
import ObjectSpecCodeUtils = require('../object-spec-code-utils');

function isEqualToDiffableObjectMethod():ObjC.Method {
  return {
    belongsToProtocol:Maybe.Just<string>('IGListDiffable'),
    code: ['return [self isEqual:object];'],
    comments:[],
    compilerAttributes:[],
    keywords: [
      {
        name: 'isEqualToDiffableObject',
        argument: Maybe.Just<ObjC.KeywordArgument>({
          name: 'object',
          modifiers: [ObjC.KeywordArgumentModifier.Nullable()],
          type: {
            name: 'id',
            reference: 'id'
          }
        })
      }
    ],
    returnType: { type: Maybe.Just({
      name: 'BOOL',
      reference: 'BOOL'
    }), modifiers: [] }
  }
}

function formattedStringValueForIvarWithFormatSpecifier(iVarString:string, stringFormatSpecifier:string, optionalCast:string=null):string {
  var castString:string = (optionalCast === null ? "" : "(" + optionalCast + ")");
  return "[NSString stringWithFormat:@\"" + stringFormatSpecifier + "\", " + castString + iVarString + "]";
}

function functionReturnValueForIvarWithFunctionName(iVarString:string, functionToCall:string):string {
  return functionToCall + '(' + iVarString + ')';
}

function objectValueForAttribute(attribute:ObjectSpec.Attribute):string {
  const iVarString:string = ObjectSpecCodeUtils.ivarForAttribute(attribute);
  const type:ObjC.Type = ObjectSpecCodeUtils.computeTypeOfAttribute(attribute);

  return ObjCTypeUtils.matchType({
    id: function() {
      return formattedStringValueForIvarWithFormatSpecifier(iVarString, "%@");
    },
    NSObject: function() {
      return iVarString;
    },
    BOOL: function() {
      return iVarString + " ? @\"YES\" : @\"NO\"";
    },
    NSInteger: function() {
      return formattedStringValueForIvarWithFormatSpecifier(iVarString, "%lld", "long long");
    },
    NSUInteger: function() {
      return formattedStringValueForIvarWithFormatSpecifier(iVarString, "%llu", "unsigned long long");
    },
    double: function() {
      return formattedStringValueForIvarWithFormatSpecifier(iVarString, "%lf");
    },
    float: function() {
      return formattedStringValueForIvarWithFormatSpecifier(iVarString, "%f");
    },
    CGFloat: function() {
      return formattedStringValueForIvarWithFormatSpecifier(iVarString, "%f");
    },
    NSTimeInterval: function() {
      return formattedStringValueForIvarWithFormatSpecifier(iVarString, "%lf");
    },
    uintptr_t: function() {
      return formattedStringValueForIvarWithFormatSpecifier(iVarString, "%ld");
    },
    uint32_t: function() {
      return formattedStringValueForIvarWithFormatSpecifier(iVarString, "%u");
    },
    uint64_t: function() {
      return formattedStringValueForIvarWithFormatSpecifier(iVarString, "%llu");
    },
    int32_t: function() {
      return formattedStringValueForIvarWithFormatSpecifier(iVarString, "%d");
    },
    int64_t: function() {
      return formattedStringValueForIvarWithFormatSpecifier(iVarString, "%lld");
    },
    SEL: function() {
      return functionReturnValueForIvarWithFunctionName(iVarString, "NSStringFromSelector");
    },
    NSRange: function() {
      return functionReturnValueForIvarWithFunctionName(iVarString, "NSStringFromRange");
    },
    CGRect: function() {
      return functionReturnValueForIvarWithFunctionName(iVarString, "NSStringFromCGRect");
    },
    CGPoint: function() {
      return functionReturnValueForIvarWithFunctionName(iVarString, "NSStringFromCGPoint");
    },
    CGSize: function() {
      return functionReturnValueForIvarWithFunctionName(iVarString, "NSStringFromCGSize");
    },
    UIEdgeInsets: function() {
      return functionReturnValueForIvarWithFunctionName(iVarString, "NSStringFromUIEdgeInsets");
    },
    Class: function() {
      return formattedStringValueForIvarWithFormatSpecifier(iVarString, "%@");
    },
    dispatch_block_t: function() {
      return formattedStringValueForIvarWithFormatSpecifier(iVarString, "%@");
    },
    unmatchedType: function() {
      return "self";
    }
  }, type);
}

function diffIdentiferAttributeFilter(attribute:ObjectSpec.Attribute, index, array):boolean {
  return (attribute.annotations["diffIdentifier"] != null);
}

function diffIdentifierMethodImplementation(objectType:ObjectSpec.Type):string[] {
  const diffIdentifierAttributes:ObjectSpec.Attribute[] = objectType.attributes.filter(diffIdentiferAttributeFilter);
  if (diffIdentifierAttributes.length > 0) {
    // use first marked attribute as identifier, if available
    return ['return ' + objectValueForAttribute(diffIdentifierAttributes[0]) + ';']
  } else {
    // fallback/default to self
    return ['return self;'];
  }
}

function diffIdentifierMethod(objectType:ObjectSpec.Type):ObjC.Method {
  return {
    belongsToProtocol:Maybe.Just<string>('IGListDiffable'),
    code: diffIdentifierMethodImplementation(objectType),
    comments:[],
    compilerAttributes:[],
    keywords: [
      {
        name: 'diffIdentifier',
        argument: Maybe.Nothing<ObjC.KeywordArgument>()
      }
    ],
    returnType: { type: Maybe.Just({
      name: 'NSObject',
      reference: 'id<NSObject>'
    }), modifiers: [] }
  }
}

export function createPlugin():ObjectSpec.Plugin {
  return {
    additionalFiles: function(objectType:ObjectSpec.Type):Code.File[] {
      return [];
    },
    additionalTypes: function(objectType:ObjectSpec.Type):ObjectSpec.Type[] {
      return [];
    },
    attributes: function(objectType:ObjectSpec.Type):ObjectSpec.Attribute[] {
      return [];
    },
    classMethods: function(objectType:ObjectSpec.Type):ObjC.Method[] {
      return [];
    },
    fileTransformation: function(request:FileWriter.Request):FileWriter.Request {
      return request;
    },
    fileType: function(objectType:ObjectSpec.Type):Maybe.Maybe<Code.FileType> {
      return Maybe.Nothing<Code.FileType>();
    },
    forwardDeclarations: function(objectType:ObjectSpec.Type):ObjC.ForwardDeclaration[] {
      return [];
    },
    functions: function(objectType:ObjectSpec.Type):ObjC.Function[] {
      return [];
    },
    headerComments: function(objectType:ObjectSpec.Type):ObjC.Comment[] {
      return [];
    },
    implementedProtocols: function(objectType:ObjectSpec.Type):ObjC.Protocol[] {
      return [
        { name: 'IGListDiffable' },
      ];
    },
    imports: function(objectType:ObjectSpec.Type):ObjC.Import[] {
      return [
        {file:'IGListDiffable.h', isPublic:true, library:Maybe.Just('IGListKit')},
      ];
    },
    instanceMethods: function(objectType:ObjectSpec.Type):ObjC.Method[] {
      return [
        isEqualToDiffableObjectMethod(),
        diffIdentifierMethod(objectType)
      ];
    },
    properties: function(objectType:ObjectSpec.Type):ObjC.Property[] {
      return [];
    },
    requiredIncludesToRun:['IGListDiffable'],
    staticConstants: function(objectType:ObjectSpec.Type):ObjC.Constant[] {
      return [];
    },
    validationErrors: function(objectType:ObjectSpec.Type):Error.Error[] {
      return [];
    },
    nullability: function(objectType:ObjectSpec.Type):Maybe.Maybe<ObjC.ClassNullability> {
      return Maybe.Nothing<ObjC.ClassNullability>();
    },
    subclassingRestricted: function(objectType:ObjectSpec.Type):boolean {
      return false;
    },
  };
}
