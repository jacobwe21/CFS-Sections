//
//  CFS_SectionsApp.swift
//  CFS Sections
//
//  Created by Jacob W Esselstyn on 11/29/24.
//

import SwiftUI
import SwiftData

@main
struct CFS_SectionsApp: App {
    var sharedModelContainer: ModelContainer = {
        
		let schema = Schema([
			SSectionData.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
			return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
			fatalError("Could not create ModelContainer: \(error)")
        }
    }()

	@State private var prompt: Prompt.Sheet?
	
    var body: some Scene {
        WindowGroup {
			ZStack {
				ContentView()
				prompt
			}
			.onAppear {
				UserDefaults.standard.set("Ocean Blue", forKey: "colorTheme")
				prompt = Prompt.Sheet(title: "Disclaimer", message: "This app has been produced for educational purposes only. This app has been created in part by modifying code from CUFSM. CUFSM © 2023 Benjamin W. Schafer", buttons: [Prompt.ok {
					prompt = nil
				}])
			}
        }
        .modelContainer(sharedModelContainer)
#if os(macOS)
		.commands {
			CommandGroup(replacing: .appInfo) {
				Button("About CFS Sections") {
					NSApplication.shared.orderFrontStandardAboutPanel(
						options: [
//							NSApplication.AboutPanelOptionKey.credits: NSAttributedString(
//								string: "This app has been produced as a final project for EN.565.740.81.FA24 Structural Stability at JHU.",
//								attributes: [
//									NSAttributedString.Key.font: NSFont.boldSystemFont(
//										ofSize: NSFont.smallSystemFontSize)
//								]
//							),
							NSApplication.AboutPanelOptionKey(
								rawValue: "Copyright"
							):
"""
© 2024 Jacob W. Esselstyn

This app has been created in part by modifying code from CUFSM.

CUFSM © 2023 Benjamin W. Schafer

MIT License

Copyright (c) 2023 Benjamin W. Schafer
					
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
""",
						]
					)
				}
			}
		}
#endif
    }
}
