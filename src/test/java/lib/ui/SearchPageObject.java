package lib.ui;

import io.appium.java_client.AppiumDriver;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.util.ArrayList;
import java.util.List;

import static junit.framework.TestCase.assertTrue;


public abstract class SearchPageObject extends MainPageObject {

        protected static String
                SEARCH_INIT_ELEMENT ,
                SEARCH_INPUT ,
                SEARCH_CANCEL_BTN ,
                SEARCH_RESULT_BY_SUBSTRING_TPL,
                NO_RESULT_LABEL ,
                SEARCH_RESULT_ELEMENT ,
                SEARCH_RESULT_ARTICLE_ELEMENT_0 ,
                SEARCH_RESULT_ARTICLE_ELEMENT_1 ,
                SEARCH_RESULT_ARTICLE_ELEMENT_TPL ,
                SEARCH_ITEM_TITLE ,
                SEARCH_IN_SAVED,
                NO_SAVED_LABEL,
                SEARCH_RESULT_ARTICLE_ELEMENT_WITH_TEXT ;


        /* template methods*/

        private static String getResultSearchElement(String substring)
        {
            return SEARCH_RESULT_BY_SUBSTRING_TPL.replace("{SUBSTRING}", substring);
        }

        private static String getResultArticleElement(String substring)
        {
            return SEARCH_RESULT_ARTICLE_ELEMENT_WITH_TEXT.replace("{TEXT}", substring);
        }

        private static String getArticleElement(String index)
        {
            return SEARCH_RESULT_ARTICLE_ELEMENT_TPL.replace("{INDEX}", index);
        }

        /* template methods*/



        public SearchPageObject(RemoteWebDriver driver)
        {
            super(driver);
        }

        public void initSearchInput()
        {
            this.waitForElementAndClick(SEARCH_INIT_ELEMENT, "Can't find and click on search init element", 5);
            this.waitForElementPresent(SEARCH_INPUT,"Can't find search input after clicking on search ini element",5);
        }

        public void typeSearchLine(String search_line)
        {
            this.waitForElementPresent(SEARCH_INPUT,"",15);
            this.waitForElementAndClick(SEARCH_INPUT,"Can't find search input after clicking on search ini element",5);
            this.waitForElementAndSendKeys(SEARCH_INPUT,search_line,"Ca", 15);
        }

        public void waitForSearchResult(String substring)
        {
            String search_result_xpath = getResultSearchElement(substring);
            this.waitForElementPresent(search_result_xpath,"can't find search result with substring "+ substring);
        }

        public void clickByArticleWithSubstring(String substring)
        {
            String search_result_xpath = getResultSearchElement(substring);
            this.waitForElementAndClick(search_result_xpath,"can't find and click search result with substring "+ substring, 25);
        }

        public void waitForCancelButtonToAppear()
        {
            this.waitForElementPresent(SEARCH_CANCEL_BTN,"Can't find search cancel btn",5);
        }

        public void waitForCancelButtonToDisappear()
        {
            this.waitForElementNotPresent(SEARCH_CANCEL_BTN,"Can't find search cancel btn",5);
        }

        public void clickCancelSearch()
        {
            this.waitForElementAndClick(SEARCH_CANCEL_BTN,"Can't click on cancel btn", 5);

        }

        public int getAmountOfFoundArticles()
        {

            this.waitForElementPresent(
                    SEARCH_RESULT_ELEMENT, "Cannot find anything by request ", 15
            );

            return this.getAmountOfElements(SEARCH_RESULT_ELEMENT);
        }

        public void waitForEmptyResultsLabel()
        {
            this.waitForElementPresent(NO_RESULT_LABEL,"Cant find no result label",5);

        }

        public void assertThereIsNoResultOfSearch()
        {
            this.assertElementNotPresent(SEARCH_RESULT_ELEMENT,"search results is still present");
        }

        public void checkNotEmptySearch()
        {
            //тут проверим наличие нескольких статей
            this.waitForElementPresent(SEARCH_RESULT_ARTICLE_ELEMENT_0, "Can't finds articles - search result is empty", 10);

            this.waitForElementPresent(SEARCH_RESULT_ARTICLE_ELEMENT_1, "Can't finds articles - search result is empty", 10);
        }

        public void searchArticleInSaved(String search_line){
            this.waitForElementAndClick(SEARCH_IN_SAVED,"cant find input in saved",5);
            this.waitForElementAndSendKeys(SEARCH_IN_SAVED,search_line,"cant find input in saved",5);
        }

        public void checkNoSavedArticles()
        {
            this.waitForElementNotPresent(NO_SAVED_LABEL,"there is no articles on page",5);
        }

    //для задания 4
//    public void checkAllSearchResultsWithJava()
//    {
//        List<WebElement> search_results = this.waitForElementsPresent(By.xpath(SEARCH_RESULT_ELEMENT), "Can't find search results elements", 5);
//
//
//        List <String> searchResultTitle = new ArrayList<>();
//        for (WebElement element:search_results){
//        searchResultTitle.add(element.findElement(By.id(SEARCH_ITEM_TITLE)).getText());
//        }
//        for (int i = 0; i < searchResultTitle.size();
//             i++)
//        {
//        assertTrue(
//                "can't find Java in search result №" + i,
//                searchResultTitle.get(i).contains("Java")||searchResultTitle.get(i).contains("java"));
//        }
//
//    }
//        private List<WebElement> waitForElementsPresent(By by, String error_message, long timeoutInSeconds ){
//
//        WebDriverWait wait = new WebDriverWait(driver, timeoutInSeconds);
//        wait.withMessage(error_message + "\n");
//
//        return wait.until(ExpectedConditions.presenceOfAllElementsLocatedBy(by));
//        }

    }





