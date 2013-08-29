package com.rackspace.cloud.api.docs;

import com.agilejava.docbkx.maven.AbstractHtmlMojo;
import com.agilejava.docbkx.maven.PreprocessingFilter;
import com.agilejava.docbkx.maven.TransformerBuilder;
import org.apache.maven.plugin.MojoExecutionException;
import org.xml.sax.InputSource;
import java.io.File;
import java.util.HashMap;
import java.util.Map;

import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.stream.StreamSource;
import javax.xml.transform.Source;
import javax.xml.transform.URIResolver;

public abstract class ApiRefMojo extends AbstractHtmlMojo {

    /**
     * @parameter expression="${project.build.directory}"
     */
    private File projectBuildDirectory;

    /**
     * @parameter 
     *     expression="${generate-html.canonicalUrlBase}"
     *     default-value=""
     */
    private String canonicalUrlBase;

    /**
     * 
     * @parameter 
     *     expression="${generate-html.failOnValidationError}"
     *     default-value="0"
     */
    private String failOnValidationError;
    
    /**
     * A parameter used to specify the security level (external, internal, reviewer, writeronly) of the document.
     *
     * @parameter 
     *     expression="${generate-html.security}" 
     *     default-value=""
     */
    private String security;
	
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

        final InputSource inputSource = new InputSource(sourceFile.toURI().toString());
        Source source = new SAXSource(filter, inputSource);

        Map<String, Object> map = new HashMap<String, Object>();
        
        map.put("security", security);
        map.put("canonicalUrlBase", canonicalUrlBase);
        map.put("failOnValidationError", failOnValidationError);
        map.put("project.build.directory", this.projectBuildDirectory);
        
        return CalabashHelper.createSource(source, pathToPipelineFile, map);
    }
}
