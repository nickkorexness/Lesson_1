package lib.ui;

import io.appium.java_client.AppiumDriver;
import org.openqa.selenium.By;

public class SearchPageObject extends MainPageObject {

    private static final String
        SEARCH_INIT_ELEMENT = "//*[contains(@text,'Search Wikipedia')]",
        SEARCH_INPUT = "//*[contains(@text,'Search…')]",
        SEARCH_CANCEL_BTN = "org.wikipedia:id/search_close_btn",
        SEARCH_RESULT_BY_SUBSTRING_TPL = "//*[@resource-id='org.wikipedia:id/page_list_item_container']//*[@text='{SUBSTRING}']",
        NO_RESULT_LABEL = "//*[contains(@text,'No results found')]",
        SEARCH_RESULT_ELEMENT = "//*[@resource-id='org.wikipedia:id/search_results_list']//*[@resource-id='org.wikipedia:id/page_list_item_container']",
        SEARCH_RESULT_ARTICLE_ELEMENT_0 = "//*[@class='android.widget.LinearLayout' and @index='0']",
        SEARCH_RESULT_ARTICLE_ELEMENT_1 = "//*[@class='android.widget.LinearLayout' and @index='2']";


    /* template methods*/

    private static String getResultSearchElement(String substring)
    {
        return SEARCH_RESULT_BY_SUBSTRING_TPL.replace("{SUBSTRING}", substring);
    }


    /* template methods*/



    public SearchPageObject(AppiumDriver driver)
    {
        super(driver);
    }

    public void initSearchInput()
    {
        this.waitForElementAndClick(By.xpath(SEARCH_INIT_ELEMENT), "Can't find and click on search init element", 5);
        this.waitForElementPresent(By.xpath(SEARCH_INPUT),"Can't find search input after clicking on search ini element",5);
    }

    public void typeSearchLine(String search_line)
    {
        this.waitForElementAndSendKeys(By.xpath(SEARCH_INPUT),search_line,"Ca", 15);
    }

    public void waitForSearchResult(String substring)
    {
        String search_result_xpath = getResultSearchElement(substring);
        this.waitForElementPresent(By.xpath(search_result_xpath),"can't find search result with substring "+ substring);
    }

    public void clickByArticleWithSubstring(String substring)
    {
        String search_result_xpath = getResultSearchElement(substring);
        this.waitForElementAndClick(By.xpath(search_result_xpath),"can't find and click search result with substring "+ substring, 25);
    }

    public void waitForCancelButtonToAppear()
    {
        this.waitForElementPresent(By.id(SEARCH_CANCEL_BTN),"Can't find search cancel btn",5);
    }

    public void waitForCancelButtonToDisappear()
    {
        this.waitForElementNotPresent(By.id(SEARCH_CANCEL_BTN),"Can't find search cancel btn",5);
    }

    public void clickCancelSearch()
    {
        this.waitForElementAndClick(By.id(SEARCH_CANCEL_BTN),"Can't click on cancel btn", 5);

    }

    public int getAmountOfFoundArticles()
    {

        this.waitForElementPresent(
                By.xpath(SEARCH_RESULT_ELEMENT),
                "Cannot find anything by request ",
                15
        );

        return this.getAmountOfElements(By.xpath(SEARCH_RESULT_ELEMENT));
    }

    public void waitForEmptyResultsLabel()
    {
        this.waitForElementPresent(By.xpath(NO_RESULT_LABEL),"Cant find no result label",5);

    }

    public void assertThereIsNoResultOfSearch()
    {
        this.assertElementNotPresent(By.xpath(SEARCH_RESULT_ELEMENT),"search results is still present");
    }

    public void checkNotEmptySearch()
    {
        //тут проверим наличие нескольких статей
        this.waitForElementPresent(By.xpath(SEARCH_RESULT_ARTICLE_ELEMENT_0), "Can't finds articles - search result is empty", 10);

        this.waitForElementPresent(
                By.xpath(SEARCH_RESULT_ARTICLE_ELEMENT_1), "Can't finds articles - search result is empty", 10);


    }

}
