import SwiftUI
import EventKit
import EventKitUI

struct EventEditView: UIViewControllerRepresentable {
    let eventStore: EKEventStore
    var event: Binding<EKEvent?>
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let controller = EKEventEditViewController()
        controller.eventStore = eventStore
        controller.event = event.wrappedValue
        controller.editViewDelegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {
        // No update needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, EKEventEditViewDelegate {
        let parent: EventEditView
        
        init(_ parent: EventEditView) {
            self.parent = parent
        }
        
        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            parent.dismiss()
        }
    }
} 
