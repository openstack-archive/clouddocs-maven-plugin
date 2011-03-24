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

import com.nexwave.nquindexer.SaxHTMLIndex;
import com.nexwave.nquindexer.WriteJSFiles;

import com.nexwave.nsidita.DirList;
import com.nexwave.nsidita.DocFileInfo;
import com.agilejava.docbkx.maven.AbstractWebhelpMojo;

import com.agilejava.docbkx.maven.TransformerBuilder;
import javax.xml.transform.URIResolver;
import com.rackspace.cloud.api.docs.DocBookResolver;

public abstract class WebHelpMojo extends AbstractWebhelpMojo {

    protected TransformerBuilder createTransformerBuilder(URIResolver resolver) {
        return super.createTransformerBuilder (new DocBookResolver (resolver, getType()));
    }

      protected String getNonDefaultStylesheetLocation() {
      return "cloud/webhelp/docbook.xsl";
    }

}


/*

  private String brandingFoobar;

  public void postProcess() throws MojoExecutionException {
    super.postProcess();
    getLog().info("FOOBAR!!! " + brandingFoobar + " BARFOO!!");
  }


*/