package com.rackspace.cloud.api.docs;

import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;
import org.junit.experimental.runners.Enclosed;
import org.junit.runner.RunWith;
import org.xml.sax.InputSource;

import javax.xml.transform.Source;
import javax.xml.transform.sax.SAXSource;

import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.mock;

/**
 * User: sbrayman
 * Date: 12/14/11
 */

@RunWith(Enclosed.class)
public class CalabashHelperTest {
    public static class whenUsingCalabashHelper {

        String pipelineURI = null;
        SAXSource source = null;
        InputSource inputSource = null;

        @Before
        public void setUp() throws Exception {
            pipelineURI = "/Users/sbrayman/Documents/workspace/rc-maven-cloud-docs/src/main/resources/test.xpl";
            source = new SAXSource(mock(InputSource.class));
        }

        @Ignore  //ugh
        @Test
        public void shouldReturnSource() throws Exception {
            assertTrue("This should return an object of type Source", CalabashHelper.createSource(source) instanceof Source);
        }
    }
}
