/**
 * Copyright (c) Meta Platforms, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

import * as Code from '../code';
import * as Error from '../error';
import * as FileWriter from '../file-writer';
import * as IGListDiffableUtils from './iglistdiffable-utils';
import * as Maybe from '../maybe';
import * as ObjC from '../objc';
import * as ObjectSpec from '../object-spec';

function diffIdentiferAttributeFilter(
  attribute: ObjectSpec.Attribute,
  index,
  array,
): boolean {
  return attribute.annotations['diffIdentifier'] != null;
}

function diffIdentifierMethodImplementation(
  objectType: ObjectSpec.Type,
): string[] {
  const diffIdentifierAttributes: ObjectSpec.Attribute[] = objectType.attributes.filter(
    diffIdentiferAttributeFilter,
  );
  if (diffIdentifierAttributes.length > 0) {
    // use first marked attribute as identifier, if available
    return [
      'return ' +
        IGListDiffableUtils.objectValueForAttribute(
          diffIdentifierAttributes[0],
        ) +
        ';',
    ];
  } else {
    // fallback/default to self
    return ['return self;'];
  }
}

function diffIdentifierMethod(objectType: ObjectSpec.Type): ObjC.Method {
  return {
    preprocessors: [],
    belongsToProtocol: Maybe.Just<string>('IGListDiffable'),
    code: diffIdentifierMethodImplementation(objectType),
    comments: [],
    compilerAttributes: [],
    keywords: [
      {
        name: 'diffIdentifier',
        argument: Maybe.Nothing<ObjC.KeywordArgument>(),
      },
    ],
    returnType: {
      type: Maybe.Just({
        name: 'NSObject',
        reference: 'id<NSObject>',
      }),
      modifiers: [],
    },
  };
}

export function createPlugin(): ObjectSpec.Plugin {
  return {
    additionalFiles: function(objectType: ObjectSpec.Type): Code.File[] {
      return [];
    },
    transformBaseFile: function(
      objectType: ObjectSpec.Type,
      baseFile: Code.File,
    ): Code.File {
      return baseFile;
    },
    additionalTypes: function(objectType: ObjectSpec.Type): ObjectSpec.Type[] {
      return [];
    },
    attributes: function(objectType: ObjectSpec.Type): ObjectSpec.Attribute[] {
      return [];
    },
    classMethods: function(objectType: ObjectSpec.Type): ObjC.Method[] {
      return [];
    },
    transformFileRequest: function(
      request: FileWriter.Request,
    ): FileWriter.Request {
      return request;
    },
    fileType: function(
      objectType: ObjectSpec.Type,
    ): Maybe.Maybe<Code.FileType> {
      return Maybe.Nothing<Code.FileType>();
    },
    forwardDeclarations: function(
      objectType: ObjectSpec.Type,
    ): ObjC.ForwardDeclaration[] {
      return [];
    },
    functions: function(objectType: ObjectSpec.Type): ObjC.Function[] {
      return [];
    },
    headerComments: function(objectType: ObjectSpec.Type): ObjC.Comment[] {
      return [];
    },
    implementedProtocols: function(
      objectType: ObjectSpec.Type,
    ): ObjC.Protocol[] {
      return [{name: 'IGListDiffable'}];
    },
    imports: function(objectType: ObjectSpec.Type): ObjC.Import[] {
      return [
        {
          file: 'IGListDiffable.h',
          isPublic: true,
          requiresCPlusPlus: false,
          library: Maybe.Just('IGListKit'),
        },
      ];
    },
    instanceMethods: function(objectType: ObjectSpec.Type): ObjC.Method[] {
      return [
        IGListDiffableUtils.isEqualToDiffableObjectMethod(),
        diffIdentifierMethod(objectType),
      ];
    },
    macros: function(valueType: ObjectSpec.Type): ObjC.Macro[] {
      return [];
    },
    properties: function(objectType: ObjectSpec.Type): ObjC.Property[] {
      return [];
    },
    requiredIncludesToRun: ['IGListDiffable'],
    staticConstants: function(objectType: ObjectSpec.Type): ObjC.Constant[] {
      return [];
    },
    validationErrors: function(objectType: ObjectSpec.Type): Error.Error[] {
      return [];
    },
    nullability: function(
      objectType: ObjectSpec.Type,
    ): Maybe.Maybe<ObjC.ClassNullability> {
      return Maybe.Nothing<ObjC.ClassNullability>();
    },
    subclassingRestricted: function(objectType: ObjectSpec.Type): boolean {
      return false;
    },
  };
}
