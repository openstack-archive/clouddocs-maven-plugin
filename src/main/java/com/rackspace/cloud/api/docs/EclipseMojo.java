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

import com.agilejava.docbkx.maven.TransformerBuilder;
import javax.xml.transform.URIResolver;
import com.rackspace.cloud.api.docs.DocBookResolver;

import com.agilejava.docbkx.maven.Parameter;
import com.agilejava.docbkx.maven.FileUtils;
import com.agilejava.docbkx.maven.AbstractEclipseMojo;

public abstract class EclipseMojo extends AbstractEclipseMojo {

    @Override
    public void adjustTransformer(Transformer transformer, String sourceFilename, File targetFile) {
        GitHelper.addCommitProperties(transformer, new File(sourceFilename), 7, getLog());
        super.adjustTransformer(transformer, sourceFilename, targetFile);
    }

}