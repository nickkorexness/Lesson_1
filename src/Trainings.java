import lib.CoreTestCase;
import lib.ui.*;
import org.junit.Test;


public class Trainings extends CoreTestCase {

//    @Test
//    public void ex2_method_creation()
//    {
//
//        SearchPageObject SearchPageObject = new SearchPageObject(driver);
//        SearchPageObject.initSearchInput();
//        SearchPageObject.typeSearchLine("Java");
//
//
//
//        String search_input_title = title_search_element.getAttribute("text");
//        assertEquals(
//                "Title('Search...') is not equal to founded title",
//                "Search…",
//                search_input_title
//        );
//
//
//    }

    

    @Test
    public void ex4_check_words_in_search()
    {

        SearchPageObject SearchPageObject = new SearchPageObject(driver);
        SearchPageObject.initSearchInput();
        SearchPageObject.typeSearchLine("Cyprus");

    }

//    @Test
//    public void ex6_title_before_refactoring()
//    {
//
//        MainPageObject.waitForElementAndClick(
//                By.xpath("//*[contains(@text,'Search Wikipedia')]"),
//                "Cannot find search input",
//                5
//        );
//
//        MainPageObject.waitForElementAndSendKeys(
//                By.xpath("//*[contains(@text,'Search…')]"),
//                "Limassol",
//                "Cannot find search input",
//                10
//        );
//
//        MainPageObject.waitForElementAndClick(
//                By.xpath("//*[@resource-id='org.wikipedia:id/page_list_item_container']//*[@text='Limassol']"),
//                "Cannot find search input",
//                15
//        );
//
//        MainPageObject.assertElementPresent(By.xpath("//*[@class='android.widget.TextView' and @index='1']"));
//
//
//    }

}