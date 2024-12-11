//
//  SwiftData.swift
//
//  Created by Jacob W Esselstyn on 1/6/24.
//

import SwiftUI
import SwiftData

@MainActor
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
struct PreviewWithSwiftData<T: PersistentModel> {
	let container: ModelContainer
	let dataObjects: [T]
	
	init(dataObjects: [T], type: T.Type) throws {
		let config = ModelConfiguration(isStoredInMemoryOnly: true)
		self.container = try ModelContainer(for: type, configurations: config)
		self.dataObjects = dataObjects
		
		for x in dataObjects {
			container.mainContext.insert(x)
		}
	}
}
//#Preview {
//	do {
//		let previewer = try PreviewWithSwiftData(dataObjects: ?, type: ?.self)
//		return View(previewer.dataObjects.first!).modelContainer(previewer.container)
//	} catch {
//		Text("Failed to create preview: \(error.localizedDescription)")
//	}
//}
