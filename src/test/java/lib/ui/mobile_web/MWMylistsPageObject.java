package lib.ui.mobile_web;

import io.appium.java_client.AppiumDriver;
import lib.ui.MyListsPageObject;
import org.openqa.selenium.remote.RemoteWebDriver;

public class MWMylistsPageObject extends MyListsPageObject {
    public MWMylistsPageObject(RemoteWebDriver driver)
    {
        super((AppiumDriver) driver);
    }

    static {
        ARTICLE_BY_TITLE_TPL = "xpath://ul[contains(@class,'watchlist']//h3[contains(text(),'{TITLE}')]";
        REMOVE_FROM_SAVED_BUTTON = "xpath://ul[contains(@class,'watchlist')]//h3[contains(text(),'{TITLE}')]//../../div[contains(@class,'watched')]";
        NOT_DELETED_ARTICLE = "xpath://a[href='/wiki/Cyprus']";
    }




}
