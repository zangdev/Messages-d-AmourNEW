

import SwiftUI
import UIKit
import Kingfisher
import ImageIO
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        return true
    }
}
extension CGRect {
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

extension CGPoint {
    static func -(lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.x - rhs.x, height: lhs.y - rhs.y)
    }
    static func +(lhs: Self, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x + rhs.width, y: lhs.y + rhs.height)
    }
    static func -(lhs: Self, rhs: CGSize) -> CGPoint {
        CGPoint(x: lhs.x - rhs.width, y: lhs.y - rhs.height)
    }
    static func *(lhs: Self, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    static func /(lhs: Self, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
}

extension CGSize {
    // the center point of an area that is our size
    var center: CGPoint {
        CGPoint(x: width/2, y: height/2)
    }
    static func +(lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
    static func -(lhs: Self, rhs: Self) -> CGSize {
        CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }
    static func *(lhs: Self, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
    }
    static func /(lhs: Self, rhs: CGFloat) -> CGSize {
        CGSize(width: lhs.width/rhs, height: lhs.height/rhs)
    }
    
    func maxRatio(with targetSize: CGSize) -> CGFloat {
        max(self.width / targetSize.width, self.height / targetSize.height)
    }
    
    func minRatio(with targetSize: CGSize) -> CGFloat {
        min(self.width / targetSize.width, self.height / targetSize.height)
    }
    
    func rotatedVector(radians: CGFloat, center: CGSize = .zero) -> CGSize {
        let newX = (self.width - center.width) * cos(radians) - (self.height - center.height) * sin(radians) + center.width
        let newY = (self.width - center.width) * sin(radians) + (self.height - center.height) * cos(radians) + center.height
        
        return CGSize(width: newX, height: newY)
    }
    
    func reverseWidth() -> CGSize {
        CGSize(width: -self.width, height: self.height)
    }
    func reverseHeight() -> CGSize {
        CGSize(width: self.width, height: -self.height)
    }
    func reverseWidthHeight() -> CGSize {
        CGSize(width: -self.width, height: -self.height)
    }
}

extension Double {
    func angleDegrees() -> Double {
        let angle = self.truncatingRemainder(dividingBy: Double.pi * 2)
        return angle * 180 / Double.pi
    }
}

extension UIColor {
    func uiImage(_ size: CGSize = CGSize(width: 1, height: 1)) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { rendererContext in
            self.setFill()
            rendererContext.fill(CGRect(origin: .zero, size: size))
        }
    }
}

extension UIImage {
    func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}

extension String {
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
}
extension UIImage {
    func toPngString() -> String? {
        let data = self.pngData()
        return data?.base64EncodedString(options: .endLineWithLineFeed)
    }
  
    func toJpegString(compressionQuality cq: CGFloat) -> String? {
        let data = self.jpegData(compressionQuality: cq)
        return data?.base64EncodedString(options: .endLineWithLineFeed)
    }
}
extension Image {
    func centerCropped() -> some View {
        GeometryReader { geo in
            self
            .resizable()
            .scaledToFill()
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped()

        }
    }
}
struct ImageHeaderData{
    static var PNG: [UInt8] = [0x89]
    static var JPEG: [UInt8] = [0xFF]
    static var GIF: [UInt8] = [0x47]
    static var TIFF_01: [UInt8] = [0x49]
    static var TIFF_02: [UInt8] = [0x4D]
}

enum ImageFormat{
    case Unknown, PNG, JPEG, GIF, TIFF
}


extension NSData{
    var imageFormat: ImageFormat{
        var buffer = [UInt8](repeating: 0, count: 1)
        self.getBytes(&buffer, range: NSRange(location: 0,length: 1))
        if buffer == ImageHeaderData.PNG
        {
            return .PNG
        } else if buffer == ImageHeaderData.JPEG
        {
            return .JPEG
        } else if buffer == ImageHeaderData.GIF
        {
            return .GIF
        } else if buffer == ImageHeaderData.TIFF_01 || buffer == ImageHeaderData.TIFF_02{
            return .TIFF
        } else{
            return .Unknown
        }
    }
}
extension KFImage {
    func centerCropped() -> some View {
        GeometryReader { geo in
            self
                .resizable()
                .scaledToFill()
            //            .frame(minWidth: 0, maxWidth: .infinity)
            //            .aspectRatio(1, contentMode: .fill)
        }
    }
}

extension Color {
    init(hex string: String) {
        var string: String = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if string.hasPrefix("#") {
            _ = string.removeFirst()
        }
        
        // Double the last value if incomplete hex
        if !string.count.isMultiple(of: 2), let last = string.last {
            string.append(last)
        }
        
        // Fix invalid values
        if string.count > 8 {
            string = String(string.prefix(8))
        }
        
        // Scanner creation
        let scanner = Scanner(string: string)
        
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        
        if string.count == 2 {
            let mask = 0xFF
            
            let g = Int(color) & mask
            
            let gray = Double(g) / 255.0
            
            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: 1)
            
        } else if string.count == 4 {
            let mask = 0x00FF
            
            let g = Int(color >> 8) & mask
            let a = Int(color) & mask
            
            let gray = Double(g) / 255.0
            let alpha = Double(a) / 255.0
            
            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: alpha)
            
        } else if string.count == 6 {
            let mask = 0x0000FF
            let r = Int(color >> 16) & mask
            let g = Int(color >> 8) & mask
            let b = Int(color) & mask
            
            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0
            
            self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
            
        } else if string.count == 8 {
            let mask = 0x000000FF
            let r = Int(color >> 24) & mask
            let g = Int(color >> 16) & mask
            let b = Int(color >> 8) & mask
            let a = Int(color) & mask
            
            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0
            let alpha = Double(a) / 255.0
            
            self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
            
        } else {
            self.init(.sRGB, red: 1, green: 1, blue: 1, opacity: 1)
        }
    }
}
extension View {
    func statusBar(color: String) -> some View {
        modifier(StatusBarModifier(color: color))
    }
}
extension UIColor {
    convenience init(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = (rgb & 0xFF0000) >> 16
        let g = (rgb & 0x00FF00) >> 8
        let b = rgb & 0x0000FF
        
        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: 1.0
        )
    }
}

