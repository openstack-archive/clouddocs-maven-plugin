package com.rackspace.cloud.api.docs.builders;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import javax.servlet.jsp.el.ELException;
import javax.servlet.jsp.el.VariableResolver;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParserFactory;
import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.URIResolver;
import javax.xml.transform.sax.SAXResult;
import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

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
import org.apache.maven.plugin.logging.Log;
import org.apache.maven.plugin.logging.SystemStreamLog;
import org.apache.maven.project.MavenProject;
import org.apache.xerces.jaxp.SAXParserFactoryImpl;
import org.apache.xml.resolver.CatalogManager;
import org.apache.xml.resolver.tools.CatalogResolver;
import org.codehaus.plexus.util.DirectoryScanner;
import org.xml.sax.EntityResolver;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;

import com.agilejava.docbkx.maven.CachingTransformerBuilder;
import com.agilejava.docbkx.maven.Entity;
import com.agilejava.docbkx.maven.ExpressionHandler;
import com.agilejava.docbkx.maven.InjectingEntityResolver;
import com.agilejava.docbkx.maven.NullWriter;
import com.agilejava.docbkx.maven.Parameter;
import com.agilejava.docbkx.maven.PreprocessingFilter;
import com.agilejava.docbkx.maven.ProcessingInstructionHandler;
import com.agilejava.docbkx.maven.StylesheetResolver;
import com.agilejava.docbkx.maven.TransformerBuilder;
import com.icl.saxon.Controller;
import com.icl.saxon.TransformerFactoryImpl;
import com.rackspace.cloud.api.docs.CalabashHelper;
import com.rackspace.cloud.api.docs.DocBookResolver;
import com.rackspace.cloud.api.docs.FileUtils;
import com.rackspace.cloud.api.docs.GlossaryResolver;

public class PDFBuilder {
	private MavenProject project;

	protected String[] catalogs = { "catalog.xml", "docbook/catalog.xml" };

	private File coverImageTemplate;
	private File coverImage;

	private static final String COVER_IMAGE_TEMPLATE_NAME = "cover.st";
	private static final String COVER_IMAGE_NAME = "cover.svg";

	private static final String COVER_XSL = "cloud/cover.xsl";

	// configure fopFactory as desired
	private String inputFilename = null; 
	
	private File autopdfTargetDirectory = null;
	private File webhelpTargetDirectory = null;
	private File sourceDirectory = null;
	private File imageDirectory = null;
	private File sourceFilePath;
	private File projectBuildDirectory;
	//transformer settings
	//TODO: need to somehow pass coverLogoPath, secondaryCoverLogoPath, coverLogoLeft, coverLogoTop, coverUrl from the WebHelp flow
	private String coverColor;
	private String pageWidth;
	private String pageHeight;
	private String omitCover;
        private String doubleSided;
	private String coverLogoPath;
	private String secondaryCoverLogoPath;
	private String coverLogoLeft;
	private String coverLogoTop;
	private String coverUrl;
	private String branding;
	private String builtForOpenStack;
	private String security;

        private String chapterAutolabel;
        private String appendixAutolabel;
        private String sectionAutolabel;
        private String sectionLabelIncludesComponentLabel;
        private String formalProcedures;
        private String generateToc;
        private String tocMaxDepth;
        private String tocSectionDepth;
        private String glossaryCollection;

	private String draftStatus;
	private String statusBarText;
	private String bodyFont;
	private String monospaceFont;
	private String localFontPath;
	private String trimWadlUriCount;
	private String computeWadlPathFromDocbookPath;
        private String pdfFilenameBase;

	/**
	 * The location of the stylesheet customization.
	 *
	 * @parameter
	 */
	private String foCustomization;
	private List<Parameter> customizationParameters = new ArrayList<Parameter>();
	private List<Entity> entities;


	private Log log = null;

	public Log getLog() {
		if ( log == null ) {
			log = new SystemStreamLog();
		}
		return log;
	}

	public void preProcess() throws MojoExecutionException {
		final File targetDirectory = getAutopdfTargetDirectory();
		File imageParentDirectory  = targetDirectory.getParentFile();

		if (!targetDirectory.exists()) {
			FileUtils.mkdir(targetDirectory);
		}

		//
		// Extract all images into the image directory.
		//
		FileUtils.extractJaredDirectory("images",PDFBuilder.class,imageParentDirectory);
		setImageDirectory (new File (imageParentDirectory, "images"));

		//
		// Extract all fonts into fonts directory
		//
		FileUtils.extractJaredDirectory("fonts",PDFBuilder.class,imageParentDirectory);
	}

