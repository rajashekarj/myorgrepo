/**************************************************************************************
Apex Class Name     : FSPaginationCustomIterable
Version             : 1.0
Function            : Pagination for FSCustomerInputForm, FSCustomerInputFormEdit VFs 
Modification Log    :
* Developer         : Deepak Jetty   
* Date              : 14th Feb 2017               
*************************************************************************************/

public class FSPaginationCustomIterable implements Iterator<list<WrpOutlet>>{
    private static final Integer ZERO=0;
    list<WrpOutlet> InnerList{get; set;}
    list<WrpOutlet> ListRequested{get; set;}
    private Integer numb {get; set;}
    public Integer setPageSize {get; set;}
    public Integer setStartNumber {get; set;}
    public Integer seti2 {get; set;}
    public integer PageNumber {get;set;}
    public integer RecordCount {get;set;}
    
    public FSPaginationCustomIterable(List<WrpOutlet> lstOutlet){
        InnerList = new list<WrpOutlet>(); 
        ListRequested = new list<WrpOutlet>();     
        InnerList = lstOutlet;
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
            final integer iUNum = LNumber + setPageSize - 1;
            return (iUnum > RecordCount) ? RecordCount : iUNum; 
        }
    }
    
    private integer getPageCount() {
        integer iPageCount = 1;
        
        if (RecordCount != 0 && setPageSize != 0) {
            iPageCount = (RecordCount/setPageSize) + ((Math.mod(RecordCount, setPageSize)) > 0 ? 1 : 0);
        }
        return iPageCount;
    }
    
    public list<WrpOutlet> first(){       
        ListRequested = new list<WrpOutlet>(); 
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
    
    public list<WrpOutlet> last(){      
        ListRequested = new list<WrpOutlet>(); 
        integer startNumber;
        final integer size = InnerList.size();
        if(hasNext()){
          numb = size;
            if(math.mod(size, setPageSize) > ZERO){    
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
    
    public list<WrpOutlet> goToPage(Integer setPN, Integer setI){    
        ListRequested = new list<WrpOutlet>();
        integer startNumber;
        if(hasNext()||hasPrevious()){
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
    
    public list<WrpOutlet> next(){
        ListRequested = new list<WrpOutlet>(); 
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
    
    public list<WrpOutlet> previous(){      
        ListRequested = new list<WrpOutlet>(); 
        final integer size = InnerList.size(); 
        if(numb == size){
            if(math.mod(size, setPageSize) > ZERO){    
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
        for(integer start = numb - setPageSize; start < numb; ++start){
            ListRequested.add(InnerList[start]);
        } 
        return ListRequested;
    } 
}