package lib;

import io.appium.java_client.AppiumDriver;
import io.appium.java_client.android.AndroidDriver;
import io.appium.java_client.ios.IOSDriver;
import junit.framework.TestCase;
import org.openqa.selenium.ScreenOrientation;
import org.openqa.selenium.remote.DesiredCapabilities;

import java.net.URL;

public class iOSTestCase extends TestCase {
    protected AppiumDriver driver;
    private static String AppiumURL = "http://127.0.0.1:4723/wd/hub";

    @Override
    protected void setUp()throws Exception
    {
        super.setUp();
        DesiredCapabilities capabilities = new DesiredCapabilities();

        capabilities.setCapability("platformName","iOS");
        capabilities.setCapability("deviceName","5s11");
        capabilities.setCapability("platformVersion","11.3");
        capabilities.setCapability("app","/Users/nickolay/Lesson_1/apks/Wikipedia.app");

        driver = new IOSDriver(new URL(AppiumURL),capabilities);
        this.rotateScreenPortrait();
    }

    @Override
    protected void tearDown () throws Exception
    {
        driver.quit();
        super.tearDown();
    }

    protected void rotateScreenPortrait()
    {
        driver.rotate(ScreenOrientation.PORTRAIT);
    }
    protected void rotateScreenLandscape()
    {
        driver.rotate(ScreenOrientation.LANDSCAPE);
    }

    protected void sendAppToBackground(int seconds_amount)
    {
        driver.runAppInBackground(seconds_amount);

    }
}
