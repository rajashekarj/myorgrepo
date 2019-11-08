public class DeferredHandler implements System.Queueable
{
    private Map<Id,String> key2val;
    public DeferredHandler(Map<Id,String> key2val) {
        this.key2val = key2val;
    }
    public void execute(System.QueueableContext objContext)
    {
        FSFETNMSConnector.airWatchAsynchronousCall(NULL,key2val);
    }
}