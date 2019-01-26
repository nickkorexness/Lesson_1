package lib;

import io.appium.java_client.AppiumDriver;
import io.appium.java_client.android.AndroidDriver;
import junit.framework.TestCase;
import org.openqa.selenium.ScreenOrientation;
import org.openqa.selenium.remote.DesiredCapabilities;

import java.net.URL;

public class CoreTestCase extends TestCase {
    protected AppiumDriver driver;
    private static String AppiumURL = "http://127.0.0.1:4723/wd/hub";

    private static final String
    PLATFORM_IOS = "ios",
    PLATFORM_ANDROID = "android";

    @Override
    protected void setUp() throws Exception {
        super.setUp();
        DesiredCapabilities capabilities = this.getCapabilitiesByPlatform();

        driver = new AndroidDriver(new URL(AppiumURL), capabilities);
        //driver = this.getDriverByPlatformEnv();
        this.rotateScreenPortrait();
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

    private DesiredCapabilities getCapabilitiesByPlatform() throws Exception {
        String platform = System.getenv("PLATFORM");
        DesiredCapabilities capabilities = new DesiredCapabilities();

        if (platform.equals(PLATFORM_ANDROID)) {
            capabilities.setCapability("platformName", "Android");
            capabilities.setCapability("deviceName", "AndroidTestDevice");
            capabilities.setCapability("platformVersion", "9");
            capabilities.setCapability("automationName", "UiAutomator2");
            capabilities.setCapability("appPackage", "org.wikipedia");
            capabilities.setCapability("appActivity", ".main.MainActivity");
            capabilities.setCapability("app", "/Users/nickolay/Lesson_1/apks/org.wikipedia.apk");
        } else if (platform.equals(PLATFORM_IOS)) {
            capabilities.setCapability("platformName", "iOS");
            capabilities.setCapability("deviceName", "5s11");
            capabilities.setCapability("platformVersion", "11.3");
            capabilities.setCapability("app", "/Users/nickolay/Lesson_1/apks/Wikipedia.app");
        } else {
            throw new Exception("can't get run platform from env variable. Platform value" + platform);
        }
        return  capabilities;
    }

    private void getDriverByPlatformEnv()
    {



    }
}



