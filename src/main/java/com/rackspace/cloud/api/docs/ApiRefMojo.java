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
import javax.xml.transform.Transformer;
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
     * Specifies the Goggle Analytics Id to use on the page
     *
     * @parameter expression="${generate-html.enableGoogleAnalytics}" default-value="1"
     */
    private String enableGoogleAnalytics;

    /**
     * Specifies the Goggle Analytics Id to use on the page
     *
     * @parameter expression="${generate-html.googleAnalyticsId}" default-value="UA-17511903-1"
     */
    private String googleAnalyticsId;

    /**
     * Specifies the Goggle Analytics domain to use on the page
     *
     * @parameter expression="${generate-html.googleAnalyticsDomain}" default-value=".openstack.org"
     */
    private String googleAnalyticsDomain;

    /**
     * A parameter used to specify the security level (external, internal, reviewer, writeronly) of the document.
     *
     * @parameter 
     *     expression="${generate-html.security}" 
     *     default-value=""
     */
    private String security;
     /**
     * Base for the html dir name. By default this is the
     * base of the input xml file.
     *
     * @parameter expression="${generate-webhelp.webhelpDirname}"
     */
    private String pdfFilename;
    /**
     * Specifies the branding to use on the page
     *
     * @parameter expression="${generate-html.branding}" default-value="openstack"
     */
    private String branding;

    protected TransformerBuilder createTransformerBuilder(URIResolver resolver) {
        return super.createTransformerBuilder (new DocBookResolver (resolver, getType()));
    }

    @Override
    public void adjustTransformer(Transformer transformer, String sourceFilename, File targetFile) {
        GitHelper.addCommitProperties(transformer, projectBuildDirectory, 7, getLog());
        super.adjustTransformer(transformer, sourceFilename, targetFile);
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

        String pathToPipelineFile = "classpath:///wadl2html.xpl"; //use "classpath:///path" for this to work

        final InputSource inputSource = new InputSource(sourceFile.toURI().toString());
        Source source = new SAXSource(filter, inputSource);

        Map<String, Object> map = new HashMap<String, Object>();
        
        map.put("security", security);
        map.put("pdfFilename", pdfFilename);
        map.put("branding", branding);
        map.put("canonicalUrlBase", canonicalUrlBase);
        map.put("failOnValidationError", failOnValidationError);
        map.put("project.build.directory", this.projectBuildDirectory);
        map.put("enableGoogleAnalytics", enableGoogleAnalytics);
        map.put("googleAnalyticsId", googleAnalyticsId);
        map.put("googleAnalyticsDomain", googleAnalyticsDomain);
        map.put("targetHtmlContentDir", new File(getTargetDirectory(),  "/wadls/"));
        return CalabashHelper.createSource(getLog(), source, pathToPipelineFile, map);
    }
}
