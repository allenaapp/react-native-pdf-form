import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  detectFormFields(pdfPath: string): Promise<Array<{ name: string, type: string }>>;
  fillFormFields(pdfPath: string, fieldData: { [key: string]: string }): Promise<string>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('PdfForm');
