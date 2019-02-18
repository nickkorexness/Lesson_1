package lib.ui;

import org.openqa.selenium.remote.RemoteWebDriver;

public class AuthPageObject extends MainPageObject {
    private final static String
        LOGIN_BUTTON = "xpath://body/div/a[text()='Log in']",
        PASSWORD_INPUT = "css:input[name='wpPassword']",
        SUBMIT_BUTTON = "css:button#wpLoginAttempt",
        LOGIN_INPUT = "css:input[name='wpName']";


    public AuthPageObject(RemoteWebDriver driver){
        super(driver);
    }

    public void clickAuthButton()
    {
        this.waitForElementPresent(LOGIN_BUTTON,"cant fing logind button", 5);
        this.waitForElementAndClick(LOGIN_BUTTON, "cant click on login button",5);
    }

    public void enterLoginData(String login, String password)
    {
        this.waitForElementAndSendKeys(LOGIN_INPUT,login,"cant find and input in login input",5);
        this.waitForElementAndSendKeys(PASSWORD_INPUT,password,"cant find and input password",5);
    }

    public void submitForm()
    {
        this.waitForElementAndClick(SUBMIT_BUTTON,":cant click on submit button",5);
    }


}
