///
//  Generated code. Do not modify.
//  source: lib/gekitai.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'gekitai.pb.dart' as $0;
export 'gekitai.pb.dart';

class GekitaiClient extends $grpc.Client {
  static final _$sendMessage = $grpc.ClientMethod<$0.Message, $0.Empty>(
      '/chat.Gekitai/SendMessage',
      ($0.Message value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$receiveMessages = $grpc.ClientMethod<$0.Empty, $0.Message>(
      '/chat.Gekitai/ReceiveMessages',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Message.fromBuffer(value));
  static final _$sendMoviment = $grpc.ClientMethod<$0.Moviment, $0.Empty>(
      '/chat.Gekitai/SendMoviment',
      ($0.Moviment value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$receiveMoviment = $grpc.ClientMethod<$0.Empty, $0.Moviment>(
      '/chat.Gekitai/ReceiveMoviment',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Moviment.fromBuffer(value));
  static final _$sendPiecePushed =
      $grpc.ClientMethod<$0.PieceWasPushed, $0.Empty>(
          '/chat.Gekitai/SendPiecePushed',
          ($0.PieceWasPushed value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));
  static final _$recievePiecePushed =
      $grpc.ClientMethod<$0.Empty, $0.PieceWasPushed>(
          '/chat.Gekitai/RecievePiecePushed',
          ($0.Empty value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.PieceWasPushed.fromBuffer(value));

  GekitaiClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.Empty> sendMessage($0.Message request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$sendMessage, request, options: options);
  }

  $grpc.ResponseStream<$0.Message> receiveMessages($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(
        _$receiveMessages, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.Empty> sendMoviment($0.Moviment request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$sendMoviment, request, options: options);
  }

  $grpc.ResponseStream<$0.Moviment> receiveMoviment($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(
        _$receiveMoviment, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.Empty> sendPiecePushed($0.PieceWasPushed request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$sendPiecePushed, request, options: options);
  }

  $grpc.ResponseStream<$0.PieceWasPushed> recievePiecePushed($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(
        _$recievePiecePushed, $async.Stream.fromIterable([request]),
        options: options);
  }
}

abstract class GekitaiServiceBase extends $grpc.Service {
  $core.String get $name => 'chat.Gekitai';

  GekitaiServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Message, $0.Empty>(
        'SendMessage',
        sendMessage_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Message.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Message>(
        'ReceiveMessages',
        receiveMessages_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Message value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Moviment, $0.Empty>(
        'SendMoviment',
        sendMoviment_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Moviment.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Moviment>(
        'ReceiveMoviment',
        receiveMoviment_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Moviment value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.PieceWasPushed, $0.Empty>(
        'SendPiecePushed',
        sendPiecePushed_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.PieceWasPushed.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.PieceWasPushed>(
        'RecievePiecePushed',
        recievePiecePushed_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.PieceWasPushed value) => value.writeToBuffer()));
  }

  $async.Future<$0.Empty> sendMessage_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Message> request) async {
    return sendMessage(call, await request);
  }

  $async.Stream<$0.Message> receiveMessages_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async* {
    yield* receiveMessages(call, await request);
  }

  $async.Future<$0.Empty> sendMoviment_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Moviment> request) async {
    return sendMoviment(call, await request);
  }

  $async.Stream<$0.Moviment> receiveMoviment_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async* {
    yield* receiveMoviment(call, await request);
  }

  $async.Future<$0.Empty> sendPiecePushed_Pre(
      $grpc.ServiceCall call, $async.Future<$0.PieceWasPushed> request) async {
    return sendPiecePushed(call, await request);
  }

  $async.Stream<$0.PieceWasPushed> recievePiecePushed_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async* {
    yield* recievePiecePushed(call, await request);
  }

  $async.Future<$0.Empty> sendMessage(
      $grpc.ServiceCall call, $0.Message request);
  $async.Stream<$0.Message> receiveMessages(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> sendMoviment(
      $grpc.ServiceCall call, $0.Moviment request);
  $async.Stream<$0.Moviment> receiveMoviment(
      $grpc.ServiceCall call, $0.Empty request);
  $async.Future<$0.Empty> sendPiecePushed(
      $grpc.ServiceCall call, $0.PieceWasPushed request);
  $async.Stream<$0.PieceWasPushed> recievePiecePushed(
      $grpc.ServiceCall call, $0.Empty request);
}
