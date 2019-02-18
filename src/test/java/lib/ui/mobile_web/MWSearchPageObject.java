package lib.ui.mobile_web;

import lib.ui.SearchPageObject;
import org.junit.Test;
import org.openqa.selenium.remote.RemoteWebDriver;

public class MWSearchPageObject extends SearchPageObject {

    static {
        SEARCH_INIT_ELEMENT = "css:button#searchIcon";
        SEARCH_INPUT = "css:form>input[type='search']";
        SEARCH_CANCEL_BTN = "css:button.cancel";
        SEARCH_RESULT_BY_SUBSTRING_TPL = "xpath://div[contains(@class,'wikidata-description')][contains(text(),'{SUBSTRING}')]";
        NO_RESULT_LABEL = "css:p.without-results";
        SEARCH_RESULT_ELEMENT = "css:ul.page-list>li.page-summary";
        SEARCH_RESULT_ARTICLE_ELEMENT_0 = "";
        SEARCH_RESULT_ARTICLE_ELEMENT_1 = "";
        SEARCH_RESULT_ARTICLE_ELEMENT_TPL = "";
        SEARCH_ITEM_TITLE = "";
        SEARCH_RESULT_ARTICLE_ELEMENT_WITH_TEXT = "";
    }

    public MWSearchPageObject(RemoteWebDriver driver)
    {
        super(driver);
    }


}
