//
//  TextAndLabels.swift
//  
//
//  Created by Jacob W Esselstyn on 12/26/22.
//

import SwiftUI

// MARK: TextBlock
public struct TextBlock: View {
	let text: Text
	let headline: Text?
	public init(headline: String? = nil, _ text: String) {
		self.text = Text(text)
		self.headline = headline.exists ? Text(headline!):nil
	}
	public init(headline: Text? = nil, _ text: Text) {
		self.text = text
		self.headline = headline
	}
	public var body: some View {
		VStack(alignment: .leading) {
			if headline.exists { headline!.font(.headline) }
			text.padding(.bottom)
		}
	}
}

// MARK: Text modifiers
public extension Text {
	func myMenuTitleStyle(colorTheme: ColorTheme) -> some View {
		self.multilineTextAlignment(.center)
		.foregroundColor(colorTheme.textColor)
		.font(.title)
	}
	/// Applies title2 and top padding
	func myLargeHeaderStyle() -> some View {
		self.font(.title2).padding(.top)
	}
	func myHeadline(alignment: TextAlignment = .center) -> some View {
		self.multilineTextAlignment(alignment).font(.headline).offset(y: 3)
	}
	func myFootnote(alignment: TextAlignment = .center) -> some View {
		self.font(.footnote).multilineTextAlignment(alignment).padding(.top, -3).padding(.bottom, 7)
	}
}

// MARK: AlignedLabels
public struct AlignedLabels: View {
	let labels: [(String,LocalizedStringKey)]
	let spacing: CGFloat
	let horizontalSpacing: CGFloat?
	let verticalSpacing: CGFloat?
	
	/// Each array must be the same length
	public init(systemImages: [String], labels: [LocalizedStringKey], spacing: CGFloat = 3, horizontalSpacing: CGFloat? = nil, verticalSpacing: CGFloat? = nil) {
		var tempLabels: [(String,LocalizedStringKey)] = []
		for i in 0..<labels.count {
			tempLabels.append((systemImages[i],labels[i]))
		}
		self.labels = tempLabels
		self.spacing = spacing
		self.horizontalSpacing = horizontalSpacing
		self.verticalSpacing = verticalSpacing
	}
	public var body: some View {
		Grid(alignment: .leading, horizontalSpacing: horizontalSpacing, verticalSpacing: verticalSpacing) {
			ForEach(labels, id: \.0) { label in
				GridRow(alignment: .firstTextBaseline) {
					Image(systemName: label.0).padding(.trailing).gridColumnAlignment(.center).font(.headline)
					Text(label.1)
						.gridColumnAlignment(.leading)
				}
			}
		}
	}
}

public struct GroupedRows<Content: View>: View {
	@Environment(\.colorTheme) var colorTheme
	
	let heading: String?
	let footnote: String?
	let content: Content
	
	public init(heading: String?, footnote: String? = nil, @ViewBuilder content: ()->Content) {
		self.heading = heading
		self.footnote = footnote
		self.content = content()
	}
	public var body: some View {
		VStack(spacing: 5) {
			if let heading {
				Text(heading)
					.offset(y: 2)
					.left()
			}
			content
			if let footnote {
				Text(footnote)
					.foregroundColor(colorTheme.textColor)
					.myFootnote()
			}
		}
		.padding(.horizontal).padding(.top, 15).padding(.bottom, 10)
		.myRoundedUIItemStyle(padding: false, backgroundColor: MyColors.systemBackground.opacity(0.25))
	}
}

//struct SwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//
//    }
//}
