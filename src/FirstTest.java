import io.appium.java_client.AppiumDriver;
import io.appium.java_client.TouchAction;
import io.appium.java_client.android.AndroidDriver;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.Dimension;
import org.openqa.selenium.ScreenOrientation;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;
import java.net.URL;
import java.util.List;


public class FirstTest {
    private AppiumDriver driver;

    @Before
    public void setUp()throws Exception
    {
        DesiredCapabilities capabilities = new DesiredCapabilities();

        capabilities.setCapability("platformName","Android");
        capabilities.setCapability("deviceName","AndroidTestDevice");
        capabilities.setCapability("platformVersion","9");
        capabilities.setCapability("automationName","UiAutomator2");
        capabilities.setCapability("appPackage","org.wikipedia");
        capabilities.setCapability("appActivity",".main.MainActivity");
        capabilities.setCapability("app","/Users/nickolay/Lesson_1/apks/org.wikipedia.apk");

        driver = new AndroidDriver(new URL("http://127.0.0.1:4723/wd/hub"),capabilities);

        driver.rotate(ScreenOrientation.PORTRAIT);
    }

    @After
    public void tearDown ()
    {
        driver.quit();
    }


    @Test
    public void ex2_method_creation()
    {

        waitForElementAndClick(
                By.xpath("//*[contains(@text,'Search Wikipedia')]"),
                "Cannot find search input",
                5
        );


        WebElement title_search_element = waitForElementPresent(
                By.id("org.wikipedia:id/search_src_text"),
                "Cant find Search... Title",
                20
        );

        String search_input_title = title_search_element.getAttribute("text");
        Assert.assertEquals(
                "Title('Search...') is not equal to founded title",
                "Search…",
                search_input_title
        );


    }


    @Test
    public void ex3_cancel_search()
    {

        waitForElementAndClick(
                By.xpath("//*[contains(@text,'Search Wikipedia')]"),
                "Cannot find search input",
                5
        );

        waitForElementAndSendKeys(
                By.xpath("//*[contains(@text,'Search…')]"),
                "Cyprus",
                "Cannot find search input",
                10
        );

        //тут проверим наличие нескольких статей
        waitForElementPresent(
                By.xpath("//*[@class='android.widget.LinearLayout' and @index='0']"),
                "Can't finds articles - search result is empty",
                10

        );

        waitForElementPresent(
                By.xpath("//*[@class='android.widget.LinearLayout' and @index='1']"),
                "Can't finds articles - search result is empty",
                10

        );

        waitForElementAndClear(
                By.id("org.wikipedia:id/search_src_text"),
                "Can't clear search input",
                5
        );

        waitForElementAndClick(
                By.id("org.wikipedia:id/search_close_btn"),
                "Cannot find close button",
                5
        );

        waitForElementNotPresent(
                By.id("org.wikipedia:id/search_close_btn"),
                "close button was founded",
                5
        );


    }

    @Test
    public void ex4_check_words_in_search()
    {

        waitForElementAndClick(
                By.xpath("//*[contains(@text,'Search Wikipedia')]"),
                "Cannot find search input",
                5
        );

        waitForElementAndSendKeys(
                By.xpath("//*[contains(@text,'Search…')]"),
                "Limassol",
                "Cannot find search input",
                10
        );


    }


