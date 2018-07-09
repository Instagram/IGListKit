/**
 * Copyright (c) 2016-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

///<reference path='../../type-defs/jasmine.d.ts'/>
///<reference path='../../type-defs/jasmine-test-additions.d.ts'/>

import IGListDiffable = require('../../plugins/iglistdiffable');
import Error = require('../../error');
import Maybe = require('../../maybe');
import ObjC = require('../../objc');
import ObjectSpec = require('../../object-spec');
import ObjectGeneration = require('../../object-generation');

const ObjectSpecPlugin = IGListDiffable.createPlugin();

function igListDiffableIsEqualMethod():ObjC.Method {
  return {
    belongsToProtocol:Maybe.Just('IGListDiffable'),
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
    returnType: { type:Maybe.Just({
      name: 'BOOL',
      reference: 'BOOL'
    }), modifiers: [] }
  }
}

function igListDiffableDiffIdentifierMethodWithCode(code:string):ObjC.Method {
  return {
    belongsToProtocol:Maybe.Just<string>('IGListDiffable'),
    code: [code],
    comments:[],
    compilerAttributes:[],
    keywords: [
      {
        name: 'diffIdentifier',
        argument: Maybe.Nothing<ObjC.KeywordArgument>()
      }
    ],
    returnType: { type:Maybe.Just({
      name: 'NSObject',
      reference: 'id<NSObject>'
    }), modifiers: [] }
  }
}

describe('ObjectSpecPlugins.IGListDiffable', function() {
  describe('Value Object', function() {
    describe('#instanceMethods', function() {

      it('returns two instance methods and uses self as diffIdentifier with no input attributes', function() {
        const objectType:ObjectSpec.Type = {
            annotations: {},
            attributes: [],
            comments: [],
            excludes: [],
            includes: [],
            libraryName: Maybe.Nothing<string>(),
            typeLookups:[],
            typeName: 'Foo'
          };

        const instanceMethods:ObjC.Method[] = ObjectSpecPlugin.instanceMethods(objectType);

        const expectedInstanceMethods:ObjC.Method[] = [
          igListDiffableIsEqualMethod(),
          igListDiffableDiffIdentifierMethodWithCode('return self;')
        ];

        expect(instanceMethods).toEqualJSON(expectedInstanceMethods);
      });

      it('returns NSObjects directly as diffIdentifier', function() {
        const objectType:ObjectSpec.Type = {
          annotations: {},
          attributes: [
            {
              annotations: {
                  diffIdentifier: []
              },
              comments: [],
              name: 'name',
              nullability:ObjC.Nullability.Inherited(),
              type: {
                fileTypeIsDefinedIn:Maybe.Nothing<string>(),
                libraryTypeIsDefinedIn:Maybe.Nothing<string>(),
                name: 'NSString',
                reference: 'NSString *',
                underlyingType:Maybe.Just<string>('NSObject'),
                conformingProtocol: Maybe.Nothing<string>()
              }
            }
          ],
          comments: [],
          excludes: [],
          includes: [],
          libraryName: Maybe.Nothing<string>(),
          typeLookups:[],
          typeName: 'Foo'
        };

        const instanceMethods:ObjC.Method[] = ObjectSpecPlugin.instanceMethods(objectType);

        const expectedInstanceMethods:ObjC.Method[] = [
          igListDiffableIsEqualMethod(),
          igListDiffableDiffIdentifierMethodWithCode('return _name;')
        ];

        expect(instanceMethods).toEqualJSON(expectedInstanceMethods);
      });

      it('returns NSInteger as formatString as diffIdentifier', function() {
        const objectType:ObjectSpec.Type = {
          annotations: {},
          attributes: [
            {
              annotations: {
                  diffIdentifier: []
              },
              comments: [],
              name: 'age',
              nullability:ObjC.Nullability.Inherited(),
              type: {
                fileTypeIsDefinedIn:Maybe.Nothing<string>(),
                libraryTypeIsDefinedIn:Maybe.Nothing<string>(),
                name: 'NSInteger',
                reference: 'NSInteger',
                underlyingType:Maybe.Nothing<string>(),
                conformingProtocol: Maybe.Nothing<string>()
              }
            }
          ],
          comments: [],
          excludes: [],
          includes: [],
          libraryName: Maybe.Nothing<string>(),
          typeLookups:[],
          typeName: 'Foo'
        };

        const instanceMethods:ObjC.Method[] = ObjectSpecPlugin.instanceMethods(objectType);

        const expectedInstanceMethods:ObjC.Method[] = [
          igListDiffableIsEqualMethod(),
          igListDiffableDiffIdentifierMethodWithCode('return [NSString stringWithFormat:@"%lld", (long long)_age];')
        ];

        expect(instanceMethods).toEqualJSON(expectedInstanceMethods);
      });

      it('returns CGRect as string as diffIdentifier', function() {
        const objectType:ObjectSpec.Type = {
          annotations: {},
          attributes: [
            {
              annotations: {
                  diffIdentifier: []
              },
              comments: [],
              name: 'rect',
              nullability:ObjC.Nullability.Inherited(),
              type: {
                fileTypeIsDefinedIn:Maybe.Nothing<string>(),
                libraryTypeIsDefinedIn:Maybe.Nothing<string>(),
                name: 'CGRect',
                reference: 'CGRect',
                underlyingType:Maybe.Nothing<string>(),
                conformingProtocol: Maybe.Nothing<string>()
              }
            }
          ],
          comments: [],
          excludes: [],
          includes: [],
          libraryName: Maybe.Nothing<string>(),
          typeLookups:[],
          typeName: 'Foo'
        };

        const instanceMethods:ObjC.Method[] = ObjectSpecPlugin.instanceMethods(objectType);

        const expectedInstanceMethods:ObjC.Method[] = [
          igListDiffableIsEqualMethod(),
          igListDiffableDiffIdentifierMethodWithCode('return NSStringFromCGRect(_rect);')
        ];

        expect(instanceMethods).toEqualJSON(expectedInstanceMethods);
      });

      it('returns property marked with %diffIdentifier as diffIdentifier', function() {
        const objectType:ObjectSpec.Type = {
          annotations: {},
          attributes: [
            {
              annotations: {},
              comments: [],
              name: 'name',
              nullability:ObjC.Nullability.Inherited(),
              type: {
                fileTypeIsDefinedIn:Maybe.Nothing<string>(),
                libraryTypeIsDefinedIn:Maybe.Nothing<string>(),
                name: 'NSString',
                reference: 'NSString *',
                underlyingType:Maybe.Just<string>('NSObject'),
                conformingProtocol: Maybe.Nothing<string>()
              }
            },
            {
              annotations: {
                  diffIdentifier: []
              },
              comments: [],
              name: 'age',
              nullability:ObjC.Nullability.Inherited(),
              type: {
                fileTypeIsDefinedIn:Maybe.Nothing<string>(),
                libraryTypeIsDefinedIn:Maybe.Nothing<string>(),
                name: 'NSInteger',
                reference: 'NSInteger',
                underlyingType:Maybe.Nothing<string>(),
                conformingProtocol: Maybe.Nothing<string>()
              }
            }
          ],
          comments: [],
          excludes: [],
          includes: [],
          libraryName: Maybe.Nothing<string>(),
          typeLookups:[],
          typeName: 'Foo'
        };

        const instanceMethods:ObjC.Method[] = ObjectSpecPlugin.instanceMethods(objectType);

        const expectedInstanceMethods:ObjC.Method[] = [
          igListDiffableIsEqualMethod(),
          igListDiffableDiffIdentifierMethodWithCode('return [NSString stringWithFormat:@"%lld", (long long)_age];')
        ];

        expect(instanceMethods).toEqualJSON(expectedInstanceMethods);
      });

    });
  });
});
