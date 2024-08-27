/**
* Executes before any event execution occurs
*/
component extends="coldbox.system.Interceptor" {

	property name="util" inject="FormUtilities@FormUtilities";
    property name="settings" inject="coldbox:moduleSettings:formUtilities";
	
	void function configure(){}
	
	void function preProcess(event,struct interceptData){
		if ( settings.autoParse ) {
            var rc = event.getCollection();
            var formCollection = util.init(true).buildFormCollections(rc);
            structAppend(rc,formCollection,true);
        }
	}

}