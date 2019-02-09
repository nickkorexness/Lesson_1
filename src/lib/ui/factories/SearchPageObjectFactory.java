package lib.ui.factories;

import io.appium.java_client.AppiumDriver;
import lib.ui.SearchPageObject;
import lib.Platform;
import lib.ui.android.AndroidSearchPageObject;
import lib.ui.iOS.IOSSearchPageObject;

public class SearchPageObjectFactory   {

    public static SearchPageObject get(AppiumDriver driver)
    {
        if (Platform.getInstance().isAndroid()){
            return new AndroidSearchPageObject(driver);
        }else {
            return new IOSSearchPageObject(driver);
        }
    }
}
