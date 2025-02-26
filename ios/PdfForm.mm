#import "PdfForm.h"
#import <PDFKit/PDFKit.h>
#import <React/RCTPromise.h>

@implementation PdfForm

RCT_EXPORT_MODULE(PdfForm)

+ (NSString *)moduleName {
  return @"PdfForm";
}

// Detect form fields in the PDF
RCT_EXPORT_METHOD(detectFormFields:(NSString *)pdfPath
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  NSURL *url = [NSURL URLWithString:pdfPath];
  if (!url) {
    reject(@"ERROR", @"Invalid PDF path", nil);
    return;
  }

  PDFDocument *document = [[PDFDocument alloc] initWithURL:url];
  if (!document) {
    reject(@"ERROR", @"Unable to load PDF", nil);
    return;
  }

  NSMutableDictionary<NSString *, NSString *> *formFields = [NSMutableDictionary dictionary];
  for (NSInteger i = 0; i < document.pageCount; i++) {
    PDFPage *page = [document pageAtIndex:i];
    NSArray<PDFAnnotation *> *annotations = page.annotations;
    for (PDFAnnotation *annotation in annotations) {
      NSString *fieldName = annotation.fieldName;
      if (fieldName && annotation.widgetFieldType != PDFAnnotationWidgetSubtypeNone) {
        NSString *type;
        switch (annotation.widgetFieldType) {
          case PDFAnnotationWidgetSubtypeText:
            type = @"text";
            break;
          case PDFAnnotationWidgetSubtypeButton:
            if (annotation.isToggleable) {
              type = @"checkbox";
            } else {
              type = @"radio";
            }
            break;
          case PDFAnnotationWidgetSubtypeChoice:
            type = @"choice";
            break;
          default:
            type = @"unknown";
            break;
        }
        formFields[fieldName] = type;
      }
    }
  }

  NSMutableArray<NSDictionary *> *fieldInfo = [NSMutableArray array];
  [formFields enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
    [fieldInfo addObject:@{@"name": key, @"type": value}];
  }];

  resolve(fieldInfo);
}

// Fill form fields in the PDF
RCT_EXPORT_METHOD(fillFormFields:(NSString *)pdfPath
                  fieldData:(NSDictionary *)fieldData
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
  NSURL *url = [NSURL URLWithString:pdfPath];
  if (!url) {
    reject(@"ERROR", @"Invalid PDF path", nil);
    return;
  }

  PDFDocument *document = [[PDFDocument alloc] initWithURL:url];
  if (!document) {
    reject(@"ERROR", @"Unable to load PDF", nil);
    return;
  }

  for (NSString *fieldName in fieldData) {
    NSString *value = fieldData[fieldName];
    for (NSInteger i = 0; i < document.pageCount; i++) {
      PDFPage *page = [document pageAtIndex:i];
      NSArray<PDFAnnotation *> *annotations = page.annotations;
      for (PDFAnnotation *annotation in annotations) {
        if ([annotation.fieldName isEqualToString:fieldName]) {
          switch (annotation.widgetFieldType) {
            case PDFAnnotationWidgetSubtypeText:
              [annotation setWidgetStringValue:value];
              break;
            case PDFAnnotationWidgetSubtypeButton:
              if (annotation.isToggleable) {
                [annotation setValue:[value.lowercaseString isEqualToString:@"true"] ? @"Yes" : @"Off"
                  forAnnotationKey:PDFAnnotationKeyWidgetValue];
              } else {
                [annotation setWidgetStringValue:value];
              }
              break;
            case PDFAnnotationWidgetSubtypeChoice:
              [annotation setWidgetStringValue:value];
              break;
            default:
              break;
          }
        }
      }
    }
  }

  NSURL *tempDir = [NSFileManager.defaultManager temporaryDirectory];
  NSString *newPath = [[tempDir URLByAppendingPathComponent:[NSUUID.UUID UUIDString]] path] + @".pdf";
  if ([document writeToFile:newPath]) {
    resolve(newPath);
  } else {
    reject(@"ERROR", @"Unable to save filled PDF", nil);
  }
}

@end