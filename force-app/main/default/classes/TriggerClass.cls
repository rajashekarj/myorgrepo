/*
* Purpose:
* Trigger Framework base class to support adding common logic to any Trigger developed
* using this Framework. This Framework turns trigger logic into re-usable class,
* adds "state"support to know the context in which the trigger is executing,
* and makes the standard Trigger variables available without littering the business logic.
*/
global virtual class TriggerClass implements TriggerInterface{
    public static Boolean AsyncRequested = false;
    public static Boolean IsBatch = false;
    public static Boolean IsScheduled = false;
    public static Boolean IsFuture = false;
    public static sObject obj;
    public static TriggerInterface trigIface { get; set; }
    public Boolean IsBefore;
    public Boolean IsDelete;
    public Boolean IsAfter;
    public Boolean IsInsert;
    public Boolean IsUpdate;
    public Boolean IsExecuting;
    public List<sObject> newList;
    public Map<ID,sObject> newMap;
    public List<sObject> oldList;
    public Map<ID,sObject> oldMap;
    
    public TriggerClass(){
    
    }
    
    public TriggerClass(Boolean IsBefore, Boolean IsDelete, Boolean IsAfter, Boolean IsInsert,
    Boolean IsUpdate, Boolean IsExecuting, List<sObject> newList,
    Map<ID,sObject> newmap, List<sObject> oldList,
    Map<ID,sObject> oldMap){
        this.IsBefore = IsBefore;
        this.IsDelete = IsDelete;
        this.IsAfter = IsAfter;
        this.IsInsert = IsInsert;
        this.IsUpdate = IsUpdate;
        this.IsExecuting = IsExecuting;
        this.newList = newList;
        this.newMap = newmap;
        this.oldList = oldList;
        this.oldMap = oldMap;
    }
    
    public TriggerClass(sObject o, Boolean IsBefore, Boolean IsDelete, Boolean IsAfter,
    Boolean IsInsert, Boolean IsUpdate, Boolean IsExecuting,
    List<sObject> newList, Map<ID,sObject> newmap, List<sObject>
    oldList, Map<ID,sObject> oldMap){
        this(IsBefore, IsDelete, IsAfter, IsInsert, IsUpdate, IsExecuting,
        newList, newmap, oldList, oldMap);
        obj = o;
    }
    
    public virtual sObjectType getObjectType(){
    return obj.getSObjectType();
    }
    
    public virtual void MainEntry(){
    if (System.isBatch())
    IsBatch = true;
    if (System.isFuture())
    IsFuture = true;
    if (System.isScheduled())
    IsScheduled = true;
    }
} // end of class