    @Test
    public void ex5_two_articles()
    {

        waitForElementAndClick(
                By.id("org.wikipedia:id/search_container"),
                "Cannot find search input",
                5
        );

        waitForElementAndSendKeys(
                By.xpath("//*[contains(@text,'Search…')]"),
                "Java",
                "Cannot find search input",
                10
        );

        //Добавляем первую статью и сохраняем в новую папку

        waitForElementAndClick(
                By.xpath("//*[@resource-id='org.wikipedia:id/page_list_item_container']//*[@text='Object-oriented programming language']"),
                "Cannot find search input",
                15
        );

        waitForElementPresent(
                By.id("org.wikipedia:id/view_page_title_text"),
                "Cant find Java Title",
                15
        );

        waitForElementAndClick(
                By.xpath("//*[@class='android.widget.ImageView' and @index='2']"),
                "Cant find 'more option' button",
                20
        );


        waitForElementAndClick(
                //By.xpath("//*[@text='Add to reading list']"),
                By.xpath("//*[@class='android.widget.LinearLayout' and @index='2']"),
                "cant fing add to reading list button",
                20
        );


        waitForElementAndClick(
                By.id("org.wikipedia:id/onboarding_button"),
                "Cant find 'got it' overlay button",
                15
        );

        waitForElementAndClear(
                By.id("org.wikipedia:id/text_input"),
                "cant find input to set the name of the folder",
                15
        );

        String name_of_folder = "Learning";

        waitForElementAndSendKeys(
                By.id("org.wikipedia:id/text_input"),
                name_of_folder,
                "cant find input to set the name of the folder",
                15
        );

        waitForElementAndClick(
                By.xpath("//*[@text ='OK']"),
                "Cant click on OK button to save the folder name",
                15
        );

        waitForElementAndClick(
                By.xpath("//android.widget.ImageButton[@content-desc='Navigate up']"),
                "Cant close the article",
                15
        );

        //Добавляем вторую статью и сохраняем в новую папку

        waitForElementAndClick(
                By.id("org.wikipedia:id/search_container"),
                "Cannot find search input",
                5
        );

        waitForElementAndSendKeys(
                By.xpath("//*[contains(@text,'Search…')]"),
                "JavaScript",
                "Cannot find search input",
                10
        );


        waitForElementAndClick(
                By.xpath("//*[@resource-id='org.wikipedia:id/page_list_item_container']//*[@text='JavaScript']"),
                "Cannot find search input",
                15
        );

        waitForElementPresent(
                By.id("org.wikipedia:id/view_page_title_text"),
                "Cant find JavaScript Title",
                15
        );

        String title_actual = waitForElementAndGetAttribute(
                        By.xpath("//*[@class='android.widget.TextView' and @index='0']"),
                        "text",
                        "cant find text or article",
                        10
        );

        waitForElementAndClick(
                By.xpath("//*[@class='android.widget.ImageView' and @index='2']"),
                "Cant find 'more option' button",
                15
        );

        waitForElementAndClick(
                By.xpath("//*[@class='android.widget.LinearLayout' and @index='2']"),
                "Cant find 'add ro reading list' button",
                15
        );

        waitForElementAndClick(
                By.xpath("//*[@text ='" + name_of_folder + "']"),
                "Cant click on OK button to save the folder name",
                15
        );

        waitForElementAndClick(
                By.xpath("//android.widget.ImageButton[@content-desc='Navigate up']"),
                "Cant close the article",
                15
        );

        // открываем папку и удаляем

        waitForElementAndClick(
                By.xpath("//android.widget.FrameLayout[@content-desc='My lists']"),
                "Cant open 'my lists' screen ",
                15
        );

        waitForElementAndClick(
                By.xpath("//*[@text ='" + name_of_folder + "']"),
                "Cant find  folder",
                15
        );

        swipeElementToLeft(
                By.xpath("//*[@text ='Java (programming language)']"),
                "Cant find saved article"
        );

        waitForElementNotPresent(By.xpath("//*[@text ='Java (programming language)']"),
                "Cant delete saved article",
                10
        );

        waitForElementPresent(
                By.xpath("//*[@text ='JavaScript']"),
                "Cant find article with Javascript entry",
                10
        );

        String title_expected = waitForElementAndGetAttribute(
                By.xpath("//*[@class='android.widget.TextView' and @index='0']"),
                "text",
                "cant find text or article",
                10
        );

        Assert.assertEquals(
                "article title is not equals",
                title_actual,
                title_expected
        );
    }

    @Test
    public void ex6_title_assert()
    {

        waitForElementAndClick(
                By.xpath("//*[contains(@text,'Search Wikipedia')]"),
                "Cannot find search input",
                5
        );

        waitForElementAndSendKeys(
                By.xpath("//*[contains(@text,'Search…')]"),
                "Limassol",
                "Cannot find search input",
                10
        );


    }

















//    @Test
//    public void FirstTest()
//    {
//
//        waitForElementAndClick(
//                By.xpath("//*[contains(@text,'Search Wikipedia')]"),
//                "Cannot find search input",
//                5
//        );
//
//        waitForElementAndSendKeys(
//                By.xpath("//*[contains(@text,'Search…')]"),
//                "Java",
//                "Cannot find search input",
//                10
//        );
//
//        waitForElementPresent(
//                By.xpath("//*[@resource-id='org.wikipedia:id/page_list_item_container']//*[@text='Object-oriented programming language']"),
//                "Cant found 'Object-oriented programming language' text",
//                30
//        );
//    }

