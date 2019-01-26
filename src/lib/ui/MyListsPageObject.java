package lib.ui;

import io.appium.java_client.AppiumDriver;
import org.openqa.selenium.By;

public class MyListsPageObject extends MainPageObject {

    public MyListsPageObject(AppiumDriver driver)
    {
        super(driver);
    }


    public final static String
        FOLDER_BY_NAME_TPL = "xpath://*[@text='Learning programming']",
        ARTICLE_BY_TITLE_TPL = "xpath://*[@text ='{TITLE}']",
        ARTICLE_TITLE = "xpath://*[@resource-id='org.wikipedia:id/page_list_item_title' and @index='0']";



    public static String getFolderXpathByName(String name_of_folder)
    {
        return FOLDER_BY_NAME_TPL.replace("{FOLDER_NAME}",name_of_folder);
    }

    public static String getSavedArticleXpathByTitle(String article_title)
    {
        return ARTICLE_BY_TITLE_TPL.replace("{TITLE}",article_title);
    }



    public void openFolderByName(String name_of_folder)
    {
        String folder_name_xpath = getFolderXpathByName(name_of_folder);
        this.waitForElementAndClick(
                folder_name_xpath,
                "Cant find  folder by name " + name_of_folder,
                15
        );
    }

    public void swipeArticleToDelete(String article_title)
    {
        String article_xpath = getSavedArticleXpathByTitle(article_title);
        this.waitForArticleToAppearByTitle(article_title);
        this.swipeElementToLeft(
                article_xpath,
                "Cant find saved article"
        );
        this.waitForArticleToDissappearByTitle(article_title);

    }

    public void waitForArticleToDissappearByTitle(String article_title)
    {
        String article_xpath = getSavedArticleXpathByTitle(article_title);
        this.waitForElementNotPresent(article_xpath, "Cant delete saved article", 10
        );
    }

    public void waitForArticleToAppearByTitle(String article_title)
    {
        String article_xpath = getFolderXpathByName(article_title);
        this.waitForElementPresent(article_xpath, "Cant find article by title", 10
        );
    }

    public void openArticle()
    {
        this.waitForElementAndClick(ARTICLE_TITLE, "Can't open first article on mylists screen", 5);
    }




}
