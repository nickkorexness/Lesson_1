package lib.ui;

import io.appium.java_client.AppiumDriver;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;

public class ArticlePageObject extends MainPageObject {

    private static final String
            ARTICLE_TITLE_ELEMENT = "id:org.wikipedia:id/view_page_title_text",
            FOOTER_ELEMENT = "xpath://*[@text='View page in browser']",
            MORE_OPTIONS_BTN = "xpath://android.widget.ImageView[@content-desc='More options']",
            ADD_TO_READING_LIST_BTN = "xpath://*[@text ='Add to reading list']",
            GOT_IT_BTN = "id:org.wikipedia:id/onboarding_button",
            OK_BTN = "xpath://*[@text ='OK']",
            MY_LIST_INPUT = "id:org.wikipedia:id/text_input",
            ARTICLE_CLOSE_BTN = "xpath://android.widget.ImageButton[@content-desc='Navigate up']",
            MYLIST_FOLDER_ELEMENT= "xpath://*[@resource-id='org.wikipedia:id/item_container' and @index='0']";




    public ArticlePageObject(AppiumDriver driver)
    {
        super(driver);
    }

    public WebElement waitForTitleElement()
    {
        return this.waitForElementPresent(ARTICLE_TITLE_ELEMENT,"Can't find article title on page",10);
    }

    public String getArticleTitle()
    {
        WebElement titleElement = waitForTitleElement();
        return titleElement.getAttribute("text");
    }

    public void swipeToFooter()
    {
        this.swipeUpToFindElement(FOOTER_ELEMENT, "cant find footer element", 10
        );
    }

    public void addFirstArticleToMyList(String name_of_folder)
    {
        this.waitForElementAndClick(
                MORE_OPTIONS_BTN,
                "Cant find 'more option' button",
                15
        );

        this.waitForElementAndClick(
                ADD_TO_READING_LIST_BTN,
                "Cant find 'add ro reading list' button",
                15
        );

        this.waitForElementAndClick(
                GOT_IT_BTN,
                "Cant find 'got it ' overlay button",
                25
        );

        this.waitForElementAndClear(
                MY_LIST_INPUT,
                "cant find input to set the name of the folder",
                15
        );


        this.waitForElementAndSendKeys(
                MY_LIST_INPUT,
                name_of_folder,
                "cant find input to set the name of the folder",
                15
        );

        this.waitForElementAndClick(
                OK_BTN,
                "Cant click on OK button to save the folder name",
                15
        );
    }

    public void addtArticleToMyList(String name_of_folder)
    {
        this.waitForElementAndClick(
                MORE_OPTIONS_BTN,
                "Cant find 'more option' button",
                15
        );

        this.waitForElementAndClick(
                ADD_TO_READING_LIST_BTN,
                "Cant find 'add ro reading list' button",
                15
        );

        this.waitForElementAndClick(MYLIST_FOLDER_ELEMENT,
                "Cant find foder to adding to my Lists",
                5);
    }

    public void closeArticle()
    {
        this.waitForElementAndClick(
                ARTICLE_CLOSE_BTN,
                "Cant close the article",
                15
        );
    }

    public void checkArticleTitleWithTimeout(int timeout)
    {
        this.waitForElementPresent(ARTICLE_TITLE_ELEMENT,"cant find article element on article page with "+ timeout + " timeout", timeout);
    }
}
