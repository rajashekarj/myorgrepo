public with sharing class UnitTestUtil {

	private static UnitTestUtil oUnitTestUtil;

    public boolean IsUnitTesting {get;set;}

    private UnitTestUtil() {
        IsUnitTesting = true;
    }

    public static UnitTestUtil getInstance() {
        if (oUnitTestUtil == null) {
            oUnitTestUtil = new UnitTestUtil();
        }

        return oUnitTestUtil;
    }

}