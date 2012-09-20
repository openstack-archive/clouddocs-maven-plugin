package com.rackspace.cloud.api.docs;

import java.io.File;
import java.io.IOException;
import java.io.StringReader;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.URIResolver;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.maven.plugin.MojoExecutionException;
import org.w3c.dom.Document;
import org.xml.sax.EntityResolver;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import com.agilejava.docbkx.maven.AbstractWebhelpMojo;
import com.agilejava.docbkx.maven.PreprocessingFilter;
import com.agilejava.docbkx.maven.TransformerBuilder;
import com.rackspace.cloud.api.docs.builders.PDFBuilder;

public abstract class WebHelpMojo extends AbstractWebhelpMojo {
    /**
     * Sets the URI for the glossary.
     *
     * @parameter expression="${glossary.uri}" default-value=""
     */
    private String glossaryUri;

    private File sourceDirectory;
    private File sourceDocBook;
    private File atomFeed;
    private File atomFeedClean;
    private static final String COPY_XSL = "cloud/webhelp/copy.xsl";

    /**
     * @parameter expression="${project.build.directory}"
     */
    private String projectBuildDirectory;

    /**
     * Controls whether output is colorized based on revisionflag attributes.
     *
     * @parameter expression="${generate-webhelp.show.changebars}"
     */
    private String showChangebars;
    
     /**
     * Display built for OpenStack logo?
     *
     * @parameter expression="${generate-webhelp.builtForOpenStack}" default-value="0"
     */
    private String builtForOpenStack;

    /**
     * Controls whether output is colorized based on revisionflag attributes.
     *
     * @parameter expression="${generate-webhelp.meta.robots}" 
     */
    private String metaRobots;

    /**
     * Controls whether the version string is used as part of the Disqus identifier.
     *
     * @parameter expression="${generate-webhelp.use.version.for.disqus}" default-value="0"
     */
    private String useVersionForDisqus;

    /**
     * Controls whether the disqus identifier is used.
     *
     * @parameter expression="${generate-webhelp.use.disqus.id}" default-value="1"
     */
    private String useDisqusId;

    /**
     * Controls whether the disqus identifier is used.
     *
     * @parameter expression="${generate-webhelp.disqus_identifier}" 
     */
    private String disqusIdentifier;

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
     * A parameter used to control whether to include Google Analytics goo.
     *
     * @parameter expression="${generate-webhelp.enable.google.analytics}" default-value=""
     */
    private String enableGoogleAnalytics;

    /**
     * A parameter used to control whether to include Google Analytics goo.
     *
     * @parameter expression="${generate-webhelp.google.analytics.id}" default-value=""
     */
    private String googleAnalyticsId;
    
    /**
     * A parameter used to control whether to include Google Analytics goo.
     *
     * @parameter expression="${generate-webhelp.google.analytics.domain}" default-value=""
     */    
    private String googleAnalyticsDomain;

    /**
     * A parameter used to specify the path to the pdf for download in webhelp.
     *
     * @parameter expression="${generate-webhelp.pdf.url}" default-value=""
     */
    private String pdfUrl;

    /**
     * @parameter 
     *     expression="${generate-webhelp.canonicalUrlBase}"
     *     default-value=""
     */
    private String canonicalUrlBase;

    /**
     * @parameter 
     *     expression="${generate-webhelp.replacementsFile}"
     *     default-value="replacements.config"
     */
    private String replacementsFile;
    
    /**
     * @parameter 
     *     expression="${generate-webhelp.makePdf}"
     *     default-value=true
     */
    private boolean makePdf;

    /**
     * @parameter
     *     expression="${generate-webhelp.strictImageValidation}"
     *     default-value=true
     */
    private boolean strictImageValidation;
    
    /**
     * 
     * @parameter 
     *     expression="${generate-webhelp.failOnValidationError}"
     *     default-value="0"
     */
    private String failOnValidationError;
    
