package com.rackspace.cloud.api.docs;

import com.agilejava.docbkx.maven.AbstractHtmlMojo;
import com.agilejava.docbkx.maven.PreprocessingFilter;
import com.agilejava.docbkx.maven.TransformerBuilder;
import org.apache.maven.plugin.MojoExecutionException;
import java.io.File;
import javax.xml.transform.stream.StreamSource;
import javax.xml.transform.Source;
import javax.xml.transform.URIResolver;

public abstract class ApiRefMojo extends AbstractHtmlMojo {

    protected TransformerBuilder createTransformerBuilder(URIResolver resolver) {
        return super.createTransformerBuilder (new DocBookResolver (resolver, getType()));
    }

    protected String getNonDefaultStylesheetLocation() {
      return "cloud/apipage/apipage.xsl";
    }

    public void postProcessResult(File result) throws MojoExecutionException {
	
	super.postProcessResult(result);
	
	final File targetDirectory = result.getParentFile();
	com.rackspace.cloud.api.docs.FileUtils.extractJaredDirectory("apiref",ApiRefMojo.class,targetDirectory);

    }


    @Override
    protected Source createSource(String inputFilename, File sourceFile, PreprocessingFilter filter)
            throws MojoExecutionException {

        String pathToPipelineFile = "classpath:/wadl2html.xpl"; //use "classpath:/path" for this to work
        Source source = super.createSource(inputFilename, sourceFile, filter);

        return CalabashHelper.createSource(source, pathToPipelineFile);
    }
}
