/**
* Executes before any event execution occurs
*/
component extends="coldbox.system.Interceptor" {

	property name="util" inject="FormUtilities@FormUtilities";
	
	void function configure(){}
	
	void function preProcess(event,struct interceptData){
		var rc = event.getCollection();
		var formCollection = util.init(true).buildFormCollections(rc);
		structAppend(rc,formCollection,true);
	}

}