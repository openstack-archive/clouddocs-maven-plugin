package com.rackspace.cloud.api.docs;

import org.apache.maven.plugin.MojoExecutionException;
import org.junit.Before;
import org.junit.Test;
import org.junit.experimental.runners.Enclosed;
import org.junit.runner.RunWith;

import javax.xml.transform.Source;

import static org.mockito.Mockito.mock;

/**
 * User: sbrayman
 * Date: 12/14/11
 */

@RunWith(Enclosed.class)
public class CalabashHelperTest {
    public static class whenUsingCalabashHelper {

        Source source = null;

        @Before
        public void setUp() throws Exception {
            source = mock(Source.class);
        }

        @Test (expected=MojoExecutionException.class)
        public void shouldThrowSAXSourceError() throws Exception {
            CalabashHelper.createSource(null, source, null,null);
        }
    }
}
