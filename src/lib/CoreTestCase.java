package lib;

import io.appium.java_client.AppiumDriver;
import junit.framework.TestCase;
import junit.framework.TestResult;
import lib.ui.iOS.WelcomePageObject;
import org.openqa.selenium.ScreenOrientation;

public class CoreTestCase extends TestCase {
    protected AppiumDriver driver;

    @Override
    protected void setUp() throws Exception {

        super.setUp();
        driver = Platform.getInstance().getDriver();
        this.rotateScreenPortrait();
        this.skipWelcomePageIOS();
    }

    @Override
    protected void tearDown() throws Exception {
        driver.quit();
        super.tearDown();
    }

    protected void rotateScreenPortrait() {
        driver.rotate(ScreenOrientation.PORTRAIT);
    }

    protected void rotateScreenLandscape() {
        driver.rotate(ScreenOrientation.LANDSCAPE);
    }

    protected void sendAppToBackground(int seconds_amount) {
        driver.runAppInBackground(seconds_amount);
    }

    private void skipWelcomePageIOS()
    {
        if(Platform.getInstance().isIOS()){
        WelcomePageObject WelcomePageObject = new WelcomePageObject(driver);
        WelcomePageObject.clickSkip();
    }
    }

}



