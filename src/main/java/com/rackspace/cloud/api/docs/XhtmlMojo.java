package com.rackspace.cloud.api.docs;

import com.rackspace.cloud.api.docs.FileUtils;
import com.agilejava.docbkx.maven.AbstractHtmlMojo;
import com.agilejava.docbkx.maven.PreprocessingFilter;
import com.agilejava.docbkx.maven.TransformerBuilder;
import org.apache.maven.plugin.MojoExecutionException;
import java.io.File;
import java.util.HashMap;
import java.util.Map;

import javax.xml.transform.stream.StreamSource;
import javax.xml.transform.Source;
import javax.xml.transform.URIResolver;

import java.io.FileOutputStream;
import java.io.IOException;
import java.util.zip.ZipOutputStream;

public abstract class XhtmlMojo extends AbstractHtmlMojo {

    private File xslDirectory;

    /**
     * @parameter expression="${project.build.directory}"
     */
    private String projectBuildDirectory;

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
	// Is this even used?
        return "cloud/war/copy.xsl";
    }

    protected void setXslDirectory (File xslDirectory) {
        this.xslDirectory = xslDirectory;
    }

    protected File getXslDirectory() {
        return this.xslDirectory;
    }

    public void postProcessResult(File result) throws MojoExecutionException {
	
	super.postProcessResult(result);
	
	//final File targetDirectory = result.getParentFile();
	// com.rackspace.cloud.api.docs.FileUtils.extractJaredDirectory("apiref",ApiRefMojo.class,targetDirectory);
	String warBasename = result.getName().substring(0, result.getName().lastIndexOf('.'));

	// Zip up the war from here.
	String sourceDir = result.getParentFile() + "/" + warBasename;
	String zipFile = result.getParentFile()  + "/" + warBasename + ".war";
	result.deleteOnExit();

	try
	    {
		//create object of FileOutputStream
		FileOutputStream fout = new FileOutputStream(zipFile);
                                 
		//create object of ZipOutputStream from FileOutputStream
		ZipOutputStream zout = new ZipOutputStream(fout);
                       
		//create File object from source directory
		File fileSource = new File(sourceDir);
                       
		FileUtils.addDirectory(zout, fileSource);
                       
		//close the ZipOutputStream
		zout.close();
                       
		System.out.println("Zip file has been created!");
                       
	    }
	catch(IOException ioe)
	    {
		System.out.println("IOException :" + ioe);     
	    }

    }

    public void preProcess() throws MojoExecutionException {
        super.preProcess();

        final File targetDirectory = getTargetDirectory();
        File xslParentDirectory  = targetDirectory.getParentFile();

        if (!targetDirectory.exists()) {
            FileUtils.mkdir(targetDirectory);
        }

        //
        // Extract all images into the image directory.
        //
        FileUtils.extractJaredDirectory("cloud/war",PDFMojo.class,xslParentDirectory);
        setXslDirectory (new File (xslParentDirectory, "xsls"));

        //
        // Extract all fonts into fonts directory
        //
        //FileUtils.extractJaredDirectory("fonts",PDFMojo.class,imageParentDirectory);
    }



    @Override
    protected Source createSource(String inputFilename, File sourceFile, PreprocessingFilter filter)
            throws MojoExecutionException {

        String pathToPipelineFile = "classpath:/war.xpl"; //use "classpath:/path" for this to work
        Source source = super.createSource(inputFilename, sourceFile, filter);

        Map map=new HashMap<String, String>();
        
        map.put("security", security);
        map.put("failOnValidationError", failOnValidationError);
        
        return CalabashHelper.createSource(source, pathToPipelineFile, map);
    }
}
