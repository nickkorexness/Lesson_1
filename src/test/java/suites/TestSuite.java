package suites;

import lib.tests.*;
import org.junit.runner.RunWith;
import org.junit.runners.Suite;

@RunWith(Suite.class)


@Suite.SuiteClasses({
        ArticleTests.class,
        ChangeAppConditionsTests.class,
        GetStartedTest.class,
        MyListsTests.class,
        SearchTests.class

})

public class TestSuite {
}
