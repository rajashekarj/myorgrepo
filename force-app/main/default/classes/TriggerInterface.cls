/*
* Purpose:
* Trigger Framework base interface to support adding common logic to any Trigger
* developed using this Framework. This Framework turns trigger logic into re-usable
* class, adds "state" support to know the context in which the trigger is executing,
* and makes the standard Trigger variables available without littering the business logic.
*/
global virtual interface TriggerInterface{
    sObjectType getObjectType();
    void MainEntry();
}