//
//  Prompt.swift
//  
//
//  Created by Jacob W Esselstyn on 5/11/24.
//

import SwiftUI

public struct Prompt {
	
	private init() {}
	
	public struct Sheet: View, Equatable {
		@Environment(\.deviceOS) var deviceOS
		@Environment(\.colorTheme) var colorTheme
		@Environment(\.horizontalSizeClass) var hSizeClass
		@Environment(\.verticalSizeClass) var vSizeClass
		let title: String
		let message: String
		let buttons: [Option]
		
		public init(title: String = "", message: String = "", buttons: [Option]) {
			self.title = title
			self.message = message
			self.buttons = buttons
			sheetType = .buttons
			subview = AnyView(EmptyView())
		}
		public init(title: String = "", message: String = "", @PromptBuilder buttons: ()->[Option]) {
			self.title = title
			self.message = message
			self.buttons = buttons()
			sheetType = .buttons
			subview = AnyView(EmptyView())
		}
		
		enum SheetType: String {
			case buttons, subview
		}
		let sheetType: SheetType
		
		let subview: AnyView
		/// Show a custom view after the message
		public init<V: View>(title: String, message: String, @ViewBuilder view: ()->V) {
			self.title = title
			self.message = message
			self.buttons = []
			sheetType = .subview
			subview = AnyView(EmptyView())
		}
		/// Show a custom view after the message
		public init<V: View>(title: String, message: String, view: V) {
			self.title = title
			self.message = message
			self.buttons = []
			sheetType = .subview
			subview = AnyView(EmptyView())
		}
	
		public func buttonsBody(geo: GeometryProxy) -> some View {
			VStack(spacing: 0) {
				Text(title)
					.font(.title)
					.minimumScaleFactor(0.75)
					.multilineTextAlignment(.center)
					.padding(.vertical)
				if !message.isEmpty {
					Text(message)
						.fontWeight(.regular)
						.multilineTextAlignment(message.count > 75 && hSizeClass == .compact ? .leading:.center)
				}
				if buttons.count < 3 && hSizeClass != .compact {
					HStack { buttonsList }.padding(.vertical)
				} else if buttons.count > 5 || vSizeClass == .compact {
					ScrollView {
						buttonsList.padding()
					}.frame(height: geo.size.height/3, alignment: .top)
					.padding(.top)
				} else {
					VStack {
						buttonsList
					}.padding(.vertical)
				}
			}
		}
		public func viewBody(geo: GeometryProxy) -> some View {
			VStack(spacing: 0) {
				Text(title)
					.font(.title)
					.foregroundColor(colorTheme.textColor)
					.multilineTextAlignment(.center)
					.padding(.vertical)
				if !message.isEmpty {
					Text(message)
						.fontWeight(.regular)
						.foregroundColor(colorTheme.textColor)
						.multilineTextAlignment(message.count > 75 && hSizeClass == .compact ? .leading:.center)
				}
				VStack {
					subview
				}.padding(.vertical)
			}
		}
		public var body: some View {
			GeometryReader { geo in
				ZStack {
					SystemBackground()
						.opacity(colorTheme == .invisible ? 0.7:0.9)
						.blur(radius: 10.0)
						.transition(.opacity)
					
					VStack(spacing: 0) {
						switch sheetType {
						case .buttons: buttonsBody(geo: geo)
						case .subview: viewBody(geo: geo)
						}
					}
					.padding(.horizontal)
					.myClippedShapeButtonStyle(theme: colorTheme, clipShape: RoundedRectangle(cornerRadius: 20), mode: .basic, hasBorder: true, padding: 0)
					.centeredSpace(minLength: deviceOS == .iPadOS && hSizeClass != .compact ? 150:50)
					.transition(.scale)
				}
			}
		}
		var buttonsList: some View {
			ForEach(buttons) { option in
				Button {
					option.action()
				} label: {
					switch option.type {
					case .basic:
						option.label
							.fontWeight(.regular)
							.lineLimit(2)
							.imageScale(.large)
							.padding()
							.clipShape(Capsule())
					case .accent:
						option.label
							.fontWeight(.regular)
							.lineLimit(2)
							.imageScale(.large)
							.padding()
							.clipShape(Capsule())
					case .highAccent:
						option.label
							.font(.bold(.body)())
							.lineLimit(2)
							.imageScale(.large)
							.padding()
							.clipShape(Capsule())
					case .destructive:
						option.label
							.font(.bold(.body)())
							.lineLimit(2)
							.imageScale(.large)
							.padding()
							.clipShape(Capsule())
					}
				}.buttonStyle(.borderedProminent)
			}
		}
		
		// MARK: Prompt Option Builder
		@resultBuilder
		public struct PromptBuilder: AnyResultBuilder {
			public typealias Element = Option
		}
		
		public static func == (lhs: Prompt.Sheet, rhs: Prompt.Sheet) -> Bool {
			lhs.title == rhs.title &&
			lhs.message == rhs.message &&
			lhs.buttons == rhs.buttons
		}
	}
	
	public struct Option: Identifiable, Equatable {
		fileprivate let label: Text
		fileprivate let type: OptionType
		fileprivate let action: () -> Void
		public var id: String
	
		public init(_ label: Text, id: String, type: OptionType = .basic, action: @escaping ()->Void) {
			self.label = label
			self.type = type
			self.action = action
			self.id = id
		}
		public init(_ label: String, type: OptionType = .basic, action: @escaping ()->Void) {
			self.label = Text(label)
			self.type = type
			self.action = action
			self.id = label
		}
		public enum OptionType {
			case basic, accent, highAccent, destructive
		}
		public static func == (lhs: Option, rhs: Option) -> Bool {
			lhs.label == rhs.label && lhs.type == rhs.type && lhs.id == rhs.id
		}
	}
	public static func ok(_ action: @escaping () -> Void) -> Self.Option {
		Option("OK", type: .accent, action: action)
	}
	public static func cancel(_ mode: Option.OptionType = .accent, _ action: @escaping () -> Void) -> Self.Option {
		Option(Text("\(Image(systemName: "xmark.circle")) Cancel"), id: "Cancel", type: .accent, action: action)
	}
	public static func delete(_ action: @escaping () -> Void) -> Self.Option {
		Option(Text("\(Image(systemName: "trash")) Delete"), id: "Delete", type: .destructive, action: action)
	}
	
}
//struct PromptPreview: PreviewProvider {
//	static var previews: some View {
//		ZStack {
//			SystemBackground()
//			Prompt.Sheet(title: "BIG fat very very very very very long TITLE", message: "This a a description of the prompt, just in case you can't read the titleetsnaheuotheuttsnohuteohuthossutshoteushoeuhoetuhsoeusoteuhtoehutneoutneo toeh usohutosehu toehu thuoe thsonhu soethusnu ohu tohuoe utohusouh stou......") {
//				//Prompt.Option("HEY") {}
//				//Prompt.Option("HEY2") {}
//				Prompt.Option("HEY3ethettah") {}
//				Prompt.delete {}
//				Prompt.ok {}
//				Prompt.cancel {}
//			}
//		}.environment(\.colorTheme, .blue)
//	}
//}
