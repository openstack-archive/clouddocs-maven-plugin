package com.rackspace.cloud.api.docs;

import org.apache.maven.plugin.MojoExecutionException;
import org.junit.Before;
import org.junit.Test;
import org.junit.experimental.runners.Enclosed;
import org.junit.runner.RunWith;
import org.xml.sax.InputSource;

import javax.xml.transform.Source;
import javax.xml.transform.sax.SAXSource;

import static org.mockito.Mockito.mock;

/**
 * User: sbrayman
 * Date: 12/14/11
 */

@RunWith(Enclosed.class)
public class CalabashHelperTest {
    public static class whenUsingCalabashHelper {

        String pipelineURI = null;
        InputSource inputSource = null;
        Source source = null;

        @Before
        public void setUp() throws Exception {
            pipelineURI = "/Users/sbrayman/Documents/workspace/rc-maven-cloud-docs/src/main/resources/test.xpl";
            inputSource = mock(InputSource.class);
            source = mock(Source.class);
        }

        @Test (expected=MojoExecutionException.class)
        public void shouldThrowSAXSourceError() throws Exception {
            CalabashHelper.createSource(source);
        }
    }
}
