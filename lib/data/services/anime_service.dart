import 'package:dio/dio.dart';
import 'package:nekoflow/data/models/episodes_model.dart';
import 'package:nekoflow/data/models/genre_model.dart';
import 'package:nekoflow/data/models/home_model.dart';
import 'package:nekoflow/data/models/info_model.dart';
import 'package:nekoflow/data/models/search_model.dart';
import 'package:nekoflow/data/models/stream_model.dart';

class AnimeService {
  static const String baseUrl =
      "https://ani-api-self.vercel.app/api/v2/hianime";
  final Dio _dio = Dio();

  AnimeService() {
    // You can configure Dio globally, like setting timeouts, interceptors, etc.
    _dio.options.baseUrl = baseUrl;
    _dio.options.headers = {'Content-Type': 'application/json'};
  }

  /// Disposes resources by closing the Dio client.
  void dispose() {
    _dio.close();
  }

  Future<HomeModel> fetchHome() async =>
      _get<HomeModel>('/home', (json) => HomeModel.fromJson(json));

  Future<AnimeInfo?> fetchAnimeInfoById({required String id}) async =>
      _get<AnimeInfo?>(
          '/anime/$id', (json) => AnimeInfo.fromJson(json));

  Future<SearchModel> fetchByQuery(
      {required String query, int page = 1}) async {
    final url = '/search?q=$query&page=$page';
    return _get<SearchModel>(url, (json) => SearchModel.fromJson(json['data']));
  }

  Future<List<Episode>> fetchEpisodes({required String id}) async {
    final url = '/anime/$id/episodes';
    return _get<List<Episode>>(url, (json) {
      return (json['data']['episodes'] as List)
          .map((e) => Episode.fromJson(e))
          .toList();
    });
  }

  Future<EpisodeServersModel> fetchEpisodeServers(
      {required String animeEpisodeId}) async {
    final url = '/episode/servers?animeEpisodeId=$animeEpisodeId';
    return _get<EpisodeServersModel>(
        url, (json) => EpisodeServersModel.fromJson(json));
  }

  Future<EpisodeStreamingLinksModel> fetchEpisodeStreamingLinks(
      {required String animeEpisodeId,
      String server = "hd-1",
      String category = "sub"}) async {
    final url =
        '/episode/sources?animeEpisodeId=$animeEpisodeId&server=$server&category=$category';
    return _get<EpisodeStreamingLinksModel>(
        url, (json) => EpisodeStreamingLinksModel.fromJson(json));
  }

  Future<GenreDetailModel> fetchGenreAnime(String genreName,
      {required int page}) async {
    final url = '/genre/$genreName?page=$page';
    return _get(url, (json) => GenreDetailModel.fromJson(json));
  }

  /// Generic HTTP GET method that handles the response parsing and error handling.
  Future<T> _get<T>(String url, T Function(dynamic json) fromJson) async {
    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        return fromJson(response.data);
      } else {
        throw Exception(
            'Failed to load data (status code: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching data from $url: $e');
    }
  }
}
