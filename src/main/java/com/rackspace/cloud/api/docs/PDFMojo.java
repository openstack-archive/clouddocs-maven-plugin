package com.rackspace.cloud.api.docs;

import java.io.File;

import org.apache.maven.plugin.MojoExecutionException;
import com.agilejava.docbkx.maven.AbstractPdfMojo;
import com.rackspace.cloud.api.docs.FileUtils;

public abstract class PDFMojo extends AbstractPdfMojo {
    /*
       Setup..
    */
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
    }
}
