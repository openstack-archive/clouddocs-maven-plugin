package com.rackspace.cloud.api.docs;

import java.io.File;

import javax.xml.transform.Transformer;
import javax.xml.transform.URIResolver;

import org.apache.maven.plugin.MojoExecutionException;

import com.agilejava.docbkx.maven.TransformerBuilder;
import com.agilejava.docbkx.maven.AbstractPdfMojo;

import com.rackspace.cloud.api.docs.FileUtils;
import com.rackspace.cloud.api.docs.DocBookResolver;

public abstract class PDFMojo extends AbstractPdfMojo {
    private File imageDirectory;

    protected void setImageDirectory (File imageDirectory) {
        this.imageDirectory = imageDirectory;
    }

    protected File getImageDirectory() {
        return this.imageDirectory;
    }

    protected String getNonDefaultStylesheetLocation() {
        return "cloud/fo/dookbook.xsl";
    }


    public void preProcess() throws MojoExecutionException {
        super.preProcess();

        final File targetDirectory = getTargetDirectory();
        File imageParentDirectory  = targetDirectory.getParentFile();

        if (!targetDirectory.exists()) {
            FileUtils.mkdir(targetDirectory);
        }

        //
        // Extract all images into the image directory.
        //
        FileUtils.extractJaredDirectory("images",PDFMojo.class,imageParentDirectory);
        setImageDirectory (new File (imageParentDirectory, "images"));
    }

    protected TransformerBuilder createTransformerBuilder(URIResolver resolver) {
        return super.createTransformerBuilder (new DocBookResolver (resolver, getType()));
    }

    public void adjustTransformer(Transformer transformer, String sourceFilename, File targetFile) {
        super.adjustTransformer(transformer, sourceFilename, targetFile);

        //
        //  Setup graphics paths
        //
        File imageDirectory = getImageDirectory();
        File calloutDirectory = new File (imageDirectory, "callouts");

        transformer.setParameter ("admon.graphics.path", imageDirectory.getAbsolutePath()+File.separator);
        transformer.setParameter ("callout.graphics.path", calloutDirectory.getAbsolutePath()+File.separator);
    }
}
