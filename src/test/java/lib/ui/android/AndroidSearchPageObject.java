package lib.ui.android;

import io.appium.java_client.AppiumDriver;
import lib.ui.SearchPageObject;
import org.openqa.selenium.remote.RemoteWebDriver;


public class AndroidSearchPageObject extends SearchPageObject {

     static {
                 SEARCH_INIT_ELEMENT = "xpath://*[contains(@text,'Search Wikipedia')]";
                 SEARCH_INPUT = "xpath://*[contains(@text,'Search…')]";
                 SEARCH_CANCEL_BTN = "id:org.wikipedia:id/search_close_btn";
                 SEARCH_RESULT_BY_SUBSTRING_TPL = "xpath://*[@resource-id='org.wikipedia:id/page_list_item_container']//*[contains(text,'{SUBSTRING}']";
                 NO_RESULT_LABEL = "xpath://*[contains(@text,'No results found')]";
                 SEARCH_RESULT_ELEMENT = "xpath://*[@resource-id='org.wikipedia:id/search_results_list']//*[@resource-id='org.wikipedia:id/page_list_item_container']";
                 SEARCH_RESULT_ARTICLE_ELEMENT_0 = "xpath://*[@class='android.widget.LinearLayout' and @index='0']";
                 SEARCH_RESULT_ARTICLE_ELEMENT_1 = "xpath://*[@class='android.widget.LinearLayout' and @index='2']";
                 SEARCH_RESULT_ARTICLE_ELEMENT_TPL = "xpath://*[@class='android.widget.LinearLayout' and @index='{INDEX}']";
                 SEARCH_ITEM_TITLE = "id:org.wikipedia:id/page_list_item_title";
                 SEARCH_RESULT_ARTICLE_ELEMENT_WITH_TEXT = "xpath://*[@class='android.widget.LinearLayout']//*[@text='{TEXT}']";
     }

    public AndroidSearchPageObject(RemoteWebDriver driver)
    {
        super(driver);
    }
}
