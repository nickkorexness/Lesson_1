package lib.ui.factories;

import io.appium.java_client.AppiumDriver;
import lib.Platform;
import lib.ui.MyListsPageObject;
import lib.ui.android.AndroidMyListsPageObject;
import lib.ui.iOS.IOSMyListsPageObject;
import lib.ui.iOS.IOSSearchPageObject;
import lib.ui.mobile_web.MWMylistsPageObject;
import lib.ui.mobile_web.MWSearchPageObject;
import org.openqa.selenium.remote.RemoteWebDriver;

public class MyListsPageObjectFactory {

    public static MyListsPageObject get(RemoteWebDriver driver)
    {
        if (Platform.getInstance().isAndroid()){
            return new AndroidMyListsPageObject(driver);
        }else if (Platform.getInstance().isIOS()){
            return new IOSMyListsPageObject(driver);
        }else {
            return new MWMylistsPageObject(driver);
        }
    }
}
