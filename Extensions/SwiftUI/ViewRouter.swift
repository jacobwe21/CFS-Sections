//
//  File.swift
//  
//
//  Created by Jacob W Esselstyn on 7/31/22.
//

import SwiftUI

public protocol ViewRouterProtocol: AnyObject {
	
	associatedtype Option: Identifiable, Hashable
	
	/// The current view in focus seen by the user.
	var currentViewOption: Option { get }
	
	/// The current prompt being shown, if not nil
	var prompt: Prompt.Sheet? { get set }
	
	/// List of previous views presented to the user
	var viewStack: [Option] { get set }
	
	init(startView: Option)
	
	func goBack()
	func goTo(_ view: Option)
	func resetToThenGoTo(resetTo: Option, goTo view: Option)
	func resetAndGoTo(_ view: Option)
	func showPrompt(_ title: String, message: String, @Prompt.Sheet.PromptBuilder options: ()->[Prompt.Option])
	func showPrompt(_ prompt: @autoclosure () -> Prompt.Sheet)
	func endPrompt()
}
	
public extension ViewRouterProtocol {
	
	var currentViewOption: Option { viewStack.last! }
	
	func goBack() {
		if viewStack.count > 1 {
			viewStack.removeLast()
		}
	}
	func goTo(_ view: Option) {
		viewStack.append(view)
	}
	func resetToThenGoTo(resetTo: Option, goTo view: Option) {
		viewStack = [resetTo]
		goTo(view)
	}
	func resetAndGoTo(_ view: Option) {
		viewStack = [view]
	}
	func showPrompt(_ title: String, message: String = "", @Prompt.Sheet.PromptBuilder options: ()->[Prompt.Option]) {
		withAnimation(.easeOut(duration: 0.3)) {
			prompt = Prompt.Sheet(title: title, message: message, buttons: options)
		}
	}
	func showPrompt(_ prompt: @autoclosure () -> Prompt.Sheet) {
		withAnimation(.easeOut(duration: 0.3)) {
			self.prompt = prompt()
		}
	}
	func endPrompt() { withAnimation(.easeOut(duration: 0.3)) { prompt = nil } }
}
