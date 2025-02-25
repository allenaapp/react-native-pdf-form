import Foundation
import PDFKit

@objc(PdfForm)
class PdfForm: NSObject, RCTTurboModule {
  @objc
  func detectFormFields(_ pdfPath: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    guard let url = URL(string: pdfPath), let document = PDFDocument(url: url) else {
      reject("ERROR", "Unable to load PDF", nil)
      return
    }
    
    var formFields: [String: String] = [:]
    for i in 0..<document.pageCount {
      if let page = document.page(at: i), let annotations = page.annotations {
        for annotation in annotations {
          if let fieldName = annotation.fieldName, annotation.widgetFieldType != .none {
            let type: String
            switch annotation.widgetFieldType {
            case .textField: type = "text"
            case .checkBox: type = "checkbox"
            case .radioButton: type = "radio"
            case .comboBox, .listBox: type = "choice"
            default: type = "unknown"
            }
            formFields[fieldName] = type
          }
        }
      }
    }
    let fieldInfo = formFields.map { ["name": $0.key, "type": $0.value] }
    resolve(fieldInfo)
  }
  
  @objc
  func fillFormFields(_ pdfPath: String, fieldData: [String: String], resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
    guard let url = URL(string: pdfPath), let document = PDFDocument(url: url) else {
      reject("ERROR", "Unable to load PDF", nil)
      return
    }
    
    for (fieldName, value) in fieldData {
      for i in 0..<document.pageCount {
        if let page = document.page(at: i), let annotations = page.annotations {
          for annotation in annotations {
            if annotation.fieldName == fieldName {
              switch annotation.widgetFieldType {
              case .textField:
                annotation.widgetStringValue = value
              case .checkBox:
                annotation.setValue(value.lowercased() == "true" ? "Yes" : "Off", forAnnotationKey: .widgetValue)
              case .radioButton:
                annotation.widgetStringValue = value
              case .comboBox, .listBox:
                annotation.widgetStringValue = value
              default:
                break
              }
            }
          }
        }
      }
    }
    
    let tempDir = FileManager.default.temporaryDirectory
    let newUrl = tempDir.appendingPathComponent(UUID().uuidString + ".pdf")
    if document.write(to: newUrl) {
      resolve(newUrl.path)
    } else {
      reject("ERROR", "Unable to save filled PDF", nil)
    }
  }
  
  static func moduleName() -> String! {
    return "PdfForm"
  }
}