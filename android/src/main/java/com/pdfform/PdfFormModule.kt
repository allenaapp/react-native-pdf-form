package com.pdfform

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise

class PdfFormModule(reactContext: ReactApplicationContext) :
  ReactContextBaseJavaModule(reactContext) {

  override fun getName(): String {
    return NAME
  }

  @ReactMethod
  fun detectFormFields(pdfPath: String, promise: Promise) {
    try {
        val file = File(Uri.parse(pdfPath).path)
        val document = PDDocument.load(file)
        val acroForm = document.documentCatalog.acroForm
        val fieldsArray = WritableNativeArray()

        acroForm?.fields?.forEach { field ->
            val name = field.partialName
            val type = when (field) {
                is PDTextField -> "text"
                is PDCheckBox -> "checkbox"
                is PDRadioButton -> "radio"
                is PDChoice -> "choice"
                else -> "unknown"
            }
            val fieldMap = WritableNativeMap().apply {
                putString("name", name)
                putString("type", type)
            }
            fieldsArray.pushMap(fieldMap)
        }

        promise.resolve(fieldsArray)
        document.close()
    } catch (e: Exception) {
        promise.reject("ERROR", "Unable to load or parse PDF: ${e.message}")
    }
  }

  @ReactMethod
  fun fillFormFields(pdfPath: String, fieldData: ReadableMap, promise: Promise) {
    try {
        val file = File(Uri.parse(pdfPath).path)
        val document = PDDocument.load(file)
        val acroForm = document.documentCatalog.acroForm

        if (acroForm != null) {
            fieldData.toHashMap().forEach { (key, value) ->
                val field = acroForm.getField(key)
                field?.let {
                    val fieldValue = value as String
                    when (it) {
                        is PDTextField -> it.setValue(fieldValue)
                        is PDCheckBox -> it.setValue(if (fieldValue.equals("true", ignoreCase = true)) "Yes" else "Off")
                        is PDRadioButton -> it.setValue(fieldValue)
                        is PDChoice -> it.setValue(fieldValue)
                    }
                }
            }
            val newPath = "${reactApplicationContext.cacheDir}/${UUID.randomUUID()}.pdf"
            document.save(newPath)
            document.close()
            promise.resolve(newPath)
        } else {
            promise.reject("ERROR", "No form found in PDF")
        }
    } catch (e: Exception) {
        promise.reject("ERROR", "Unable to fill or save PDF: ${e.message}")
    }
  }

  companion object {
    const val NAME = "PdfForm"
  }
}
