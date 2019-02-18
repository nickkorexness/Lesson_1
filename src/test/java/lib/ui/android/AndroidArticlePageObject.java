package lib.ui.android;

import io.appium.java_client.AppiumDriver;
import lib.ui.ArticlePageObject;
import org.openqa.selenium.remote.RemoteWebDriver;

public class AndroidArticlePageObject extends ArticlePageObject {
    public AndroidArticlePageObject(RemoteWebDriver driver)
    {
        super(driver);
    }

     static {
                 ARTICLE_TITLE_ELEMENT = "id:org.wikipedia:id/view_page_title_text";
                 FOOTER_ELEMENT = "xpath://*[@text='View page in browser']";
                 MORE_OPTIONS_BTN = "xpath://android.widget.ImageView[@content-desc='More options']";
                 ADD_TO_READING_LIST_BTN = "xpath://*[@text ='Add to reading list']";
                 GOT_IT_BTN = "id:org.wikipedia:id/onboarding_button";
                 OK_BTN = "xpath://*[@text ='OK']";
                 MY_LIST_INPUT = "id:org.wikipedia:id/text_input";
                 ARTICLE_CLOSE_BTN = "xpath://android.widget.ImageButton[@content-desc='Navigate up']";
                 MYLIST_FOLDER_ELEMENT = "xpath://*[@resource-id='org.wikipedia:id/item_container' and @index='0']";
     }
}