    /**
     * A parameter used to specify the security level (external, internal, reviewer, writeronly) of the document.
     *
     * @parameter 
     *     expression="${generate-webhelp.security}" 
     *     default-value=""
     */
    private String security;
 
    /**
     * 
     *
     * @parameter expression="${basedir}"
     */
    private File baseDir;

    /**
     * A parameter used to specify the presence of extensions metadata.
     *
     * @parameter 
     *     expression="${generate-webhelp.includes}" 
     *     default-value=""
     */
    private String transformDir;   
    
    /**
     * A parameter used to configure how many elements to trim from the URI in the documentation for a wadl method.
     *
     * @parameter expression="${generate-webhelp.trim.wadl.uri.count}" default-value=""
     */
    private String trimWadlUriCount;

    /**
     * Controls how the path to the wadl is calculated. If 0 or not set, then
     * The xslts look for the normalized wadl in /generated-resources/xml/xslt/.
     * Otherwise, in /generated-resources/xml/xslt/path/to/docbook-src, e.g.
     * /generated-resources/xml/xslt/src/docbkx/foo.wadl
     *
     * @parameter expression="${generate-webhelp.compute.wadl.path.from.docbook.path}" default-value="0"
     */
    private String computeWadlPathFromDocbookPath;

     /**
      * Sets the email for TildeHash (internal) comments. Note that this
      * doesn't affect Disqus comments.
      *
      * @parameter expression="${generate-webhelp.feedback.email}" default-value=""
      */
    private String feedbackEmail;

     /**
      * Controls whether or not the social icons are displayed.
      *
      * @parameter expression="${generate-webhelp.social.icons}" default-value="0"
      */
    private String socialIcons;
    /**
     * A parameter used to specify the path to the lega notice in webhelp.
     *
     * @parameter expression="${generate-webhelp.legal.notice.url}" default-value="index.html"
     */
    private String legalNoticeUrl;
    
    // Profiling attrs:
    /**
     * @parameter expression="${generate-webhelp.profile.os}" 
     */
    private String profileOs;
    /**
     * @parameter expression="${generate-webhelp.profile.arch}" 
     */
    private String profileArch;
    /**
     * @parameter expression="${generate-webhelp.profile.condition}" 
     */
    private String profileCondition;
    /**
     * @parameter expression="${generate-webhelp.profile.audience}" 
     */
    private String profileAudience;
    /**
     * @parameter expression="${generate-webhelp.profile.conformance}" 
     */
    private String profileConformance;
    /**
     * @parameter expression="${generate-webhelp.profile.revision}" 
     */
    private String profileRevision;
    /**
     * @parameter expression="${generate-webhelp.profile.userlevel}" 
     */
    private String profileUserlevel;
    /**
     * @parameter expression="${generate-webhelp.profile.vendor}" 
     */
    private String profileVendor;
    private String autoPdfUrl;


