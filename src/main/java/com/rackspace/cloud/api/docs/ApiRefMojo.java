package com.rackspace.cloud.api.docs;

import com.agilejava.docbkx.maven.AbstractHtmlMojo;
import com.agilejava.docbkx.maven.PreprocessingFilter;
import com.agilejava.docbkx.maven.TransformerBuilder;
import org.apache.maven.plugin.MojoExecutionException;
import java.io.File;
import javax.xml.transform.stream.StreamSource;
import javax.xml.transform.Source;

public abstract class ApiRefMojo extends AbstractHtmlMojo {

    protected String getNonDefaultStylesheetLocation() {
      return "cloud/apipage/apipage.xsl";
    }

    @Override
    protected Source createSource(String inputFilename, File sourceFile, PreprocessingFilter filter)
            throws MojoExecutionException {

        String pathToPipelineFile = "classpath:/wadl2html.xpl"; //use "classpath:/path" for this to work
        Source source = super.createSource(inputFilename, sourceFile, filter);

        return CalabashHelper.createSource(source, pathToPipelineFile);
    }
}
