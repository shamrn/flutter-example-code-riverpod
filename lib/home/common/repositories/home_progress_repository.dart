import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:prime_ballet/home/home/common/models/home_progress_response.dart';
import 'package:retrofit/http.dart';

part 'home_progress_repository.g.dart';

@RestApi()
@injectable
abstract class HomeProgressRepository {
  @factoryMethod
  factory HomeProgressRepository(Dio dio) => _HomeProgressRepository(dio);

  @DELETE('/api/mobile/playlists/{playlist_id}/progress/reset/')
  Future<void> reset(@Path('playlist_id') int playlistId);

  @GET('/api/mobile/playlists/{playlist_id}/progress/total/')
  Future<HomeProgressResponse> fetchProgress(
    @Path('playlist_id') int playlistId,
  );
}
