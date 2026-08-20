import 'package:trackora/core/face/embedding_service.dart';
import 'package:trackora/core/face/face_pipeline.dart';
import 'package:trackora/core/face/face_profile_store.dart';

late final FacePipeline facePipeline;

Future<void> initFaceServices() async {
  await FaceProfileStore.migrateIfNeeded();
  facePipeline = FacePipeline(EmbeddingService());
  await facePipeline.init();
}
