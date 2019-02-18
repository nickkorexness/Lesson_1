package lib.ui.iOS;

import io.appium.java_client.AppiumDriver;
import lib.ui.ArticlePageObject;
import org.openqa.selenium.remote.RemoteWebDriver;

public class IOSArticlePageObject extends ArticlePageObject {
    public IOSArticlePageObject(RemoteWebDriver driver)
    {
        super(driver);
    }

    static {
        ARTICLE_TITLE_ELEMENT = "id:Java (programming language)";
        FOOTER_ELEMENT = "id:View article in browser";
        ADD_TO_READING_LIST_BTN = "//XCUIElementTypeButton[@name='Save for later']";
        GOT_IT_BTN = "";
        OK_BTN = "";
        MY_LIST_INPUT = "";
        ARTICLE_CLOSE_BTN = "id:Back";
        MYLIST_FOLDER_ELEMENT = "";
    }
}
