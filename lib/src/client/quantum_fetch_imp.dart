import 'package:dio/dio.dart';
import 'package:quantum_fetch/quantum_fetch.dart';

import '../typedef/decoder.dart';

class QuantumFetch extends QuantumFetchImpl {
  QuantumFetch(QuantumFetchConfig config) : super(config);
}

class QuantumFetchImpl implements IQuantumFetch {
  final QuantumFetchConfig config;

  QuantumFetchImpl(this.config);

  @override
  Future<Map<String, String>> getDefaultHeaders() async {
    final token = await config.token;
    return {
      'Authorization': token != null ? '${config.tokenPrefix}$token' : '',
    };
  }

  @override
  Future<APIResponse<T>> get<T>(
    String path, {
    Map<String, String> headers = const {},
    required Decoder<T>? decoder,
    OnProgress? onProgress,
    JsonResponseNode? dataNode,
  }) async {
    final response =
        await getRaw(path, onProgress: onProgress, headers: headers);
    return APIResponse<T>.fromDioResponse(response, decoder, dataNode, config);
  }

  Future<Response<dynamic>> getRaw(String path,
      {OnProgress? onProgress, Map<String, dynamic> headers = const {}}) async {
    final dio = await instance;
    final response = await dio.get(path,
        options: Options(headers: headers),
        onReceiveProgress: ((count, total) =>
            onProgress?.call(total ~/ count)));
    return response;
  }

  Future<Response<dynamic>> postRaw(String path,
      {OnProgress? onProgress,
      Map<String, dynamic> data = const {},
      Map<String, dynamic> headers = const {}}) async {
    final dio = await instance;
    final response = await dio.post(path,
        data: data,
        options: Options(headers: headers),
        onSendProgress: ((count, total) => onProgress?.call(total ~/ count)));
    return response;
  }

  Future<Response<dynamic>> patchRaw(String path,
      {OnProgress? onProgress,
      Map<String, dynamic> data = const {},
      Map<String, dynamic> headers = const {}}) async {
    final dio = await instance;
    final response = await dio.patch(path,
        data: data,
        options: Options(headers: headers),
        onSendProgress: ((count, total) => onProgress?.call(total ~/ count)));
    return response;
  }

  Future<Response<dynamic>> putRaw(String path,
      {OnProgress? onProgress,
      Map<String, dynamic> data = const {},
      Map<String, dynamic> headers = const {}}) async {
    final dio = await instance;
    final response = await dio.put(path,
        data: data,
        options: Options(headers: headers),
        onSendProgress: ((count, total) => onProgress?.call(total ~/ count)));
    return response;
  }

  @override
  Future<APIResponseList<T>> getList<T>(
    String path, {
    Map<String, String> headers = const {},
    required Decoder<T>? decoder,
    OnProgress? onProgress,
    JsonResponseNode? dataNode,
  }) async {
    final response =
        await getRaw(path, onProgress: onProgress, headers: headers);
    return APIResponseList<T>.fromDioResponse(
        response, decoder, dataNode, config);
  }

  @override
  Future<APIResponse<T>> post<T>(
    String path, {
    Map<String, String> headers = const {},
    Map<String, dynamic> body = const {},
    required Decoder<T>? decoder,
    OnProgress? onProgress,
    JsonResponseNode? dataNode,
  }) async {
    final response = await postRaw(path,
        data: body, headers: headers, onProgress: onProgress);
    return APIResponse<T>.fromDioResponse(response, decoder, dataNode, config);
  }

  @override
  Future<APIResponseList<T>> postAndGetList<T>(
    String path, {
    Map<String, String> headers = const {},
    Map<String, dynamic> body = const {},
    Decoder<T>? decoder,
    OnProgress? onProgress,
    JsonResponseNode? dataNode,
  }) async {
    final response = await postRaw(path,
        data: body, headers: headers, onProgress: onProgress);
    return APIResponseList<T>.fromDioResponse(
        response, decoder, dataNode, config);
  }

  @override
  Future<APIResponse<T>> patch<T>(
    String path, {
    Map<String, String> headers = const {},
    Map<String, dynamic> body = const {},
    required Decoder<T>? decoder,
    OnProgress? onProgress,
    JsonResponseNode? dataNode,
  }) async {
    final response = await patchRaw(path,
        data: body, headers: headers, onProgress: onProgress);
    return APIResponse<T>.fromDioResponse(response, decoder, dataNode, config);
  }

  @override
  Future<APIResponse<T>> put<T>(
    String path, {
    Map<String, String> headers = const {},
    Map<String, dynamic> body = const {},
    required Decoder<T>? decoder,
    OnProgress? onProgress,
    JsonResponseNode? dataNode,
  }) async {
    final response = await putRaw(path,
        data: body, headers: headers, onProgress: onProgress);
    return APIResponse<T>.fromDioResponse(response, decoder, dataNode, config);
  }

  @override
  Future<APIResponseList<T>> putAndGetList<T>(
    String path, {
    Map<String, String> headers = const {},
    Map<String, dynamic> body = const {},
    required Decoder<T>? decoder,
    OnProgress? onProgress,
    JsonResponseNode? dataNode,
  }) async {
    final response = await putRaw(path,
        data: body, headers: headers, onProgress: onProgress);
    return APIResponseList<T>.fromDioResponse(
        response, decoder, dataNode, config);
  }

  @override
  Future<APIResponseList<T>> patchAndGetList<T>(
    String path, {
    Map<String, String> headers = const {},
    Map<String, dynamic> body = const {},
    required Decoder<T>? decoder,
    OnProgress? onProgress,
    JsonResponseNode? dataNode,
  }) async {
    final response = await patchRaw(path,
        data: body, headers: headers, onProgress: onProgress);
    return APIResponseList<T>.fromDioResponse(
        response, decoder, dataNode, config);
  }

  @override
  Future<APIResponse<T>> delete<T>(
    String path, {
    Map<String, String> headers = const {},
    Map<String, dynamic> body = const {},
    required Decoder<T>? decoder,
    OnProgress? onProgress,
    JsonResponseNode? dataNode,
  }) async {
    final dio = await instance;
    final response = await dio.delete(path, data: body);
    return APIResponse<T>.fromDioResponse(response, decoder, dataNode, config);
  }

  int calculateProgress(int a, int b) {
    return a ~/ b;
  }

  Future<Dio> get instance async {
    return Dio(
      BaseOptions(
          baseUrl: config.baseUrl,
          connectTimeout: Duration(seconds: config.connectTimeout),
          receiveTimeout: Duration(seconds: config.receiveTimeout),
          validateStatus: (d) => true,
          headers: await getDefaultHeaders()),
    )..interceptors.addAll([
        LogInterceptor(
            requestBody: true, responseBody: true, responseHeader: false),
        RequestBodyIntercepter(),
        ...config.interceptors,
        cacheIntercepter(),
      ]);
  }

  @override
  Future<APIResponse<T>> upload<T>(String path,
      {Map<String, String> headers = const {},
      Map<String, dynamic> body = const {},
      T Function(Map<String, dynamic> p1)? decoder,
      OnProgress? onProgress,
      JsonResponseNode? dataNode}) async{
    final response = await postRaw(path,
        data: body, headers: headers, onProgress: onProgress);
    return APIResponse<T>.fromDioResponse(
        response, (json) => decoder?.call(json) ?? json as T, dataNode, config);
  }
}
