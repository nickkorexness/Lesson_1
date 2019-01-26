package lib.tests.iOS;

import lib.iOSTestCase;
import lib.ui.iOS.WelcomePageObject;
import org.junit.Test;

public class GetStartedTest extends iOSTestCase {

    @Test
    public void testPassWelcome()
    {
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
