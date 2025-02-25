import PdfForm from './NativePdfForm';

export function detectFormFields(pdfPath: string): Promise<Array<{ name: string, type: string }>> {
  return PdfForm.detectFormFields(pdfPath);
}

export function fillFormFields(pdfPath: string, fieldData: { [key: string]: string }): Promise<string> {
  return PdfForm.fillFormFields(pdfPath, fieldData);
}
