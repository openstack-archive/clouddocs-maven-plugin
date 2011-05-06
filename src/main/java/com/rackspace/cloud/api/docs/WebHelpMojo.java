package com.rackspace.cloud.api.docs;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

import java.net.URL;

import java.security.CodeSource;
import java.util.*;
import java.util.zip.ZipInputStream;

import javax.xml.transform.Transformer;

import org.apache.maven.plugin.MojoExecutionException;
import com.agilejava.docbkx.maven.AbstractWebhelpMojo;

import com.agilejava.docbkx.maven.TransformerBuilder;
import javax.xml.transform.URIResolver;
import com.rackspace.cloud.api.docs.DocBookResolver;

import com.agilejava.docbkx.maven.Parameter;
import com.agilejava.docbkx.maven.FileUtils;

public abstract class WebHelpMojo extends AbstractWebhelpMojo {

    /**
     * Controls the branding of the output.
     *
     * @parameter expression="${generate-webhelp.branding}" default-value="rackspace"
     */
    private String branding;

    /**
     * Controls whether Disqus comments appear at the bottom of each page.
     *
     * @parameter expression="${generate-webhelp.enable.disqus}" default-value="0"
     */
    private String enableDisqus;

    /**
     * A parameter used by the Disqus comments. 
     *
     * @parameter expression="${generate-webhelp.disqus.shortname}" default-value=""
     */
    private String disqusShortname;

  /**
   * DOCUMENT ME!
   *
   * @param transformer DOCUMENT ME!
   * @param sourceFilename DOCUMENT ME!
   * @param targetFile DOCUMENT ME!
   */
  public void adjustTransformer(Transformer transformer, String sourceFilename, File targetFile) {
    super.adjustTransformer(transformer, sourceFilename, targetFile);

    transformer.setParameter("branding", branding);
    transformer.setParameter("enable.disqus", enableDisqus);
    if(disqusShortname != null){
	transformer.setParameter("disqus.shortname", disqusShortname);
    }
  }

    protected TransformerBuilder createTransformerBuilder(URIResolver resolver) {
        return super.createTransformerBuilder (new DocBookResolver (resolver, getType()));
    }

    //Note for this to work, you need to have the customization layer in place.
    protected String getNonDefaultStylesheetLocation() {
      return "cloud/webhelp/profile-webhelp.xsl";
    }
    
    public void postProcessResult(File result) throws MojoExecutionException {
	super.postProcessResult(result);
	
	copyTemplate(result);	
    }

    protected void copyTemplate(File result) throws MojoExecutionException {

	final File targetDirectory = result.getParentFile();

	com.rackspace.cloud.api.docs.FileUtils.extractJaredDirectory("content",WebHelpMojo.class,targetDirectory);
	com.rackspace.cloud.api.docs.FileUtils.extractJaredDirectory("common",WebHelpMojo.class,targetDirectory);
	com.agilejava.docbkx.maven.FileUtils.copyFile(new File(targetDirectory,"common/images/favicon-" + branding + ".ico"), new File(targetDirectory,"favicon.ico"));
	com.agilejava.docbkx.maven.FileUtils.copyFile(new File(targetDirectory,"common/css/positioning-" + branding + ".css"), new File(targetDirectory,"common/css/positioning.css"));
	com.agilejava.docbkx.maven.FileUtils.copyFile(new File(targetDirectory,"common/main-" + branding + ".js"), new File(targetDirectory,"common/main.js"));
    }


}