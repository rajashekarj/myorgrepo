/**************************************************************************************
Apex Class Name     : FSPaginationCustomIterable
Version             : 1.0
Function            : Pagination for FSHomePageAlerts VFs 
Modification Log    :
* Developer         : Vinay
* Date              : 14th Feb 2017               
*************************************************************************************/

public class FSPaginationCustomIterableAlerts implements Iterator<list<Task>> {
    public Integer valZero = 0;
    list<Task> InnerList{get; set;}
    list<Task> ListRequested{get; set;}
	@testVisible
    Integer numb {get; set;} 
    public Integer setPageSize {get; set;}
    public Integer setStartNumber {get; set;}
    public Integer seti2 {get; set;}
    public integer PageNumber {get;set;}
    public integer RecordCount {get;set;}
    
    public FSPaginationCustomIterableAlerts(final List<Task> lstTask){
        InnerList = new list<Task>(); 
        ListRequested = new list<Task>();     
        InnerList = lstTask;
        setPageSize = 10;
        RecordCount=InnerList.size();
        numb = 0;
        PageNumber = 0;
    }
    
    public boolean hasNext(){ 
        boolean isNxt;
        if(numb >= InnerList.size()) {
            isNxt = false; 
        } else {
           isNxt = true; 
        }
        return isNxt;
    }
    
    public boolean hasPrevious(){ 
        boolean isPrev;
        if(numb <= setPageSize) {
           isPrev = false; 
        } else {
           isPrev = true; 
        }
        return isPrev;
    }
    public integer PageIndex {
        get { return PageNumber - 1; }
    }
    public integer PageCount {
        get { return getPageCount(); }
    }
    public integer Offset {
        get { return setPageSize * PageIndex; }
    }
    
    public integer LNumber {
        get { return RecordCount == 0 ? 0 : (Offset + 1); }
    }
    public integer UNumber {
        get { 
            final integer iUNum = (LNumber + setPageSize) - 1;
            return (iUnum > RecordCount) ? RecordCount : iUNum; 
        }
    }
    @TestVisible
    private integer getPageCount() {
        integer iPageCount = 1;
        
        if (RecordCount != 0 && setPageSize != 0) {
            iPageCount = (RecordCount/setPageSize) + ((Math.mod(RecordCount, setPageSize)) > 0 ? 1 : 0);
        }
        return iPageCount;
    }
    public list<Task> first(){       
        ListRequested = new list<Task>(); 
        integer startNumber;
        if(hasPrevious()){  
            numb = setPageSize;
            startNumber = 0;
            setStartNumber = startNumber;
            seti2 = numb;                     
            for(integer start = startNumber; start < numb; start++)
            {
                ListRequested.add(InnerList[start]);
            }
        } 
        return ListRequested;
    }
    
    public list<Task> last(){       
        ListRequested = new list<Task>(); 
        integer startNumber;
        final integer size = InnerList.size();
        if(hasNext()){
        	numb = size;
            if(math.mod(size, setPageSize) > valZero){    
                startNumber = size - math.mod(size, setPageSize);
            }else{
                startNumber = size - setPageSize;
            }
            setStartNumber = startNumber;
            seti2 = numb; 
            for(integer start = startNumber; start < numb; start++)
            {
                ListRequested.add(InnerList[start]);
            }
        } 
        return ListRequested;
    }
    
    public list<Task> goToPage(final Integer setPN,final Integer setI){       
        ListRequested = new list<Task>();
        integer startNumber;
        if(hasNext()){
		    startNumber = setPN;
		    numb = setI;
	        setStartNumber = startNumber;
	        seti2 = numb; 
	        for(integer start = startNumber; start < numb; start++){
	            ListRequested.add(InnerList[start]);
	        }
        }
        return ListRequested;
    }
    
    public list<Task> next(){
        ListRequested = new list<Task>(); 
        integer startNumber;
        final integer size = InnerList.size();
        if(hasNext()){  
            if(size <= (numb + setPageSize))
            {
                startNumber = numb;
                numb = size;
            }else{
                numb = numb + setPageSize;
                startNumber = numb - setPageSize;
            }
            setStartNumber = startNumber;
            seti2 = numb;
            for(integer start = startNumber; start < numb; start++){
                ListRequested.add(InnerList[start]);
            }
        } 
        return ListRequested;
    }
    
    public list<Task> previous(){      
        ListRequested = new list<Task>(); 
        final integer size = InnerList.size(); 
        
        if(numb == size){
            if(math.mod(size, setPageSize) > valZero){    
                numb = size - math.mod(size, setPageSize);
            }else{
                numb = size - setPageSize;
            } 
        }
        else{
            numb = numb - setPageSize;
        }
        setStartNumber = numb - setPageSize;
        seti2 = numb;
        for(integer start = numb - setPageSize;start < numb; ++start){
            ListRequested.add(InnerList[start]);
        } 
        return ListRequested;
    } 
}