//WINDOW FOR ALL IOS VERSION  [CURRENT (17)]
//TO USING CALL: UIApplication.shared.currentWindow
extension UIApplication {
    var currentWindow: UIWindow? {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        return window
    }
    var currentWindowLast: UIWindow? {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.last
        return window
    }
}
@main
struct Love_QuotesApp: App {
    @State private var selectedOptions = 0
    @State private var isShowSetting = false
    
    @State private var isShowMainView = true
    @State private var categoryName = "NONE"
    
    //DATA FOR IAMGE
    @State private var isShowImage = false
    @State private var isShowImageSlide = false
    @State private var isShowImageEdit = false
    @State private var urlImageChoose = "https://lh3.googleusercontent.com/zYbiiAgbKD6VrABXXjQfwXA4FhUkHxtKxz5oIK8xrJiGjHe3c4jNhZuDMAeKSL1GFR-ku2oEzFSMguNATEEru8eDEN0VtUfO83kC9LpVGITKArJOtywfD1l5VRcuK8mKe3knxWFVKf53Vz_rF4bfig4GE14weZRc7oaVZxEyc8f1Mb4CiS0U_h9wnFjRAwDggu2QSk0eOOsV3dk3oJdle8hlZZFrigqxq7ame9REpnSRSl4b9c88bYIXAGoQE1002xZnQANfIrK93mmIQLAHFpvfFhTogJunt9Cw1Rup08C5B1l0CiuU-nVHel_-i3Dnv8UE7brcA22Z2lpMpbpOGfnu8PJj5qSSA3GHLI1u78lG7iHsYjWl47KV0y8YY0PuoO76Em1xSMEQbPXvKKRAajAuoCpuZwiX95EpHtWR6tGnZ8yolypM_66QCetBb5gssFJzE2JFE5R5VwynIGHQmyQHHlw_xjEyzxVrcCzBcgo9TidPu66pbPV5qLF7YJr06-NsVR-Ts-Utmzujscy_GJ4llfCNn4teXgDeoH6aawa8yfqzdtyfpRnGtZx2h-4vLb9Hb_xoWJzVRQf08dffGDHbOQ4BhMfVXK-wN-AxhiFHDOJh2UYXf7n4zKkliDORqjhvYPYZhJkTquGpF1mKysVA3lMStHq-a-E26JIg0j8sOn2pUnda0UjfKvv6VieJA4MW8fWhXMMWfSaJkxm0D7xWRHhauqKv8iXCwpyQmmPRL82iz1_zn60E7-wQsHK1S1SYr2NLLXctDMGcL3qidLMVpSHhamvPiMjuLcyQm7sfBjaRMpMxirDQYSbvJp6b2ZjKYBVd1LpyMWJpWlszrgZx_2B3w5co4BXnKZfAkWRG3GCrQaDtHNjzKfWh6K79ZenlM4I5HT-G4K9OCjKGrdOHTJbDNBv2cgQu6dlpFrw7_eBO=w658-h658-s-no?authuser=0"
    
    
    @State private var isShowImageHome = false
    @State private var isShowMessHome = false
    @State private var isShowMess = false
    @State private var isShowMessFavoriteView = false
    @State private var isShowMessFavoriteSlide = false
    @State private var isShowMessSlide = false
    @State private var isShowBackgroundView = false
    @State private var isShowImageMessGif = false
    @State private var isShowGif = false
    @State var DATABASE_HELPER: DBHelper
    @State var MESSAGES_MANAGER: MessagesManager
    @State var QUOTES_MANAGER: QuotesManagerUntil
    
