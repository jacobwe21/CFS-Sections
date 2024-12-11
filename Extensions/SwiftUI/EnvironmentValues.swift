//
//  EnvironmentValues.swift
//  
//
//  Created by Jacob W Esselstyn on 2/5/22.
//

import SwiftUI
import StoreKit
import Combine

public struct EnvironmentView<Content: View>: View {
	@AppStorage("appVersion") var appVersion: String = "0"
	@AppStorage("initialRun") var initialRun: Bool = true
	@AppStorage("colorTheme") var colorTheme: ColorTheme = .stone
	@Environment(\.deviceOS) var os: EnvironmentValues.DeviceOS
	#if canImport(UIKit)
	@Environment(\.basicViewController) var basicViewController: BasicViewControllerRepresentable
	#endif
	@State private var orientation: EnvironmentValues.ViewOrientation = .portrait
	@State private var viewBounds: CGSize = .zero
	@State private var screenBounds: CGSize? = nil
	
	var onInitialRun: ()->Void
	var onAppUpdate: ()->Void
	
	var contentBody: Content
	#if !os(macOS)
	var uiWindow: UIWindow? {
		let connectedScenes = UIApplication.shared.connectedScenes
			.filter { $0.activationState == .foregroundActive }
			.compactMap { $0 as? UIWindowScene }
		
		let window = connectedScenes.first?
			.windows
			.first { $0.isKeyWindow }
		return window
	}
	#endif
	
	public init(defaultTheme: ColorTheme = .stone, @ViewBuilder _ content: ()->Content, initialRunClosure: @escaping ()->Void = {}, onAppUpdateClosure: @escaping ()->Void = {}) {
		self.contentBody = content()
		onInitialRun = initialRunClosure
		onAppUpdate = onAppUpdateClosure
		if initialRun {
			colorTheme = defaultTheme
		}
	}
	
	#if os(macOS)
	public var body: some View {
		ZStack {
			// Sets Screen Bounds
			GeometryReader { superWindowGeometryProxy in
				PlainBackgroundV()
					.onAppear {
						screenBounds = superWindowGeometryProxy.size
					}
					.onChange(of: superWindowGeometryProxy.size) {
						screenBounds = superWindowGeometryProxy.size
					}
			}.ignoresSafeArea(.all)
			// Primary View
			VStack {
				GeometryReader { windowGeometryProxy in
					contentBody.tint(colorTheme.accentColor)
						.environment(\EnvironmentValues.orientation, self.orientation)
						.environment(\EnvironmentValues.screenBounds, self.screenBounds ?? self.viewBounds)
						.environment(\EnvironmentValues.viewBounds, windowGeometryProxy.size)
						.onAppear {
							updateEnvironmentBounds(size: windowGeometryProxy.size)
						}
						.onChange(of: windowGeometryProxy.size) {
							updateEnvironmentBounds(size: windowGeometryProxy.size)
						}
				}
				.frame(minWidth: 400, idealWidth: 1200, maxWidth: .infinity, minHeight: 400, idealHeight: 800, maxHeight: .infinity)
			}
		}
		.environment(\EnvironmentValues.colorTheme, self.colorTheme)
		.onAppear {
			let currentVersion = Bundle.main.releaseVersionNumberPretty
			if initialRun {
				print("Current Version: " + currentVersion)
				appVersion = currentVersion
				onInitialRun()
				initialRun = false
			} else {
				if appVersion != currentVersion {
					appVersion = currentVersion
					onAppUpdate()
				}
			}
		}
	}
	#else
	public var body: some View {
		ZStack {
			// Sets Screen Bounds
			GeometryReader { superWindowGeometryProxy in
				PlainBackgroundV()
					.onAppear {
						screenBounds = superWindowGeometryProxy.size
					}
					.onChange(of: superWindowGeometryProxy.size) {
						screenBounds = superWindowGeometryProxy.size
					}
			}.ignoresSafeArea(.all)
			// Primary View
			VStack {
				GeometryReader { windowGeometryProxy in
					contentBody.tint(colorTheme.accentColor)
						.environment(\EnvironmentValues.orientation, self.orientation)
						.environment(\EnvironmentValues.screenBounds, self.screenBounds ?? self.viewBounds)
						.environment(\EnvironmentValues.viewBounds, windowGeometryProxy.size)
						.environment(\EnvironmentValues.uiWindow, uiWindow)
						.onAppear {
							updateEnvironmentBounds(size: windowGeometryProxy.size)
						}
						.onChange(of: windowGeometryProxy.size) {
							updateEnvironmentBounds(size: windowGeometryProxy.size)
						}
				}
			}
		}
		.addKeyboardVisibilityToEnvironment()
		.environment(\EnvironmentValues.colorTheme, self.colorTheme)
		.onAppear {
			let currentVersion = Bundle.main.releaseVersionNumberPretty
			if initialRun {
				print("Initial Run: Current Version: " + currentVersion)
				appVersion = currentVersion
				onInitialRun()
				initialRun = false
			} else {
				if appVersion != currentVersion {
					print("App Updated: Current Version: " + currentVersion)
					appVersion = currentVersion
					onAppUpdate()
				}
			}
		}
	}
	#endif
	
	func updateEnvironmentBounds(size: CGSize) {
		if size.width / size.height > 1.25 {
			orientation = .landscape
		} else {
			orientation = .portrait
		}
	}
}
#if canImport(UIKit)
public extension UIApplication {
	var keyWindowInConnectedScenes: UIWindow? {
		// Get connected scenes
		return UIApplication.shared.connectedScenes
			// Keep only active scenes, onscreen and visible to the user
			.filter { $0.activationState == .foregroundActive }
			// Keep only the first `UIWindowScene`
			.first(where: { $0 is UIWindowScene })
			// Get its associated windows
			.flatMap({ $0 as? UIWindowScene })?.windows
			// Finally, keep only the key window
			.first(where: \.isKeyWindow)
	}
}



