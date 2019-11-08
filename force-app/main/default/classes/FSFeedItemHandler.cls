/********************************************************************************************************* 
Name         : FSFeedItemHandler
Created By   : Pallavi Sharma (Appiro)
Created Date : 25 - Sep - 2013
Usage        : Trigger Handler for Feed Item
***********************************************************************************************************/
public without sharing class FSFeedItemHandler {
	
	//Method called after feedItem Inserted
	public static void afterInsert(){
		cloneFeedToHeadQuarter();
	}
	
	//Method clones Feed Items. Feed Items which is related to Chain Accounts will be cloned to Headquarter Account
	private static void cloneFeedToHeadQuarter(){
		Map<Id, FeedItem> mapChainFeed = new Map<Id, FeedItem>();
		//Get Parent Id of Feed if it is insert from Account. Account Ids will always starts with 001 
		for(FeedItem fi : (List<FeedItem>) trigger.newMap.values()){
			if(String.valueOf(fi.ParentId).startsWith('001')){
				mapChainFeed.put(fi.ParentId, fi);
			}
		}
		if(mapChainFeed.size() > 0 ){
			//Get Headquarters of Chain account 
			Map<Id,Account> mapHeadAccount = new Map<Id,Account>(
			[Select Id, (Select Id From Chains__r where RecordType.Name = 'FS Headquarters' ) 
			 From Account  
			 Where Id IN :mapChainFeed.keySet() And RecordType.Name = 'FS Chain']);
			 
			if(mapHeadAccount.size() > 0 ){
				Map<Id, List<FeedItem>> mapChainHeadquarterFeed = new Map<Id, List<FeedItem>>();
				List<FeedItem> headFeedToInsert = new List<FeedItem>();
				//Clone feed items for all headquarters account
				for(Id chainId :  mapChainFeed.keySet()){
					for(Account headQtr : mapHeadAccount.get(chainId).Chains__r ){
						FeedItem newFeed = mapChainFeed.get(chainId).clone();
						newFeed.ParentId = headQtr.Id;
						//Check for RelatedRecordId, if RelatedRecordId exist that means feed have related content , no need content data and content file 
						if(newFeed.RelatedRecordId != null){
							newFeed.ContentFileName = null;
							newFeed.ContentData = null;
						}
						headFeedToInsert.add(newFeed);
						if(!mapChainHeadquarterFeed.containsKey(chainId))
							mapChainHeadquarterFeed.put(chainId, new List<FeedItem>());
						mapChainHeadquarterFeed.get(chainId).add(newFeed);
					}
				}
				if(FSUtil.checkAccessForSobject('FeedItem', FSConstants.ACCESS_IS_CREATABLE)){ 
					//Insert Headquarter FeedItems
					insert headFeedToInsert;
				}
				//Create junction with Chain FeedItem Id and Headquartes FeedItem Ids
				List<FS_Feed_Item_Junction__c> lstFeedItemJunction = new List<FS_Feed_Item_Junction__c>();
				for(Id chainId : mapChainHeadquarterFeed.keySet()){
					for(FeedItem hFeeds :  mapChainHeadquarterFeed.get(chainId)){
						if(mapChainFeed.containsKey(chainId)){
						  lstFeedItemJunction.add(new FS_Feed_Item_Junction__c(FS_Chain_Feed_Item__c = mapChainFeed.get(chainId).Id , FS_Headquarter_Feed_Item__c = hFeeds.Id));
						}
					}
				}
				if(FSUtil.checkAccessForSobject('FS_Feed_Item_Junction__c',FSConstants.ACCESS_IS_CREATABLE)){
					//Insert Chain Headquarter FeedItem Junction Records
					insert lstFeedItemJunction;
				}
			}
		}
	}
	
	//Method called before feedItem Inserted
	public static void beforeDelete(){
	  deleteClondFeeds();
	}
	
	//Methos deletes Headquarter Feeds when same Feed is deleted on Chain
	private static void deleteClondFeeds(){
		set<String> setChainFeedIds = new set<String>();
		//Get Parent Id of Feed if it is insert from Account. Account Ids will always starts with 001 
		for(FeedItem fi : (List<FeedItem>) Trigger.oldMap.values()){
			if(String.valueOf(fi.ParentId).startsWith('001')){
				setChainFeedIds.add(fi.Id);
			}
		}
		if(setChainFeedIds.size() > 0 ){
			List<FS_Feed_Item_Junction__c> lstJunctionToDelete = new List<FS_Feed_Item_Junction__c>();
			List<FeedItem> lstHeadFeedToDelete = new List<FeedItem>();
			Set<String> headQtrFeedIds = new Set<String>();
			//Get Headquarter FeedItem Ids related to Chain Account FeedItems Ids
			for(FS_Feed_Item_Junction__c junction : [Select	FS_Headquarter_Feed_Item__c From FS_Feed_Item_Junction__c 
																							 Where FS_Chain_Feed_Item__c IN : setChainFeedIds]){
					headQtrFeedIds.add(junction.FS_Headquarter_Feed_Item__c);
					lstJunctionToDelete.add(junction);
			}
			//Get Headquarter FeedItems
			for(FeedItem hFeeds : [Select Id from FeedItem Where Id IN : headQtrFeedIds] ){																							
					lstHeadFeedToDelete.add(hFeeds);
			}
			if(FSUtil.checkAccessForSobject('FeedItem',FSConstants.ACCESS_IS_DELETABLE)){
				//Delete Headquarter FeedItems
				delete lstHeadFeedToDelete;
			}
			if(FSUtil.checkAccessForSobject('FS_Feed_Item_Junction__c', FSConstants.ACCESS_IS_DELETABLE)){
				//Delete Chain Headquarter FeedItem Junction Records
				delete lstJunctionToDelete;
			}
		}
	}
}