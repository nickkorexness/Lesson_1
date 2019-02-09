package lib.ui.iOS;

import io.appium.java_client.AppiumDriver;
import io.appium.java_client.ios.IOSDriver;
import lib.ui.NavigationUI;

public class IOSNavigationUI extends NavigationUI {

    public IOSNavigationUI(AppiumDriver driver){
        super(driver);
    }

    static {
        MY_LISTS_BTN = "id:Saved";
    }
}
