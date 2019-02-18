package lib.ui.iOS;

import io.appium.java_client.AppiumDriver;
import io.appium.java_client.ios.IOSDriver;
import lib.ui.NavigationUI;
import org.openqa.selenium.remote.RemoteWebDriver;

public class IOSNavigationUI extends NavigationUI {

    public IOSNavigationUI(RemoteWebDriver driver){
        super((AppiumDriver) driver);
    }

    static {
        MY_LISTS_BTN = "id:Saved";
    }
}