public struct BasicViewControllerRepresentable: UIViewControllerRepresentable {
	public let viewController = UIViewController()

	public func makeUIViewController(context: Context) -> some UIViewController {
		return viewController
	}
	public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
		// No implementation needed. Nothing to update.
	}
}
private struct BasicViewControllerEnvironmentKey: EnvironmentKey {
	static let defaultValue: BasicViewControllerRepresentable = BasicViewControllerRepresentable()
}
public extension EnvironmentValues {
	var basicViewController: BasicViewControllerRepresentable {
		get { self[BasicViewControllerEnvironmentKey.self] }
	}
}



private struct UIWindowEnvironmentKey: EnvironmentKey {
	static let defaultValue: UIWindow? = nil
}
public extension EnvironmentValues {
	var uiWindow: UIWindow! {
		get { self[UIWindowEnvironmentKey.self] }
		set { self[UIWindowEnvironmentKey.self] = newValue }
	}
}
#endif

private struct ColorThemeEnvironmentKey: EnvironmentKey {
	static let defaultValue: ColorTheme = .blue
}
public extension EnvironmentValues {
	var colorTheme: ColorTheme {
		get { self[ColorThemeEnvironmentKey.self] }
		set { self[ColorThemeEnvironmentKey.self] = newValue }
	}
}

private struct OrientationEnvironmentKey: EnvironmentKey {
	static let defaultValue: EnvironmentValues.ViewOrientation = {
		#if canImport(UIKit)
		if UIDevice.current.userInterfaceIdiom == .phone { return .portrait } else { return .landscape }
		#else
		return .landscape
		#endif
	}()
}
public extension EnvironmentValues {
	var orientation: ViewOrientation {
		get { self[OrientationEnvironmentKey.self] }
		set { self[OrientationEnvironmentKey.self] = newValue }
	}
	/// Returns whether the user's device is in portait or landscape
	enum ViewOrientation: String {
		case portrait
		case landscape
		
		public var isPortrait: Bool { self == .portrait }
		public var isLandscape: Bool { self == .landscape }
	}
}

private struct ViewBoundsEnvironmentKey: EnvironmentKey {
	static let defaultValue: CGSize = .zero
}
private struct ScreenBoundsEnvironmentKey: EnvironmentKey {
	static let defaultValue: CGSize = .zero
}
public extension EnvironmentValues {
	var viewBounds: CGSize {
		get { self[ViewBoundsEnvironmentKey.self] }
		set { self[ViewBoundsEnvironmentKey.self] = newValue }
	}
	var screenBounds: CGSize {
		get { self[ScreenBoundsEnvironmentKey.self] }
		set { self[ScreenBoundsEnvironmentKey.self] = newValue }
	}
}

// MARK: Keyboard Visibility
public extension View {
	/// Sets an environment value for keyboardShowing
	/// Access this in any child view with
	/// @Environment(\.keyboardShowing) var keyboardShowing
	func addKeyboardVisibilityToEnvironment() -> some View {
		modifier(KeyboardVisibility())
	}
}
private struct KeyboardShowingEnvironmentKey: EnvironmentKey {
	static let defaultValue: Bool = false
}
public extension EnvironmentValues {
	/// True if the keyboard is showing. Otherwise false. 0.1s delay.
	/// WARNING - if a view containing a text field is conditionally controlled by this variable, the results are unpredictable.
	var keyboardShowing: Bool {
		get { self[KeyboardShowingEnvironmentKey.self] }
		set { self[KeyboardShowingEnvironmentKey.self] = newValue }
	}
}
private struct KeyboardVisibility:ViewModifier {
#if os(macOS)
	fileprivate func body(content: Content) -> some View {
		content.environment(\.keyboardShowing, false)
	}
#else
	@State var isKeyboardShowing:Bool = false
	private var keyboardPublisher: AnyPublisher<Bool, Never> {
		Publishers
			.Merge(
				NotificationCenter
					.default
					.publisher(for: UIResponder.keyboardWillShowNotification)
					.map { _ in true },
				NotificationCenter
					.default
					.publisher(for: UIResponder.keyboardWillHideNotification)
					.map { _ in false })
			.debounce(for: .seconds(0.1), scheduler: RunLoop.main)
			.eraseToAnyPublisher()
	}
	fileprivate func body(content: Content) -> some View {
		content
			.environment(\.keyboardShowing, isKeyboardShowing)
			.onReceive(keyboardPublisher) { value in
				isKeyboardShowing = value
			}
	}
#endif
}

#if canImport(UIKit)
import UIKit
#endif
public extension EnvironmentValues {
	var deviceOS: DeviceOS {
		get {
			#if os(watchOS)
			return .watchOS
			#elseif os(macOS)
			return .macOS
			#elseif os(tvOS)
			return .tvOS
			#elseif canImport(UIKit)
			switch UIDevice.current.userInterfaceIdiom {
			case UIUserInterfaceIdiom.pad: return .iPadOS
			case UIUserInterfaceIdiom.phone: return .iOS
			case UIUserInterfaceIdiom.mac: return .macOS
			case UIUserInterfaceIdiom.tv: return .tvOS
			case UIUserInterfaceIdiom.carPlay: return .carPlay
			case UIUserInterfaceIdiom.vision: return .vision
			default: return .iPadOS
			}
			#else
			return .iPadOS
			#endif
		}
	}
	enum DeviceOS: String {
		case macOS, iPadOS, iOS, watchOS, tvOS, carPlay, vision
	}
}
