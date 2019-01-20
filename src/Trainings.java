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
    public void ex3_cancel_search()
    {

        SearchPageObject SearchPageObject = new SearchPageObject(driver);
        SearchPageObject.initSearchInput();
        SearchPageObject.typeSearchLine("Cyprus");
        SearchPageObject.getAmountOfFoundArticles();
        assert (SearchPageObject.getAmountOfFoundArticles() > 0);
        SearchPageObject.clickCancelSearch();
        SearchPageObject.clickCancelSearch();
        SearchPageObject.waitForCancelButtonToDisappear();
    }

    @Test
    public void ex4_check_words_in_search()
    {

        SearchPageObject SearchPageObject = new SearchPageObject(driver);
        SearchPageObject.initSearchInput();
        SearchPageObject.typeSearchLine("Cyprus");

    }

    @Test
    public void test_ex5_two_articles()
    {
        SearchPageObject SearchPageObject = new SearchPageObject(driver);

        SearchPageObject.initSearchInput();
        SearchPageObject.typeSearchLine("Java");
        SearchPageObject.clickByArticleWithSubstring("Object-oriented programming language");

        ArticlePageObject ArticlePageObject = new ArticlePageObject(driver);
        ArticlePageObject.waitForTitleElement();

        String article_title = ArticlePageObject.getArticleTitle();
        String name_of_folder = "Learning programming";

        ArticlePageObject.addFirstArticleToMyList(name_of_folder);
        ArticlePageObject.closeArticle();
        //Добавляем вторую статью и сохраняем в новую папку

        SearchPageObject.initSearchInput();
        SearchPageObject.typeSearchLine("JavaScript");
        SearchPageObject.clickByArticleWithSubstring("Programming language");

        String title_actual = ArticlePageObject.getArticleTitle();
        ArticlePageObject.addtArticleToMyList(name_of_folder);
        ArticlePageObject.closeArticle();

        // открываем папку и удаляем
        NavigationUI NavigationUI = new NavigationUI(driver);
        NavigationUI.clickMyLists();
        MyListsPageObject MyListsPageObject = new MyListsPageObject(driver);

        MyListsPageObject.openFolderByName(name_of_folder);
        MyListsPageObject.swipeArticleToDelete(article_title);
        MyListsPageObject.waitForArticleToDissappearByTitle("Java");

        //открываем статью ,получаем тайтл и сверяем с полученным ранее
        MyListsPageObject.openArticle();
        String title_expected = ArticlePageObject.getArticleTitle();
        ArticlePageObject.closeArticle();

        assertEquals(
                "article title is not equals",
                title_actual,
                title_expected
        );
        //вывод для проверки получения тайтла
        System.out.println(title_actual);
        System.out.println(title_expected);
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