///
//  Generated code. Do not modify.
//  source: lib/gekitai.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,deprecated_member_use_from_same_package,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:core' as $core;
import 'dart:convert' as $convert;
import 'dart:typed_data' as $typed_data;
@$core.Deprecated('Use pieceWasPushedDescriptor instead')
const PieceWasPushed$json = const {
  '1': 'PieceWasPushed',
  '2': const [
    const {'1': 'from', '3': 1, '4': 1, '5': 5, '10': 'from'},
    const {'1': 'to', '3': 2, '4': 1, '5': 5, '10': 'to'},
    const {'1': 'sender', '3': 3, '4': 1, '5': 9, '10': 'sender'},
  ],
};

/// Descriptor for `PieceWasPushed`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pieceWasPushedDescriptor = $convert.base64Decode('Cg5QaWVjZVdhc1B1c2hlZBISCgRmcm9tGAEgASgFUgRmcm9tEg4KAnRvGAIgASgFUgJ0bxIWCgZzZW5kZXIYAyABKAlSBnNlbmRlcg==');
@$core.Deprecated('Use movimentDescriptor instead')
const Moviment$json = const {
  '1': 'Moviment',
  '2': const [
    const {'1': 'color', '3': 1, '4': 1, '5': 3, '10': 'color'},
    const {'1': 'index', '3': 2, '4': 1, '5': 5, '10': 'index'},
    const {'1': 'sender', '3': 3, '4': 1, '5': 9, '10': 'sender'},
  ],
};

/// Descriptor for `Moviment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List movimentDescriptor = $convert.base64Decode('CghNb3ZpbWVudBIUCgVjb2xvchgBIAEoA1IFY29sb3ISFAoFaW5kZXgYAiABKAVSBWluZGV4EhYKBnNlbmRlchgDIAEoCVIGc2VuZGVy');
@$core.Deprecated('Use messageDescriptor instead')
const Message$json = const {
  '1': 'Message',
  '2': const [
    const {'1': 'isSent', '3': 1, '4': 1, '5': 8, '10': 'isSent'},
    const {'1': 'text', '3': 2, '4': 1, '5': 9, '10': 'text'},
    const {'1': 'sender', '3': 3, '4': 1, '5': 9, '10': 'sender'},
  ],
};

/// Descriptor for `Message`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageDescriptor = $convert.base64Decode('CgdNZXNzYWdlEhYKBmlzU2VudBgBIAEoCFIGaXNTZW50EhIKBHRleHQYAiABKAlSBHRleHQSFgoGc2VuZGVyGAMgASgJUgZzZW5kZXI=');
@$core.Deprecated('Use emptyDescriptor instead')
const Empty$json = const {
  '1': 'Empty',
  '2': const [
    const {'1': 'sender', '3': 1, '4': 1, '5': 9, '10': 'sender'},
  ],
};

/// Descriptor for `Empty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emptyDescriptor = $convert.base64Decode('CgVFbXB0eRIWCgZzZW5kZXIYASABKAlSBnNlbmRlcg==');
