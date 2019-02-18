package lib.ui;

import io.appium.java_client.AppiumDriver;
import lib.Platform;

abstract public class MyListsPageObject extends MainPageObject {

    public MyListsPageObject(AppiumDriver driver)
    {
        super(driver);
    }


    protected static String
        FOLDER_BY_NAME_TPL,
        ARTICLE_BY_TITLE_TPL,
        REMOVE_FROM_SAVED_BUTTON,
        NOT_DELETED_ARTICLE,
        ARTICLE_TITLE;



    public static String getFolderXpathByName(String name_of_folder)
    {
        return FOLDER_BY_NAME_TPL.replace("{FOLDER_NAME}",name_of_folder);
    }

    public static String getSavedArticleXpathByTitle(String article_title)
    {
        return ARTICLE_BY_TITLE_TPL.replace("{TITLE}",article_title);
    }

    public static String getRemoveButtonByTitle(String article_title)
    {
        return REMOVE_FROM_SAVED_BUTTON.replace("{TITLE}",article_title);
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
        this.waitForArticleToAppearByTitle(article_title);
        String article_xpath = getSavedArticleXpathByTitle(article_title);

        if (Platform.getInstance().isIOS() || Platform.getInstance().isAndroid()){
            this.swipeElementToLeft(
                    article_xpath,
                    "Cant find saved article"
            );
        } else {
            String remove_locator = getRemoveButtonByTitle(article_title);
            this.waitForElementAndClick(remove_locator,"cant click on delete button",10);
        }


        if (Platform.getInstance().isIOS()){
            this.clickElementToUpperRightCorner(article_xpath,"cannot find saved article");
        }


        if (Platform.getInstance().isMobileWeb()){
            driver.navigate().refresh();
        }

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

    public void clickByNotDeletedArticle(){
        this.waitForElementPresent(NOT_DELETED_ARTICLE,"cant find article",5);
        this.waitForElementAndClick(NOT_DELETED_ARTICLE,"cant find article",5);
    }




}
