package lib.ui.android;

import io.appium.java_client.AppiumDriver;
import lib.ui.MyListsPageObject;

public class AndroidMyListsPageObject extends MyListsPageObject {
    public AndroidMyListsPageObject(AppiumDriver driver)
    {
        super(driver);
    }

    static {
        FOLDER_BY_NAME_TPL = "xpath://*[@text='Learning programming']";
        ARTICLE_BY_TITLE_TPL = "xpath://*[@text ='{TITLE}']";
        ARTICLE_TITLE = "xpath://*[@resource-id='org.wikipedia:id/page_list_item_title' and @index='0']";
    }
}
