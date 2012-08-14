package com.rackspace.cloud.api.docs;

import com.agilejava.docbkx.maven.AbstractFoMojo;
import com.agilejava.docbkx.maven.PreprocessingFilter;
import com.agilejava.docbkx.maven.TransformerBuilder;
import com.rackspace.cloud.api.docs.CalabashHelper;
import com.rackspace.cloud.api.docs.FileUtils;
import com.rackspace.cloud.api.docs.GlossaryResolver;

import org.antlr.stringtemplate.StringTemplate;
import org.antlr.stringtemplate.StringTemplateGroup;
import org.apache.avalon.framework.configuration.Configuration;
import org.apache.avalon.framework.configuration.ConfigurationException;
import org.apache.avalon.framework.configuration.DefaultConfigurationBuilder;
import org.apache.commons.io.IOUtils;
import org.apache.fop.apps.FOPException;
import org.apache.fop.apps.FOUserAgent;
import org.apache.fop.apps.Fop;
import org.apache.fop.apps.FopFactory;
import org.apache.fop.apps.MimeConstants;
import org.apache.maven.plugin.MojoExecutionException;
import org.xml.sax.SAXException;

import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.URIResolver;
import javax.xml.transform.sax.SAXResult;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.MalformedURLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

public abstract class PDFMojo extends AbstractFoMojo {
    private File imageDirectory;
    private File sourceDirectory;
    private File sourceDocBook;

    private File coverImageTemplate;
    private File coverImage;

    private static final String COVER_IMAGE_TEMPLATE_NAME = "cover.st";
    private static final String COVER_IMAGE_NAME = "cover.svg";

    private static final String COVER_XSL = "cloud/cover.xsl";

    /**
     * @parameter expression="${project.build.directory}"
     */
    private String projectBuildDirectory;

    /**
     * The greeting to display.
     *
     * @parameter expression="${generate-pdf.branding}" default-value="rackspace"
     */
    private String branding;


    /**
     * Display built for OpenStack logo?
     *
     * @parameter expression="${generate-pdf.builtForOpenStack}" default-value="0"
     */
    private String builtForOpenStack;

    /**
     * Path to an alternative cover logo.
     *
     * @parameter expression="${generate-pdf.coverLogoPath}" default-value=""
     */
    private String coverLogoPath;


    /**
     * Path to an alternative cover logo.
     *
     * @parameter expression="${generate-pdf.secondaryCoverLogoPath}" default-value=""
     */
    private String secondaryCoverLogoPath;


    /**
     * Distance from the left edge of the page at which the 
     * cover logo is displayed. 
     *
     * @parameter expression="${generate-pdf.coverLogoLeft}" default-value=""
     */
    private String coverLogoLeft;

    /**
     * Distance from the top of the page at which teh 
     * cover logo is displayed.
     *
     * @parameter expression="${generate-pdf.coverLogoTop}" default-value=""
     */
    private String coverLogoTop;

    /**
     * url to display under the cover logo. 
     *
     * @parameter expression="${generate-pdf.coverUrl}" default-value=""
     */
    private String coverUrl;

    /**
     * The color to use for the polygon on the cover
     *
     * @parameter expression="${generate-pdf.coverColor}" default-value=""
     */
    private String coverColor;

    /**
     * The greeting to display.
     *
     * @parameter expression="${generate-pdf.variablelistAsBlocks}" 
     */
    private String variablelistAsBlocks;

    
    /**
     * A parameter used to configure how many elements to trim from the URI in the documentation for a wadl method.
     *
     * @parameter expression="${generate-pdf.trim.wadl.uri.count}" default-value=""
     */
    private String trimWadlUriCount;

    /**
     * Controls how the path to the wadl is calculated. If 0 or not set, then 
     * The xslts look for the normalized wadl in /generated-resources/xml/xslt/.
     * Otherwise, in /generated-resources/xml/xslt/path/to/docbook-src, e.g.
     * /generated-resources/xml/xslt/src/docbkx/foo.wadl
     *
     * @parameter expression="${generate-pdf.compute.wadl.path.from.docbook.path}" default-value="0"
     */
    private String computeWadlPathFromDocbookPath;

    /**
     * @parameter 
     *     expression="${generate-pdf.canonicalUrlBase}"
     *     default-value=""
     */
    private String canonicalUrlBase;
    
    /**
     * @parameter 
     *     expression="${generate-pdf.replacementsFile}"
     *     default-value=""
     */
    private String replacementsFile;

    /**
     * 
     * @parameter 
     *     expression="${generate-pdf.failOnValidationError}"
     */
    private String failOnValidationError;
    
