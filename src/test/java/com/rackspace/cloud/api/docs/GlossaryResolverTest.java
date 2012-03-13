package com.rackspace.cloud.api.docs;

import org.junit.Before;
import org.junit.Ignore;
import org.junit.Rule;
import org.junit.Test;
import org.junit.experimental.runners.Enclosed;
import org.junit.rules.ExpectedException;
import org.junit.runner.RunWith;

import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;

import static org.junit.Assert.assertNull;

/**
 * User: sbrayman
 * Date: 10/19/11
 */

@RunWith(Enclosed.class)
public class GlossaryResolverTest {

    public static class WhenResolvingTheGlossary {

        URIResolver nullUriResolver;

        @Rule
        public ExpectedException exception = ExpectedException.none();

        @Before
        public void setUp() throws Exception {
            nullUriResolver = null;
        }

        @Test
        public void shouldReturnNullWithNullResolver() throws Exception {
            assertNull("If you pass a bad URL and a null resolver, it should return null",
                       new GlossaryResolver(nullUriResolver, "").resolve("bad URL of some sort", "figure out how base works here"));
        }

        @Ignore
        public void shouldThrowTransformerException() throws Exception {
            //TODO: figure out how to force a TransformerException.
            exception.expect(TransformerException.class);

        }
    }
}