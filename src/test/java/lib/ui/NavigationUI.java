package lib.ui;

import io.appium.java_client.AppiumDriver;
import lib.Platform;
import org.openqa.selenium.By;
import org.openqa.selenium.remote.RemoteWebDriver;

abstract public class NavigationUI extends MainPageObject {

    protected static  String
    MY_LISTS_BTN ,
    OPEN_NAVIGATION;


    public NavigationUI (RemoteWebDriver driver)
    {
        super(driver);
    }

    public void openNavigation(){
        if (Platform.getInstance().isMobileWeb()){
            this.waitForElementAndClick(OPEN_NAVIGATION,"cant click on navigation button",5);
        }else System.out.println("method not for this platform");
    }

    public void clickMyLists()
    {
        if (Platform.getInstance().isMobileWeb()){
            this.tryClickWithFewAttempts(MY_LISTS_BTN,"cant click on my lists button",10);
        }
        this.waitForElementPresent(MY_LISTS_BTN,
                "Cant open 'my lists' screen ",
                15);
        this.waitForElementAndClick(
                MY_LISTS_BTN,
                "Cant open 'my lists' screen ",
                15
        );
    }
}
