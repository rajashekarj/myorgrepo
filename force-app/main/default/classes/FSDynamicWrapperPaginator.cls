/*********************************************************************************************************
Name         : FSDynamicWrapperPaginator
Created By   : Infosys Limited 
Created Date : 4-April-2017
Usage        : DynamicWrapperPaginator to paginate all kinds of record collection

***********************************************************************************************************/
public virtual class FSDynamicWrapperPaginator{
  
  private Integer index=0;  //keeps track of the offset
  public Integer pageNum=1; //sets the page size or number of rows
  public Integer totalResults; //used to show user the total size of the list
  public static final Integer ZERO=0;
  public List<Object> wrapperCollection{get;set;}
  /*****************************************************************
  Method: FSDynamicWrapperPaginator
  Description: Constructor
  *******************************************************************/
  public FSDynamicWrapperPaginator(List<Object> wrapperCollection){
    this.wrapperCollection=wrapperCollection;
    totalResults=wrapperCollection.size();
  }
  /*****************************************************************
  Method: populateResults
  Description: Populating the values to return the collection
  *******************************************************************/ 
  public List<Object> populateResults(){
    List<Object> objectCollection= new List<Object>();
    
    Integer upperLimit=pageNum+index;
    for(Integer i=index ; i< upperLimit;i++){
        if(i < totalResults){
          objectCollection.add(wrapperCollection.get(i));
        }
        else{
          break;
        }
    }
    return objectCollection;
  }
  /*****************************************************************
  Method: First
  Description: Takes the user to the first page of the collection
  *******************************************************************/ 
  public PageReference First() { 
      index = 0;
      return null;
  }
  /*****************************************************************
  Method: Previous
  Description: Takes the user to the Previous page of the collection
  *******************************************************************/        
  public PageReference Previous() {
      index -= pageNum;
      if(index <ZERO){
          index =0;
      }
      
      return null;
  }
 /*****************************************************************
  Method: Next
  Description: Takes the user to the Next page of the collection
  *******************************************************************/        
   public PageReference Next() { 
      index += pageNum;
      return null;
      
   }
  /*****************************************************************
  Method: Last
  Description: Takes the user to the Last page of the collection
  *******************************************************************/         
   public PageReference Last() { 
     if(math.mod(totalResults, pageNum) > ZERO) {
       index = totalResults - math.mod(totalResults, pageNum);
     }
     else{
      index = totalResults - math.mod(totalResults, pageNum)-1;
     }
     return null;
   }
  /*****************************************************************
  Method: getDisablePrevious
  Description: this will disable the previous and first buttons
  *******************************************************************/           
   public Boolean getDisablePrevious() { 
      if (index>ZERO){
      	return false;
      }          
      else {
      	return true;
      }         
   }
  /*****************************************************************
  Method: getDisableNext
  Description: this will disable the next and Last buttons
  *******************************************************************/          
   public Boolean getDisableNext() {
      if (index + pageNum < totalResults) {
      	return false; 
      }         
      else{
      	 return true;
      } 
        
   }
  /*****************************************************************
  Method: getTotalResultsize
  Description: This returns the total result size
  *******************************************************************/          
   public Integer getTotalResultsize() {
      return totalResults;
   }
  /*****************************************************************
  Method: getPageNumber
  Description: This returns the page Number
  *******************************************************************/           
   public Integer getPageNumber() {
      if(totalResults==ZERO){
          return 0;
      }
      return index/pageNum + 1;
   }
  /*****************************************************************
  Method: getTotalPages
  Description: This returns the total pages count
  *******************************************************************/          
   public Integer getTotalPages() {
      if (math.mod(totalResults, pageNum) > ZERO) {
         return totalResults/pageNum + 1;
      } else {
         return totalResults/pageNum;
      }
   }
   
}