    /**
     * DOCUMENT ME!
     *
     * @param transformer    DOCUMENT ME!
     * @param sourceFilename DOCUMENT ME!
     * @param targetFile     DOCUMENT ME!
     */
    public void adjustTransformer(Transformer transformer, String sourceFilename, File targetFile) {
        super.adjustTransformer(transformer, sourceFilename, targetFile);
                    
    if(glossaryUri != null){
	  transformer.setParameter("glossary.uri", glossaryUri);
    }

    if(feedbackEmail != null){
      transformer.setParameter("feedback.email", feedbackEmail);
    }


    if(useDisqusId != null){
	transformer.setParameter("use.disqus.id", useDisqusId);
    }

        if (useVersionForDisqus != null) {
            transformer.setParameter("use.version.for.disqus", useVersionForDisqus);
        }
        transformer.setParameter("project.build.directory", projectBuildDirectory);
        transformer.setParameter("branding", branding);
        
        //if the pdf is generated automatically with webhelp then this will be set.
        transformer.setParameter("autoPdfUrl", autoPdfUrl);
        
        transformer.setParameter("builtForOpenStack", builtForOpenStack);
        transformer.setParameter("enable.disqus", enableDisqus);
        if (disqusShortname != null) {
            transformer.setParameter("disqus.shortname", disqusShortname);
        }
        if (disqusIdentifier != null) {
            transformer.setParameter("disqus_identifier", disqusIdentifier);
        }

        if (enableGoogleAnalytics != null) {
            transformer.setParameter("enable.google.analytics", enableGoogleAnalytics);
        }
        if (googleAnalyticsId != null) {
            transformer.setParameter("google.analytics.id", googleAnalyticsId);
        }
        if(googleAnalyticsDomain != null){
        	transformer.setParameter("google.analytics.domain", googleAnalyticsDomain);
        }
        if (pdfUrl != null) {
            transformer.setParameter("pdf.url", pdfUrl);
        }
        if (legalNoticeUrl != null) {
            transformer.setParameter("legal.notice.url", legalNoticeUrl);
        }

    if(canonicalUrlBase != null){
	transformer.setParameter("canonical.url.base",canonicalUrlBase);
    }

    if(security != null){
	transformer.setParameter("security",security);
    }
   if(showChangebars != null){
	transformer.setParameter("show.changebars",showChangebars);
    }
   if(metaRobots != null){
	transformer.setParameter("meta.robots",metaRobots);
    }
   if(trimWadlUriCount != null){
	transformer.setParameter("trim.wadl.uri.count",trimWadlUriCount);
    }

	transformer.setParameter("social.icons",socialIcons);

   sourceDocBook = new File(sourceFilename);
   sourceDirectory = sourceDocBook.getParentFile();
   transformer.setParameter("docbook.infile",sourceDocBook.getAbsolutePath());
   transformer.setParameter("source.directory",sourceDirectory);
   transformer.setParameter("compute.wadl.path.from.docbook.path",computeWadlPathFromDocbookPath);

    }

    protected TransformerBuilder createTransformerBuilder(URIResolver resolver) {
        return super.createTransformerBuilder(new DocBookResolver(resolver, getType()));
    }

    //Note for this to work, you need to have the customization layer in place.
    protected String getNonDefaultStylesheetLocation() {
        return "cloud/webhelp/profile-webhelp.xsl";
    }

    public void postProcessResult(File result) throws MojoExecutionException {

        super.postProcessResult(result);

        copyTemplate(result);

        transformFeed(result);
    }

    protected void copyTemplate(File result) throws MojoExecutionException {

        final File targetDirectory = result.getParentFile();

        com.rackspace.cloud.api.docs.FileUtils.extractJaredDirectory("content", WebHelpMojo.class, targetDirectory);
        com.rackspace.cloud.api.docs.FileUtils.extractJaredDirectory("common", WebHelpMojo.class, targetDirectory);
        com.agilejava.docbkx.maven.FileUtils.copyFile(new File(targetDirectory, "common/images/favicon-" + branding + ".ico"), new File(targetDirectory, "favicon.ico"));
        com.agilejava.docbkx.maven.FileUtils.copyFile(new File(targetDirectory, "common/css/positioning-" + branding + ".css"), new File(targetDirectory, "common/css/positioning.css"));
        com.agilejava.docbkx.maven.FileUtils.copyFile(new File(targetDirectory, "common/main-" + branding + ".js"), new File(targetDirectory, "common/main.js"));
    }


