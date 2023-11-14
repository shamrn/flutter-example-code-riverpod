import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:prime_ballet/home/home/common/models/home_activate_training_program_request.dart';
import 'package:retrofit/http.dart';

part 'home_activate_training_program_repository.g.dart';

@RestApi()
@lazySingleton
abstract class HomeActivateTrainingProgramRepository {
  @factoryMethod
  factory HomeActivateTrainingProgramRepository(Dio dio) =>
      _HomeActivateTrainingProgramRepository(dio);

  @POST('/api/mobile/playlists/activate_program/')
  Future<void> activate(
    @Body() HomeActivateTrainingProgramRequest homeViewActiveProgramRequest,
  );
}
