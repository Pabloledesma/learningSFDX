public class ProjectCalloutService {
	
    @InvocableMethod
	public static void postOpportunityToPMS(List<Id> oppIds){
		
        Opportunity opp = [
            SELECT Id, Name, Account.Name, CloseDate, Amount
            FROM Opportunity
            WHERE Id =: oppIds[0]
        ];

		String token = ServiceTokens__c.getValues('ProjectServiceToken').Token__c;
		
		String jsonInput = '{\n' +
				' "opportunityId"    : "'+opp.Id+'",\n'+
				' "opportunityName"  : "'+opp.Name+'",\n'+
				' "accountName"      : "'+opp.Account.Name+'",\n'+
				' "closeDate"        : "'+String.ValueOf(opp.CloseDate).mid(0,10)+'",\n'+
				' "amount"           : "'+opp.Amount+'"\n}';

		System.enqueueJob(new QueueablePMSCall(token, jsonInput, opp.Id));
    }

	class QueueablePMSCall implements Queueable, Database.AllowsCallouts{
		
        private String token;
		private String JsonInput;
		private ID     opportunityId;
		
		public QueueablePMSCall(String token, String JsonInput, Id opportunityId){
			this.token = token;
			this.JsonInput = JsonInput;
			this.opportunityId = opportunityId;
		}
		public void execute(QueueableContext qc){
			postTOPMS(token,JsonInput, opportunityId);
		}
	}

	@Future(callout=true)
	private static void postToPMS(String token,String jsonInput, Id oppId){
		HttpRequest request = new HttpRequest();
		request.setEndpoint('callout:ProjectService');
		request.setMethod('POST');
		request.setHeader('Content-Type', 'application/json;charset=utf-8');
		request.setBody(jsonInput);
		
		Http http = new Http();
		HttpResponse response = http.send(request);
		
		Opportunity opportunity = new Opportunity(Id = oppId);
		
        if (response.getStatusCode() == 201) {
			opportunity.StageName = 'Submitted Project';
		} else {
			opportunity.StageName = 'Resubmit Project';
		}
        
		update opportunity;
	}
}