    protected void transformFeed(File result) throws MojoExecutionException {
        try {
	    atomFeed = new File (result.getParentFile(),"atom-doctype.xml");
	    atomFeedClean = new File (result.getParentFile(),"atom.xml");

	    if(!atomFeed.isFile()){
		return;
	    }

            ClassLoader classLoader = Thread.currentThread()
                                            .getContextClassLoader();

            TransformerFactory factory = TransformerFactory.newInstance();
            Transformer transformer = factory.newTransformer(new StreamSource(classLoader.getResourceAsStream(COPY_XSL)));


            DocumentBuilderFactory dbfactory = DocumentBuilderFactory.newInstance();
            dbfactory.setValidating(false);
            DocumentBuilder builder = dbfactory.newDocumentBuilder();
            builder.setEntityResolver(new EntityResolver() {
                @Override
                public InputSource resolveEntity(String publicId, String systemId)
                        throws SAXException, IOException {
                    return new InputSource(new StringReader(""));
                }
            });

            Document xmlDocument = builder.parse(atomFeed);
            DOMSource source = new DOMSource(xmlDocument);

            transformer.transform(source, new StreamResult(atomFeedClean));

            atomFeed.deleteOnExit();

        }
        catch (TransformerConfigurationException e)
            {
            throw new MojoExecutionException("Failed to load JAXP configuration", e);
            }
	catch (javax.xml.parsers.ParserConfigurationException e)
	    {
            throw new MojoExecutionException("Failed to configure parser", e);
	    }
	catch (org.xml.sax.SAXException e)
	    {
            throw new MojoExecutionException("Sax exception", e);
	    }
	catch(java.io.IOException e)
	    {
            throw new MojoExecutionException("IO Exception", e);
	    }
        catch (TransformerException e)
            {
            throw new MojoExecutionException("Failed to transform to atom feed", e);
        }

    }

    public void preProcess() throws MojoExecutionException {
        super.preProcess();

        final File targetDirectory = getTargetDirectory();
        File xslParentDirectory  = targetDirectory.getParentFile();

        if (!targetDirectory.exists()) {
            com.rackspace.cloud.api.docs.FileUtils.mkdir(targetDirectory);
        }

        //
        // Extract all images into the image directory.
        //
        com.rackspace.cloud.api.docs.FileUtils.extractJaredDirectory("cloud/war",PDFMojo.class,xslParentDirectory);
    }


