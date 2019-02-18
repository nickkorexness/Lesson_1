package lib.ui.factories;

import io.appium.java_client.AppiumDriver;
import lib.Platform;
import lib.ui.ArticlePageObject;
import lib.ui.android.AndroidArticlePageObject;
import lib.ui.iOS.IOSArticlePageObject;
import lib.ui.iOS.IOSSearchPageObject;
import lib.ui.mobile_web.MWArticlePageObject;
import lib.ui.mobile_web.MWSearchPageObject;
import org.openqa.selenium.remote.RemoteWebDriver;

public class ArticlePageObjectFactory {

    public static ArticlePageObject get(RemoteWebDriver driver)
    {
        if (Platform.getInstance().isAndroid()){
            return new AndroidArticlePageObject(driver);
        }else if (Platform.getInstance().isIOS()){
            return new IOSArticlePageObject(driver);
        }else {
            return new MWArticlePageObject(driver);
        }
    }
}
