public with sharing class FSRevenueCenterUtil {
  public static String lookupRevenueCenter(String marketID) {
    if(marketID.length() < 3) {return 'length is ' + marketID.length();}
    String first2Chars = marketID.substring(0,2);
    String first3Chars = marketID.substring(0,3);
    System.debug('********** first2Chars **********: ' + first2Chars);
    if(first2Chars == '15' || first2Chars == '25' || first2Chars == '85' || first2Chars == '95' ) {
      if(marketID.startsWith('253')) {        
        return 'Central Region - Independent Bottler';
      }
      else {
        return 'Central Region';
      }
    } else if (first2Chars == '16' ||  first2Chars == '26' || first2Chars == '86' || first2Chars == '96') {
      if(marketID.startsWith('263')) {
        return 'East Region - Independent Bottler';
      }
      else {
        return 'East Region';
      }
    } else if (first2Chars == '17' ||  first2Chars == '27' || first2Chars == '87' || first2Chars == '97') {
      if(marketID.startsWith('273')) {
        return 'West Region - Independent Bottler';
      }
      else {
        return 'West Region';
      }
    }  
    else if (first2Chars == '72') {
       return 'Warehouse Sales';
    }  
    else if (first2Chars == '77') {
       return '7-Eleven';
    }
    else if (first2Chars == '60' || first2Chars == '69') {
       return 'NFSOP Foodservice';
    }
    else if (first2Chars == '61') {
       return 'Burger King';
    }
    else if (first2Chars == '62') {
       return 'Subway';
    }
    else if (first2Chars == '63') {
       return 'Sonic';
    }
 
    else if (first2Chars == '66') {
       return 'Wendys';
    }
    
    else if (first2Chars == '68') {
       return 'National Distribution';
    }
    else if (first2Chars == '51') {
       return 'McDonalds';
    }
    else if (first3Chars == '711') {
       return 'Walmart/Sams';
    }
    else if (first3Chars == '712') {
       return 'Kroger';
    }
    else if (first3Chars == '713') {
       return 'Large Store Northern Market';
    }
    else if (first3Chars == '714') {
        if(marketID.startsWith('7141')){
           return 'Large Store East Dispensed'; //Updated in July 2017 based on the file from May 2015
        }else if(marketID.startsWith('7142')){
            return 'Publix';//Updated in July 2017 based on the file from May 2015
        }else{
           return 'Large Store East';
        }
    }
    else if (first3Chars == '715') {
        if(marketID.startsWith('7151')){
           return 'Large Store Central Dispensed'; //Updated in July 2017 based on the file from May 2015
        }else if(marketID.startsWith('7152')){
            return 'Target';//Updated in July 2017 based on the file from May 2015
        }else{
           return 'Large Store Central';
        }
    }
    else if (first3Chars == '716') {
        if(marketID.startsWith('7161')){
           return 'Large Store West Dispensed'; //Updated in July 2017 based on the file from May 2015
        }else if(marketID.startsWith('7162')){
            return 'Stater Bros';//Updated in July 2017 based on the file from May 2015
        }else if(marketID.startsWith('7163')){
            return 'Safeway';//Updated in July 2017 based on the file from May 2015
        }else{
            return 'Large Store West';
        }
    }
    else if (first3Chars == '717') {
        if(marketID.startsWith('7171')){
           return 'Convenience Retail East'; //Updated in July 2017 based on the file from May 2015
        }else if(marketID.startsWith('7172')){
            return 'Convenience Retail West';//Updated in July 2017 based on the file from May 2015
        }else if(marketID.startsWith('7173')){
            return 'Circle K';//Updated in July 2017 based on the file from May 2015
        }else if(marketID.startsWith('7174')){
            return 'Convenience Retail Central';//Updated in July 2017 based on the file from May 2015
        }else{
            return 'Convenience Retail';
        }
    }
    else if (first3Chars == '718') {
        if(marketID.startsWith('7181')){
            return 'Walgreens';//Updated in July 2017 based on the file from May 2015
        }else if(marketID.startsWith('7182')){
            return 'Drug Value Other';//Updated in July 2017 based on the file from May 2015
        }else{
            return 'Drug Value Channel';
        }
    }
    else if (first3Chars == '719') {
       return 'Specialty Retail & Emerging';
    }
    //Updated in July 2017 based on the file from May 2015
    else if (first3Chars == '141' || first3Chars == '841' || first3Chars == '941') {
       return 'NFSOP East Zone';
    }
    //Updated in July 2017 based on the file from May 2015
    else if (first3Chars == '142' || first3Chars == '842' || first3Chars == '942') {
       return 'NFSOP Central Zone';
    }
    //Updated in July 2017 based on the file from May 2015
    else if ( first3Chars == '143' || first3Chars == '843' || first3Chars == '943') {
       return 'NFSOP West Zone';
    }
    
    //Updated in July 2017 based on the file from May 2015
    else if(first2Chars=='64'){
        if(first3Chars == '641'){
            return 'NFSOP East Zone';
        }
        else if(first3Chars == '642'){
            return 'NFSOP Central Zone';
        }
        else if(first3Chars == '643'){
            return 'NFSOP West Zone';
        }
        return 'NFSOP Zones';
    }
    
    
    
    //Updated in July 2017 based on the file from May 2015
    else if (first2Chars == '65') {
        if (first3Chars == '651') {
            return 'SPM Airlines';
        }
        else if (first3Chars == '652') {
            return 'SPM Strategic Alliances';
        }
       return 'Strategic Partnership Marketing (SPM)';
    }
    
    
    else if (first2Chars == '67') {
        if (first3Chars == '671') {
            if(marketID.startsWith('6712')){
                return 'Compass';//Updated in July 2017 based on the file from May 2015
            }else if(marketID.startsWith('6713')){
                return 'Aramark';//Updated in July 2017 based on the file from May 2015
            }else{
                return 'Onsite - Daly';
            }
        }
        else if (first3Chars == '672') {
            if(marketID.startsWith('6721')){
                return 'Sodexo';//Updated in July 2017 based on the file from May 2015
            }else if(marketID.startsWith('6722')){
                return 'HMS Host';//Updated in July 2017 based on the file from May 2015
            }else if(marketID.startsWith('6723')){
                return 'Healthcare';//Updated in July 2017 based on the file from May 2015
            }else{
                return 'Onsite - Taylor';
            }
        }
        else if (first3Chars == '673') {
            if(marketID.startsWith('6732')){
                return 'NSR Central and West';//Updated in July 2017 based on the file from May 2015
            }else if(marketID.startsWith('6733')){
                return 'NSR East';//Updated in July 2017 based on the file from May 2015
            }else if(marketID.startsWith('6734')){
                return 'Home Depot';//Updated in July 2017 based on the file from May 2015
            }else{
                 return 'Onsite - NSR';
            }
        }
        
      return 'Onsite & NSR';
    }
    
    else if (marketID.startsWith('9001')) {
      return 'Military Account Group';
    }
    else if (marketID.startsWith('12')) {
      return 'Regions Sales';
    }
    else {
      return 'no match';
    }
  
  }
}