    @Override
    protected Source createSource(String inputFilename, File sourceFile, PreprocessingFilter filter)
            throws MojoExecutionException {

        String pathToPipelineFile = "classpath:/webhelp.xpl"; //use "classpath:/path" for this to work
        Source source = super.createSource(inputFilename, sourceFile, filter);

        Map<String, String> map=new HashMap<String, String>();
        
        map.put("security", this.security);
        map.put("canonicalUrlBase", this.canonicalUrlBase);
        map.put("replacementsFile", this.replacementsFile);
        map.put("failOnValidationError", this.failOnValidationError);
        map.put("project.build.directory", this.projectBuildDirectory);
        map.put("inputSrcFile", inputFilename);
        map.put("strictImageValidation", String.valueOf(this.strictImageValidation));

        // Profiling attrs:
        map.put("profileOs", this.profileOs);
        map.put("profileArch", this.profileArch);
        map.put("profileCondition", this.profileCondition);
        map.put("profileAudience", this.profileAudience);
        map.put("profileConformance", this.profileConformance);
        map.put("profileRevision", this.profileRevision);
        map.put("profileUserlevel", this.profileUserlevel);
        map.put("profileVendor", this.profileVendor);

        int lastSlash=inputFilename.lastIndexOf("/");
        //This is the case if the path includes a relative path
        if(-1!=lastSlash){
        	String theFileName=inputFilename.substring(lastSlash);
        	String theDirName=inputFilename.substring(0,lastSlash);
            
        	int index = theFileName.indexOf('.');
        	if(-1!=index){
            	String targetFile="target/docbkx/webhelp/"+theDirName+theFileName.substring(0,index)+"/content/"+"ext_query.xml";

            	map.put("targetExtQueryFile", targetFile);        		
        	}
        	else{
        		//getLog().info("~~~~~~~~theFileName file has incompatible format: "+theFileName);
        	}

        }
        //This is the case when it's just a file name with no path information
        else{
        	String theFileName=inputFilename;
        	int index = theFileName.indexOf('.');
        	if(-1!=index){
            	String targetFile="target/docbkx/webhelp/"+theFileName.substring(0,index)+"/content/"+"ext_query.xml";
            	map.put("targetExtQueryFile", targetFile);        		
        	}
        	else{
        		//getLog().info("~~~~~~~~inputFilename file has incompatible format: "+inputFilename);
        	}
        }
        
        //targetExtQueryFile can tell us where the html will be built. We pass this absolute path to the
        //pipeline so that the copy-and-transform-image step can use it to calculate where to place the images.
        String targetExtQueryFile = (String) map.get("targetExtQueryFile");
        int pos = targetExtQueryFile.lastIndexOf(File.separator);
        targetExtQueryFile = targetExtQueryFile.substring(0, pos);
        map.put("targetHtmlContentDir", baseDir+File.separator+targetExtQueryFile);
        map.put("targetDir", baseDir.getAbsolutePath()+File.separator+"figures");


        //makePdf is a POM configuration for generate-webhelp goal to control the execution of
        //automatic building of pdf output
        if(this.makePdf) {
        	getLog().info("\n************************************* START: Automatically generating PDF for WEBHELP *************************************");
        	//Target directory for Webhelp points to ${basepath}/target/docbkx/webhelp. So get parent.
        	File baseDir = getTargetDirectory().getParentFile();
        	//The point FO/PDF file output to be generated at ${basepath}/target/docbkx/autopdf.
        	File targetDir = new File(baseDir.getAbsolutePath()+"/autopdf");
        	//Create a new instance of PDFBuilder class and set config variables.
        	PDFBuilder pdfBuilder = new PDFBuilder();
        	
        	pdfBuilder.setProject(getMavenProject());
        	pdfBuilder.setSourceDirectory(getSourceDirectory());
        	pdfBuilder.setAutopdfTargetDirectory(targetDir);
        	pdfBuilder.setBranding(branding);
        	pdfBuilder.setIncludes(getIncludes());
        	pdfBuilder.setEntities(getEntities());
        	
        	String srcFilename = this.projectBuildDirectory+"/docbkx/"+sourceFile.getName();
	    	File tempHandle = new File(srcFilename);
	    	if(tempHandle.exists()) {
	    		System.out.println("***********************"+ srcFilename);
	    		pdfBuilder.setSourceFilePath(srcFilename);
	    	} else {
	    		System.out.println("***********************"+ getSourceDirectory()+File.separator+inputFilename);
	    		pdfBuilder.setSourceFilePath(getSourceDirectory()+File.separator+inputFilename);
	    	}
        	
        	pdfBuilder.setProjectBuildDirectory(baseDir.getAbsolutePath());
        	//setup fonts and images 
        	pdfBuilder.preProcess();
        	//process input docbook to create FO file

        	File foFile = pdfBuilder.processSources(map);
        	//transform FO file to PDF
        	File pdfFile = pdfBuilder.postProcessResult(foFile);
        	//move PDF to where the webhelp stuff is for this docbook.
        	if(pdfFile!=null) {
        		int index = inputFilename.lastIndexOf('.');
        		File targetDirForPdf = new File(getTargetDirectory().getAbsolutePath(),inputFilename.substring(0,index));
        		if(!targetDirForPdf.exists()) {
        			FileUtils.mkdir(targetDirForPdf);
        		}
        		boolean moved = pdfBuilder.movePdfToWebhelpDir(pdfFile, targetDirForPdf);
        		if(moved) {
        			getLog().info("Successfully moved auto-generated PDF file to Webhelp target directory!");
        		} else {
        			getLog().error("Unable to move auto-generated PDF file to Webhelp target directory!");
        		}
        	}
        	autoPdfUrl = "../"+pdfFile.getName();
        	getLog().info("************************************* END: Automatically generating PDF for WEBHELP *************************************\n");
        }

        
        map.put("webhelp", "true");
        
        //this parameter will be used the copy and transform image step to decide whether to just check the existence of an image (for pdf)
        //or to check existence, transform and copy image as well (for html)
        map.put("outputType", "html");

        return CalabashHelper.createSource(source, pathToPipelineFile, map);
    }

}
