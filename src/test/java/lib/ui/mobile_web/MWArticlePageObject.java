package lib.ui.mobile_web;

import lib.ui.ArticlePageObject;
import org.openqa.selenium.remote.RemoteWebDriver;

public class MWArticlePageObject extends ArticlePageObject {
    public MWArticlePageObject(RemoteWebDriver driver)
    {
        super(driver);
    }

    static {
        ARTICLE_TITLE_ELEMENT = "css:#content h1";
        FOOTER_ELEMENT = "css:footer";
        ADD_TO_READING_LIST_BTN = "css:#page-actions li#ca-watch";
        REMOVE_FROM_FAVORITE_BUTTON="css:#page-actions li#ca-watch.mw-ui-icon-mf-watched watched button";

    }
}