    @Test
    public void testCancelSearch()
    {
        waitForElementAndClick(
                By.id("org.wikipedia:id/search_container"),
                "Cannot find search input",
                5
        );

        waitForElementAndSendKeys(
                By.xpath("//*[contains(@text,'Search…')]"),
                "Java",
                "Cannot find search input",
                10
        );

        waitForElementAndClear(
                By.id("org.wikipedia:id/search_src_text"),
                "Can't clear",
                5
        );

        waitForElementAndClick(
                By.id("org.wikipedia:id/search_close_btn"),
                "Cannot find close button",
                5
        );

        waitForElementNotPresent(
                By.id("org.wikipedia:id/search_close_btn"),
                "close button was founded",
                5
        );

    }

    @Test
    public void testCompareArticleTitle() {
        waitForElementAndClick(
                By.id("org.wikipedia:id/search_container"),
                "Cannot find search input",
                5
        );

        waitForElementAndSendKeys(
                By.xpath("//*[contains(@text,'Search…')]"),
                "Java",
                "Cannot find search input",
                10
        );

        waitForElementAndClick(
                By.xpath("//*[@resource-id='org.wikipedia:id/page_list_item_container']//*[@text='Object-oriented programming language']"),
                "Cannot find search input",
                30
        );

        WebElement title_element = waitForElementPresent(
                By.id("org.wikipedia:id/view_page_title_text"),
                "Cant find Java Title",
                20
        );

        String article_title = title_element.getAttribute("text");
        Assert.assertEquals(
                "Title is not equal to expected title",
                "Java (programming language)",
                article_title
        );
    }

    @Test
    public void testSwipeArticle()
    {
        waitForElementAndClick(
                By.id("org.wikipedia:id/search_container"),
                "Cannot find search input",
                5
        );

        waitForElementAndSendKeys(
                By.xpath("//*[contains(@text,'Search…')]"),
                "Appium",
                "Cannot find search input",
                10
        );

        waitForElementAndClick(
                By.xpath("//*[@resource-id='org.wikipedia:id/page_list_item_title'][@text='Appium']"),
                "Cannot find appium in search input",
                30
        );

        waitForElementPresent(
                By.id("org.wikipedia:id/view_page_title_text"),
                "Cant find Java Title",
                20
        );

//            swipeUp(2000);
//            swipeUp(2000);
//            swipeUp(2000);
//            swipeUp(2000);
//            swipeUp(2000);

        swipeUpToFindElement(
                By.xpath("//*[@text ='View page in browser']"),
                "Cant find  te and of article",
                20
        );
    }


    @Test
    public void saveFirstArticleToMyList()
    {
        waitForElementAndClick(
                By.id("org.wikipedia:id/search_container"),
                "Cannot find search input",
                5
        );

        waitForElementAndSendKeys(
                By.xpath("//*[contains(@text,'Search…')]"),
                "Java",
                "Cannot find search input",
                10
        );

        waitForElementAndClick(
                By.xpath("//*[@resource-id='org.wikipedia:id/page_list_item_container']//*[@text='Object-oriented programming language']"),
                "Cannot find search input",
                30
        );

        waitForElementPresent(
                By.id("org.wikipedia:id/view_page_title_text"),
                "Cant find Java Title",
                20
        );

        waitForElementAndClick(
                By.xpath("//android.widget.ImageView[@content-desc='More option']"),
                "Cant find 'more option' button",
                15
        );

        waitForElementAndClick(
                By.xpath("//*[@text ='Add to reading list']"),
                "Cant find 'add ro reading list' button",
                15
        );

        waitForElementAndClick(
                By.xpath("org.wikipedia:id/onboarding_button"),
                "Cant find 'got it ' overlay button",
                15
        );

        waitForElementAndClear(
                By.id("org.wikipedia:id/text_input"),
                "cant find input to set the name of the folder",
                15
        );

        String name_of_folder = "Learning programming";

        waitForElementAndSendKeys(
                By.id("org.wikipedia:id/text_input"),
                name_of_folder,
                "cant find input to set the name of the folder",
                15
        );

        waitForElementAndClick(
                By.xpath("//*[@text ='OK']"),
                "Cant click on OK button to save the folder name",
                15
        );

        waitForElementAndClick(
                By.xpath("//android.widget.ImageButton[@content-desc='Navigate UP']"),
                "Cant close the article",
                15
        );

        waitForElementAndClick(
                By.xpath("//android.widget.FrameLayout[@content-desc='My lists']"),
                "Cant open 'my lists' screen ",
                15
        );

        waitForElementAndClick(
                By.xpath("//*[@text ='" + name_of_folder + "']"),
                "Cant find  folder",
                15
        );

        swipeElementToLeft(
                By.xpath("//*[@text ='Java (programming language)']"),
                "Cant find saved article"
        );

        waitForElementNotPresent(By.xpath("//*[@text ='Java (programming language)']"),
                "Cant delete saved article",
                10
        );

    }