    /**
     * A parameter used to specify the security level (external, internal, reviewer, writeronly) of the document.
     *
     * @parameter 
     *     expression="${generate-pdf.security}" 
     */
    private String security;
    
    
    protected void setImageDirectory (File imageDirectory) {
        this.imageDirectory = imageDirectory;
    }

    protected File getImageDirectory() {
        return this.imageDirectory;
    }

    protected String getNonDefaultStylesheetLocation() {
        return "cloud/fo/docbook.xsl";
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

        //
        // Extract all fonts into fonts directory
        //
        FileUtils.extractJaredDirectory("fonts",PDFMojo.class,imageParentDirectory);
    }


    //
    //  Really this is an exact copy of the parent impl, except I use
    //  my own version of loadFOPConfig.  Really, I should be able to
    //  overwrite that method.
    //
    public void postProcessResult(File result) throws MojoExecutionException {
        final FopFactory fopFactory = FopFactory.newInstance();
        final FOUserAgent userAgent = fopFactory.newFOUserAgent();

        // First transform the cover page
        transformCover();

        // FOUserAgent can be used to set PDF metadata
        Configuration configuration = loadFOPConfig();
        InputStream in = null;
        OutputStream out = null;

        try
            {
                String baseURL = sourceDirectory.toURL().toExternalForm();
                baseURL = baseURL.replace("file:/", "file:///");

                userAgent.setBaseURL(baseURL);
                System.err.println ("Absolute path is "+baseURL);

                in = openFileForInput(result);
                out = openFileForOutput(getOutputFile(result));
                fopFactory.setUserConfig(configuration);
                Fop fop = fopFactory.newFop(MimeConstants.MIME_PDF, userAgent, out);

                // Setup JAXP using identity transformer
                TransformerFactory factory = TransformerFactory.newInstance();
                Transformer transformer = factory.newTransformer(); // identity transformer

                // Setup input stream
                Source src = new StreamSource(in);

                // Resulting SAX events (the generated FO) must be piped through to FOP
                Result res = new SAXResult(fop.getDefaultHandler());

                // Start XSLT transformation and FOP processing
                transformer.transform(src, res);
            }
        catch (FOPException e)
            {
                throw new MojoExecutionException("Failed to convert to PDF", e);
            }
        catch (TransformerConfigurationException e)
            {
                throw new MojoExecutionException("Failed to load JAXP configuration", e);
            }
        catch (TransformerException e)
            {
                throw new MojoExecutionException("Failed to transform to PDF", e);
            }
        catch (MalformedURLException e)
            {
                throw new MojoExecutionException("Failed to get FO basedir", e);
            }
        finally
            {
                IOUtils.closeQuietly(out);
                IOUtils.closeQuietly(in);
            }
    }

    protected InputStream openFileForInput(File file)
            throws MojoExecutionException {
        try {
            return new FileInputStream(file);
        } catch (FileNotFoundException fnfe) {
            throw new MojoExecutionException("Failed to open " + file
                    + " for input.");
        }
    }

    protected File getOutputFile(File inputFile) {
        return new File (inputFile.getAbsolutePath().replaceAll(".fo$",".pdf"));
    }

    protected OutputStream openFileForOutput(File file)
            throws MojoExecutionException {
        try {
          return new BufferedOutputStream(new FileOutputStream(file));
        } catch (FileNotFoundException fnfe) {
            throw new MojoExecutionException("Failed to open " + file
                    + " for output.");
        }
    }

    protected Configuration loadFOPConfig() throws MojoExecutionException {
        System.out.println ("At load config");
        String fontPath  = (new File(getTargetDirectory().getParentFile(), "fonts")).getAbsolutePath();
        StringTemplateGroup templateGroup = new StringTemplateGroup("fonts", fontPath);
        StringTemplate template = templateGroup.getInstanceOf("fontconfig");
        DefaultConfigurationBuilder builder = new DefaultConfigurationBuilder();
        template.setAttribute ("fontPath",fontPath);
        final String config = template.toString();
        if (getLog().isDebugEnabled()) {
            getLog().debug(config);
        }
        try {
            return builder.build(IOUtils.toInputStream(config));
        } catch (IOException ioe) {
            throw new MojoExecutionException("Failed to load FOP config.", ioe);
        } catch (SAXException saxe) {
            throw new MojoExecutionException("Failed to parse FOP config.",
                    saxe);
        } catch (ConfigurationException e) {
            throw new MojoExecutionException(
                    "Failed to do something Avalon requires....", e);
        }
   }

