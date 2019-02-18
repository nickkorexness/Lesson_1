import lib.CoreTestCase;
import lib.Platform;
import lib.ui.*;
import lib.ui.factories.ArticlePageObjectFactory;
import lib.ui.factories.MyListsPageObjectFactory;
import lib.ui.factories.NavigationUIFactory;
import lib.ui.factories.SearchPageObjectFactory;
import lib.ui.iOS.WelcomePageObject;
import org.junit.Assert;
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
    public void test_ex3_cancel_search()
    {

        SearchPageObject SearchPageObject = SearchPageObjectFactory.get(driver);
        SearchPageObject.initSearchInput();
        SearchPageObject.typeSearchLine("Cyprus");
        SearchPageObject.getAmountOfFoundArticles();
        assert (SearchPageObject.getAmountOfFoundArticles() > 0);
        SearchPageObject.clickCancelSearch();
        SearchPageObject.clickCancelSearch();
        SearchPageObject.waitForCancelButtonToDisappear();
    }

    @Test
    public void test_ex5_two_articles()
    {
        SearchPageObject SearchPageObject = SearchPageObjectFactory.get(driver);

        SearchPageObject.initSearchInput();
        SearchPageObject.typeSearchLine("Java");
        SearchPageObject.clickByArticleWithSubstring("Object-oriented programming language");

        ArticlePageObject ArticlePageObject = ArticlePageObjectFactory.get(driver);
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
        NavigationUI NavigationUI = NavigationUIFactory.get(driver);
        NavigationUI.clickMyLists();
        MyListsPageObject MyListsPageObject = MyListsPageObjectFactory.get(driver);

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

    @Test
    public void test_ex6_title()
    {

        SearchPageObject SearchPageObject = SearchPageObjectFactory.get(driver);

        SearchPageObject.initSearchInput();
        SearchPageObject.typeSearchLine("Limassol");
        SearchPageObject.clickByArticleWithSubstring("City in Cyprus");

        ArticlePageObject ArticlePageObject = ArticlePageObjectFactory.get(driver);
        ArticlePageObject.checkArticleTitleWithTimeout(0);

    }

//    @Test
//    public void test_ex4_check_words_in_search()
//    {
//        //ищем слово и проверяем его наличие в результатах поиска
//        //открываем поиск и вводим строку для поиска
//        SearchPageObject SearchPageObject = SearchPageObjectFactory.get(driver);
//        SearchPageObject.initSearchInput();
//        SearchPageObject.typeSearchLine("Java");
//        SearchPageObject.checkAllSearchResultsWithJava();
//        }

    @Test
    public void test_ex11_ios_version_for_ex5()
    {
        ArticlePageObject ArticlePageObject = ArticlePageObjectFactory.get(driver);
        NavigationUI NavigationUI = NavigationUIFactory.get(driver);
        MyListsPageObject MyListsPageObject = MyListsPageObjectFactory.get(driver);
        SearchPageObject SearchPageObject = SearchPageObjectFactory.get(driver);

        String name_of_folder = "Learning programming";
        //save 1st article
        SearchPageObject.initSearchInput();
        //SearchPageObject.typeSearchLine("Java");
        SearchPageObject.clickByArticleWithSubstring("Object-oriented programming language");
        ArticlePageObject.waitForTitleElement();

        String java_title = ArticlePageObject.getArticleTitle();
        if (Platform.getInstance().isAndroid()){
            ArticlePageObject.addFirstArticleToMyList(name_of_folder);
        }else {
            ArticlePageObject.addArticlesToMySaved();
        }
        ArticlePageObject.closeArticle();

        //save 2nd article
        SearchPageObject.initSearchInput();
        SearchPageObject.typeSearchLine("Cyprus");
        SearchPageObject.clickByArticleWithSubstring("Island country in Mediterranean");;
        ArticlePageObject.waitForTitleElement();
        String cyprus_title2 = ArticlePageObject.getArticleTitle();
        if (Platform.getInstance().isAndroid()){
            ArticlePageObject.addFirstArticleToMyList(name_of_folder);
        }else {
            ArticlePageObject.addArticlesToMySaved();
        }
        ArticlePageObject.closeArticle();

        NavigationUI.clickMyLists();
        if (Platform.getInstance().isAndroid()){
            MyListsPageObject.openFolderByName(name_of_folder);
        }

        MyListsPageObject.swipeArticleToDelete(java_title);

        if (Platform.getInstance().isIOS()){
            SearchPageObject.searchArticleInSaved("Cyprus");
            SearchPageObject.checkNoSavedArticles();

        }




    }

    @Test
    public void test_17_web2Articles()
    {
        String name_of_folder = "Learning programming";
        final String login = "wikitestqa";
        final String password = "Zxcdsa123";

        SearchPageObject SearchPageObject = SearchPageObjectFactory.get(driver);

        SearchPageObject.initSearchInput();
        SearchPageObject.typeSearchLine("Java");
        SearchPageObject.clickByArticleWithSubstring("bject-oriented programming language");
        String ACTUAL_LINK = driver.getCurrentUrl();

        ArticlePageObject ArticlePageObject = ArticlePageObjectFactory.get(driver);
        ArticlePageObject.waitForTitleElement();
        String article_title = ArticlePageObject.getArticleTitle();

        if (Platform.getInstance().isAndroid()){
            ArticlePageObject.addFirstArticleToMyList(name_of_folder);
        }else if (Platform.getInstance().isIOS()){
            ArticlePageObject.addArticlesToMySaved();
        }else if (Platform.getInstance().isMobileWeb()){
            AuthPageObject Auth = new AuthPageObject(driver);
            Auth.clickAuthButton();
            Auth.enterLoginData(login,password);
            Auth.submitForm();
            ArticlePageObject.waitForTitleElement();
            ArticlePageObject.addArticlesToMySaved();
        }
        ArticlePageObject.closeArticle();

        //добавляем вторую статью
        SearchPageObject.initSearchInput();
        SearchPageObject.typeSearchLine("Cyprus");
        SearchPageObject.clickByArticleWithSubstring("sland country in Mediterranean");

        if (Platform.getInstance().isAndroid()){
            ArticlePageObject.addFirstArticleToMyList(name_of_folder);
        }else if (Platform.getInstance().isIOS()){
            ArticlePageObject.addArticlesToMySaved();
        }else if (Platform.getInstance().isMobileWeb()){
            ArticlePageObject.addArticlesToMySaved();
        }

        //удаляем первую статью
        NavigationUI NavigationUI = NavigationUIFactory.get(driver);
        NavigationUI.openNavigation();
        NavigationUI.clickMyLists();

        //открываем папку если мы на андроиде
        MyListsPageObject MyListsPageObject = MyListsPageObjectFactory.get(driver);
        if (Platform.getInstance().isAndroid()){
            MyListsPageObject.openFolderByName(name_of_folder);
        }
        MyListsPageObject.swipeArticleToDelete(article_title);
        driver.navigate().refresh();

        //Проверка для веба
        if (Platform.getInstance().isMobileWeb()){
            MyListsPageObject.clickByNotDeletedArticle();
            String EXPECTED_LINK = driver.getCurrentUrl();
            Assert.assertNotEquals("Links are not equal -that mean that we had deleted correct article",
                    EXPECTED_LINK,
                    ACTUAL_LINK);
        System.out.println("OK");
        }else {
            System.out.println("This method only for web");
        }

    }


}