    let adsVM = AdsViewModel.shared
    @Environment(\.scenePhase) private var scenePhase
    init() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        _DATABASE_HELPER = State(initialValue: DBHelper())
        _MESSAGES_MANAGER = State(initialValue: MessagesManager(DBH: DBHelper()))
        _QUOTES_MANAGER = State(initialValue: QuotesManagerUntil())
    }
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var appOpen = AppOpen()
    var body: some Scene {
        WindowGroup {
   
            if(isShowMainView){
                HomeView(isShowImageHome: $isShowImageHome, isShowMessHome: $isShowMessHome ,MESSAGES_MANAGER: $MESSAGES_MANAGER, QUOTES_MANAGER: $QUOTES_MANAGER ,categoryName: $categoryName, isShowMainView: $isShowMainView,isShowImageEdit: $isShowImageEdit, isShowSetting: $isShowSetting, isShowImage: $isShowImage, isShowMess: $isShowMess, isShowMessFavoriteView: $isShowMessFavoriteView, isShowGif: $isShowGif, isShowImageSlide: $isShowImageSlide, urlImageChoose: $urlImageChoose, selectedOption: $selectedOptions)
       
                    .environmentObject(adsVM)
                    .colorScheme(.dark)
            }
            else if isShowMessHome {
                MessagesViewHome(MESSAGES_MANAGER: $MESSAGES_MANAGER, isShowMainView: $isShowMainView, isShowMessViewHome: $isShowMessHome, isShowMessView: $isShowMess, categoryName: $categoryName)
                    .colorScheme(.dark)
            }
            else if (isShowImageEdit) {

                if let uiImageTemp = urlImageChoose.toImage() {
                    @State var uiImage = uiImageTemp // Assign uiImageTemp to uiImage
                    EditImageView(isShowMainView: $isShowMainView, isShowImageEdit: $isShowImageEdit, selectedItem: $urlImageChoose, image: $uiImage)
             
                        .environmentObject(adsVM)
                        .colorScheme(.dark)
                } else {
                    if let uiImageTemp = UIImage(named: urlImageChoose) {
                        @State var uiImage = uiImageTemp
                        EditImageView(isShowMainView: $isShowMainView, isShowImageEdit: $isShowImageEdit, selectedItem: $urlImageChoose, image: $uiImage)
   
                            .environmentObject(adsVM)
                            .colorScheme(.dark)
                    }
                }

            }
            else if (isShowBackgroundView) {
                BackgroundChooseView(isShowSettingView: $isShowSetting, isShowBackgroundView: $isShowBackgroundView)
                    .colorScheme(.dark)
            }
            else if (isShowMessFavoriteView) {
                MessagesFavoriteView(MESSAGES_MANAGER: $MESSAGES_MANAGER ,isShowMainView: $isShowMainView, isShowMessFavoriteView: $isShowMessFavoriteView, isShowMessSlideView: $isShowMessFavoriteSlide, categoryName: $categoryName, urlImageChoose: $urlImageChoose)

                    .environmentObject(adsVM)
                    .colorScheme(.dark)
            }
            else if (isShowSetting) {
                SettingView(isShowMainView: $isShowMainView, isShowSetting: $isShowSetting, isShowBackgroundView: $isShowBackgroundView)
                    .environmentObject(adsVM)
                    .colorScheme(.dark)
            }
            else if(isShowImage){
                ImagesView(QUOTES_MANAGER: $QUOTES_MANAGER ,isShowMainView: $isShowMainView, isShowImage: $isShowImage, isShowImageSlide: $isShowImageSlide, categoryName: $categoryName, urlImageChoose: $urlImageChoose)
         
                    .colorScheme(.dark)
            }
            else if(isShowImageSlide){
                ImagesSlideView(QUOTES_MANAGER: $QUOTES_MANAGER ,isShowMainView: $isShowMainView, isShowImage: $isShowImage, isShowImageSlide: $isShowImageSlide, categoryName: $categoryName, selectedItem: $urlImageChoose)
   
                    .environmentObject(adsVM)
                    .colorScheme(.dark)
            }
            else if(isShowMess){
                MessagesView(MESSAGES_MANAGER: $MESSAGES_MANAGER ,isShowMessHome: $isShowMessHome,  isShowMessView: $isShowMess, isShowMessSlideView: $isShowMessSlide, categoryName: $categoryName, urlImageChoose: $urlImageChoose)
                    .statusBar(color: ColorStrings.toolbarColor)
                    .colorScheme(.dark)
            }
            else if(isShowMessFavoriteSlide){
                MessagesFavoriteViewSlide(MESSAGES_MANAGER: $MESSAGES_MANAGER, isShowMainView: $isShowMainView, isShowMessFavoriteView: $isShowMessFavoriteView, isShowMessFavoriteSlide: $isShowMessFavoriteSlide, categoryName: $categoryName, selectedItem: $urlImageChoose)
        
                    .environmentObject(adsVM)
                    .colorScheme(.dark)
            }
            else if(isShowMessSlide){
                MessagesViewSlide(MESSAGES_MANAGER: $MESSAGES_MANAGER, isShowMainView: $isShowMainView, isShowMess: $isShowMess, isShowMessSlide: $isShowMessSlide, categoryName: $categoryName, selectedItem: $urlImageChoose)
          
                    .environmentObject(adsVM)
                    .colorScheme(.dark)
            }
        }
        .onChange(of: scenePhase) { newValue in
            if newValue == .active {
                print("lalala")
                appOpen.ShowAppOpenAd()
            }
        }
    }
}
