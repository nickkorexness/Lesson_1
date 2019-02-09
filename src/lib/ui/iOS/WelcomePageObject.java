package lib.ui.iOS;

import io.appium.java_client.AppiumDriver;
import lib.ui.MainPageObject;
import org.openqa.selenium.By;

public class WelcomePageObject extends MainPageObject {

    public WelcomePageObject (AppiumDriver driver)
    {
        super(driver);
    }

    private static final String
    STEP_LEARN_MORE_LINK = "Learn more about Wikipedia",
    STEP_NEW_WAYS_TO_EXPLORE_TEXT ="New ways to explore",
    STEP_ADD_OR_EDIT_PREFERRED_LANG_LINK = "Add or edit preferred languages",
    STEP_LEARN_MORE_ABOUT_DATA_COLLECTED = "Learn more about data collected",
    NEXT_LINK = "Next",
    SKIP_BUTTON = "xpath://XCUIElementTypeButton[@name='Skip']",
    GET_STARTED_LINK = "Get started";


    public void waitForLearnMoreLink()
    {
        this.waitForElementPresent(STEP_LEARN_MORE_LINK,"Can't find the link",10);
    }

    public void waitForNewWaysToExplore()
    {
        this.waitForElementPresent(STEP_NEW_WAYS_TO_EXPLORE_TEXT,"Can't find the link",10);
    }

    public void waitForAddOrEditPrefferedLang()
    {
        this.waitForElementPresent(STEP_ADD_OR_EDIT_PREFERRED_LANG_LINK,"Can't find the preferred languages text",10);
    }

    public void waitForLearnMoreAboutDataLink()
    {
        this.waitForElementPresent(STEP_LEARN_MORE_ABOUT_DATA_COLLECTED,"Can't find the Learn more about data collected Link",10);
    }

    public void clickNextButton()
    {
        this.waitForElementAndClick(NEXT_LINK,"Can't click on next button",10);
    }

    public void clickGetStartedButton()
    {
        this.waitForElementAndClick(GET_STARTED_LINK,"Can't click on next button",10);
    }

    public void clickSkip()
    {
        this.waitForElementPresent(SKIP_BUTTON, "cant find skip button",10);
        this.waitForElementAndClick(SKIP_BUTTON,"can't find and click on skip button",15);
    }
}
