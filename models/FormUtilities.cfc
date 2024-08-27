component {

	any function init( boolean updateFormScope = true ) {
		variables.updateFormScope = arguments.updateFormScope;
		return this;
	}

	/**
	 * BuildFormCollections
	 * Converts a flat form scope into structs and arrays based on the field names.
	 *
	 * @formScope
	 * @updateFormScope
	 */
	any function buildFormCollections(
		required struct formScope,
		boolean updateFormScope = variables.updateFormScope
	){
		var output = {
			"_formCollections" : [],
			"_formCollectionErrors" : []
		};

		// loop through each field in the form scope
        for ( var field in arguments.formScope ) {
			
            field = trim( field );

			// If the field has a dot or a bracket...
			if ( hasFormCollectionSyntax( field ) ) {
				
                // Validate field name before processing. It needs to match specific pattern(s)
				if ( !isValidFieldName( field ) ) {
					// Log the error and skip processing this field
					output["_formCollectionErrors"].append( field );
					continue;
				}
                
                // Add collection to list if not present.
				appendToFormCollections( output, field );

				var currentElement = output;

				// Use regex to split the key into parts, recognizing both dot and bracket notations.
				var keyParts = reMatch( "[^.\[\]]+", field );

				for ( var i = 1; i <= keyParts.len(); i++ ) {
					var tempElement = keyParts[ i ];
					var tempIndex = 0;

					// If the next character is a number, determine the index
					if ( i < keyParts.len() && reFind( "^\d+$", keyParts[ i + 1 ] ) ) {
						tempIndex = keyParts[ i + 1 ];

                        // Check if the index is 0, if so, log error and skip processing
                        if ( tempIndex == "0" ) {
                            output._formCollectionErrors.append( field );
                            break;
                        }

						i++; // Skip the index part in the next loop iteration
					}

					// If there is a temp element defined, means this field is an array or struct.
					if ( !currentElement.keyExists( tempElement ) ) {
						// If tempIndex is numeric, it's an Array, otherwise a Struct.
						currentElement[ tempElement ] = ( tempIndex == 0 ) ? {} : [];
					}

					// If this is the last element defined by dots in the form field name, assign the form field value to the variable.
					if ( i == keyParts.len() ) {
						if ( tempIndex == 0 ) {
							currentElement[ tempElement ] = trim(
								canonicalize( arguments.formScope[ field ], true, true )
							);
						} else {
							currentElement[ tempElement ][ tempIndex ] = trim(
								canonicalize( arguments.formScope[ field ], true, true )
							);
						}
					} else {
						// Keep traversing the structure
						if ( tempIndex == 0 ) {
							currentElement = currentElement[ tempElement ];
						} else {
							if ( !arrayIsDefined( currentElement[ tempElement ], tempIndex ) ) {
								currentElement[ tempElement ][ tempIndex ] = {};
							}
							currentElement = currentElement[ tempElement ][ tempIndex ];
						}

					}
				}
			}
		}

		// Done looping. If we've been set to update the form scope, append the created form collections to the form scope.
		if ( arguments.updateFormScope ) {
			arguments.formScope.append( output );
		}

		return output;
	}

    /**
     * Compare Lists
     * Given two versions of a list, I return a struct containing the values that were added, the values that were removed, and the values that stayed the same.
     *
     * @fieldName 
     */
    struct function compareLists( 
        required any originalList, 
        required any newList
    ){
		var results = { added : [], removed : [], same : [] };

		for ( var thisItem in arguments.originalList.ListToArray() ) {
			if ( arguments.newList.ListFindNoCase( thisItem ) ) {
				results.same.append( thisItem );
			} else {
				results.removed.append( thisItem );
			}
		}

		for ( thisItem in arguments.newList.ListToArray() ) {
			if ( !listFindNoCase( arguments.originalList, thisItem ) ) {
				results.added.append( thisItem );
			}
		}

		return results;
	}

	/**
	 * Checks if a field name contains form collection syntax.
	 * @param fieldName String The form field name.
	 * @return Boolean True if the field name contains collection syntax, false otherwise.
	 */
	private boolean function hasFormCollectionSyntax( required any fieldName ){
		return arguments.fieldName contains "." || arguments.fieldName contains "[";
	}

	/**
	 * Adds the collection name to the list of collection names if it isn't already there.
	 * @param _formCollections String The existing list of collection names.
	 * @param fieldName String The field name to add.
	 * @return String The updated list of collection names.
	 */
	private void function appendToFormCollections(
		required struct output,
		required string fieldName
	){
		// sanitize the field name
		var cleanFieldName = reReplaceNoCase( arguments.fieldName, "(\.|\[).+", "" );

		if ( !arguments.output._formCollections.findNoCase( cleanFieldName ) ) {
			arguments.output._formCollections.append( cleanFieldName );
		}
	}

    /**
	 * Validates if a field name follows the correct syntax.
	 * @param fieldName String The form field name.
	 * @return Boolean True if the field name is valid, false otherwise.
	 */
	private boolean function isValidFieldName(required string fieldName) {
		// Valid field names contain only alphanumeric characters and underscores between dots or brackets
		return reFind("^[a-zA-Z0-9_]+(\[\d*\]|\[[a-zA-Z0-9_]+\])*(\.[a-zA-Z0-9_]+)?(\[\d*\]|\[[a-zA-Z0-9_]+\])*(\.[a-zA-Z0-9_]+)*$", fieldName) > 0;
	}

}