    @Test
    public void testAmountOfNotEmptySearch()
    {
        waitForElementAndClick(
                By.id("org.wikipedia:id/search_container"),
                "Cannot find search input",
                5
        );

        String search_input_text = "Linkin Park Discography";

        waitForElementAndSendKeys(
                By.xpath("//*[contains(@text,'Search…')]"),
                search_input_text,
                "Cannot find search input",
                10
        );

        String search_result_locator = "//*[@resource-id = 'org.wikipedia:id/search_result_list']/*[@resource-id = 'org.wikipedia:id/page_list_item_container']";
        waitForElementPresent(
                By.xpath(search_result_locator),
                "Cannot find anything by request " + search_input_text,
                15
        );

        int amount_of_search_result = getAmountOfElements(By.xpath(search_result_locator));

        Assert.assertTrue(
                "we found too few results",
                amount_of_search_result > 0
        );
    }


    @Test
    public void testAmountOfEmptySearch()
    {
        waitForElementAndClick(
                By.id("org.wikipedia:id/search_container"),
                "Cannot find search input",
                5
        );

        String search_input_text = "zyxckvljbkn;lmji";

        waitForElementAndSendKeys(
                By.xpath("//*[contains(@text,'Search…')]"),
                search_input_text,
                "Cannot find search input",
                10
        );

        String search_result_locator = "//*[@resource-id = 'org.wikipedia:id/search_result_list']/*[@resource-id = 'org.wikipedia:id/page_list_item_container']";
        String empty_result_label = "//*[contains(@text,'No results found')]";

        waitForElementPresent(
                By.xpath(empty_result_label),
                "cant find empty result label by the request" + search_input_text,
                10
        );

        assertElementNotPresent(
                By.xpath(search_result_locator),
                "some results were found by text: " + search_input_text
        );

    }

    @Test
    public void testChangeScreenOrientationOnSearchResults()
    {
        waitForElementAndClick(
                By.id("org.wikipedia:id/search_container"),
                "Cannot find search input",
                5
        );

        String search_input_text = "Java";

        waitForElementAndSendKeys(
                By.xpath("//*[contains(@text,'Search…')]"),
                search_input_text,
                "Cannot find search input",
                10
        );

        waitForElementAndClick(
                By.xpath("//*[@resource-id='org.wikipedia:id/page_list_item_container']//*[@text='Object-oriented programming language']"),
                "Cannot find search 'Object-oriented programming language' by request " + search_input_text,
                15
        );

        String title_before_rotation = waitForElementAndGetAttribute(
                By.id("org.wikipedia:/view_page_title_text"),
                "text",
                "cant find text or article",
                15
        );

        driver.rotate(ScreenOrientation.LANDSCAPE);

        String title_after_rotation = waitForElementAndGetAttribute(
                By.id("org.wikipedia:/view_page_title_text"),
                "text",
                "cant find text or article",
                15
        );

        Assert.assertEquals(
                "article title has been changed ofter screen rotation",
                title_before_rotation,
                title_after_rotation
        );

        driver.rotate(ScreenOrientation.PORTRAIT);

        String title_after_back_rotation = waitForElementAndGetAttribute(
                By.id("org.wikipedia:/view_page_title_text"),
                "text",
                "cant find text or article",
                15
        );

        Assert.assertEquals(
                "article title has been changed ofter screen rotation",
                title_before_rotation,
                title_after_back_rotation
        );
    }

