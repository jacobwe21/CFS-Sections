//
//  SwiftUIView.swift
//  
//
//  Created by Jacob W Esselstyn on 1/29/23.
//

import SwiftUI

public struct LicenseView: View {
	
	@Environment(\.openURL) var openURL
	@Environment(\.colorTheme) var colorTheme
	@Environment(\.horizontalSizeClass) var hSizeClass
	
	let copyrightYear: String?
	let copyrightName: String
	let description: String
	let detailedDescription: String?
	let urlLink: URL?
	let licenseType: LicenseType
	let cSymbol: Bool
	
	@State private var showOverlay: Bool = false
	
	/// Creates a View that displays a software license or attribution
	/// - Parameters:
	///   - owner: The copyright holder/owner
	///   - year: The copyright year
	///   - softwareDescription: A short description of the software being used.
	///   - licenseType: The type of attribution or license
	///   - url: Provides a link to the software source.
	public init(c: Bool = true, owner: String, year: Int?, description: String, licenseType: LicenseType, url: URL? = nil, detailedDescription: String? = nil) {
		copyrightName = owner
		copyrightYear = year.exists ? String(year!):nil
		self.description = description
		self.licenseType = licenseType
		urlLink = url
		self.detailedDescription = detailedDescription
		cSymbol = c
	}
	
	public var body: some View {
		ZStack {
			VStack(alignment: .leading) {
				HStack {
					if !showOverlay {
						if hSizeClass == .compact || urlLink.exists {
							VStack(alignment: .leading) {
								if licenseType == .attribution {
									Text(copyrightText).font(.headline)
									Text(description)
								} else {
									Text(description).font(.headline)
								}
							}
						} else {
							HStack {
								if licenseType == .attribution {
									Text(copyrightText).font(.headline)
									Spacer(minLength: 10)
									Text(description)
								} else {
									Text(description).font(.headline)
								}
							}
						}
					}
					Spacer()
					if urlLink.exists {
						Button {
							showOverlay = true
						} label: {
							Label("Website", systemImage: "globe")
								.padding(.vertical, -5)
								.myCapsuleButtonStyle(theme: colorTheme, mode: .accent)
						}
					}
				}
				switch licenseType {
				case .MIT:
					Text(mitLicense(copyright: copyrightText)).font(.footnote)
				case .none, .attribution:
					if let detailedDescription {
						Text(detailedDescription)
							.font(.footnote)
					} else {
						EmptyView()
					}
				}
			}
			.disabled(showOverlay)
			
			if showOverlay {
				SystemBackground()
					.padding(-15)
					.opacity(colorTheme == .invisible ? 0.9:0.7)
					.blur(radius: 8.0)
					.transition(.opacity)
				bodyOverlay
			}
		}
		.multilineTextAlignment(.leading)
		.myRoundedUIItemStyle()
		.animation(.default, value: showOverlay)
	}
	public var bodyOverlay: some View {
		HStack {
			Text("Leave App?")
			Spacer()
			Button {
				showOverlay = false
				open(url: urlLink)
			} label: {
				Text("Yes")
					.padding(.vertical, -5)
					.myCapsuleButtonStyle(theme: colorTheme, mode: .highAccent).frame(height: 30)
			}.padding(.trailing, 5)
			Button {
				showOverlay = false
			} label: {
				Text("No")
					.padding(.vertical, -5)
					.myCapsuleButtonStyle(theme: colorTheme, mode: .accent).frame(height: 30)
			}
		}.transition(.opacity)
	}
	
	private var copyrightText: String {
		if copyrightYear.exists {
			if cSymbol {
				return "© "+copyrightYear!+" "+copyrightName
			} else {
				return copyrightYear!+" "+copyrightName
			}
		} else {
			if cSymbol {
				return "© "+copyrightName
			} else {
				return copyrightName
			}
		}
	}
	
	public enum LicenseType {
		case attribution, MIT, none
	}
	
	func mitLicense(copyright: String) -> String {
		"""
		MIT License
		
		Copyright (c) \(copyright)
		
		Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
		
		The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
		
		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
		
		"""
	}
	private func open(url: URL?) {
		guard url.exists else { return }
		openURL(url!)
	}
}

struct LicenseView_Previews: PreviewProvider {
    static var previews: some View {
		ZStack {
			Rectangle().fill(MyColors.blue).zIndex(-1)
			LicenseView(owner: "Owner", year: 2023, description: "Cool Software", licenseType: .attribution, detailedDescription: "This is a detailed description of the software... Hope it's not too boring...")
		}
    }
}
