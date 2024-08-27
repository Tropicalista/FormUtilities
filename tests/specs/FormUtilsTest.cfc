/**
 * My first spec file
 */
component extends="testbox.system.BaseSpec" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
        // do setup here
	}

	function afterAll(){
		// do cleanup here
	}

	/*********************************** BDD SUITES ***********************************/

	function run(){
		/**
		 * describe() starts a suite group of spec tests. It is the main BDD construct.
		 * You can also use the aliases: story(), feature(), scenario(), given(), when()
		 * to create fluent chains of human-readable expressions.
		 *
		 * Arguments:
		 *
		 * @title    Required: The title of the suite, Usually how you want to name the desired behavior
		 * @body     Required: A closure that will resemble the tests to execute.
		 * @labels   The list or array of labels this suite group belongs to
		 * @asyncAll If you want to parallelize the execution of the defined specs in this suite group.
		 * @skip     A flag that tells TestBox to skip this suite group from testing if true
		 * @focused A flag that tells TestBox to only run this suite and no other
		 */
		describe( "FormUtils Spec", () => {

			/**
			 * --------------------------------------------------------------------------
			 * Runs before each spec in THIS suite group or nested groups
			 * --------------------------------------------------------------------------
			 */
			beforeEach( () => {
				model = new root.models.FormUtilities();
			} );

			/**
			 * --------------------------------------------------------------------------
			 * Runs after each spec in THIS suite group or nested groups
			 * --------------------------------------------------------------------------
			 */
			afterEach( () => {
			} );

			/**
			 * it() describes a spec to test. Usually the title is prefixed with the suite name to create an expression.
			 * You can also use the aliases: then() to create fluent chains of human-readable expressions.
			 *
			 * Arguments:
			 *
			 * @title  The title of this spec
			 * @body   The closure that represents the test
			 * @labels The list or array of labels this spec belongs to
			 * @skip   A flag or a closure that tells TestBox to skip this spec test from testing if true. If this is a closure it must return boolean.
			 * @data   A struct of data you would like to bind into the spec so it can be later passed into the executing body function
			 * @focused A flag that tells TestBox to only run this spec and no other
			 */
			it( "can be created", () => {
				expect( model ).toBeComponent();
			} );

            it( "can build form collections", () => {
				
                var rc = {
                    // should be ignored
                    "name": "Dave", 
                    // Simple Struct
                    "address.street": "1234 Elm St",
                    "address.city": "Springfield",
                    "address.state": "IL",
                    "address.zip": "62701",
                    // simple array
                    "phone[0]": "111-111-1111", // should be ignored and added to errors
                    "phone[1]": "217-555-1212",
                    "phone[2]": "217-555-3434",
                    "phone[3]": "217-555-5656",
                    // Array of structs
                    "music[1].title": "Here Comes the Sun",
                    "music[1].artist": "The Beatles",
                    "music[2].title": "Stairway to Heaven",
                    "music[2].artist": "Led Zeppelin",
                    // Array of structs version 2
                    "movies[1][title]": "Star Wars",
                    "movies[1][director]": "George Lucas",
                    "movies[2][title]": "The Godfather",
                    "movies[2][director]": "Francis Ford Coppola",
                    // Deeply Nested (1)
                    "food[fruits][apples][red]": "Red Delicious",
                    "food[fruits][apples][green]": "Granny Smith",
                    "food[vetables][green][1]": "Spinach",
                    "food[vetables][green][2]": "Kale",
                    // Deeply Nested (2)
                    "order[1].item[1].name": "Widget",
                    "order[1].item[1].quantity": "2",
                    "order[1].item[2].name": "Gadget",
                    "order[1].item[2].quantity": "3",
                    "order[2].item[1].name": "Doodad",
                    "order[2].item[1].quantity": "4",
                    // Badly formed
                    "badly[formed": "This is badly formed",
                    "movies[3][director]xx": "I Should Not Be Here",

                };

                var validFormCollections = [ "address", "phone", "music", "movies", "food", "order" ];
                
                var result = model.buildFormCollections( rc );

                debug( result );
                
                expect( result._formCollections.len() ).toBe( validFormCollections.len() );
                validFormCollections.each( function( item ) {
                    expect( result._formCollections.findNoCase( item ) ).toBeTrue();
                } );
                // expect not to have the simple value
                expect( result._formCollections.findNoCase( "name" ) ).toBeFalse();
                expect( result ).notToHaveKey( "name" );

                // Simple Struct
                expect( result.address ).toBeStruct();
                expect( result.address.street ).toBe( "1234 Elm St" );
                expect( result.address.city ).toBe( "Springfield" );
                expect( result.address.state ).toBe( "IL" );
                expect( result.address.zip ).toBe( "62701" );

                // Simple Array
                expect( result.phone ).toBeArray();
                expect( result.phone[ 1 ] ).toBe( "217-555-1212" );
                expect( result.phone[ 2 ] ).toBe( "217-555-3434" );
                expect( result.phone[ 3 ] ).toBe( "217-555-5656" );

                // Array of Structs
                expect( result.music ).toBeArray();
                expect( result.music[ 1 ] ).toBeStruct();
                expect( result.music[ 1 ].title ).toBe( "Here Comes the Sun" );
                expect( result.music[ 1 ].artist ).toBe( "The Beatles" );
                expect( result.music[ 2 ] ).toBeStruct();
                expect( result.music[ 2 ].title ).toBe( "Stairway to Heaven" );
                expect( result.music[ 2 ].artist ).toBe( "Led Zeppelin" );

                // Array of Structs version 2
                expect( result.movies ).toBeArray();
                expect( result.movies[ 1 ] ).toBeStruct();
                expect( result.movies[ 1 ].title ).toBe( "Star Wars" );
                expect( result.movies[ 1 ].director ).toBe( "George Lucas" );
                expect( result.movies[ 2 ] ).toBeStruct();
                expect( result.movies[ 2 ].title ).toBe( "The Godfather" );
                expect( result.movies[ 2 ].director ).toBe( "Francis Ford Coppola" );

                // Error fields
                expect( result._formCollectionErrors.find( "phone[0]" ) ).toBeTrue();
                expect( result._formCollectionErrors.find( "badly[formed" ) ).toBeTrue();
                expect( result._formCollectionErrors.find( "movies[3][director]xx" ) ).toBeTrue();

			} );

		} );
	}

}
