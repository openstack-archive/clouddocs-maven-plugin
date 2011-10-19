package com.rackspace.cloud.api.docs;

import java.io.IOException;
import java.net.URL;

import javax.xml.transform.URIResolver;
import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.stream.StreamSource;

import java.util.regex.Pattern;
import java.util.regex.Matcher;

/**
   We are adding a customization layer on top of the docbook one, so we
   need to distinguish when we wish to visit the original docbook
   entries or our entries.

   The resolver helps us do this:

   urn:docbkx:stylesheet-orig : will always point to the original
   stylesheets.
 **/
public class DocBookResolver implements URIResolver {
    private URIResolver originalResolver;
    private String type;
    private static final Pattern urnPatternA = Pattern.compile ("urn:docbkx:stylesheet\\-orig(/.*)?");
    private static final Pattern urnPatternB = Pattern.compile ("urn:docbkx:stylesheet\\-base(/.*)?");
    public DocBookResolver (URIResolver original, String type) {
        this.originalResolver = original;
        this.type = type;
    }

    public Source resolve (String href, String base) throws TransformerException {
        Matcher mA = urnPatternA.matcher (href);
        Matcher mB = urnPatternB.matcher (href);
        if (mA.matches()) {
            String grpMatch = mA.group(1);
            String file = (mA.group(1) == null) ? "/docbook.xsl" : grpMatch;
            String filePath = "docbook/"+type+file;

            URL url = this.getClass().getClassLoader().getResource(filePath);

            if (url != null) {
                try {
                    return new StreamSource (url.openStream(), url.toExternalForm());
                }catch (IOException ioe) {
                    throw new TransformerException ("Can't get docbook refrence "+href+"->"+filePath, ioe);
                }
            } else {
                throw new TransformerException ("Can't resolve docbook link: "+href+"->"+filePath+" Docbook missing in classpath?");
            }
        }else if (mB.matches()) {
            String grpMatch = mB.group(1);
            String file = (mB.group(1) == null) ? "/docbook.xsl" : grpMatch;
            String filePath = "docbook"+file;

            URL url = this.getClass().getClassLoader().getResource(filePath);

            if (url != null) {
                try {
                    return new StreamSource (url.openStream(), url.toExternalForm());
                }catch (IOException ioe) {
                    throw new TransformerException ("Can't get docbook refrence "+href+"->"+filePath, ioe);
                }
            } else {
                throw new TransformerException ("Can't resolve docbook link: "+href+"->"+filePath+" Docbook missing in classpath?");
            }
        }
	
        //
        //  We can't resolve, maybe the next resolver in the chain
        //  can.
        //
        if (originalResolver != null) {
            return originalResolver.resolve (href, base);
        }
        return null;
    }
}
