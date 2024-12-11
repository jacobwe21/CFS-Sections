//
//  ContentView.swift
//  CFS Sections
//
//  Created by Jacob W Esselstyn on 11/29/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
	@Query(sort: \SSectionData.timestamp, order: .reverse) private var items: [SSectionData]
	
	@State private var showSectionTemplateSheet: Bool = false
	@State private var templateSection: SSectionCFS = .defaultSection
	@State private var navigationContext = NavigationContext()

	@Environment(\.dismiss) var dismiss
	
    var body: some View {
		@Bindable var navigationContext = navigationContext
		NavigationSplitView {
			List(selection: $navigationContext.selectedSection) {
				ForEach(items) { item in
					NavigationLink(value: item) {
						Text("\(item.name) - \(item.timestamp.formatted(date: .numeric, time: .shortened))")
					}
					.contextMenu {
						Button {
							duplicateItem(item)
						} label: {
							Text("Duplicate")
						}
						Button {
							deleteItem(item)
						} label: {
							Text("Delete")
						}
					}
                }
                .onDelete(perform: deleteItems)
#if os(macOS)
				.onDeleteCommand {
					if navigationContext.selectedSection != nil {
						deleteItem(navigationContext.selectedSection!)
					}
				}
#endif
            }
#if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
#endif
			.navigationTitle("CFS Sections")
			.toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
				ToolbarItem(placement: .automatic) {
					Button {
						showSectionTemplateSheet = true
					} label: {
                        Label("New Structural Section", systemImage: "plus")
                    }
                }
            }
        } detail: {
			VStack {
				if navigationContext.selectedSection != nil {
					SSectionEditor(section: navigationContext.selectedSection!)
				} else {
					if items.isEmpty {
						Text("Create a new Structural Section")
						Button {
							showSectionTemplateSheet = true
						} label: {
							Label("New Structural Section", systemImage: "plus")
						}
					} else {
						Text("Select a Structural Section to Edit & View")
							.padding(.bottom)
						Text("Or create a new Structural Section...")
						Button {
							showSectionTemplateSheet = true
						} label: {
							Label("New Structural Section", systemImage: "plus")
						}
					}
				}
			}
        }
		.sheet(isPresented: $showSectionTemplateSheet) {
			templateSection = .defaultSection
		} content: {
			SSectionTemplate(sectionTemplate: $templateSection)
				.macOS { view in
					view
						.frame(minWidth: 600, idealWidth: 1000, maxWidth: .infinity, minHeight: 300, idealHeight: 400, maxHeight: .infinity)
				}
		}
    }

	private func addItem(_ item: SSectionCFS? = nil, name: String = "New Section") {
        withAnimation {
			if let item = item {
				let newItem = SSectionData(timestamp: Date(), name: name, section: item)
				modelContext.insert(newItem)
			} else {
				let newItem = SSectionData(timestamp: Date(), name: name, section: SSectionCFS.defaultSection)
				modelContext.insert(newItem)
			}
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
	private func deleteItem(_ item: SSectionData) {
		withAnimation {
			modelContext.delete(item)
		}
	}
	private func duplicateItem(_ item: SSectionData) {
		withAnimation {
			let newItem = SSectionData(timestamp: Date(), name: item.name, section: item.section)
			modelContext.insert(newItem)
		}
	}
}

#Preview {
    ContentView()
        .modelContainer(for: SSectionData.self, inMemory: true)
}

@Observable
class NavigationContext {
	var selectedSection: SSectionData?
	
	init(selectedSection: SSectionData? = nil) {
		self.selectedSection = selectedSection
	}
}