	public File processSources(Map<String, Object> map) throws MojoExecutionException {
		final String[] included = scanIncludedFiles();
		// configure a resolver for catalog files
		final CatalogManager catalogManager = createCatalogManager();
		final CatalogResolver catalogResolver = new CatalogResolver(catalogManager);
		// configure a resolver for urn:dockbx:stylesheet
		final URIResolver uriResolver = createStyleSheetResolver(catalogResolver);

		// configure a resolver for xml entities
		final InjectingEntityResolver injectingResolver = createEntityResolver(catalogResolver);

		EntityResolver resolver = catalogResolver;
		if (injectingResolver != null) {
			resolver = injectingResolver;
		}

		// configure the builder for XSL Transforms
		final TransformerBuilder builder = createTransformerBuilder(uriResolver);
		// configure the XML parser
		SAXParserFactory factory = createParserFactory();

		for (int i = included.length - 1; i >= 0; i--) {

			try {
				if (injectingResolver != null) {

					injectingResolver.forceInjection();
				}

				final String inputFilename = included[i];

				//final String inputFilename = sourceFilePath;
				// targetFilename is inputFilename - ".xml" + targetFile extension				
				String baseTargetFile;
				if(null != pdfFilenameBase && !pdfFilenameBase.isEmpty()){
				    baseTargetFile = pdfFilenameBase;
				} else {
				    baseTargetFile = inputFilename.substring(0, inputFilename.length() - 4);
				}

				final String targetFilename = baseTargetFile + ".fo";

				final File sourceFile = new File(sourceDirectory, inputFilename);
				File targetFile = new File(autopdfTargetDirectory, targetFilename);

				final XMLReader reader = factory.newSAXParser().getXMLReader();
				// configure XML reader
				reader.setEntityResolver(resolver);
				// eval PI
				final PreprocessingFilter filter = createPIHandler(resolver, reader);
				// configure SAXSource for XInclude
				final Source xmlSource = createSource(inputFilename, sourceFile, filter, map);

				// XSL Transformation
				final Transformer transformer = builder.build();
				adjustTransformer(transformer, sourceFile.getAbsolutePath(), targetFile);
				final Result result = new StreamResult(targetFile.getAbsolutePath());

				transformer.transform(xmlSource, result);
				if (getLog().isDebugEnabled()) {
				    getLog().debug(targetFile + " has been generated.");
				}
				return targetFile;
			} catch (SAXException saxe) {
				throw new MojoExecutionException("Failed to parse " + sourceFilePath + ".", saxe);
			} catch (TransformerException te) {
				throw new MojoExecutionException("Failed to transform " + sourceFilePath + ".", te);
			} catch (ParserConfigurationException pce) {
				throw new MojoExecutionException("Failed to construct parser.", pce);
			} 
		}
		return null;
	}

	public File postProcessResult(File result) throws MojoExecutionException {
		final FopFactory fopFactory = FopFactory.newInstance();
		final FOUserAgent userAgent = fopFactory.newFOUserAgent();

		// First transform the cover page
		transformCover();

		// Get properties file from webhelp war
		String warBasename = result.getName().substring(0, result.getName().lastIndexOf('.'));
	
		Properties properties = new Properties();
		InputStream is;
		
		try {
		    File f = new File(projectBuildDirectory, "autopdf/pdf.properties");
		    is = new FileInputStream( f );
		    properties.load(is);
		}
		catch ( Exception e ) { 
		    System.out.println("Got an Exception: " + e.getMessage());          
		}

		// FOUserAgent can be used to set PDF metadata
		Configuration configuration = loadFOPConfig();
		InputStream in = null;
		OutputStream out = null;
		File targetPdfFile = null;
		try
		{
			String baseURL = sourceDirectory.toURI().toURL().toExternalForm();
			baseURL = baseURL.replace("file:/", "file:///");

			userAgent.setBaseURL(baseURL);
			if (getLog().isDebugEnabled()) {
			    getLog().debug("Absolute path is "+baseURL);
			}
			in = new FileInputStream(result);

			targetPdfFile = new File (result.getAbsolutePath().replaceAll(".fo$", properties.getProperty("pdfsuffix","") + ".pdf"));
			out = new FileOutputStream(targetPdfFile);
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
		} catch (FileNotFoundException e) {
			throw new MojoExecutionException("File not found!", e);
		}
		finally
		{
			IOUtils.closeQuietly(out);
			IOUtils.closeQuietly(in);
		}
		return targetPdfFile;
	}
	
