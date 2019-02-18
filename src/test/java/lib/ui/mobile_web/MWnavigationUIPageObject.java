package lib.ui.mobile_web;

import lib.ui.NavigationUI;
import org.openqa.selenium.remote.RemoteWebDriver;

public class MWnavigationUIPageObject extends NavigationUI {


    public MWnavigationUIPageObject(RemoteWebDriver driver)
    {
        super(driver);
    }

    static {

    MY_LISTS_BTN = "css:a[data-event-name='watchlist']";
    OPEN_NAVIGATION = "css:#mw-mf-main-menu-button";

    }

}

