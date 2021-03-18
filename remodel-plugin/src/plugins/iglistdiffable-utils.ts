/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import * as Maybe from '../maybe';
import * as ObjC from '../objc';
import * as ObjCTypeUtils from '../objc-type-utils';
import * as ObjectSpec from '../object-spec';
import * as ObjectSpecCodeUtils from '../object-spec-code-utils';

function isEqualToDiffableObjectMethod(): ObjC.Method {
  return {
    preprocessors: [],
    belongsToProtocol: Maybe.Just<string>('IGListDiffable'),
    code: ['return [self isEqual:object];'],
    comments: [],
    compilerAttributes: [],
    keywords: [
      {
        name: 'isEqualToDiffableObject',
        argument: Maybe.Just<ObjC.KeywordArgument>({
          name: 'object',
          modifiers: [ObjC.KeywordArgumentModifier.Nullable()],
          type: {
            name: 'id<IGListDiffable>',
            reference: 'id<IGListDiffable>',
          },
        }),
      },
    ],
    returnType: {
      type: Maybe.Just({
        name: 'BOOL',
        reference: 'BOOL',
      }),
      modifiers: [],
    },
  };
}

function functionReturnValueForIvarWithFunctionName(
  iVarString: string,
  functionToCall: string,
): string {
  return functionToCall + '(' + iVarString + ')';
}

function formattedStringValueForIvarWithFormatSpecifier(
  iVarString: string,
  stringFormatSpecifier: string,
  optionalCast: string = null,
): string {
  var castString: string =
    optionalCast === null ? '' : '(' + optionalCast + ')';
  return (
    '[NSString stringWithFormat:@"' +
    stringFormatSpecifier +
    '", ' +
    castString +
    iVarString +
    ']'
  );
}

function nullableObjectValueWithFallback(
  objectValue: string,
  optionalFallback: string = null,
) {
  return optionalFallback === null
    ? objectValue
    : `${objectValue} ?: ${optionalFallback}`;
}

function wrappedInNSValueForTypeName(iVarString: string, typeName: string) {
  return `[NSValue valueWith${typeName}:${iVarString}]`;
}

function objectValueForAttribute(
  attribute: ObjectSpec.Attribute,
  optionalFallback: string = null,
): string {
  const iVarString: string = ObjectSpecCodeUtils.ivarForAttribute(attribute);
  const type: ObjC.Type = ObjectSpecCodeUtils.computeTypeOfAttribute(attribute);

  return ObjCTypeUtils.matchType(
    {
      id: function() {
        return formattedStringValueForIvarWithFormatSpecifier(iVarString, '%@');
      },
      NSObject: function() {
        return nullableObjectValueWithFallback(iVarString, optionalFallback);
      },
      BOOL: function() {
        return `@(${iVarString})`;
      },
      NSInteger: function() {
        return `@(${iVarString})`;
      },
      NSUInteger: function() {
        return `@(${iVarString})`;
      },
      double: function() {
        return `@(${iVarString})`;
      },
      float: function() {
        return `@(${iVarString})`;
      },
      CGFloat: function() {
        return `@(${iVarString})`;
      },
      NSTimeInterval: function() {
        return `@(${iVarString})`;
      },
      uintptr_t: function() {
        return `@(${iVarString})`;
      },
      uint32_t: function() {
        return `@(${iVarString})`;
      },
      uint64_t: function() {
        return `@(${iVarString})`;
      },
      int32_t: function() {
        return `@(${iVarString})`;
      },
      int64_t: function() {
        return `@(${iVarString})`;
      },
      SEL: function() {
        return functionReturnValueForIvarWithFunctionName(
          iVarString,
          'NSStringFromSelector',
        );
      },
      NSRange: function() {
        return wrappedInNSValueForTypeName(iVarString, 'Range');
      },
      CGRect: function() {
        return wrappedInNSValueForTypeName(iVarString, type.name);
      },
      CGPoint: function() {
        return wrappedInNSValueForTypeName(iVarString, type.name);
      },
      CGSize: function() {
        return wrappedInNSValueForTypeName(iVarString, type.name);
      },
      UIEdgeInsets: function() {
        return wrappedInNSValueForTypeName(iVarString, type.name);
      },
      Class: function() {
        return formattedStringValueForIvarWithFormatSpecifier(iVarString, '%@');
      },
      dispatch_block_t: function() {
        return formattedStringValueForIvarWithFormatSpecifier(iVarString, '%@');
      },
      unmatchedType: function() {
        return nullableObjectValueWithFallback('self', optionalFallback);
      },
    },
    type,
  );
}

export {isEqualToDiffableObjectMethod, objectValueForAttribute};