    @Test
    public void testArticleTitleAfterBackgorundSending()
    {

        waitForElementAndClick(
                By.id("org.wikipedia:id/search_container"),
                "Cannot find search input",
                5
        );

        String search_input_text = "Java";

        waitForElementAndSendKeys(
                By.xpath("//*[contains(@text,'Search…')]"),
                search_input_text,
                "Cannot find search input",
                10
        );

        waitForElementPresent(
                By.xpath("//*[@resource-id='org.wikipedia:id/page_list_item_container']//*[@text='Object-oriented programming language']"),
                "Cannot find search 'Object-oriented programming language' by request " + search_input_text,
                15
        );

        driver.runAppInBackground(2);

        waitForElementPresent(
                By.xpath("//*[@resource-id='org.wikipedia:id/page_list_item_container']//*[@text='Object-oriented programming language']"),
                "Cannot find search 'Object-oriented programming language' by request " + search_input_text + "after returning from background",
                15
        );

    }







    private WebElement waitForElementPresent(By by, String error_message, long timeoutInSeconds)
    {
        WebDriverWait wait = new WebDriverWait(driver, timeoutInSeconds);
        wait.withMessage(error_message + "\n");
        return wait.until(
                ExpectedConditions.presenceOfElementLocated(by)
        );
    }

    private WebElement waitForElementPresent(By by, String error_message)
    {
        return waitForElementPresent(by, error_message, 5);
    }

    private WebElement waitForElementAndClick(By by, String error_message, long timeoutInSeconds)
    {
        WebElement element = waitForElementPresent(by, error_message, timeoutInSeconds);
        element.click();
        return element;
    }

    private WebElement waitForElementAndSendKeys(By by, String value, String error_message, long timeoutInSeconds)
    {
        WebElement element = waitForElementPresent(by, error_message, timeoutInSeconds);
        element.sendKeys(value);
        return element;
    }

    private boolean waitForElementNotPresent(By by, String error_message, long timeoutInSeconds)
    {
        WebDriverWait wait = new WebDriverWait(driver,timeoutInSeconds);
        wait.withMessage(error_message + "\n");
        return wait.until(
                ExpectedConditions.invisibilityOfElementLocated(by)
        );
    }

    private WebElement waitForElementAndClear(By by, String error_message, long timeoutInSeconds)
    {
        WebElement element = waitForElementPresent(by, error_message, timeoutInSeconds);
        element.clear();
        return element;
    }

    protected void swipeUp(int timeOfSwipe)
    {
        TouchAction action = new TouchAction(driver);
        Dimension size = driver.manage().window().getSize();
        int x = size.width /2;
        int start_y = (int) (size.height * 0.8);
        int end_y = (int) (size.height * 0.2);


        action
                .press(x,start_y)
                .waitAction(timeOfSwipe)
                .moveTo(x,end_y)
                .release()
                .perform();
    }

    protected void swipeUpQick()
    {
        swipeUp(200);
    }

    protected void swipeUpToFindElement(By by,String error_message, int max_swipes)
    {
        int already_swiped = 0;
        while (driver.findElements(by).size()==0){

            if (already_swiped>max_swipes){
                waitForElementPresent(by, "cannot find element by swiping up \n"+error_message,0);
                return;
            }

            swipeUpQick();
            ++already_swiped;
        }
    }

    protected void swipeElementToLeft(By by, String error_message)
    {
        WebElement element = waitForElementPresent(by , error_message, 10);
        int left_x= element.getLocation().getX();
        int right_x= left_x + element.getSize().getWidth();
        int upper_y= element.getLocation().getY();
        int lower_y= upper_y + element.getSize().getHeight();
        int middle_y= (upper_y+lower_y)/2;

        TouchAction action = new TouchAction(driver);
        action
                .press(right_x,middle_y)
                .waitAction(600)
                .moveTo(left_x, middle_y)
                .release()
                .perform();

    }

    private int getAmountOfElements (By by)
    {
        List elements = driver.findElements(by);
        return elements.size();
    }

    private  void assertElementNotPresent(By by, String error_message)
    {
        int amount_of_elements = getAmountOfElements(by);
        if (amount_of_elements>0){
            String default_message = " An element '" + by.toString() + "' supposed to be not present ";
            throw new AssertionError(default_message + " " + error_message);
        }


    }

    private String waitForElementAndGetAttribute(By by, String attribute, String error_message, long timeoutInSeconds)
    {
        WebElement element = waitForElementPresent(by, error_message, timeoutInSeconds);
        return element.getAttribute(attribute);
    }
}