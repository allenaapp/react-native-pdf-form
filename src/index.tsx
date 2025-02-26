import { NativeModules, Platform } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-pdf-form' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

const PdfForm = NativeModules.PdfForm
  ? NativeModules.PdfForm
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

export function detectFormFields(pdfPath: string): Promise<Array<{ name: string, type: string }>> {
  return PdfForm.detectFormFields(pdfPath);
}

export function fillFormFields(pdfPath: string, fieldData: { [key: string]: string }): Promise<string> {
  return PdfForm.fillFormFields(pdfPath, fieldData);
}
