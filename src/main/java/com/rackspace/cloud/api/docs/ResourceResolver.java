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
public class ResourceResolver implements URIResolver {  //TODO: Kill this class?

    private URIResolver originalResolver;
    private String type;
    private String exampleIri = "mvn://com.rackspace.cloud.api:glossary/glossary.xml";

    public ResourceResolver(URIResolver original, String type) {
        this.originalResolver = original;
        this.type = type;
    }

    public Source resolve(String href, String base) throws TransformerException {

        String filePath = exampleIri;

        URL url = this.getClass().getResource(filePath);

        if (url != null) {
            try {
                return new StreamSource(url.openStream(), url.toExternalForm());
            } catch (IOException ioe) {
                throw new TransformerException("Can't resolve path: " + href + "->" + filePath + ". Resource missing in classpath?", ioe);
            }
        }
        //System.err.println("This failed to match. " + href);
        return originalResolver.resolve(href, base);
    }
}
