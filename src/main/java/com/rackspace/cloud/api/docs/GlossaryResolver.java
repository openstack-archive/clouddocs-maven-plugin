package com.rackspace.cloud.api.docs;

import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;
import javax.xml.transform.stream.StreamSource;
import java.io.IOException;
import java.net.URL;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * User: sbrayman
 * Date: 10/19/11
 */
public class GlossaryResolver implements URIResolver {

    private URIResolver originalResolver;
    private String type;
    private static final Pattern urnPattern = Pattern.compile("urn:rackspace\\-glossary.xml");

    public GlossaryResolver(URIResolver original, String type) {
        this.originalResolver = original;
        this.type = type;
    }

    public Source resolve(String href, String base) throws TransformerException {

        Matcher m = urnPattern.matcher(href);

        if (m.matches()) {
            String filePath = "/glossary.xml";

            URL url = this.getClass().getResource(filePath);

            if (url != null) {
                try {
                    return new StreamSource(url.openStream(), url.toExternalForm());
                } catch (IOException ioe) {
                    throw new TransformerException("Can't get glossary reference " + href + "->" + filePath, ioe);
                }
            } else {
                throw new TransformerException("Can't resolve glossary link: " + href + "->" + filePath + ". Glossary missing in classpath?");
            }
        } else if (originalResolver != null) {          //  We can't resolve, maybe the next resolver in the chain can.
            //System.err.println("This failed to match. " + href);
            return originalResolver.resolve(href, base);
        }
        return null;
    }
}