	public boolean movePdfToWebhelpDir(File pdfFile, File webhelpTargetDir) {
		if(pdfFile.renameTo(new File(webhelpTargetDir,pdfFile.getName()))){
			return true;
		}
		return false;
	}

	public void adjustTransformer(Transformer transformer, String sourceFilename, File targetFile) {
		String baseUrl;
		try {
			final String str = (new File(sourceFilename)).getParentFile().toURI().toURL().toExternalForm();
			baseUrl = str.replace("file:/", "file:///");
		} catch (MalformedURLException e) {
			getLog().warn("Failed to get FO basedir", e);
		}
		
		// Only set this here! Don't ever set in PdfMojo
		transformer.setParameter("autoPdfGlossaryInfix","/..");

		transformer.setParameter("branding", branding);

		if(null != builtForOpenStack){
		    transformer.setParameter("builtForOpenStack", builtForOpenStack);
		}
		transformer.setParameter("coverLogoPath", coverLogoPath);

		if(null != secondaryCoverLogoPath){
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

		if(null != glossaryCollection){
		    transformer.setParameter("glossary.collection", glossaryCollection);
		}
		if(null != sectionAutolabel){
		    transformer.setParameter("section.autolabel", sectionAutolabel);
		}
		if(null != sectionLabelIncludesComponentLabel){
		    transformer.setParameter("section.label.includes.component.label", sectionLabelIncludesComponentLabel);
		}
		if(null != chapterAutolabel){
		    transformer.setParameter("chapter.autolabel", chapterAutolabel);
		}
		if(null != appendixAutolabel){
		    transformer.setParameter("appendix.autolabel", appendixAutolabel);
		}

		if(null != generateToc){
		    transformer.setParameter("generate.toc", generateToc);
		}
		if(null != tocMaxDepth){
		    transformer.setParameter("toc.max.depth", tocMaxDepth);
		}
		if(null != tocSectionDepth){
		    transformer.setParameter("toc.section.depth", tocSectionDepth);
		}
		if(null != formalProcedures){
		    transformer.setParameter("formal.procedures", formalProcedures);
		}
		
		transformer.setParameter("project.build.directory", projectBuildDirectory.toURI().toString());

		String sysSecurity=System.getProperty("security");
		if(null!=sysSecurity && !sysSecurity.isEmpty()){
		    security=sysSecurity;
		}
		if(security != null){
		    transformer.setParameter("security",security);
		}

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

		if(trimWadlUriCount != null){
			transformer.setParameter("trim.wadl.uri.count",trimWadlUriCount);
		}

		//
		//  Setup graphics paths
		//
		File sourceDocBook = new File(sourceFilename);
		sourceDirectory = sourceDocBook.getParentFile();
		File imageDirectory = getImageDirectory();
		File calloutDirectory = new File (imageDirectory, "callouts");

		transformer.setParameter("docbook.infile",sourceDocBook.toURI().toString());
		transformer.setParameter("source.directory",sourceDirectory.toURI().toString());

		transformer.setParameter("compute.wadl.path.from.docbook.path",computeWadlPathFromDocbookPath);
		transformer.setParameter("pdfFilenameBase",pdfFilenameBase)
;
		transformer.setParameter ("admon.graphics.path", imageDirectory.toURI().toString());
		transformer.setParameter ("callout.graphics.path", calloutDirectory.toURI().toString());

		//
		//  Setup the background image file
		//
		File cloudSub = new File (imageDirectory, "cloud");
		File ccSub    = new File (imageDirectory, "cc");
		coverImage = new File (cloudSub, COVER_IMAGE_NAME);
		coverImageTemplate = new File (cloudSub, COVER_IMAGE_TEMPLATE_NAME);

		coverImageTemplate = new File (cloudSub, "rackspace-cover.st");

		transformer.setParameter ("cloud.api.background.image", coverImage.toURI().toString());
		transformer.setParameter ("cloud.api.cc.image.dir", ccSub.toURI().toString());

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

			File cloudSub = new File (imageDirectory, "cloud");
			File ccSub    = new File (imageDirectory, "cc");
			coverImage = new File (cloudSub, COVER_IMAGE_NAME);
			coverImageTemplate = new File (cloudSub, COVER_IMAGE_TEMPLATE_NAME);
			coverImageTemplate = new File (cloudSub, "rackspace-cover.st");

			transformer.setParameter ("cloud.api.background.image", coverImage.toURI().toString());
			transformer.setParameter ("cloud.api.cc.image.dir", ccSub.toURI().toString());
			if (getLog().isDebugEnabled()) {
			    getLog().info("SOURCE FOR COVER PAGE: "+sourceFilePath);
			}
			// transformer.setParameter("docbook.infile", sourceFilePath.toURI().toString());

			if (getLog().isDebugEnabled()) {
			    getLog().debug("SOURCE FOR COVER PAGE: " + new File(projectBuildDirectory, inputFilename).getAbsolutePath());
			}
			transformer.setParameter("docbook.infile", new File(projectBuildDirectory, inputFilename).toURI().toString());

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

	protected Configuration loadFOPConfig() throws MojoExecutionException {
	        String fontPath  = (null != localFontPath && localFontPath != "") ? localFontPath : (new File(getAutopdfTargetDirectory().getParentFile(), "fonts")).getAbsolutePath();
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

	public void setInputFilename(String inputFilename) {
		this.inputFilename = inputFilename;
	}

	public MavenProject getProject() {
		return project;
	}
	public void setProject(MavenProject project) {
		this.project = project;
	}


	public File getAutopdfTargetDirectory() {
		return autopdfTargetDirectory;
	}
	public void setAutopdfTargetDirectory(File autopdfTargetDirectory) {
		this.autopdfTargetDirectory = autopdfTargetDirectory;
	}

	public File getWebhelpTargetDirectory() {
		return webhelpTargetDirectory;
	}
	public void setWebhelpTargetDirectory(File webhelpTargetDirectory) {
		this.webhelpTargetDirectory = webhelpTargetDirectory;
	}


	public File getSourceDirectory() {
		return sourceDirectory;
	}
	public void setSourceDirectory(File sourceDirectory) {
		this.sourceDirectory = sourceDirectory;
	}

	public File getImageDirectory() {
		return imageDirectory;
	}
	public void setImageDirectory(File imageDirectory) {
		this.imageDirectory = imageDirectory;
	}

	public File getSourceFilePath() {
		return sourceFilePath;
	}
	public void setSourceFilePath(File sourceDocBook) {
		this.sourceFilePath = sourceDocBook;
	}

	public File getProjectBuildDirectory() {
		return projectBuildDirectory;
	}
	public void setProjectBuildDirectory(File projectBuildDirectory) {
		this.projectBuildDirectory = projectBuildDirectory;
	}

	public String getCoverColor() {
		return coverColor;
	}
	public void setCoverColor(String coverColor) {
		this.coverColor = coverColor;
	}

	public String getCoverLogoPath() {
		return coverLogoPath;
	}

	public void setCoverLogoPath(String coverLogoPath) {
		this.coverLogoPath = coverLogoPath;
	}

	public String getSecondaryCoverLogoPath() {
		return secondaryCoverLogoPath;
	}

	public void setSecondaryCoverLogoPath(String secondaryCoverLogoPath) {
		this.secondaryCoverLogoPath = secondaryCoverLogoPath;
	}

	public String getCoverLogoLeft() {
		return coverLogoLeft;
	}

	public void setCoverLogoLeft(String coverLogoLeft) {
		this.coverLogoLeft = coverLogoLeft;
	}

	public String getCoverLogoTop() {
		return coverLogoTop;
	}

	public void setCoverLogoTop(String coverLogoTop) {
		this.coverLogoTop = coverLogoTop;
	}

	public String getCoverUrl() {
		return coverUrl;
	}

	public void setCoverUrl(String coverUrl) {
		this.coverUrl = coverUrl;
	}

	public String getBranding() {
		return branding;
	}
	public void setBranding(String branding) {
		this.branding = branding;
	}

	public String getBuiltForOpenStack() {
		return builtForOpenStack;
	}
	public void setBuiltForOpenStack(String builtForOpenStack) {
		this.builtForOpenStack = builtForOpenStack;
	}

	public String getPageWidth() {
		return pageWidth;
	}
	public void setPageWidth(String pageWidth) {
		this.pageWidth = pageWidth;
	}

 	public String getPageHeight() {
		return pageHeight;
	}
	public void setPageHeight(String pageHeight) {
		this.pageHeight = pageHeight;
	}

  	public String getOmitCover() {
		return omitCover;
	}
	public void setOmitCover(String omitCover) {
		this.omitCover = omitCover;
	}

  	public String getDoubleSided() {
		return doubleSided;
	}
	public void setDoubleSided(String doubleSided) {
		this.doubleSided = doubleSided;
	}


	public String getSecurity() {
		return security;
	}

	public void setSecurity(String security) {
		this.security = security;
	}

	public String getChapterAutolabel() {
		return chapterAutolabel;
	}

	public void setChapterAutolabel(String chapterAutolabel) {
		this.chapterAutolabel = chapterAutolabel;
	}

	public String getAppendixAutolabel() {
		return appendixAutolabel;
	}

	public void setAppendixAutolabel(String appendixAutolabel) {
		this.appendixAutolabel = appendixAutolabel;
	}


	public String getSectionAutolabel() {
		return sectionAutolabel;
	}

	public void setSectionAutolabel(String sectionAutolabel) {
		this.sectionAutolabel = sectionAutolabel;
	}

	public String getGlossaryCollection() {
		return glossaryCollection;
	}

	public void setGlossaryCollection(String glossaryCollection) {
		this.glossaryCollection = glossaryCollection;
	}


	public String getSectionLabelIncludesComponentLabel() {
		return sectionLabelIncludesComponentLabel;
	}

	public void setSectionLabelIncludesComponentLabel(String sectionLabelIncludesComponentLabel) {
		this.sectionLabelIncludesComponentLabel = sectionLabelIncludesComponentLabel;
	}
	public String getFormalProcedures() {
		return formalProcedures;
	}

	public void setFormalProcedures(String formalProcedures) {
		this.formalProcedures = formalProcedures;
	}

	public String getGenerateToc() {
		return generateToc;
	}

	public void setGenerateToc(String generateToc) {
		this.generateToc = generateToc;
	}

	public String getTocMaxDepth() {
		return tocMaxDepth;
	}

	public void setTocSectionDepth(String tocSectionDepth) {
		this.tocSectionDepth = tocSectionDepth;
	}

	public String getTocSectionDepth() {
		return tocSectionDepth;
	}

	public void setTocMaxDepth(String tocMaxDepth) {
		this.tocMaxDepth = tocMaxDepth;
	}


	public String getDraftStatus() {
		return draftStatus;
	}

	public void setDraftStatus(String draftStatus) {
		this.draftStatus = draftStatus;
	}

	public String getStatusBarText() {
		return statusBarText;
	}

	public void setStatusBarText(String statusBarText) {
		this.statusBarText = statusBarText;
	}

	public void setBodyFont(String bodyFont) {
		this.bodyFont = bodyFont;
	}

	public String getBodyFont() {
		return bodyFont;
	}

	public void setMonospaceFont(String monospaceFont) {
		this.monospaceFont = monospaceFont;
	}

	public String getMonospaceFont() {
		return monospaceFont;
	}

	public void setLocalFontPath(String localFontPath) {
		this.localFontPath = localFontPath;
	}

	public String getLocalFontPath() {
		return localFontPath;
	}

	public String getTrimWadlUriCount() {
		return trimWadlUriCount;
	}

	public void setTrimWadlUriCount(String trimWadlUriCount) {
		this.trimWadlUriCount = trimWadlUriCount;
	}

	public String getComputeWadlPathFromDocbookPath() {
		return computeWadlPathFromDocbookPath;
	}

	public void setComputeWadlPathFromDocbookPath(
			String computeWadlPathFromDocbookPath) {
		this.computeWadlPathFromDocbookPath = computeWadlPathFromDocbookPath;
	}

	public String getPdfFilenameBase() {
		return pdfFilenameBase;
	}

	public void setPdfFilenameBase(
			String pdfFilenameBase) {
		this.pdfFilenameBase = pdfFilenameBase;
	}


	public List<Entity> getEntities() {
		return entities;
	}
	public void setEntities(List<Entity> entities) {
		this.entities = entities;
	}

	/**
	 * Creates an XML entity resolver.
	 *
	 * @param resolver The initial resolver to use.
	 * @return The new XML entity resolver or null if there is no entities to resolve.
	 * @see com.agilejava.docbkx.maven.InjectingEntityResolver
	 */
	private InjectingEntityResolver createEntityResolver(EntityResolver resolver) {
		if (getEntities() != null) {
			return new InjectingEntityResolver(getEntities(), resolver, getType(), getLog());
		} else {
			return null;
		}
	}




	protected String getNonDefaultStylesheetLocation() {
		return "cloud/fo/docbook.xsl";
	}
	/**
	 * Returns the URL of the default stylesheet.
	 *
	 * @return The URL of the stylesheet.
	 */
	protected URL getNonDefaultStylesheetURL() {
		if (getNonDefaultStylesheetLocation() != null) {
			URL url = this.getClass().getClassLoader().getResource(getNonDefaultStylesheetLocation());
			return url;
		} else {
			return null;
		}
	}

	/**
	 * Returns the list of docbook files to include.
	 */
	private String[] scanIncludedFiles() {
		final DirectoryScanner scanner = new DirectoryScanner();
		scanner.setBasedir(sourceDirectory);
		scanner.setIncludes(new String[]{inputFilename});
		scanner.scan();
		return scanner.getIncludedFiles();
	}


	/**
	 * Creates a <code>CatalogManager</code>, used to resolve DTDs and other entities.
	 *
	 * @return A <code>CatalogManager</code> to be used for resolving DTDs and other entities.
	 */
	protected CatalogManager createCatalogManager() {

		CatalogManager manager = new CatalogManager();
		manager.setIgnoreMissingProperties(true);
		ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
		StringBuffer builder = new StringBuffer();
		boolean first = true;
		for (int i = 0; i < catalogs.length; i++) {
			final String catalog = catalogs[i];

			try {
				Enumeration<URL> enumeration = classLoader.getResources(catalog);
				while (enumeration.hasMoreElements()) {
					if (!first) {
						builder.append(';');
					} else {
						first = false;
					}
					URL resource = enumeration.nextElement();
					builder.append(resource.toExternalForm());
				}
			} catch (IOException ioe) {
				getLog().warn("Failed to search for catalog files: " + catalog);
				// Let's be a little tolerant here.
			}
		}
		//builder.append("jar:file:/Users/salmanqureshi/.m2/repository/net/sf/docbook/docbook-xsl/1.76.1/docbook-xsl-1.76.1-ns-resources.zip!/docbook/catalog.xml");
		String catalogFiles = builder.toString();
		if (catalogFiles.length() == 0) {
			getLog().warn("Failed to find catalog files.");
		} else {
			if (getLog().isDebugEnabled()) {
				getLog().debug("Catalogs to load: " + catalogFiles);
			}
			manager.setCatalogFiles(catalogFiles);
		}
		return manager;
	}

	/**
	 * Creates an URI resolver to handle <code>urn:docbkx:stylesheet(/)</code> as a special URI. This URI points to the
	 * default docbook stylesheet location
	 *
	 * @param catalogResolver The initial resolver to use
	 * @return The Stylesheet resolver.
	 * @throws MojoExecutionException If an error occurs while reading the stylesheet
	 */
	private URIResolver createStyleSheetResolver(CatalogResolver catalogResolver) throws MojoExecutionException {
		URIResolver uriResolver;
		try {			
			URL url = getNonDefaultStylesheetURL() == null ? getDefaultStylesheetURL() : getNonDefaultStylesheetURL();
			if (getLog().isDebugEnabled()) {
			    getLog().debug("Using stylesheet: " + url.toExternalForm());
			}
			uriResolver = new StylesheetResolver("urn:docbkx:stylesheet", new StreamSource(url.openStream(), url
					.toExternalForm()), catalogResolver);
		} catch (IOException ioe) {
			throw new MojoExecutionException("Failed to read stylesheet.", ioe);
		}
		return uriResolver;
	}
	/**
	 * Returns the URL of the default stylesheet.
	 *
	 * @return The URL of the stylesheet.
	 */
	protected URL getDefaultStylesheetURL() {
		URL url = this.getClass().getClassLoader().getResource(getDefaultStylesheetLocation());
		return url;
	}
	public String getDefaultStylesheetLocation() {
		return "docbook/fo/docbook.xsl";
	}

	public String getType() {
		return "fo";
	}

	/**
	 * Constructs the default {@link TransformerBuilder}.
	 */
	protected TransformerBuilder createTransformerBuilder(URIResolver resolver) {
		//return new CachingTransformerBuilder(new DefaultTransformerBuilder(resolver));
		URIResolver resolver1 = new GlossaryResolver(new DocBookResolver (resolver, getType()), getType());
		return new CachingTransformerBuilder(new DefaultTransformerBuilder(resolver1));
	}

	/**
	 * The default policy for constructing Transformers.
	 */
	private class DefaultTransformerBuilder implements TransformerBuilder {

		/**
		 * The standard {@link URIResolver}.
		 */
		private URIResolver resolver;

		public DefaultTransformerBuilder(URIResolver resolver) {
			this.resolver = resolver;
		}

		public Transformer build() throws TransformerBuilderException {
			Transformer transformer = createTransformer(resolver);
			transformer.setURIResolver(resolver);
			return transformer;
		}

		/**
		 * Returns a <code>Transformer</code> capable of rendering a particular type of output from DocBook input.
		 *
		 * @param uriResolver
		 * @return A <code>Transformer</code> capable of rendering a particular type of output from DocBook input.
		 * @throws MojoExecutionException If the operation fails to create a <code>Transformer</code>.
		 */
		protected Transformer createTransformer(URIResolver uriResolver) throws TransformerBuilderException {
			URL url = getStylesheetURL();
			try {
				TransformerFactory transformerFactory = new TransformerFactoryImpl();
				transformerFactory.setURIResolver(uriResolver);
				Source source = new StreamSource(url.openStream(), url.toExternalForm());
				Transformer transformer = transformerFactory.newTransformer(source);

				if (!isShowXslMessages()) {
					Controller controller = (Controller) transformer;
					try {
						controller.makeMessageEmitter();
						controller.getMessageEmitter().setWriter(new NullWriter());
					} catch (TransformerException te) {
						getLog().error("Failed to redirect xsl:message output.", te);
					}
				}

				if (getCustomizationParameters() != null) {
					final Iterator<Parameter> iterator = getCustomizationParameters().iterator();
					while (iterator.hasNext()) {
						Parameter param = iterator.next();
						if (param.getName() != null) // who knows
						{
							transformer.setParameter(param.getName(), param.getValue());
						}
					}
				}
				//configure(transformer);
				return transformer;
			} catch (IOException ioe) {
				throw new TransformerBuilderException("Failed to read stylesheet from " + url.toExternalForm(), ioe);
			} catch (TransformerConfigurationException tce) {
				throw new TransformerBuilderException("Failed to build Transformer from " + url.toExternalForm(), tce);
			}
		}
	}
	/**
	 * Returns the URL of the stylesheet. You can override this operation to return a URL pointing to a stylesheet residing
	 * on a location that can be adressed by a URL. By default, it will return a stylesheet that will be loaded from the
	 * classpath, using the resource name returned by {@link #getStylesheetLocation()}.
	 *
	 * @return The URL of the stylesheet.
	 */
	protected URL getStylesheetURL() {
		URL url = this.getClass().getClassLoader().getResource(getStylesheetLocation());
		if (url == null) {
			try {
				if (getStylesheetLocation().startsWith("http://")) {
					return new URL(getStylesheetLocation());
				}
				return new File(getStylesheetLocation()).toURI().toURL();
			} catch (MalformedURLException mue) {
				return null;
			}
		} else {
			return url;
		}
	}

	public String getStylesheetLocation() {
		if (foCustomization != null) {
			return foCustomization;
		} else if (getNonDefaultStylesheetLocation() == null) {
			return getDefaultStylesheetLocation();
		} else {
			return getNonDefaultStylesheetLocation();
		}
	}

	protected boolean isShowXslMessages() {
		//return showXslMessages;
		return false;
	}

	public List<Parameter> getCustomizationParameters()
	{
		return customizationParameters;
	}
	/**
	 * Returns the SAXParserFactory used for constructing parsers.
	 */
	private SAXParserFactory createParserFactory() {
		SAXParserFactory factory = new SAXParserFactoryImpl();
		factory.setXIncludeAware(getXIncludeSupported());
		return factory;
	}

	private boolean getXIncludeSupported() { return true; }

	/**
	 * Creates an XML Processing handler for the built-in docbkx <code>&lt;?eval?&gt;</code> PI. This PI resolves maven
	 * properties and basic math formula.
	 *
	 * @param resolver The initial resolver to use.
	 * @param reader   The source XML reader.
	 * @return The XML PI filter.
	 */
	private PreprocessingFilter createPIHandler(EntityResolver resolver, XMLReader reader) {
		PreprocessingFilter filter = new PreprocessingFilter(reader);
		ProcessingInstructionHandler resolvingHandler = new ExpressionHandler(new VariableResolver() {

			public Object resolveVariable(String name) throws ELException {
				if ("date".equals(name)) {
					return DateFormat.getDateInstance(DateFormat.LONG).format(new Date());
				} else if ("project".equals(name)) {
					return getProject();
				} else {
					return getProject().getProperties().get(name);
				}
			}

		}, getLog());
		filter.setHandlers(Arrays.asList(new Object[] { resolvingHandler }));
		filter.setEntityResolver(resolver);
		return filter;
	}

	protected Source createSource(String inputFilename, File sourceFile, PreprocessingFilter filter, Map<String, Object> map)
			throws MojoExecutionException {
		String pathToPipelineFile = "classpath:///pdf.xpl"; //use "classpath:///path" for this to work

		String sourceFileNameNormalized = sourceFile.toURI().toString();
		//from super
		final InputSource inputSource = new InputSource(sourceFileNameNormalized);
		Source source = new SAXSource(filter, inputSource);

		Map<String, Object> localMap = new HashMap<String, Object>(map);
		localMap.put("outputType", "pdf");

		//removing webhelp specific settings from map
		localMap.remove("webhelp");
		localMap.remove("webhelp.war");
		localMap.remove("groupId");
		localMap.remove("artifactId");
		localMap.remove("docProjectVersion");

		return CalabashHelper.createSource(getLog(), source, pathToPipelineFile, localMap);
	}

	/**
	 * Main method.
	 * @param args command-line arguments
	 */
	public static void main(String[] args) {
		try {

			System.out.println("setting up fonts and images directories\n");
			System.out.println("FOP ExampleFO2PDF\n");
			System.out.println("Preparing...");

			//Setup directories
			File sourceDir = new File("/Users/salmanqureshi/Projects/Rackspace/Dev/compute-api-final/openstack-compute-api-2/src");
			File baseDir = new File("/Users/salmanqureshi/Projects/Rackspace/Dev/compute-api-final/openstack-compute-api-2");
			//			File outDir = new File(baseDir, "out");
			//			outDir.mkdirs();

			//Setup input and output files
			//File fofile = new File(baseDir, "xml/fo/helloworld.fo");
			//File fofile = new File(baseDir, "os-compute-devguide.fo");
			//File fofile = new File(baseDir, "../fo/pagination/franklin_2pageseqs.fo");
			//File pdffile = new File(outDir, "ResultFO2PDF.pdf");


			//System.out.println("Input: XSL-FO (" + fofile + ")");
			//System.out.println("Output: PDF (" + pdffile + ")");
			System.out.println("Transforming...");

			PDFBuilder pdfBuilder = new PDFBuilder();
			File targetDir = new File(baseDir, "target/docbkx/pdf1");
			pdfBuilder.setSourceDirectory(sourceDir);
			pdfBuilder.setAutopdfTargetDirectory(targetDir);
			pdfBuilder.setImageDirectory(targetDir.getParentFile());
			pdfBuilder.setBranding("rackspace");

			pdfBuilder.setInputFilename("os-compute-devguide.xml");

			pdfBuilder.setSourceFilePath(new File(sourceDir, "os-compute-devguide.xml"));
			pdfBuilder.setProjectBuildDirectory(sourceDir.getParentFile());

			pdfBuilder.preProcess();
			//File fofile = pdfBuilder.processSources();
			//pdfBuilder.convertFO2PDF(fofile);

			System.out.println("Success!");
		} catch (Exception e) {
			e.printStackTrace(System.err);
			System.exit(-1);
		}
	}
}
