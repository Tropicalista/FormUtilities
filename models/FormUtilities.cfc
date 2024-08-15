component{
	
	public function init( boolean updateFormScope=false,
						boolean trimFields=true,
						boolean cleanFields=true
		)
	{

		variables.instance.updateFormScope = arguments.updateFormScope;
		variables.instance.trimFields = arguments.trimFields;
		variables.instance.cleanFields = arguments.cleanFields;
		return this;
	}
	
	public struct function compareLists(required any originalList, required any newList){
		var local = StructNew();
		
		local.results = StructNew();
		local.results.addedList = "";
		local.results.removedList = "";
		local.results.sameList = "";
		
		cfloop( list="#arguments.originalList#", index="local.thisItem"){
			if( ListFindNoCase(arguments.newList, local.thisItem) ){
				local.results.sameList = ListAppend(local.results.sameList, local.thisItem);
			}else{
				local.results.removedList = ListAppend(local.results.removedList, local.thisItem);
			}
		}
		
		cfloop( list="#arguments.newList#", index="local.thisItem"){
			if( not ListFindNoCase(arguments.originalList, local.thisItem) ){
				local.results.addedList = ListAppend(local.results.addedList, local.thisItem);
			}
		}
		
		return local.results;
	}
	
	public any function buildFormCollections(
			required struct formScope,
			required boolean updateFormScope="#variables.instance.updateFormScope#",
			required boolean trimFields="#variables.instance.trimFields#",
			required boolean cleanFields="#variables.instance.cleanFields#"
		){

		var local = StructNew();
		
		local.tempStruct = StructNew();
		local.tempStruct['formCollectionsList'] = "";
		
		// Loop over the form scope.
		cfloop (collection="#arguments.formScope#", item="local.thisField"){
			if( arguments.cleanFields ){
				// protect from cross site scripting
				if( isStruct(arguments.formscope[local.thisField]) ){
					arguments.formScope[local.thisField] = htmlEditFormat(serializeJson(arguments.formscope[local.thisField]));
				}else{
					arguments.formScope[local.thisField] = htmlEditFormat( arguments.formScope[local.thisField] );
				}
			}
			local.thisField = Trim(local.thisField);

			// If the field has a dot or a bracket...
			if( hasFormCollectionSyntax(local.thisField) ){

				// Add collection to list if not present.
				local.tempStruct['formCollectionsList'] = addCollectionNameToCollectionList(local.tempStruct['formCollectionsList'], local.thisField);

				local.currentElement = local.tempStruct;

				// Loop over the field using . as the delimiter.
				local.delimiterCounter = 1;
				cfloop(list="#local.thisField#", delimiters=".", index="local.thisElement"){
					local.tempElement = local.thisElement;
					local.tempIndex = 0;

					// If the current piece of the field has a bracket, determine the index and the element name.
					if( local.tempElement contains "[" ){
						local.tempIndex = ReReplaceNoCase(local.tempElement, '.+\[|\]', '', 'all');
						local.tempElement = ReReplaceNoCase(local.tempElement, '\[.+\]', '', 'all');
					}

					// If there is a temp element defined, means this field is an array or struct.
					if( not StructKeyExists(local.currentElement, local.tempElement) ){

						// If tempIndex is numeric, it's an Array, otherwise an Struct.
						if( IsNumeric(local.tempIndex) ){
							local.currentElement[local.tempElement] = ArrayNew(1);
						}else{
							local.currentElement[local.tempElement] = StructNew();
						}	
					}	

					// If this is the last element defined by dots in the form field name, assign the form field value to the variable.
					if( local.delimiterCounter eq ListLen(local.thisField, '.') ){

						if( local.tempIndex eq 0 ){
							local.currentElement[local.tempElement] = arguments.formScope[local.thisField];
						}else{
							local.currentElement[local.tempElement][local.tempIndex] = arguments.formScope[local.thisField];
						}	

					// Otherwise, keep going through the field name looking for more structs or arrays.
					}else{
						
						// If this field was a Struct, make the next element the current element for the next loop iteration.
						if( local.tempIndex eq 0 ){
							local.currentElement = local.currentElement[local.tempElement];
						}else{
							
							// If we're on CF8, leverage the ArrayIsDefined() function to avoid throwing costly exceptions.
							if( server.coldfusion.productName eq "ColdFusion Server" and ListFirst(server.coldfusion.productVersion) gte 8 ){
								
								if( ArrayIsEmpty(local.currentElement[local.tempElement]) 
										or ArrayLen(local.currentElement[local.tempElement]) lt local.tempIndex
										or not ArrayIsDefined(local.currentElement[local.tempElement], local.tempIndex ) ){
									local.currentElement[local.tempElement][local.tempIndex] = StructNew();
								}
								
							}else{
							
								// Otherwise it's an Array, so we have to catch array element undefined errors and set them to new Structs.
								try{
									local.currentElement[local.tempElement][local.tempIndex];
								}catch(any e){
										local.currentElement[local.tempElement][local.tempIndex] = StructNew();
								}
							
							}
							
							// Make the next element the current element for the next loop iteration.
							local.currentElement = local.currentElement[local.tempElement][local.tempIndex];

						}
						local.delimiterCounter = local.delimiterCounter + 1;
					}
					
				}
			}
		}
		
		// Done looping. If we've been set to update the form scope, append the created form collections to the form scope.
		if( arguments.updateFormScope ){
			StructAppend(arguments.formScope, local.tempStruct);
		}

		return local.tempStruct;
	}
	
	private string function hasFormCollectionSyntax(required any fieldName){
		return arguments.fieldName contains "." or arguments.fieldName contains "[";
	}
	
	private string function addCollectionNameToCollectionList(required string formCollectionsList, required string fieldName){

		if (not ListFindNoCase( arguments.formCollectionsList, ReReplaceNoCase( arguments.fieldName, '(\.|\[).+', '') ) ){
			arguments.formCollectionsList = ListAppend(arguments.formCollectionsList, ReReplaceNoCase(arguments.fieldName, '(\.|\[).+', ''));
		}
		return arguments.formCollectionsList;
	}
	
}
