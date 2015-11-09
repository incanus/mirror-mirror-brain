import Cocoa
import Parse
import AVFoundation
import AVKit

@NSApplicationMain

class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var label: NSTextField!

    var playerView: AVPlayerView!
    var index = 1

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        Parse.setApplicationId("<your parse app id>",
            clientKey: "<your parse client key>")

        let layer = CALayer()
        layer.backgroundColor = NSColor.blackColor().CGColor
        window.contentView!.wantsLayer = true
        window.contentView!.layer = layer

        PFUser.enableAutomaticUser()

        let defaultACL: PFACL = PFACL()
        defaultACL.setPublicReadAccess(true)
        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser: true)

        NSApplication.sharedApplication().registerForRemoteNotificationTypes(.Alert)

        playerView = AVPlayerView(frame: window.frame)
        playerView.controlsStyle = .None
        playerView.hidden = true
        window.contentView!.addSubview(playerView)
    }

    func application(application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()

        PFPush.subscribeToChannelInBackground("")
    }

    func application(application: NSApplication, didReceiveRemoteNotification userInfo: [String : AnyObject]) {
        if let aps = userInfo["aps"] as? Dictionary<String, AnyObject>, let alert = aps["alert"] as? String {
            label.stringValue = "motion: \(alert)"
            print(label.stringValue)
            if alert == "true" && playerView.hidden || playerView.player == nil  {
                playerView.hidden = false
                let player = AVPlayer(URL: NSURL(fileURLWithPath:
                    NSBundle.mainBundle().pathForResource("\(index)", ofType: "mp4")!))
                playerView.player = player
                player.play()
//                index++
//                if index == 7 {
//                    index = 1
//                }
            } else if playerView.player?.currentItem?.currentTime() >= playerView.player?.currentItem?.duration {
                playerView.player?.pause()
                playerView.player?.pause()
                playerView.player = nil
                playerView.hidden = true
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }

}
