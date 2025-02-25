import { TurboModule } from 'react-native';

export interface PdfFormSpec extends TurboModule {
  detectFormFields(pdfPath: string): Promise<Array<{ name: string; type: string }>>;
  fillFormFields(pdfPath: string, fieldData: { [key: string]: string }): Promise<string>;
}