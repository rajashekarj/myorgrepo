/***************************************************************************
 Name         : FSRowIterator
 Created By   : Infosys Limited
 Description  : Class to Iterate over the excel file used for fileupload functionality on flavor change and dispenser updates
 Created Date : 15-FEB-2017
****************************************************************************/
public with sharing class FSRowIterator implements Iterator<String>, Iterable<String>{
   private String mData;
   private String mName;
   private Integer mindex = 0;
   private String mrowDelimiter = '\n';
   
    
   public FSRowIterator (final String fileData,final String fileName){
      mData = fileData; 
      mName = fileName;
   }
   
    
   public Boolean hasNext(){
      return mindex < mData.length() ? true : false;
   }
   
   public String next(){     
      Integer key = mData.indexOf(mrowDelimiter, mindex);
      
       if (key == -1){
          key = mData.length(); 
       }        
      
      final String row = mData.subString(mindex, key)+ ',' +mName;
      
      mindex = key + 1;
      
      return row;
   }
   
   public Iterator<String> iterator(){
      return this;   
   }
}