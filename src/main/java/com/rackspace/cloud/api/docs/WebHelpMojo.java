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

    protected TransformerBuilder createTransformerBuilder(URIResolver resolver) {
        return super.createTransformerBuilder (new DocBookResolver (resolver, getType()));
    }

    //Note for this to work, you need to have the customization layer in place.
    protected String getNonDefaultStylesheetLocation() {
      return "cloud/webhelp/docbook.xsl";
    }
    
    public void postProcessResult(File result) throws MojoExecutionException {
	super.postProcessResult(result);
	
	copyTemplate(result);	
    }

    protected void copyTemplate(File result) throws MojoExecutionException {

	final File targetDirectory = result.getParentFile();

	com.rackspace.cloud.api.docs.FileUtils.extractJaredDirectory("content",WebHelpMojo.class,targetDirectory);
	com.rackspace.cloud.api.docs.FileUtils.extractJaredDirectory("common",WebHelpMojo.class,targetDirectory);

	if (getCustomizationParameters() != null) {
	    getLog().info("Listing customization parameters");
	    final Iterator iterator = getCustomizationParameters()
		.iterator();
	    while (iterator.hasNext()) {
		com.agilejava.docbkx.maven.Parameter param = (com.agilejava.docbkx.maven.Parameter) iterator.next();
		if (param.getName().equals("branding")) 
		    {
			getLog().info("Copying favicon.ico");
			com.agilejava.docbkx.maven.FileUtils.copyFile(new File(targetDirectory,"common/images/favicon-" + param.getValue() + ".ico"), new File(targetDirectory,"favicon.ico"));

		    }		
	    }
	}

    }


}