    protected TransformerBuilder createTransformerBuilder(URIResolver resolver) {
        return super.createTransformerBuilder (new GlossaryResolver(new DocBookResolver (resolver, getType()), getType()));
    }

    public void adjustTransformer(Transformer transformer, String sourceFilename, File targetFile) {
        super.adjustTransformer(transformer, sourceFilename, targetFile);

	transformer.setParameter("branding", branding);
	transformer.setParameter("builtForOpenStack", builtForOpenStack);
	transformer.setParameter("coverLogoPath", coverLogoPath);
	transformer.setParameter("secondaryCoverLogoPath", secondaryCoverLogoPath);
	transformer.setParameter("coverLogoLeft", coverLogoLeft);
	transformer.setParameter("coverLogoTop", coverLogoTop);
	transformer.setParameter("coverUrl", coverUrl);
	transformer.setParameter("coverColor", coverColor);

	transformer.setParameter("project.build.directory", projectBuildDirectory);

	if(security != null){
	    transformer.setParameter("security",security);
	}
	
   if(trimWadlUriCount != null){
	transformer.setParameter("trim.wadl.uri.count",trimWadlUriCount);
    }

        //
        //  Setup graphics paths
        //
        sourceDocBook = new File(sourceFilename);
        sourceDirectory = sourceDocBook.getParentFile();
        File imageDirectory = getImageDirectory();
        File calloutDirectory = new File (imageDirectory, "callouts");

	transformer.setParameter("docbook.infile",sourceDocBook.getAbsolutePath());
	transformer.setParameter("source.directory",sourceDirectory);
	transformer.setParameter("compute.wadl.path.from.docbook.path",computeWadlPathFromDocbookPath);
	
        transformer.setParameter ("admon.graphics.path", imageDirectory.getAbsolutePath()+File.separator);
        transformer.setParameter ("callout.graphics.path", calloutDirectory.getAbsolutePath()+File.separator);

        //
        //  Setup the background image file
        //
        File cloudSub = new File (imageDirectory, "cloud");
        File ccSub    = new File (imageDirectory, "cc");
        coverImage = new File (cloudSub, COVER_IMAGE_NAME);
        coverImageTemplate = new File (cloudSub, COVER_IMAGE_TEMPLATE_NAME);

	coverImageTemplate = new File (cloudSub, "rackspace-cover.st");

        transformer.setParameter ("cloud.api.background.image", coverImage.getAbsolutePath());
        transformer.setParameter ("cloud.api.cc.image.dir", ccSub.getAbsolutePath());
    }

    protected void transformCover() throws MojoExecutionException {
        try {
            ClassLoader classLoader = Thread.currentThread()
                .getContextClassLoader();

            TransformerFactory factory = TransformerFactory.newInstance();
            Transformer transformer = factory.newTransformer(new StreamSource(classLoader.getResourceAsStream(COVER_XSL)));
	    if(coverColor != null){
		transformer.setParameter("coverColor", coverColor);
	    }
	    transformer.setParameter("branding", branding);

            //transformer.setParameter("docbook.infile",sourceDocBook.getAbsolutePath());
	    	String srcFilename = sourceDocBook.getName();
	    	getLog().info("SOURCE FOR COVER PAGE: "+this.projectBuildDirectory+"/docbkx/"+srcFilename);
	    	transformer.setParameter("docbook.infile", this.projectBuildDirectory+"/docbkx/"+srcFilename);
            transformer.transform (new StreamSource(coverImageTemplate), new StreamResult(coverImage));
        }
        catch (TransformerConfigurationException e)
            {
                throw new MojoExecutionException("Failed to load JAXP configuration", e);
            }
        catch (TransformerException e)
            {
                throw new MojoExecutionException("Failed to transform to cover", e);
            }
    }
    
    
    
    @Override
    protected Source createSource(String inputFilename, File sourceFile, PreprocessingFilter filter)
            throws MojoExecutionException {

        String pathToPipelineFile = "classpath:/test.xpl"; //use "classpath:/path" for this to work
        Source source = super.createSource(inputFilename, sourceFile, filter);

        Map map=new HashMap<String, String>();
        
        map.put("security", security);
        map.put("canonicalUrlBase", canonicalUrlBase);
        map.put("replacementsFile", replacementsFile);
        map.put("failOnValidationError", failOnValidationError);
        map.put("project.build.directory", this.projectBuildDirectory);
        map.put("inputSrcFile", inputFilename);
        //String outputDir=System.getProperty("project.build.outputDirectory ");        
        return CalabashHelper.createSource(source, pathToPipelineFile, map);
    }
}
