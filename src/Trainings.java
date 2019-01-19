import lib.CoreTestCase;
import lib.ui.*;
import org.junit.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;



public class Trainings extends CoreTestCase {

    @Test
    public void ex2_method_creation()
    {

        MainPageObject.waitForElementAndClick(
                By.xpath("//*[contains(@text,'Search Wikipedia')]"),
                "Cannot find search input",
                5
        );


        WebElement title_search_element = MainPageObject.waitForElementPresent(
                By.id("org.wikipedia:id/search_src_text"),
                "Cant find Search... Title",
                20
        );

        String search_input_title = title_search_element.getAttribute("text");
        assertEquals(
                "Title('Search...') is not equal to founded title",
                "Search…",
                search_input_title
        );


    }

    @Test
    public void ex3_cancel_search()
    {

        MainPageObject.waitForElementAndClick(
                By.xpath("//*[contains(@text,'Search Wikipedia')]"),
                "Cannot find search input",
                5
        );

        MainPageObject.waitForElementAndSendKeys(
                By.xpath("//*[contains(@text,'Search…')]"),
                "Cyprus",
                "Cannot find search input",
                10
        );

        //тут проверим наличие нескольких статей
        MainPageObject.waitForElementPresent(
                By.xpath("//*[@class='android.widget.LinearLayout' and @index='0']"),
                "Can't finds articles - search result is empty",
                10

        );

        MainPageObject.waitForElementPresent(
                By.xpath("//*[@class='android.widget.LinearLayout' and @index='1']"),
                "Can't finds articles - search result is empty",
                10

        );

        MainPageObject.waitForElementAndClear(
                By.id("org.wikipedia:id/search_src_text"),
                "Can't clear search input",
                5
        );

        MainPageObject.waitForElementAndClick(
                By.id("org.wikipedia:id/search_close_btn"),
                "Cannot find close button",
                5
        );

        MainPageObject.waitForElementNotPresent(
                By.id("org.wikipedia:id/search_close_btn"),
                "close button was founded",
                5
        );


    }

    @Test
    public void ex4_check_words_in_search()
    {

        MainPageObject.waitForElementAndClick(
                By.xpath("//*[contains(@text,'Search Wikipedia')]"),
                "Cannot find search input",
                5
        );

        MainPageObject.waitForElementAndSendKeys(
                By.xpath("//*[contains(@text,'Search…')]"),
                "Limassol",
                "Cannot find search input",
                10
        );

    }

