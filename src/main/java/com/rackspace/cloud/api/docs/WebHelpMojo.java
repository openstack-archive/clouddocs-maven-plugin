package com.rackspace.cloud.api.docs;

import java.net.*;
import java.io.File;
import java.io.IOException;
import java.io.StringReader;
import java.io.FileInputStream;
import java.io.InputStream;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

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
import javax.xml.transform.sax.SAXSource;

import org.apache.maven.project.MavenProject;

import org.apache.maven.plugin.MojoExecutionException;
import org.w3c.dom.Document;
import org.xml.sax.EntityResolver;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;

import com.agilejava.docbkx.maven.AbstractWebhelpMojo;
import com.agilejava.docbkx.maven.PreprocessingFilter;
import com.agilejava.docbkx.maven.TransformerBuilder;
import com.rackspace.cloud.api.docs.builders.PDFBuilder;

import com.rackspace.cloud.api.docs.CalabashHelper;
import com.rackspace.cloud.api.docs.DocBookResolver;

import com.agilejava.docbkx.maven.Parameter;
import com.agilejava.docbkx.maven.FileUtils;

import java.io.FileOutputStream;
import java.io.IOException;
import java.util.zip.ZipOutputStream;

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
       * A reference to the project.
       *
       * @parameter expression="${project}"
       * @required
       */
      private MavenProject docProject;

    /**
     * @parameter expression="${project.build.directory}"
     */
    private File projectBuildDirectory;
    
    /**
     * Controls whether to build webhelp war output or not.
     *
     * @parameter expression="${generate-webhelp.webhelp.war}" 
     */
    private String webhelpWar;

    /**
     * List of emails (comma delimited) to send a notification to when
     * a war is deployed in autopublish.
     *
     * @parameter expression="${generate-webhelp.publicationNotificationEmails}" 
     */
    private String publicationNotificationEmails;

    /**
     * Controls whether the pubdate is included in the pdf file name.
     * 
     * @parameter expression="${generate-webhelp.includeDateInPdfFilename}" 
     */
    private String includeDateInPdfFilename;

    /**
     * Base for the pdf file name. By default this is the 
     * base of the input xml file.
     * 
     * @parameter expression="${generate-webhelp.pdfFilenameBase}" 
     */
    private String pdfFilenameBase;

    /**
     * Base for the webhelp dir name. By default this is the 
     * base of the input xml file.
     * 
     * @parameter expression="${generate-webhelp.webhelpDirname}" 
     */
    private String webhelpDirname;

    /**
     * Controls whether output is colorized based on revisionflag attributes.
     *
     * @parameter expression="${generate-webhelp.show.changebars}"
     */
    private String showChangebars;
    
     /**
     * Display built for OpenStack logo?
     *
     * @parameter expression="${generate-webhelp.builtForOpenStack}" 
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
     * @parameter expression="${generate-webhelp.secondaryCoverLogoPath}" 
     */
    private String secondaryCoverLogoPath;


    /**
     * Distance from the left edge of the page at which the 
     * cover logo is displayed. 
     *
     * @parameter expression="${generate-webhelp.coverLogoLeft}" default-value=""
     */
    private String coverLogoLeft;

    /**
     * Distance from the top of the page at which teh 
     * cover logo is displayed.
     *
     * @parameter expression="${generate-webhelp.coverLogoTop}" default-value=""
     */
    private String coverLogoTop;

    /**
     * url to display under the cover logo. 
     *
     * @parameter expression="${generate-webhelp.coverUrl}" default-value=""
     */
    private String coverUrl;

    /**
     * The color to use for the polygon on the cover
     *
     * @parameter expression="${generate-webhelp.coverColor}" default-value=""
     */
    private String coverColor;

    /**
     * 
     *
     * @parameter expression="${generate-pdf.pageWidth}" default-value=""
     */
    private String pageWidth;

    /**
     * 
     *
     * @parameter expression="${generate-pdf.pageHeight}" default-value=""
     */
    private String pageHeight;
    /**
     * Should cover be omitted?
     *
     * @parameter expression="${generate-pdf.omitCover}" default-value=""
     */
    private String omitCover;

    /**
     * Double sided pdfs?
     *
     * @parameter expression="${generate-pdf.doubleSided}" default-value=""
     */
    private String doubleSided;


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
     * If makePdf is set to true then just before creating the Webhelp output this variable will be set
     * with the location of the automatically created pdf file. 
     */
    private String autoPdfUrl;

    /**
     * A parameter used to control whether the autoPdfUrl is changed
     * to end with -latest.pdf instead of being the actual file name. 
     *
     * @parameter expression="${generate-webhelp.useLatestSuffixInPdfUrl}" 
     */
    private String useLatestSuffixInPdfUrl;

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
     *     default-value="yes"
     */
    private String failOnValidationError;

    /**
     * 
     * @parameter 
     *     expression="${generate-webhelp.commentsPhp}"
     */
    private String commentsPhp;

    
    /**
     * A parameter used to specify the security level (external, internal, reviewer, writeronly) of the document.
     *
     * @parameter 
     *     expression="${generate-webhelp.security}" 
     *     default-value="external"
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

    /**
     * 
     *
     * @parameter expression="${generate-webhelp.draft.status}" default-value=""
     */
    private String draftStatus;

    /**
     * 
     *
     * @parameter expression="${generate-webhelp.draft.status}" default-value=""
     */
    private String statusBarText;
    
    /**
     *
     * @parameter expression="${generate-webhelp.bodyFont}"
     */
    private String bodyFont;

    /**
     *
     * @parameter expression="${generate-webhelp.monospaceFont}"
     */
    private String monospaceFont;

    /**
     *
     * @parameter expression="${generate-webhelp.localFontPath}"
     */
    private String localFontPath;

    /**
     * DOCUMENT ME!
     *
     * @param transformer    DOCUMENT ME!
     * @param sourceFilename DOCUMENT ME!
     * @param targetFile     DOCUMENT ME!
     */
    public void adjustTransformer(Transformer transformer, String sourceFilename, File targetFile) {
        GitHelper.addCommitProperties(transformer, baseDir, 7, getLog());

	String warBasename;
	String webhelpOutdir = targetFile.getName().substring(0, targetFile.getName().lastIndexOf('.'));
	if(null != webhelpDirname && !webhelpDirname.isEmpty()){
	    warBasename = webhelpDirname;
	} else {
	    warBasename = webhelpOutdir;
	}


	targetFile = new File( getTargetDirectory() + "/" + warBasename + "/dummy.webhelp" );

        super.adjustTransformer(transformer, sourceFilename, targetFile);
                    
                    
    transformer.setParameter("groupId", docProject.getGroupId());
    transformer.setParameter("artifactId", docProject.getArtifactId());
    transformer.setParameter("docProjectVersion", docProject.getVersion());
    transformer.setParameter("pomProjectName", docProject.getName());
    if(commentsPhp != null){
	transformer.setParameter("comments.php", commentsPhp);
    }            
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
        transformer.setParameter("project.build.directory", projectBuildDirectory.toURI().toString());
        transformer.setParameter("branding", branding);
        
        //if the pdf is generated automatically with webhelp then this will be set.
        transformer.setParameter("autoPdfUrl", autoPdfUrl);
        
	if (null != builtForOpenStack) {
	    transformer.setParameter("builtForOpenStack", builtForOpenStack);
	}
	transformer.setParameter("coverLogoPath", coverLogoPath);

	if (null != secondaryCoverLogoPath) {
	    transformer.setParameter("secondaryCoverLogoPath", secondaryCoverLogoPath);
	}
	transformer.setParameter("coverLogoLeft", coverLogoLeft);
	transformer.setParameter("coverLogoTop", coverLogoTop);
	transformer.setParameter("coverUrl", coverUrl);
	transformer.setParameter("coverColor", coverColor);

	if(null != pageWidth){ 	
	    transformer.setParameter("page.width", pageWidth); 
	}
	if(null != pageHeight){ 	
	    transformer.setParameter("page.height", pageHeight); 
	}
	if(null != omitCover){ 	
	    transformer.setParameter("omitCover", omitCover); 
	}
	if(null != doubleSided){ 	
	    transformer.setParameter("double.sided", doubleSided); 
	}


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
        if (useLatestSuffixInPdfUrl != null) {
            transformer.setParameter("useLatestSuffixInPdfUrl", useLatestSuffixInPdfUrl);
        }
        if (legalNoticeUrl != null) {
            transformer.setParameter("legal.notice.url", legalNoticeUrl);
        }
        
    String sysWebhelpWar=System.getProperty("webhelp.war");
	if(null!=sysWebhelpWar && !sysWebhelpWar.isEmpty()){
	    webhelpWar=sysWebhelpWar;
	}
	transformer.setParameter("webhelp.war", webhelpWar);

	if(null != includeDateInPdfFilename){
	    transformer.setParameter("includeDateInPdfFilename", includeDateInPdfFilename); 
	}
	transformer.setParameter("pdfFilenameBase", pdfFilenameBase); 
	transformer.setParameter("webhelpDirname", webhelpDirname); 

	transformer.setParameter("publicationNotificationEmails", publicationNotificationEmails);

	String sysDraftStatus=System.getProperty("draft.status");
	if(null!=sysDraftStatus && !sysDraftStatus.isEmpty()){
	    draftStatus=sysDraftStatus;
	}
	transformer.setParameter("draft.status", draftStatus);

	String sysStatusBarText=System.getProperty("statusBarText");
	if(null!=sysStatusBarText && !sysStatusBarText.isEmpty()){
	    statusBarText=sysStatusBarText;
	}
	if(null != statusBarText){
	    transformer.setParameter("status.bar.text", statusBarText);
	}
	if(null != bodyFont){
	    transformer.setParameter("bodyFont", bodyFont);
	}
	if(null != monospaceFont){
	    transformer.setParameter("monospaceFont", monospaceFont);
	}


    if(canonicalUrlBase != null){
	transformer.setParameter("canonical.url.base",canonicalUrlBase);
    }

    String sysSecurity=System.getProperty("security");
    if(null!=sysSecurity && !sysSecurity.isEmpty()){
	security=sysSecurity;
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
   transformer.setParameter("docbook.infile",sourceDocBook.toURI().toString());
   transformer.setParameter("source.directory",sourceDirectory.toURI().toString());
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
	
	String warBasename;
	String webhelpOutdir = result.getName().substring(0, result.getName().lastIndexOf('.'));
	if(null != webhelpDirname && !webhelpDirname.isEmpty()){
	    warBasename = webhelpDirname;
	} else {
	    warBasename = webhelpOutdir;
	}	
	result = new File( getTargetDirectory() + "/" + warBasename + "/" + "dummy.xml" );

	super.postProcessResult(result);
	
	copyTemplate(result);
    
	transformFeed(result);
	       

	//final File targetDirectory = result.getParentFile();
	//com.rackspace.cloud.api.docs.FileUtils.extractJaredDirectory("apiref",ApiRefMojo.class,targetDirectory);
        
	Properties properties = new Properties();
	InputStream is = null;
	
	try {
	    File f = new File(result.getParentFile(), "webapp/WEB-INF/bookinfo.properties");
	    is = new FileInputStream( f );
	    properties.load(is);
	}
	catch ( Exception e ) { 
	    System.out.println("Got an Exception: " + e.getMessage());          
	}

	warBasename = warBasename == null ? null : new File(warBasename).getName();

	String warSuffix = webhelpDirname != null ? "" : properties.getProperty("warsuffix","");
	String warPrefix = webhelpDirname != null ? "" : properties.getProperty("warprefix","");
	String warSuffixForWar = warSuffix.equals("-external") ? "" : warSuffix;
	if(null != webhelpWar && !"0".equals(webhelpWar)){
	    //Zip up the war from here.
	    File sourceDir = new File(result.getParentFile().getParentFile(), warBasename);
	    File zipFile = new File(result.getParentFile().getParentFile(), warPrefix + warBasename + warSuffixForWar + ".war");
	    //result.deleteOnExit();

	    try{
		//create object of FileOutputStream
		FileOutputStream fout = new FileOutputStream(zipFile);
                                         
		//create object of ZipOutputStream from FileOutputStream
		ZipOutputStream zout = new ZipOutputStream(fout);
                               
		com.rackspace.cloud.api.docs.FileUtils.addDirectory(zout, sourceDir);
                               
		//close the ZipOutputStream
		zout.close();
                                                              
	    }catch(IOException ioe){
		System.out.println("IOException :" + ioe);     
	    }
	}

	//	if(null == webhelpWar || webhelpWar.equals("0")){
	    //TODO: Move dir to add warsuffix/security value
	    //String sourceDir = result.getParentFile().getParentFile()  + "/" + warBasename ;
	    File webhelpDirWithSecurity = new File(result.getParentFile().getParentFile(), warBasename + warSuffix);
	    File webhelpOrigDir = new File(result.getParentFile().getParentFile(), webhelpOutdir );
	    boolean success = webhelpOrigDir.renameTo(webhelpDirWithSecurity);
	    //}
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
        com.rackspace.cloud.api.docs.FileUtils.extractJaredDirectory("cloud/webhelp",PDFMojo.class,xslParentDirectory);
    }

    @Override
    protected Source createSource(String inputFilename, File sourceFile, PreprocessingFilter filter)
            throws MojoExecutionException {

        String pathToPipelineFile = "classpath:///webhelp.xpl"; //use "classpath:///path" for this to work

	String sourceFileNameNormalized = sourceFile.toURI().toString();
	//from super
	final InputSource inputSource = new InputSource(sourceFileNameNormalized);
	Source source = new SAXSource(filter, inputSource);
	//Source source = super.createSource(inputFilename, sourceFile, filter);

        Map<String, Object> map = new HashMap<String, Object>();
        
        
        String sysWebhelpWar=System.getProperty("webhelp.war");
    	if(null!=sysWebhelpWar && !sysWebhelpWar.isEmpty()){
    	    webhelpWar=sysWebhelpWar;
    	}

	String targetDirString = "";
	
	try{
	    targetDirString = this.getTargetDirectory().getParentFile().getCanonicalPath().replace(File.separatorChar, '/');
	}catch(Exception e){
	    getLog().info("Exceptional!" + e);
	}
	map.put("targetDirectory", getTargetDirectory().getParentFile());
    	map.put("webhelp.war", webhelpWar);
	map.put("publicationNotificationEmails", publicationNotificationEmails);
        map.put("includeDateInPdfFilename", includeDateInPdfFilename);    
        map.put("pdfFilenameBase", pdfFilenameBase);    
        map.put("webhelpDirname", webhelpDirname);    
        map.put("groupId", docProject.getGroupId());
        map.put("artifactId", docProject.getArtifactId());
        map.put("docProjectVersion", docProject.getVersion());
	map.put("pomProjectName", docProject.getName());
        map.put("security", this.security);
        map.put("branding", this.branding);
        map.put("canonicalUrlBase", this.canonicalUrlBase);
        map.put("replacementsFile", this.replacementsFile);
        map.put("failOnValidationError", this.failOnValidationError);
        map.put("comments.php", this.commentsPhp);
        map.put("project.build.directory", this.projectBuildDirectory);
        map.put("inputSrcFile", inputFilename);
        map.put("strictImageValidation", String.valueOf(this.strictImageValidation));
        map.put("trim.wadl.uri.count", this.trimWadlUriCount);
        map.put("status.bar.text", getProperty("statusBarText"));
        map.put("bodyFont", getProperty("bodyFont"));
        map.put("monospaceFont", getProperty("monospaceFont"));
        map.put("draft.status", getProperty("draftStatus"));
        
        // Profiling attrs:        
        map.put("profile.os", getProperty("profileOs"));
        map.put("profile.arch", getProperty("profileArch"));
        map.put("profile.condition", getProperty("profileCondition"));
        map.put("profile.audience", getProperty("profileAudience"));
        map.put("profile.conformance", getProperty("profileConformance"));
        map.put("profile.revision", getProperty("profileRevision"));
        map.put("profile.userlevel", getProperty("profileUserlevel"));
        map.put("profile.vendor", getProperty("profileVendor"));

        int lastSlash=inputFilename.lastIndexOf("/");
	//This is the case if the path includes a relative path
	if (-1!=lastSlash){
        	String theFileName=inputFilename.substring(lastSlash);
        	String theDirName=inputFilename.substring(0,lastSlash);
            
        	int index = theFileName.indexOf('.');
        	if(-1!=index){
            	String targetFile=  getTargetDirectory() + "/" + theDirName+theFileName.substring(0,index)+"/content/"+"ext_query.xml";

            	map.put("targetExtQueryFile", targetFile);     
		map.put("targetHtmlContentDir", new File(getTargetDirectory(), theDirName+theFileName.substring(0,index) + "/content/"));
            	map.put("base.dir", new File(getTargetDirectory(), theDirName+theFileName.substring(0,index)));
            	map.put("input.filename",theDirName+theFileName.substring(0,index));
        	}
        	else{
        		//getLog().info("~~~~~~~~theFileName file has incompatible format: "+theFileName);
        	}

        }
        //This is the case when it's just a file name with no path information
        else {
        	String theFileName=inputFilename;
        	int index = theFileName.indexOf('.');
        	if(-1!=index){
            	File targetFile= new File(getTargetDirectory(), theFileName.substring(0,index)+"/content/ext_query.xml");
            	map.put("targetExtQueryFile", targetFile);  
		map.put("targetHtmlContentDir", new File(getTargetDirectory(), theFileName.substring(0,index) + "/content/"));
            	
            	File targetDir = new File(getTargetDirectory(), theFileName.substring(0,index) + "/");
            	map.put("base.dir", targetDir);        		
            	map.put("input.filename", theFileName.substring(0,index));  	      		
        	}
        	else{
        		//getLog().info("~~~~~~~~inputFilename file has incompatible format: "+inputFilename);
        	}
        }

        if (null != webhelpDirname && !webhelpDirname.isEmpty() ) {

	    map.put("targetExtQueryFile", new File(getTargetDirectory(), webhelpDirname + "/content/ext_query.xml"));
	    map.put("base.dir", new File(getTargetDirectory(), webhelpDirname));
	    map.put("targetHtmlContentDir", new File(getTargetDirectory(), webhelpDirname + "/content/"));
	}

        
        //targetExtQueryFile can tell us where the html will be built. We pass this absolute path to the
        //pipeline so that the copy-and-transform-image step can use it to calculate where to place the images.

	map.put("targetDir", new File(baseDir, "figures"));

	// getLog().info("~~~~~~~~FOOBAR~~~~~~~~~~~~~~~~:");
	// getLog().info("~~~~~~~~baseDir:" + baseDir);
	// getLog().info("~~~~~~~~projectBuildDirectory:" + projectBuildDirectory);
	// getLog().info("~~~~~~~~targetDirectory:"+ getTargetDirectory());
	// getLog().info("~~~~~~~~targetDirectory (map.put):" + this.getTargetDirectory().getParentFile().getAbsolutePath());
	// getLog().info("~~~~~~~~inputFilename:" + inputFilename);
	// getLog().info("~~~~~~~~targetExtQueryFile:" + map.get("targetExtQueryFile"));
        // getLog().info("~~~~~~~~targetHtmlContentDir:" + map.get("targetHtmlContentDir"));
	// getLog().info("~~~~~~~~targetDir:" + map.get("targetDir"));	
	// getLog().info("~~~~~~~~FOOBAR~~~~~~~~~~~~~~~~:");

        //makePdf is a POM configuration for generate-webhelp goal to control the execution of
        //automatic building of pdf output
        if(this.makePdf) {
	    if (getLog().isDebugEnabled()) {
        	getLog().info("\n************************************* START: Automatically generating PDF for WEBHELP *************************************");
	    }
        	//Target directory for Webhelp points to ${basepath}/target/docbkx/webhelp. So get parent.
        	File baseDir = getTargetDirectory().getParentFile();
        	//The point FO/PDF file output to be generated at ${basepath}/target/docbkx/autopdf.
        	File targetDir = new File(baseDir.getAbsolutePath(), "autopdf");
        	//Create a new instance of PDFBuilder class and set config variables.
        	PDFBuilder pdfBuilder = new PDFBuilder();
        	
        	pdfBuilder.setProject(getMavenProject());
        	pdfBuilder.setSourceDirectory(getSourceDirectory());
        	pdfBuilder.setAutopdfTargetDirectory(targetDir);
        	pdfBuilder.setCoverColor(coverColor);

        	pdfBuilder.setPageWidth(pageWidth);
        	pdfBuilder.setPageHeight(pageHeight);
        	pdfBuilder.setOmitCover(omitCover);
        	pdfBuilder.setDoubleSided(doubleSided);

        	pdfBuilder.setCoverLogoPath(coverLogoPath);
        	pdfBuilder.setSecondaryCoverLogoPath(secondaryCoverLogoPath);
        	pdfBuilder.setCoverLogoLeft(coverLogoLeft);
        	pdfBuilder.setCoverLogoTop(coverLogoTop);
        	pdfBuilder.setCoverUrl(coverUrl);
		pdfBuilder.setPdfFilenameBase(pdfFilenameBase);
        	        	
        	pdfBuilder.setBranding(branding);
        	pdfBuilder.setBuiltForOpenStack(builtForOpenStack);
        	pdfBuilder.setSecurity(security);
        	pdfBuilder.setDraftStatus(draftStatus);
        	pdfBuilder.setStatusBarText(statusBarText);
        	pdfBuilder.setBodyFont(bodyFont);
        	pdfBuilder.setMonospaceFont(monospaceFont);
        	pdfBuilder.setLocalFontPath(localFontPath);
        	pdfBuilder.setTrimWadlUriCount(trimWadlUriCount);
        	pdfBuilder.setComputeWadlPathFromDocbookPath(computeWadlPathFromDocbookPath);
        	
        	pdfBuilder.setInputFilename(inputFilename);
        	pdfBuilder.setEntities(getEntities());

        	pdfBuilder.setChapterAutolabel(getProperty("chapterAutolabel"));
        	pdfBuilder.setAppendixAutolabel(getProperty("appendixAutolabel"));
        	pdfBuilder.setSectionAutolabel(getProperty("sectionAutolabel"));
        	pdfBuilder.setSectionLabelIncludesComponentLabel(getProperty("sectionLabelIncludesComponentLabel"));
		pdfBuilder.setFormalProcedures(getProperty("formalProcedures"));
		pdfBuilder.setGenerateToc(getProperty("generateToc"));
		pdfBuilder.setTocMaxDepth(getProperty("tocMaxDepth"));
		pdfBuilder.setTocSectionDepth(getProperty("tocSectionDepth"));
        	pdfBuilder.setGlossaryCollection(getProperty("glossaryCollection"));

        	File srcFilename = new File(this.projectBuildDirectory, "docbkx/"+sourceFile.getName());
	    	if(srcFilename.exists()) {
		    if (getLog().isDebugEnabled()) {
	    		getLog().debug("***********************"+ srcFilename);
		    }
	    		pdfBuilder.setSourceFilePath(srcFilename);
	    	} else {
		    if (getLog().isDebugEnabled()) {
	    		getLog().debug("***********************"+ getSourceDirectory()+File.separator+inputFilename);
		    }
	    		pdfBuilder.setSourceFilePath(new File(getSourceDirectory(), inputFilename));
	    	}
        	
        	pdfBuilder.setProjectBuildDirectory(baseDir);
        	//setup fonts and images 
        	pdfBuilder.preProcess();
        	//process input docbook to create FO file

        	File foFile = pdfBuilder.processSources(map);
        	//transform FO file to PDF
        	File pdfFile = pdfBuilder.postProcessResult(foFile);
        	//move PDF to where the webhelp stuff is for this docbook.
        	if(pdfFile!=null) {
		    File targetDirForPdf = ((File)map.get("targetHtmlContentDir")).getParentFile();
        		if(!targetDirForPdf.exists()) {
        			com.rackspace.cloud.api.docs.FileUtils.mkdir(targetDirForPdf);
        		}
        		boolean moved = pdfBuilder.movePdfToWebhelpDir(pdfFile, targetDirForPdf);
        		if(moved && getLog().isDebugEnabled()) {
        			getLog().info("Successfully moved auto-generated PDF file to Webhelp target directory!");
        		} else if(getLog().isDebugEnabled()) {
        			getLog().error("Unable to move auto-generated PDF file to Webhelp target directory!");
        		}
        	}
        	autoPdfUrl = "../"+foFile.getName();
		if (getLog().isDebugEnabled()) {
		    getLog().info("************************************* END: Automatically generating PDF for WEBHELP *************************************\n");
		}
        }

        
        map.put("webhelp", "true");
	map.put("autoPdfUrl",autoPdfUrl);
        //this parameter will be used the copy and transform image step to decide whether to just check the existence of an image (for pdf)
        //or to check existence, transform and copy image as well (for html)
        map.put("outputType", "html");

        return CalabashHelper.createSource(getLog(), source, pathToPipelineFile, map);
    }

}
