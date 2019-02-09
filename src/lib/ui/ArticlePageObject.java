package lib.ui;

import io.appium.java_client.AppiumDriver;
import lib.Platform;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;

abstract  public class ArticlePageObject extends MainPageObject {

    protected static String
            ARTICLE_TITLE_ELEMENT,
            FOOTER_ELEMENT,
            MORE_OPTIONS_BTN,
            ADD_TO_READING_LIST_BTN ,
            GOT_IT_BTN ,
            OK_BTN ,
            MY_LIST_INPUT ,
            ARTICLE_CLOSE_BTN ,
            MYLIST_FOLDER_ELEMENT ;




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
        if (Platform.getInstance().isAndroid()){
            return titleElement.getAttribute("text");
        } else {return
            titleElement.getAttribute("name");
        }
    }

    public void swipeToFooter()
    {
        if(Platform.getInstance().isAndroid()){
            this.swipeUpToFindElement(FOOTER_ELEMENT, "cant find footer element", 40);
        } else {
            this.swipeUpTillElementAppeared(FOOTER_ELEMENT,"cant find footer element", 50);
        }

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

    public void addArticlesToMySaved()
    {
        this.waitForElementAndClick(ADD_TO_READING_LIST_BTN,"can't click and add article to my favorites",5);
    }
}
