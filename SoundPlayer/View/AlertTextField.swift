//
//  AlertTextField.swift
//  SoundPlayer
//
//  iOS 15以前の環境でAlertにTextFieldを表示する
//
//  Created by masazumi oeda on 2024/05/16.
//

import SwiftUI
import UIKit

struct AlertTextFieldActionButton {
    let title: String
    let style: UIAlertAction.Style
    let aciton: Optional<() -> Void>
    
    init(title: String, style: UIAlertAction.Style, action: Optional<() -> Void> = nil) {
        self.title = title
        self.style = style
        self.aciton = action
    }
}

struct AlertTextField: UIViewControllerRepresentable {
    @Binding var textFieldText: String
    @Binding var isPresented: Bool
    
    let title: String?
    let message: String?
    let placeholderText: String
    
    let primaryButton: AlertTextFieldActionButton?
    let secondaryButton: AlertTextFieldActionButton?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<AlertTextField>) -> UIViewController {
        return UIViewController() // holder controller - required to present alert
    }
    
    // SwiftUIから新しい情報を受け、viewControllerが更新されるタイミングで呼ばれる
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<AlertTextField>) {
        guard context.coordinator.alert == nil else {
            return
        }
        
        guard isPresented else {
            return
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        context.coordinator.alert = alert
        
        // TextFieldの追加
        alert.addTextField { textField in
            textField.placeholder = placeholderText
            textField.returnKeyType = .done
            
            textField.text = self.textFieldText            // << initial value if any
            textField.delegate = context.coordinator    // << use coordinator as delegate
        }
        
        // 左側のボタン (デフォルトのラベル: キャンセル)
        let primaryAction = UIAlertAction(title: primaryButton?.title ?? "Cancel", style: primaryButton?.style ?? .cancel) { _ in
            if let primaryActionClosure = primaryButton?.aciton {
                primaryActionClosure()
            }
        }
        
        // 右側のボタン (デフォルトのラベル: 決定)
        let secondaryAction = UIAlertAction(title: secondaryButton?.title ?? "OK", style: secondaryButton?.style ?? .default) { _ in
            if let secondaryActionClosure = secondaryButton?.aciton {
                secondaryActionClosure()
            }
        }
        
        alert.addAction(primaryAction)
        alert.addAction(secondaryAction)
        
        DispatchQueue.main.async {
            uiViewController.present(alert, animated: true) {
                self.isPresented = false
                
                context.coordinator.alert = nil
            }
        }
    }
    
    func makeCoordinator() -> AlertTextField.Coordinator {
        return Coordinator(self)
    }
    
    final class Coordinator: NSObject, UITextFieldDelegate {
        var alert: UIAlertController?
        var control: AlertTextField
        
        init(_ control: AlertTextField) {
            self.control = control
        }
        
        // TextField への入力のたびに発火
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if let text = textField.text as NSString? {
                self.control.textFieldText = text.replacingCharacters(in: range, with: string)
            } else {
                self.control.textFieldText = ""
            }
            
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            textField.resignFirstResponder()
        }
    }
}
 
struct AlertTextFieldModifier: ViewModifier {
    @Binding var textFieldText: String
    @Binding var isPresented: Bool
    
    let title: String?
    let message: String?
    let placeholderText: String
    
    let primaryButton: AlertTextFieldActionButton?
    let secondaryButton: AlertTextFieldActionButton?
    
    func body(content: Content) -> some View {
        content
            .background(
                AlertTextField(
                    textFieldText: $textFieldText,
                    isPresented: $isPresented,
                    title: title,
                    message: message,
                    placeholderText: placeholderText,
                    primaryButton: primaryButton,
                    secondaryButton: secondaryButton
                )
            )
    }
}


extension View {
    func alertTextField(
        _ text: Binding<String>,
        isPresented: Binding<Bool>,
        title: String?,
        message: String? = nil,
        placeholderText: String,
        primaryButton: AlertTextFieldActionButton? = nil,
        secondaryButton: AlertTextFieldActionButton? = nil
    ) -> some View {
        
        self.modifier(
            AlertTextFieldModifier(
                textFieldText: text,
                isPresented: isPresented,
                title: title,
                message: message,
                placeholderText: placeholderText,
                primaryButton: primaryButton,
                secondaryButton: secondaryButton
            )
        )
    }
}

