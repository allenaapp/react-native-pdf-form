# react-native-pdf-form

A React Native library to detect and fill PDF forms

## Installation

```sh
npm install react-native-pdf-form
```

## Usage


```js
import PdfForm from 'react-native-pdf-form';

// ...

  PdfForm.detectFormFields('file:///path/to/form.pdf')
    .then((fields) => {
      console.log('Form Fields:', fields);
    })
    .catch((error) => console.error(error));

  // Fill form fields
  const fieldData = {
    firstName: 'John',
    agree: 'true',
  };

  PdfForm.fillFormFields('file:///path/to/form.pdf', fieldData)
    .then((filledPdfPath) => {
      console.log('Filled PDF saved at:', filledPdfPath);
    })
    .catch((error) => console.error(error));

```


## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
