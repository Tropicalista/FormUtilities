# FormUtilities
A coldbox module that wrap Brian Kotek form utilities plugin

The main capability of this CFC is to generate arrays and structures on the ColdFusion server based on the names of your form fields. So a form field named "user.firstName" would create a structure named "user" with a key of "firstName", holding the value of that field.

It will also generate arrays. A form field named "user[1].firstName" would create an array, with the first element in the array being a structure called "user" with a key of "firstName".

These can be created to any arbitrary level of complexity.

The CFC also has a handy function that will take an original list and a new list, and return a structure telling you what was added to the the list, removed from the list, and what stayed in the list. Useful for handling forms with checkboxes.

