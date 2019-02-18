package lib;

import io.appium.java_client.AppiumDriver;
import junit.framework.TestCase;
import junit.framework.TestResult;
import lib.ui.iOS.WelcomePageObject;
import org.openqa.selenium.ScreenOrientation;
import org.openqa.selenium.remote.RemoteWebDriver;

public class CoreTestCase extends TestCase {
    protected RemoteWebDriver driver;

    @Override
    protected void setUp() throws Exception {

        super.setUp();
        driver = Platform.getInstance().getDriver();
        this.rotateScreenPortrait();
        this.skipWelcomePageIOS();
        this.openWikiPageforMobileWeb();
    }

    @Override
    protected void tearDown() throws Exception {
        driver.quit();
        super.tearDown();
    }

    protected void rotateScreenPortrait() {

        if (driver instanceof AppiumDriver) {
            AppiumDriver driver = (AppiumDriver) this.driver;
            driver.rotate(ScreenOrientation.PORTRAIT);
        } else {
            System.out.println("Method swipeUp does nothing for web");
        }


    }

    protected void rotateScreenLandscape() {

        if (driver instanceof AppiumDriver) {
            AppiumDriver driver = (AppiumDriver) this.driver;
            driver.rotate(ScreenOrientation.LANDSCAPE);
        } else {
            System.out.println("Method swipeUp does nothing for web");
        }

    }

    protected void sendAppToBackground(int seconds_amount) {

        if (driver instanceof AppiumDriver) {
            AppiumDriver driver = (AppiumDriver) this.driver;
            driver.runAppInBackground(seconds_amount);
        } else {
            System.out.println("Method swipeUp does nothing for web");
        }
    }

    private void skipWelcomePageIOS()
    {
        if(Platform.getInstance().isIOS()){
            AppiumDriver driver = (AppiumDriver) this.driver;
        WelcomePageObject WelcomePageObject = new WelcomePageObject(driver);
        WelcomePageObject.clickSkip();
            }
    }

    protected void openWikiPageforMobileWeb()
        {
        if (Platform.getInstance().isMobileWeb()){
            driver.get("https://en.m.wikipedia.org");
        }else{
            System.out.println("Method swipeUp does nothing for web");

        }
    }

}



