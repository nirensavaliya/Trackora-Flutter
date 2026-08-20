import Flutter
import GoogleMaps
import UIKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    GMSServices.provideAPIKey("AIzaSyBYJLJci7kmoV7dHnwngzeEaSzGNpq91bE")
    super.scene(scene, willConnectTo: session, options: connectionOptions)
  }
}
