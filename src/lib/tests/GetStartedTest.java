package lib.tests;

import lib.CoreTestCase;
import lib.Platform;
import lib.ui.iOS.WelcomePageObject;
import org.junit.Test;

public class GetStartedTest extends CoreTestCase {

    @Test
    public void testPassWelcome()
    {
        if (Platform.getInstance().isAndroid()){
            return;
        }
        WelcomePageObject WelcomePage = new WelcomePageObject(driver);

        WelcomePage.waitForLearnMoreLink();
        WelcomePage.clickNextButton();

        WelcomePage.waitForNewWaysToExplore();
        WelcomePage.clickNextButton();

        WelcomePage.waitForAddOrEditPrefferedLang();
        WelcomePage.clickNextButton();

        WelcomePage.waitForLearnMoreAboutDataLink();
        WelcomePage.clickGetStartedButton();
    }

}
