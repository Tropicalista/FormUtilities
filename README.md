# FormUtilities
A ColdBox module that extends and enhances Brian Kotek and [James Mohler's](https://github.com/jmohler1970/FormUtils) form utilities components.

## Dynamic Structure and Array Generation:
This module parses form field names to automatically create naitive CFML structures and arrays.

For example:

- A form field named `user.firstName` will create a CFML structure named `user` with a key of `firstName`, holding the value of that field.

- A form field named `user[1].firstName` or `user[1][firstName]` will create an array named `user`. The first element in this array will be a structure with a key of `firstName`.

## Requirements

This module was tested in the following CFML engines:

- Lucee 5
- Adobe ColdFusion 2018
- Adobe ColdFusion 2021

## Installation

Install FormUtilities using [CommandBox](https://commandbox.ortusbooks.com/):

```bash
box install formutilities
```

## Configuration

Configure FormUtilities in your Coldbox `config/Coldbox.cfc` file:

```js
moduleSettings = {
    // default configuration
    formUtilities: {
        "autoParse" = true
    }
};
```

| Setting      | Type | Default | Description |
| ----------- | ----------- | ----------- | ----------- |
| autoParse      | Boolean  | true | Parse the `rc` scope automatically on every request.

## Wirebox Integration

To manually use FormUtilities in your Coldbox application, inject the `FormUtilities` model into your handlers, models, or interceptors using the following Wirebox DSL:

```js
property name="formUtilities" inject="FormUtilities@FormUtilities";
```



## Usage in HTML Forms

In order to take advantage of FormUtilities parsing, you need to name your form fields in a specific way. Here are some examples:

```html
<!-- Simple Array -->
<input name="telephone[1]" value="111-111-1111" />
<input name="telephone[2]" value="222-222-2222" />
<input name="telephone[3]" value="333-333-3333" />

<!-- Simple Struct -->
<input name="address.street" value="1234 Elm St" />
<input name="address.city" value="Springfield" />
<input name="address.state" value="IL" />
<input name="address.zip" value="62701" />

<!-- Array of Structs (option 1) -->
<input name="order[1].item" value="Laptop" />
<input name="order[1].price" value="1000" />
<input name="order[2].item" value="Tablet" />
<input name="order[2].price" value="500" />

<!-- Array of Structs (option 2) -->
<input name="order[1][item]" value="Laptop" />
<input name="order[1][price]" value="1000" />
<input name="order[2][item]" value="Tablet" />
<input name="order[2][price]" value="500" />

<!-- Complex nesting -->
<input name="order[1].item[1].name" value="Laptop" />
<input name="order[1].item[1].price" value="1000" />
<input name="order[1].item[2].name" value="Tablet" />
<input name="order[1].item[2].price" value="500" />
<input name="order[2].item[1].name" value="Phone" />
<input name="order[2].item[1].price" value="300" />
```

**Important Note** Javascript starts array indexes at 0, but ColdFusion starts at 1. Your HTML form input names should start indexes at 1 to match CFML.

## Manual Parsing

If you have disabled `autoParse` in your configuration, you can manually parse the `rc` scope using the `buildFormCollections()` method.  The method accepts the following arguments:

| Setting      | Type | Default | Description |
| ----------- | ----------- | ----------- | ----------- |
| `rc`     | Struct  | n/a | The struct of data to parse, usually the form scope |
| `updateFormScope`     | Boolean  | true | Update the passed struct with the parsed data |

Examples:

```js
// Parse the rc scope and automatically update it
formUtilities.buildFormCollections( rc, true );
```

```js
// Parse the rc scope without updating it and output the parsed data
var result = formUtilities.buildFormCollections( rc, false );
writeDump( result );
```

The `buildFormCollections()` method returns a struct with the following important fields: 

- `_formCollections`: An array containing all resulting arrays and structures parsed from the original data
- `_formCollectionErrors` An array containing field names with errors that could not be parsed

## But Wait, There's More!

### Canonicalize Form Fields

When the parser builds structures and arrays, it automatically trims and [canonicalizes](https://cfdocs.org/canonicalize) the field values.  It will not canonicalize regular form fields that aren't part of a structure or array, so you will need to take care of that yourself.

### Utility Methods

#### `compareLists()`

In addition to form processing, the CFC includes a utility method, `compareLists()` that compares two lists (an original list and a new list) and returns a structure indicating:

- Added Items: Elements present in the new list but not in the original.
- Removed Items: Elements present in the original list but not in the new one.
- Same items: Elements present in both lists.

Example:

```js
var list1 = "apple,banana,orange";
var list2 = "banana,orange,grape";

// compare the two lists
var result = formUtilities.compareLists( list1, list2 );

writeDump( result );

// Output: { added = "grape", removed = "apple", same = "banana,orange" }
```

### Unit Tests

To run the unit tests on this module, fire up CommandBox and enter the following commands to start a CFML server of your choice. Included server configs are as follows:

```bash
start server-lucee@5.json
start server-adobe@2018.json
start server-adobe@2021.json
```

Then open a browser and navigate to `http://localhost:port/tests/runner.cfm` to automatically run the tests.