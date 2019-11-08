/***************************************************************************
 Name         : FSRecordSplitterToAvoidGovernorLimits
 Created By   : FET Operational Capacity Support
 Description  : Class has methods to split records in context to smaller Chunks
 Created Date : Oct 3, 2016
****************************************************************************/
public class FSRecordSplitterToAvoidGovernorLimits{

 /**@desc Split list into as many list as the result of this ((numberOfRecords/ChunkSize))
  *@param List<Object> $listOfRecordsToSplit- list that is to be split into parts(numberOfRecords/ChunkSize)
  *       Integer chunkSize --maximum number of records in each list after split
  *@return List<List<Object>>
  */

  
  public static List<List<Object>> processRecords(final List<Object> listOfRecordsToSplit,final Integer chunkSize){
  
     //Collection variable to hold the list of smaller chunks
     List<List<Object>> splitList =new List<List<Object>>();
     
     //Number of records in the list to be split/processed
     Decimal numberOfRecordsInCOntext=0;
     
     if(!listOfRecordsToSplit.isEmpty()){
        numberOfRecordsInCOntext=listOfRecordsToSplit.size();
        
        //Number of times the future method to be called --> This would be equivalent to the returned list size after split
    final Decimal preciseValue=numberOfRecordsInCOntext.divide(chunkSize,2);
    final Integer absoluteValue=Integer.valueOf(preciseValue);
        final Integer frequencyOfMethodCall= preciseValue > absoluteValue ? (absoluteValue+1): absoluteValue;
        
        splitList=returnSplitList(listOfRecordsToSplit,Integer.valueOf(numberOfRecordsInCOntext),frequencyOfMethodCall,chunkSize);
        
     } 
     
      return splitList;
  }
  
  /**@desc Split list into as many list as the result of this ((numberOfRecords/ChunkSize))
  *@param List<Object> $listOfRecordsToSplit- list that is to be split into parts(numberOfRecords/ChunkSize)
  *       Integer numberOfRecordsInCOntext --size of list to be split
  *       Integer frequencyOfMethodCall -- maximum number of split list
  *       Integer chunkSize --maximum number of records in each list after split
  *@return List<List<Object>>
  */
  public static List<List<Object>> returnSplitList(final List<Object> listOfRecordsToSplit,final Integer numberOfRecordsInCOntext,final Integer frequencyOfMethodCall,final Integer chunkSize){
    
    //Collection variable to hold the list of smaller chunks
   final List<List<Object>> returnList=new List<List<Object>>();
    
    //Number of list with smaller chunks
    Integer numberOfList= 0;
    
    // Number of records to be put in the smaller chunks list in each iteration
    Integer chunkLimit=0;
    
    while (numberOfList < frequencyOfMethodCall){
       final Integer counter = numberOfRecordsInCOntext - chunkLimit> chunkSize ? chunkSize : numberOfRecordsInCOntext - chunkLimit;
        
       final List<Object> tempList=new List<Object>();
        
        for(Integer i=chunkLimit;i<(counter +chunkLimit);i++){
          tempList.add(listOfRecordsToSplit.get(i));
        }
        
        returnList.add(tempList);
        chunkLimit+= chunkSize;
        numberOfList++;
    }    
    return returnList;
  }
  
  /**@desc Split Map into as many Map as the result of this ((numberOfRecords/ChunkSize))
  *@param Map<Object,Object> $mapOfRecordsToSplit- Map that is to be split into parts(numberOfRecords/ChunkSize)
  *       Integer chunkSize --maximum number of records in each Map after split
  *@return List<Map<Object,Object>>
  */
  public static List<Map<Object,Object>> processRecords(final Map<Object,Object> mapOfRecordsToSplit,final Integer chunkSize){
  
     //Collection variable to hold the list of smaller chunks
     List<Map<Object,Object>> splitMap =new List<Map<Object,Object>>();
     
     //Number of records in the list to be split/processed
     Decimal numberOfRecordsInCOntext=0;
     
     if(!mapOfRecordsToSplit.isEmpty()){
        numberOfRecordsInCOntext=mapOfRecordsToSplit.size();
        
        //Number of times the future method to be called --> This would be equivalent to the returned list size after split
       final Decimal  preciseValue=numberOfRecordsInCOntext.divide(chunkSize,2);
       final Integer absoluteValue=Integer.valueOf(preciseValue);
       final Integer frequencyOfMethodCall= preciseValue > absoluteValue ? (absoluteValue+1): absoluteValue;
        
        splitMap =returnSplitMap(mapOfRecordsToSplit,Integer.valueOf(numberOfRecordsInCOntext),frequencyOfMethodCall,chunkSize);
        
     } 
     
      return splitMap ;
  }
  
  
  /**@desc Split Map into as many Map as the result of this ((numberOfRecords/ChunkSize))
  *@param Map<Object,Object> $mapOfRecordsToSplit- Map that is to be split into parts(numberOfRecords/ChunkSize)
  *       Integer numberOfRecordsInCOntext --size of Map to be split
  *       Integer frequencyOfMethodCall -- maximum number of split Map
  *       Integer chunkSize --maximum number of records in each Map after split
  *@return List<Map<Object,Object>>
  */
  public static List<Map<Object,Object>> returnSplitMap(final Map<Object,Object> mapOfRecordsToSplit,final Integer numberOfRecordsInCOntext,final Integer frequencyOfMethodCall,final Integer chunkSize){
    
    //Collection variable to hold the Map of smaller chunks
    final List<Map<Object,Object>> returnMap=new List<Map<Object,Object>>();
    
    //Number of Map with smaller chunks
    Integer numberOfMap= 0;
    
    // Number of records to be put in the smaller chunks Map in each iteration
    Integer chunkLimit=0;
    
    while (numberOfMap < frequencyOfMethodCall){
        final Integer counter = numberOfRecordsInCOntext - chunkLimit> chunkSize ? chunkSize : numberOfRecordsInCOntext - chunkLimit;
        
        final Map<Object,Object> tempMap=new Map<Object,Object>();
        //type cast map keys from set of object to list of object
       final List<Object> listOfkeys=new List<Object>(mapOfRecordsToSplit.keySet()); 
        
        for(Integer i=chunkLimit;i<(counter +chunkLimit);i++){
          tempMap.put(listOfkeys.get(i),mapOfRecordsToSplit.get(listOfkeys.get(i)));
        }
        
        returnMap.add(tempMap);
        chunkLimit+= chunkSize;
        numberOfMap++;
    }    
    return returnMap;
  }
  
}