    @Test
    public void ex5_two_articles()
    {

        MainPageObject.waitForElementAndClick(
                By.id("org.wikipedia:id/search_container"),
                "Cannot find search input",
                5
        );

        MainPageObject.waitForElementAndSendKeys(
                By.xpath("//*[contains(@text,'Search…')]"),
                "Java",
                "Cannot find search input",
                10
        );

        //Добавляем первую статью и сохраняем в новую папку

        MainPageObject.waitForElementAndClick(
                By.xpath("//*[@resource-id='org.wikipedia:id/page_list_item_container']//*[@text='Object-oriented programming language']"),
                "Cannot find search input",
                15
        );

        MainPageObject.waitForElementPresent(
                By.id("org.wikipedia:id/view_page_title_text"),
                "Cant find Java Title",
                15
        );

        MainPageObject.waitForElementAndClick(
                By.xpath("//*[@class='android.widget.ImageView' and @index='2']"),
                "Cant find 'more option' button",
                20
        );

        MainPageObject.waitForElementAndClick(
                //By.xpath("//*[@text='Add to reading list']"),
                By.xpath("//*[@class='android.widget.LinearLayout' and @index='2']"),
                "cant fing add to reading list button",
                20
        );

        MainPageObject.waitForElementAndClick(
                By.id("org.wikipedia:id/onboarding_button"),
                "Cant find 'got it' overlay button",
                15
        );

        MainPageObject.waitForElementAndClear(
                By.id("org.wikipedia:id/text_input"),
                "cant find input to set the name of the folder",
                15
        );

        String name_of_folder = "Learning";

        MainPageObject.waitForElementAndSendKeys(
                By.id("org.wikipedia:id/text_input"),
                name_of_folder,
                "cant find input to set the name of the folder",
                15
        );

        MainPageObject.waitForElementAndClick(
                By.xpath("//*[@text ='OK']"),
                "Cant click on OK button to save the folder name",
                15
        );

        MainPageObject.waitForElementAndClick(
                By.xpath("//android.widget.ImageButton[@content-desc='Navigate up']"),
                "Cant close the article",
                15
        );

        //Добавляем вторую статью и сохраняем в новую папку

        MainPageObject.waitForElementAndClick(
                By.id("org.wikipedia:id/search_container"),
                "Cannot find search input",
                5
        );

        MainPageObject.waitForElementAndSendKeys(
                By.xpath("//*[contains(@text,'Search…')]"),
                "JavaScript",
                "Cannot find search input",
                10
        );

        MainPageObject.waitForElementAndClick(
                By.xpath("//*[@resource-id='org.wikipedia:id/page_list_item_container']//*[@text='JavaScript']"),
                "Cannot find search input",
                15
        );

        MainPageObject.waitForElementPresent(
                By.id("org.wikipedia:id/view_page_title_text"),
                "Cant find JavaScript Title",
                15
        );

        String title_actual = MainPageObject.waitForElementAndGetAttribute(
                        By.xpath("//*[@class='android.widget.TextView' and @index='0']"),
                        "text",
                        "cant find text or article",
                        10
        );

        MainPageObject.waitForElementAndClick(
                By.xpath("//*[@class='android.widget.ImageView' and @index='2']"),
                "Cant find 'more option' button",
                15
        );

        MainPageObject.waitForElementAndClick(
                By.xpath("//*[@class='android.widget.LinearLayout' and @index='2']"),
                "Cant find 'add ro reading list' button",
                15
        );

        MainPageObject.waitForElementAndClick(
                By.xpath("//*[@text ='" + name_of_folder + "']"),
                "Cant click on OK button to save the folder name",
                15
        );

        MainPageObject.waitForElementAndClick(
                By.xpath("//android.widget.ImageButton[@content-desc='Navigate up']"),
                "Cant close the article",
                15
        );

        // открываем папку и удаляем

        MainPageObject.waitForElementAndClick(
                By.xpath("//android.widget.FrameLayout[@content-desc='My lists']"),
                "Cant open 'my lists' screen ",
                15
        );

        MainPageObject.waitForElementAndClick(
                By.xpath("//*[@text ='" + name_of_folder + "']"),
                "Cant find  folder",
                15
        );

        MainPageObject.swipeElementToLeft(
                By.xpath("//*[@text ='Java (programming language)']"),
                "Cant find saved article"
        );

        MainPageObject.waitForElementNotPresent(By.xpath("//*[@text ='Java (programming language)']"),
                "Cant delete saved article",
                10
        );

        MainPageObject.waitForElementPresent(
                By.xpath("//*[@text ='JavaScript']"),
                "Cant find article with Javascript entry",
                10
        );

        String title_expected = MainPageObject.waitForElementAndGetAttribute(
                By.xpath("//*[@class='android.widget.TextView' and @index='0']"),
                "text",
                "cant find text or article",
                10
        );

        assertEquals(
                "article title is not equals",
                title_actual,
                title_expected
        );
    }

    @Test
    public void ex6_title()
    {

        MainPageObject.waitForElementAndClick(
                By.xpath("//*[contains(@text,'Search Wikipedia')]"),
                "Cannot find search input",
                5
        );

        MainPageObject.waitForElementAndSendKeys(
                By.xpath("//*[contains(@text,'Search…')]"),
                "Limassol",
                "Cannot find search input",
                10
        );

        MainPageObject.waitForElementAndClick(
                By.xpath("//*[@resource-id='org.wikipedia:id/page_list_item_container']//*[@text='Limassol']"),
                "Cannot find search input",
                15
        );

        MainPageObject.assertElementPresent(By.xpath("//*[@class='android.widget.TextView' and @index='1']"));


    }

}