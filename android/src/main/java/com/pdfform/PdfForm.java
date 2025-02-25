package com.pdfform;

import android.net.Uri;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.WritableArray;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.bridge.WritableNativeArray;
import com.facebook.react.bridge.WritableNativeMap;
import com.tom_roush.pdfbox.pdmodel.PDDocument;
import com.tom_roush.pdfbox.pdmodel.interactive.form.PDAcroForm;
import com.tom_roush.pdfbox.pdmodel.interactive.form.PDField;
import com.tom_roush.pdfbox.pdmodel.interactive.form.PDTextField;
import com.tom_roush.pdfbox.pdmodel.interactive.form.PDCheckBox;
import com.tom_roush.pdfbox.pdmodel.interactive.form.PDRadioButton;
import com.tom_roush.pdfbox.pdmodel.interactive.form.PDChoice;
import java.io.File;
import java.util.UUID;

public class PdfForm extends ReactContextBaseJavaModule {
  public PdfForm(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @Override
  public String getName() {
    return "PdfForm";
  }

  @ReactMethod
  public void detectFormFields(String pdfPath, Promise promise) {
    try {
      File file = new File(Uri.parse(pdfPath).getPath());
      PDDocument document = PDDocument.load(file);
      PDAcroForm acroForm = document.getDocumentCatalog().getAcroForm();
      WritableArray fieldsArray = new WritableNativeArray();
      if (acroForm != null) {
        for (PDField field : acroForm.getFields()) {
          String name = field.getPartialName();
          String type;
          if (field instanceof PDTextField) {
            type = "text";
          } else if (field instanceof PDCheckBox) {
            type = "checkbox";
          } else if (field instanceof PDRadioButton) {
            type = "radio";
          } else if (field instanceof PDChoice) {
            type = "choice";
          } else {
            type = "unknown";
          }
          WritableMap fieldMap = new WritableNativeMap();
          fieldMap.putString("name", name);
          fieldMap.putString("type", type);
          fieldsArray.pushMap(fieldMap);
        }
      }
      promise.resolve(fieldsArray);
      document.close();
    } catch (Exception e) {
      promise.reject("ERROR", "Unable to load or parse PDF: " + e.getMessage());
    }
  }

  @ReactMethod
  public void fillFormFields(String pdfPath, ReadableMap fieldData, Promise promise) {
    try {
      File file = new File(Uri.parse(pdfPath).getPath());
      PDDocument document = PDDocument.load(file);
      PDAcroForm acroForm = document.getDocumentCatalog().getAcroForm();
      if (acroForm != null) {
        for (Object keyObj : fieldData.toHashMap().keySet()) {
          String key = (String) keyObj;
          PDField field = acroForm.getField(key);
          if (field != null) {
            String value = fieldData.getString(key);
            if (field instanceof PDTextField) {
              field.setValue(value);
            } else if (field instanceof PDCheckBox) {
              field.setValue(value.equalsIgnoreCase("true") ? "Yes" : "Off");
            } else if (field instanceof PDRadioButton) {
              field.setValue(value);
            } else if (field instanceof PDChoice) {
              field.setValue(value);
            }
          }
        }
        String newPath = getReactApplicationContext().getCacheDir() + "/" + UUID.randomUUID().toString() + ".pdf";
        document.save(newPath);
        document.close();
        promise.resolve(newPath);
      } else {
        promise.reject("ERROR", "No form found in PDF");
      }
    } catch (Exception e) {
      promise.reject("ERROR", "Unable to fill or save PDF: " + e.getMessage());
    }
  }
}