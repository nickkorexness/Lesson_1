package lib.ui;

import io.appium.java_client.AppiumDriver;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;

public class ArticlePageObject extends MainPageObject {

    private static final String
            ARTICLE_TITLE_ELEMENT = "org.wikipedia:id/view_page_title_text",
            FOOTER_ELEMENT = "//*[@text='View page in browser']",
            MORE_OPTIONS_BTN = "//android.widget.ImageView[@content-desc='More options']",
            ADD_TO_READING_LIST_BTN = "//*[@text ='Add to reading list']",
            GOT_IT_BTN = "org.wikipedia:id/onboarding_button",
            OK_BTN = "//*[@text ='OK']",
            MY_LIST_INPUT = "org.wikipedia:id/text_input",
            ARTICLE_CLOSE_BTN = "//android.widget.ImageButton[@content-desc='Navigate up']",
            MYLIST_FOLDER_ELEMENT= "//*[@resource-id='org.wikipedia:id/item_container' and @index='0']";




    public ArticlePageObject(AppiumDriver driver)
    {
        super(driver);
    }

    public WebElement waitForTitleElement()
    {
        return this.waitForElementPresent(By.id(ARTICLE_TITLE_ELEMENT),"Can't find article title on page",10);
    }

    public String getArticleTitle()
    {
        WebElement titleElement = waitForTitleElement();
        return titleElement.getAttribute("text");
    }

    public void swipeToFooter()
    {
        this.swipeUpToFindElement(
                By.xpath(FOOTER_ELEMENT),
                "cant find footer element",
                10
        );
    }

    public void addFirstArticleToMyList(String name_of_folder)
    {
        this.waitForElementAndClick(
                By.xpath(MORE_OPTIONS_BTN),
                "Cant find 'more option' button",
                15
        );

        this.waitForElementAndClick(
                By.xpath(ADD_TO_READING_LIST_BTN),
                "Cant find 'add ro reading list' button",
                15
        );

        this.waitForElementAndClick(
                By.id(GOT_IT_BTN),
                "Cant find 'got it ' overlay button",
                25
        );

        this.waitForElementAndClear(
                By.id(MY_LIST_INPUT),
                "cant find input to set the name of the folder",
                15
        );


        this.waitForElementAndSendKeys(
                By.id(MY_LIST_INPUT),
                name_of_folder,
                "cant find input to set the name of the folder",
                15
        );

        this.waitForElementAndClick(
                By.xpath(OK_BTN),
                "Cant click on OK button to save the folder name",
                15
        );
    }

    public void addtArticleToMyList(String name_of_folder)
    {
        this.waitForElementAndClick(
                By.xpath(MORE_OPTIONS_BTN),
                "Cant find 'more option' button",
                15
        );

        this.waitForElementAndClick(
                By.xpath(ADD_TO_READING_LIST_BTN),
                "Cant find 'add ro reading list' button",
                15
        );

        this.waitForElementAndClick(By.xpath(MYLIST_FOLDER_ELEMENT),
                "Cant find foder to adding to my Lists",
                5);
    }

    public void closeArticle()
    {
        this.waitForElementAndClick(
                By.xpath(ARTICLE_CLOSE_BTN),
                "Cant close the article",
                15
        );
    }


}
