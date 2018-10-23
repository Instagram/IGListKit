import Maybe = require('../maybe');
import ObjC = require('../objc');
import ObjCTypeUtils = require('../objc-type-utils');
import ObjectSpec = require('../object-spec');
import ObjectSpecCodeUtils = require('../object-spec-code-utils');

function isEqualToDiffableObjectMethod():ObjC.Method {
  return {
    preprocessors:[],
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

function functionReturnValueForIvarWithFunctionName(iVarString:string, functionToCall:string):string {
  return functionToCall + '(' + iVarString + ')';
}

function formattedStringValueForIvarWithFormatSpecifier(iVarString:string, stringFormatSpecifier:string, optionalCast:string=null):string {
  var castString:string = (optionalCast === null ? "" : "(" + optionalCast + ")");
  return "[NSString stringWithFormat:@\"" + stringFormatSpecifier + "\", " + castString + iVarString + "]";
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

export {isEqualToDiffableObjectMethod, objectValueForAttribute};
