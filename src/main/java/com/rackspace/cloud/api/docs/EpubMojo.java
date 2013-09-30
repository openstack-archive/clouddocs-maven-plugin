package com.rackspace.cloud.api.docs;

import com.agilejava.docbkx.maven.Entity;
import com.agilejava.docbkx.maven.Parameter;
import javax.xml.transform.*;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.batik.transcoder.TranscoderInput;
import org.apache.batik.transcoder.TranscoderOutput;
import org.apache.batik.transcoder.image.JPEGTranscoder;
import org.apache.batik.transcoder.image.PNGTranscoder;
import org.apache.maven.plugin.MojoExecutionException;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.util.List;
import java.util.Properties;
import org.apache.maven.artifact.Artifact;
import org.apache.maven.project.MavenProject;
import org.apache.tools.ant.Target;
import org.xml.sax.XMLReader;
import org.xml.sax.SAXException;

import org.codehaus.plexus.archiver.Archiver;
import org.codehaus.plexus.archiver.manager.ArchiverManager;
import org.codehaus.plexus.archiver.zip.ZipArchiver;
import org.codehaus.plexus.util.FileUtils;

import java.io.IOException;
import java.net.URL;


/**
 * A Maven plugin for generating epub output from DocBook documents, using version
 * 1.76.1 of the DocBook XSL stylesheets.
 *
 */
public abstract class EpubMojo
  extends com.agilejava.docbkx.maven.AbstractEpubMojo
{

    private File imageDirectory;
    private File sourceDocBook;

    private File coverImageTemplate;
    private File coverImage;

    private static final String COVER_IMAGE_TEMPLATE_NAME = "cover.st";
    private static final String COVER_IMAGE_NAME = "cover.svg";

    private static final String COVER_XSL = "cloud/cover.xsl";

    /**
     * The plugin dependencies.
     *
     * @parameter expression="${plugin.artifacts}"
     * @required
     * @readonly
     */
    List<Artifact> artifacts;

    /**
     * Ant tasks to be executed before the transformation. Comparable
     * to the tasks property in the maven-antrun-plugin.
     *
     * @parameter
     */
    private Target preProcess;

    /**
     * Ant tasks to be executed after the transformation. Comparable
     * to the tasks property in the maven-antrun-plugin.
     *
     * @parameter
     */
    private Target postProcess;

    /**
     * @parameter expression="${project}"
     * @required
     * @readonly
     */
    private MavenProject project;

    /**
     * A list of entities to be substituted in the source
     * documents. Note that you can <em>only</em> specify entities if
     * your source DocBook document contains a DTD
     * declaration. Otherwise it will not have any effect at all.
     *
     * @parameter
     */
    private List<Entity> entities;

    /**
     * A list of additional XSL parameters to give to the XSLT engine.
     * These parameters overrides regular docbook ones as they are last
     * configured.<br/>
     * For regular docbook parameters perfer the use of this plugin facilities
     * offering nammed paramters.<br/>
     * These parameters feet well for custom properties you may have defined
     * within your customization layer.
     *
     * @parameter
     */
    private List<Parameter> customizationParameters;

    /**
     * List of additional System properties.
     *
     * @parameter
     */
    private Properties systemProperties;

    /**
     * The pattern of the files to be included.
     *
     * @parameter default-value="*.xml"
     */
    private String includes;

    /**
     * A boolean, indicating if XInclude should be supported.
     *
     * @parameter default="false"
     */
     private boolean xincludeSupported;

    /**
     * The location of the stylesheet customization.
     *
     * @parameter
     */
    private String epubCustomization;

    /**
     * The extension of the target file name.
     *
     * @parameter default-value="epub"
     */
    private String targetFileExtension;


    /**
     * The target directory to which all output will be written.
     *
     * @parameter expression="${basedir}/target/docbkx/epub"
     */
    private File targetDirectory;

    /**
     * The directory containing the source DocBook files.
     *
     * @parameter expression="${basedir}/src/docbkx"
     */
    private File sourceDirectory;

    /**
     * The directory containing the resolved DocBook source before given to the transformer.
     *
     * @parameter
     */
    private File generatedSourceDirectory;

    private boolean useStandardOutput = false;

    /**
     * If zero (the default), the XSL processor emits a message naming each separate chunk filename as it is being output.
     * (Original XSL attribuut: <code>chunk.quietly</code>.)
     *
     * @parameter
     */  
    protected String chunkQuietly;

    /**
     * The value of this parameter specifies profiles which should be included in the output.
     * (Original XSL attribuut: <code>profile.condition</code>.)
     *
     * @parameter
     */  
    protected String profileCondition;

    /**
     * In DocBook documents that conform to a schema older than V4.
     * (Original XSL attribuut: <code>use.role.as.xrefstyle</code>.)
     *
     * @parameter
     */  
    protected String useRoleAsXrefstyle;

    /**
     * The value of this parameter specifies profiles which should be included in the output.
     * (Original XSL attribuut: <code>profile.role</code>.)
     *
     * @parameter
     */  
    protected String profileRole;

    /**
     * Sets the filename extension to use on navigational graphics used in the headers and footers of chunked HTML.
     * (Original XSL attribuut: <code>navig.graphics.extension</code>.)
     *
     * @parameter
     */  
    protected String navigGraphicsExtension;

    /**
     * Specifies the border color of table frames.
     * (Original XSL attribuut: <code>table.frame.border.color</code>.)
     *
     * @parameter
     */  
    protected String tableFrameBorderColor;

    /**
     * If true, ToC and LoT (List of Examples, List of Figures, etc.
     * (Original XSL attribuut: <code>chunk.tocs.and.lots</code>.)
     *
     * @parameter
     */  
    protected String chunkTocsAndLots;

    /**
     * For compatibility with DSSSL based DBTeXMath from Allin Cottrell you should set this parameter to 0.
     * (Original XSL attribuut: <code>tex.math.delims</code>.)
     *
     * @parameter
     */  
    protected String texMathDelims;

    /**
     * 
     * (Original XSL attribuut: <code>graphic.default.extension</code>.)
     *
     * @parameter
     */  
    protected String graphicDefaultExtension;

    /**
     * 
     * (Original XSL attribuut: <code>part.autolabel</code>.)
     *
     * @parameter
     */  
    protected String partAutolabel;

    /**
     * 
     * (Original XSL attribuut: <code>show.revisionflag</code>.)
     *
     * @parameter
     */  
    protected String showRevisionflag;

    /**
     * 
     * (Original XSL attribuut: <code>variablelist.as.table</code>.)
     *
     * @parameter
     */  
    protected String variablelistAsTable;

    /**
     * Set to true to generate a binary TOC.
     * (Original XSL attribuut: <code>htmlhelp.hhc.binary</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpHhcBinary;

    /**
     * 
     * (Original XSL attribuut: <code>graphicsize.extension</code>.)
     *
     * @parameter
     */  
    protected String graphicsizeExtension;

    /**
     * 
     * (Original XSL attribuut: <code>epub.cover.linear</code>.)
     *
     * @parameter
     */  
    protected String epubCoverLinear;

    /**
     * The fixed value used for calculations based upon the size of a character.
     * (Original XSL attribuut: <code>points.per.em</code>.)
     *
     * @parameter
     */  
    protected String pointsPerEm;

    /**
     * This parameter specifies initial position of help window.
     * (Original XSL attribuut: <code>htmlhelp.window.geometry</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpWindowGeometry;

    /**
     * 
     * (Original XSL attribuut: <code>olink.sysid</code>.)
     *
     * @parameter
     */  
    protected String olinkSysid;

    /**
     * 
     * (Original XSL attribuut: <code>inherit.keywords</code>.)
     *
     * @parameter
     */  
    protected String inheritKeywords;

    /**
     * The value of this parameter specifies profiles which should be included in the output.
     * (Original XSL attribuut: <code>profile.revision</code>.)
     *
     * @parameter
     */  
    protected String profileRevision;

    /**
     * 
     * (Original XSL attribuut: <code>ebnf.assignment</code>.)
     *
     * @parameter
     */  
    protected String ebnfAssignment;

    /**
     * 
     * (Original XSL attribuut: <code>qanda.defaultlabel</code>.)
     *
     * @parameter
     */  
    protected String qandaDefaultlabel;

    /**
     * Set to true to include the Prev button  on the toolbar.
     * (Original XSL attribuut: <code>htmlhelp.button.prev</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpButtonPrev;

    /**
     * 
     * (Original XSL attribuut: <code>chunk.first.sections</code>.)
     *
     * @parameter
     */  
    protected String chunkFirstSections;

    /**
     * Graphic widths expressed as a percentage are problematic.
     * (Original XSL attribuut: <code>nominal.image.width</code>.)
     *
     * @parameter
     */  
    protected String nominalImageWidth;

    /**
     * 
     * (Original XSL attribuut: <code>footnote.number.format</code>.)
     *
     * @parameter
     */  
    protected String footnoteNumberFormat;

    /**
     * 
     * (Original XSL attribuut: <code>reference.autolabel</code>.)
     *
     * @parameter
     */  
    protected String referenceAutolabel;

    /**
     * This language is used when there is no language attribute on programlisting.
     * (Original XSL attribuut: <code>highlight.default.language</code>.)
     *
     * @parameter
     */  
    protected String highlightDefaultLanguage;

    /**
     * A mediaobject may contain several objects such as imageobjects.
     * (Original XSL attribuut: <code>preferred.mediaobject.role</code>.)
     *
     * @parameter
     */  
    protected String preferredMediaobjectRole;

    /**
     * 
     * (Original XSL attribuut: <code>manual.toc</code>.)
     *
     * @parameter
     */  
    protected String manualToc;

    /**
     * This parameter has a structured value.
     * (Original XSL attribuut: <code>generate.toc</code>.)
     *
     * @parameter
     */  
    protected String generateToc;

    /**
     * This parameter lets you select which method to use for sorting and grouping  index entries in an index.
     * (Original XSL attribuut: <code>index.method</code>.)
     *
     * @parameter
     */  
    protected String indexMethod;

    /**
     * 
     * (Original XSL attribuut: <code>insert.olink.pdf.frag</code>.)
     *
     * @parameter
     */  
    protected String insertOlinkPdfFrag;

    /**
     * Selects the border on EBNF tables.
     * (Original XSL attribuut: <code>ebnf.table.border</code>.)
     *
     * @parameter
     */  
    protected String ebnfTableBorder;

    /**
     * 
     * (Original XSL attribuut: <code>index.on.type</code>.)
     *
     * @parameter
     */  
    protected String indexOnType;

    /**
     * String used to separate labels and titles in a table of contents.
     * (Original XSL attribuut: <code>autotoc.label.separator</code>.)
     *
     * @parameter
     */  
    protected String autotocLabelSeparator;

    /**
     * In order to convert CALS column widths into HTML column widths, it is sometimes necessary to have an absolute table width to use for conversion of mixed absolute and relative widths.
     * (Original XSL attribuut: <code>nominal.table.width</code>.)
     *
     * @parameter
     */  
    protected String nominalTableWidth;

    /**
     * When olinks between documents are resolved, the generated text may not make it clear that the reference is to another document.
     * (Original XSL attribuut: <code>olink.doctitle</code>.)
     *
     * @parameter
     */  
    protected String olinkDoctitle;

    /**
     * 
     * (Original XSL attribuut: <code>htmlhelp.use.hhk</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpUseHhk;

    /**
     * Title of Jump2 button.
     * (Original XSL attribuut: <code>htmlhelp.button.jump2.title</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpButtonJump2Title;

    /**
     * 
     * (Original XSL attribuut: <code>chunk.fast</code>.)
     *
     * @parameter
     */  
    protected String chunkFast;

    /**
     * 
     * (Original XSL attribuut: <code>insert.xref.page.number</code>.)
     *
     * @parameter
     */  
    protected String insertXrefPageNumber;

    /**
     * 
     * (Original XSL attribuut: <code>biblioentry.alt.primary.seps</code>.)
     *
     * @parameter
     */  
    protected String biblioentryAltPrimarySeps;

    /**
     * Normally first chunk of document is displayed when you open HTML Help file.
     * (Original XSL attribuut: <code>htmlhelp.default.topic</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpDefaultTopic;

    /**
     * 
     * (Original XSL attribuut: <code>html.stylesheet</code>.)
     *
     * @parameter
     */  
    protected String htmlStylesheet;

    /**
     * 
     * (Original XSL attribuut: <code>emphasis.propagates.style</code>.)
     *
     * @parameter
     */  
    protected String emphasisPropagatesStyle;

    /**
     * Set to true to have an application menu bar in your HTML Help window.
     * (Original XSL attribuut: <code>htmlhelp.show.menu</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpShowMenu;

    /**
     * 
     * (Original XSL attribuut: <code>onechunk</code>.)
     *
     * @parameter
     */  
    protected String onechunk;

    /**
     * 
     * (Original XSL attribuut: <code>chunk.append</code>.)
     *
     * @parameter
     */  
    protected String chunkAppend;

    /**
     * 
     * (Original XSL attribuut: <code>html.append</code>.)
     *
     * @parameter
     */  
    protected String htmlAppend;

    /**
     * 
     * (Original XSL attribuut: <code>variablelist.term.break.after</code>.)
     *
     * @parameter
     */  
    protected String variablelistTermBreakAfter;

    /**
     * If you want advanced search features in your help, turn this parameter to 1.
     * (Original XSL attribuut: <code>htmlhelp.show.advanced.search</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpShowAdvancedSearch;

    /**
     * If non-zero, this value will be used as the default cellspacing value in HTML tables.
     * (Original XSL attribuut: <code>html.cellspacing</code>.)
     *
     * @parameter
     */  
    protected String htmlCellspacing;

    /**
     * If true, comments will be displayed, otherwise they are suppressed.
     * (Original XSL attribuut: <code>show.comments</code>.)
     *
     * @parameter
     */  
    protected String showComments;

    /**
     * The value of this parameter specifies profiles which should be included in the output.
     * (Original XSL attribuut: <code>profile.os</code>.)
     *
     * @parameter
     */  
    protected String profileOs;

    /**
     * Specifies the border style of table frames.
     * (Original XSL attribuut: <code>table.frame.border.style</code>.)
     *
     * @parameter
     */  
    protected String tableFrameBorderStyle;

    /**
     * 
     * (Original XSL attribuut: <code>html.longdesc.link</code>.)
     *
     * @parameter
     */  
    protected String htmlLongdescLink;

    /**
     * 
     * (Original XSL attribuut: <code>callout.graphics.number.limit</code>.)
     *
     * @parameter
     */  
    protected String calloutGraphicsNumberLimit;

    /**
     * If true, header and footer navigation will be suppressed.
     * (Original XSL attribuut: <code>suppress.navigation</code>.)
     *
     * @parameter
     */  
    protected String suppressNavigation;

    /**
     * 
     * (Original XSL attribuut: <code>biblioentry.item.separator</code>.)
     *
     * @parameter
     */  
    protected String biblioentryItemSeparator;

    /**
     * This parameter allows you to control the punctuation of certain types of generated cross reference text.
     * (Original XSL attribuut: <code>xref.title-page.separator</code>.)
     *
     * @parameter
     */  
    protected String xrefTitlePageSeparator;

    /**
     * The table columns extension function adjusts the widths of table columns in the HTML result to more accurately reflect the specifications in the CALS table.
     * (Original XSL attribuut: <code>tablecolumns.extension</code>.)
     *
     * @parameter
     */  
    protected String tablecolumnsExtension;

    /**
     * When cross reference data is collected for resolving olinks, it may be necessary to prepend a base URI to each target's href.
     * (Original XSL attribuut: <code>olink.base.uri</code>.)
     *
     * @parameter
     */  
    protected String olinkBaseUri;

    /**
     * 
     * (Original XSL attribuut: <code>make.valid.html</code>.)
     *
     * @parameter
     */  
    protected String makeValidHtml;

    /**
     * This image is used inline to identify the location of annotations.
     * (Original XSL attribuut: <code>annotation.graphic.open</code>.)
     *
     * @parameter
     */  
    protected String annotationGraphicOpen;

    /**
     * Value of this parameter specifies profiles which should be included in the output.
     * (Original XSL attribuut: <code>profile.audience</code>.)
     *
     * @parameter
     */  
    protected String profileAudience;

    /**
     * 
     * (Original XSL attribuut: <code>email.delimiters.enabled</code>.)
     *
     * @parameter
     */  
    protected String emailDelimitersEnabled;

    /**
     * The stylesheets are capable of generating both default and custom CSS stylesheet files.
     * (Original XSL attribuut: <code>generate.css.header</code>.)
     *
     * @parameter
     */  
    protected String generateCssHeader;

    /**
     * Content of this parameter will be used as a title for generated HTML Help.
     * (Original XSL attribuut: <code>htmlhelp.title</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpTitle;

    /**
     * If you want type math directly in TeX notation in equations, this parameter specifies notation used.
     * (Original XSL attribuut: <code>tex.math.in.alt</code>.)
     *
     * @parameter
     */  
    protected String texMathInAlt;

    /**
     * 
     * (Original XSL attribuut: <code>htmlhelp.force.map.and.alias</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpForceMapAndAlias;

    /**
     * 
     * (Original XSL attribuut: <code>section.autolabel.max.depth</code>.)
     *
     * @parameter
     */  
    protected String sectionAutolabelMaxDepth;

    /**
     * 
     * (Original XSL attribuut: <code>id.warnings</code>.)
     *
     * @parameter
     */  
    protected String idWarnings;

    /**
     * 
     * (Original XSL attribuut: <code>ade.extensions</code>.)
     *
     * @parameter
     */  
    protected String adeExtensions;

    /**
     * 
     * (Original XSL attribuut: <code>formal.object.break.after</code>.)
     *
     * @parameter
     */  
    protected String formalObjectBreakAfter;

    /**
     * The value of this parameter specifies profiles which should be included in the output.
     * (Original XSL attribuut: <code>profile.arch</code>.)
     *
     * @parameter
     */  
    protected String profileArch;

    /**
     * Set the name of map file.
     * (Original XSL attribuut: <code>htmlhelp.map.file</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpMapFile;

    /**
     * This parameter specifies the list of elements that should be escaped as CDATA sections by the chunking stylesheet.
     * (Original XSL attribuut: <code>chunker.output.cdata-section-elements</code>.)
     *
     * @parameter
     */  
    protected String chunkerOutputCdataSectionElements;

    /**
     * The value of this parameter specifies profiles which should be included in the output.
     * (Original XSL attribuut: <code>profile.conformance</code>.)
     *
     * @parameter
     */  
    protected String profileConformance;

    /**
     * 
     * (Original XSL attribuut: <code>html.head.legalnotice.link.multiple</code>.)
     *
     * @parameter
     */  
    protected String htmlHeadLegalnoticeLinkMultiple;

    /**
     * 
     * (Original XSL attribuut: <code>refclass.suppress</code>.)
     *
     * @parameter
     */  
    protected String refclassSuppress;

    /**
     * If non-zero, this value will be used as the default cellpadding value in HTML tables.
     * (Original XSL attribuut: <code>html.cellpadding</code>.)
     *
     * @parameter
     */  
    protected String htmlCellpadding;

    /**
     * Eclipse Help plugin id.
     * (Original XSL attribuut: <code>eclipse.plugin.id</code>.)
     *
     * @parameter
     */  
    protected String eclipsePluginId;

    /**
     * This parameter specifies the public identifier that should be used by the chunking stylesheet in the document type declaration of chunked pages.
     * (Original XSL attribuut: <code>chunker.output.doctype-public</code>.)
     *
     * @parameter
     */  
    protected String chunkerOutputDoctypePublic;

    /**
     * 
     * (Original XSL attribuut: <code>para.propagates.style</code>.)
     *
     * @parameter
     */  
    protected String paraPropagatesStyle;

    /**
     * 
     * (Original XSL attribuut: <code>make.clean.html</code>.)
     *
     * @parameter
     */  
    protected String makeCleanHtml;

    /**
     * When an automatically generated Table of Contents (or List of Titles) is produced, this HTML element will be used to make the list.
     * (Original XSL attribuut: <code>toc.list.type</code>.)
     *
     * @parameter
     */  
    protected String tocListType;

    /**
     * If true, the navigational headers and footers in chunked HTML are presented in an alternate style that uses graphical icons for Next, Previous, Up, and Home.
     * (Original XSL attribuut: <code>navig.graphics</code>.)
     *
     * @parameter
     */  
    protected String navigGraphics;

    /**
     * 
     * (Original XSL attribuut: <code>generate.revhistory.link</code>.)
     *
     * @parameter
     */  
    protected String generateRevhistoryLink;

    /**
     * The stylesheets are capable of generating a default CSS stylesheet file.
     * (Original XSL attribuut: <code>docbook.css.link</code>.)
     *
     * @parameter
     */  
    protected String docbookCssLink;

    /**
     * 
     * (Original XSL attribuut: <code>l10n.xml</code>.)
     *
     * @parameter
     */  
    protected String l10nXml;

    /**
     * 
     * (Original XSL attribuut: <code>table.footnote.number.symbols</code>.)
     *
     * @parameter
     */  
    protected String tableFootnoteNumberSymbols;

    /**
     * 
     * (Original XSL attribuut: <code>ulink.target</code>.)
     *
     * @parameter
     */  
    protected String ulinkTarget;

    /**
     * This parameter specifies the encoding to be used in files generated by the chunking stylesheet.
     * (Original XSL attribuut: <code>chunker.output.encoding</code>.)
     *
     * @parameter
     */  
    protected String chunkerOutputEncoding;

    /**
     * If true (true), unlabeled sections will be enumerated.
     * (Original XSL attribuut: <code>section.autolabel</code>.)
     *
     * @parameter
     */  
    protected String sectionAutolabel;

    /**
     * 
     * (Original XSL attribuut: <code>generate.meta.abstract</code>.)
     *
     * @parameter
     */  
    protected String generateMetaAbstract;

    /**
     * If you want to include some additional parameters into project file, store appropriate part of project file into this parameter.
     * (Original XSL attribuut: <code>htmlhelp.hhp.tail</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpHhpTail;

    /**
     * 
     * (Original XSL attribuut: <code>chunk.toc</code>.)
     *
     * @parameter
     */  
    protected String chunkToc;

    /**
     * Set to true to include a Favorites tab in the navigation pane  of the help window.
     * (Original XSL attribuut: <code>htmlhelp.show.favorities</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpShowFavorities;

    /**
     * 
     * (Original XSL attribuut: <code>glossterm.auto.link</code>.)
     *
     * @parameter
     */  
    protected String glosstermAutoLink;

    /**
     * 
     * (Original XSL attribuut: <code>get</code>.)
     *
     * @parameter
     */  
    protected String get;

    /**
     * 
     * (Original XSL attribuut: <code>simplesect.in.toc</code>.)
     *
     * @parameter
     */  
    protected String simplesectInToc;

    /**
     * If true, header navigation will be suppressed.
     * (Original XSL attribuut: <code>suppress.header.navigation</code>.)
     *
     * @parameter
     */  
    protected String suppressHeaderNavigation;

    /**
     * Set to true to include the Jump2 button  on the toolbar.
     * (Original XSL attribuut: <code>htmlhelp.button.jump2</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpButtonJump2;

    /**
     * 
     * (Original XSL attribuut: <code>htmlhelp.button.jump1</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpButtonJump1;

    /**
     * This parameter specifies the value of the omit-xml-declaration specification for generated pages.
     * (Original XSL attribuut: <code>chunker.output.omit-xml-declaration</code>.)
     *
     * @parameter
     */  
    protected String chunkerOutputOmitXmlDeclaration;

    /**
     * Set to true to include the  Forward button  on the toolbar.
     * (Original XSL attribuut: <code>htmlhelp.button.forward</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpButtonForward;

    /**
     * This parameter specifies the punctuation that should be added after an honorific in a personal name.
     * (Original XSL attribuut: <code>punct.honorific</code>.)
     *
     * @parameter
     */  
    protected String punctHonorific;

    /**
     * If true, the scaling attributes on graphics and media objects are ignored.
     * (Original XSL attribuut: <code>ignore.image.scaling</code>.)
     *
     * @parameter
     */  
    protected String ignoreImageScaling;

    /**
     * 
     * (Original XSL attribuut: <code>appendix.autolabel</code>.)
     *
     * @parameter
     */  
    protected String appendixAutolabel;

    /**
     * 
     * (Original XSL attribuut: <code>entry.propagates.style</code>.)
     *
     * @parameter
     */  
    protected String entryPropagatesStyle;

    /**
     * If true, footer navigation will be suppressed.
     * (Original XSL attribuut: <code>suppress.footer.navigation</code>.)
     *
     * @parameter
     */  
    protected String suppressFooterNavigation;

    /**
     * This parameter permits you to override the text to insert between the end of an index term and its list of page references.
     * (Original XSL attribuut: <code>index.term.separator</code>.)
     *
     * @parameter
     */  
    protected String indexTermSeparator;

    /**
     * 
     * (Original XSL attribuut: <code>callout.list.table</code>.)
     *
     * @parameter
     */  
    protected String calloutListTable;

    /**
     * Set to true if you want to play with various HTML Help parameters and you don't need to regenerate all HTML files.
     * (Original XSL attribuut: <code>htmlhelp.only</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpOnly;

    /**
     * 
     * (Original XSL attribuut: <code>html.longdesc</code>.)
     *
     * @parameter
     */  
    protected String htmlLongdesc;

    /**
     * 
     * (Original XSL attribuut: <code>editedby.enabled</code>.)
     *
     * @parameter
     */  
    protected String editedbyEnabled;

    /**
     * This parameter specifies the media type that should be used by the chunking stylesheet.
     * (Original XSL attribuut: <code>chunker.output.media-type</code>.)
     *
     * @parameter
     */  
    protected String chunkerOutputMediaType;

    /**
     * 
     * (Original XSL attribuut: <code>segmentedlist.as.table</code>.)
     *
     * @parameter
     */  
    protected String segmentedlistAsTable;

    /**
     * Set the name of the TOC file.
     * (Original XSL attribuut: <code>htmlhelp.hhc</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpHhc;

    /**
     * Change this parameter if you want different name of project file than htmlhelp.
     * (Original XSL attribuut: <code>htmlhelp.hhp</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpHhp;

    /**
     * This parameter specifies the value of the indent specification for generated pages.
     * (Original XSL attribuut: <code>chunker.output.indent</code>.)
     *
     * @parameter
     */  
    protected String chunkerOutputIndent;

    /**
     * set the name of the index file.
     * (Original XSL attribuut: <code>htmlhelp.hhk</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpHhk;

    /**
     * 
     * (Original XSL attribuut: <code>custom.css.source</code>.)
     *
     * @parameter
     */  
    protected String customCssSource;

    /**
     * HTML Help Compiler is not UTF-8 aware, so you should always use an appropriate single-byte encoding here.
     * (Original XSL attribuut: <code>htmlhelp.encoding</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpEncoding;

    /**
     * This image is used on popup annotations as the “x” that the user can click to dismiss the popup.
     * (Original XSL attribuut: <code>annotation.graphic.close</code>.)
     *
     * @parameter
     */  
    protected String annotationGraphicClose;

    /**
     * This value will be used when there is no frame attribute on the table.
     * (Original XSL attribuut: <code>default.table.frame</code>.)
     *
     * @parameter
     */  
    protected String defaultTableFrame;

    /**
     * Glossaries maintained independently across a set of documents are likely to become inconsistent unless considerable effort is expended to keep them in sync.
     * (Original XSL attribuut: <code>glossary.collection</code>.)
     *
     * @parameter
     */  
    protected String glossaryCollection;

    /**
     * 
     * (Original XSL attribuut: <code>olink.outline.ext</code>.)
     *
     * @parameter
     */  
    protected String olinkOutlineExt;

    /**
     * 
     * (Original XSL attribuut: <code>menuchoice.menu.separator</code>.)
     *
     * @parameter
     */  
    protected String menuchoiceMenuSeparator;

    /**
     * The value of this parameter specifies profiles which should be included in the output.
     * (Original XSL attribuut: <code>profile.security</code>.)
     *
     * @parameter
     */  
    protected String profileSecurity;

    /**
     * 
     * (Original XSL attribuut: <code>chapter.autolabel</code>.)
     *
     * @parameter
     */  
    protected String chapterAutolabel;

    /**
     * 
     * (Original XSL attribuut: <code>biblioentry.primary.count</code>.)
     *
     * @parameter
     */  
    protected String biblioentryPrimaryCount;

    /**
     * When lengths are converted to pixels, this value is used to determine the size of a pixel.
     * (Original XSL attribuut: <code>pixels.per.inch</code>.)
     *
     * @parameter
     */  
    protected String pixelsPerInch;

    /**
     * 
     * (Original XSL attribuut: <code>contrib.inline.enabled</code>.)
     *
     * @parameter
     */  
    protected String contribInlineEnabled;

    /**
     * 
     * (Original XSL attribuut: <code>olink.resolver</code>.)
     *
     * @parameter
     */  
    protected String olinkResolver;

    /**
     * 
     * (Original XSL attribuut: <code>htmlhelp.button.back</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpButtonBack;

    /**
     * Specifies where formal object titles should occur.
     * (Original XSL attribuut: <code>formal.title.placement</code>.)
     *
     * @parameter
     */  
    protected String formalTitlePlacement;

    /**
     * 
     * (Original XSL attribuut: <code>chunker.output.quiet</code>.)
     *
     * @parameter
     */  
    protected String chunkerOutputQuiet;

    /**
     * Maintaining bibliography entries across a set of documents is tedious, time consuming, and error prone.
     * (Original XSL attribuut: <code>bibliography.collection</code>.)
     *
     * @parameter
     */  
    protected String bibliographyCollection;

    /**
     * This parameter permits you to override the text to insert between the two numbers of a page range in an index.
     * (Original XSL attribuut: <code>index.range.separator</code>.)
     *
     * @parameter
     */  
    protected String indexRangeSeparator;

    /**
     * If you want Locate button shown on toolbar, turn this parameter to 1.
     * (Original XSL attribuut: <code>htmlhelp.button.locate</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpButtonLocate;

    /**
     * 
     * (Original XSL attribuut: <code>shade.verbatim</code>.)
     *
     * @parameter
     */  
    protected String shadeVerbatim;

    /**
     * If line numbering is enabled, line numbers will appear right justified in a field "width" characters wide.
     * (Original XSL attribuut: <code>linenumbering.width</code>.)
     *
     * @parameter
     */  
    protected String linenumberingWidth;

    /**
     * 
     * (Original XSL attribuut: <code>l10n.gentext.default.language</code>.)
     *
     * @parameter
     */  
    protected String l10nGentextDefaultLanguage;

    /**
     * 
     * (Original XSL attribuut: <code>generate.legalnotice.link</code>.)
     *
     * @parameter
     */  
    protected String generateLegalnoticeLink;

    /**
     * 
     * (Original XSL attribuut: <code>refentry.generate.name</code>.)
     *
     * @parameter
     */  
    protected String refentryGenerateName;

    /**
     * 
     * (Original XSL attribuut: <code>admon.style</code>.)
     *
     * @parameter
     */  
    protected String admonStyle;

    /**
     * This parameter allows you to control the punctuation of certain types of generated cross reference text.
     * (Original XSL attribuut: <code>xref.label-title.separator</code>.)
     *
     * @parameter
     */  
    protected String xrefLabelTitleSeparator;

    /**
     * 
     * (Original XSL attribuut: <code>html.stylesheet.type</code>.)
     *
     * @parameter
     */  
    protected String htmlStylesheetType;

    /**
     * 
     * (Original XSL attribuut: <code>variablelist.term.separator</code>.)
     *
     * @parameter
     */  
    protected String variablelistTermSeparator;

    /**
     * 
     * (Original XSL attribuut: <code>qanda.inherit.numeration</code>.)
     *
     * @parameter
     */  
    protected String qandaInheritNumeration;

    /**
     * 
     * (Original XSL attribuut: <code>callout.defaultcolumn</code>.)
     *
     * @parameter
     */  
    protected String calloutDefaultcolumn;

    /**
     * The value of this parameter specifies profiles which should be included in the output.
     * (Original XSL attribuut: <code>profile.revisionflag</code>.)
     *
     * @parameter
     */  
    protected String profileRevisionflag;

    /**
     * 
     * (Original XSL attribuut: <code>procedure.step.numeration.formats</code>.)
     *
     * @parameter
     */  
    protected String procedureStepNumerationFormats;

    /**
     * 
     * (Original XSL attribuut: <code>rootid</code>.)
     *
     * @parameter
     */  
    protected String rootid;

    /**
     * This parameter sets the depth of section chunking.
     * (Original XSL attribuut: <code>chunk.section.depth</code>.)
     *
     * @parameter
     */  
    protected String chunkSectionDepth;

    /**
     * 
     * (Original XSL attribuut: <code>refentry.xref.manvolnum</code>.)
     *
     * @parameter
     */  
    protected String refentryXrefManvolnum;

    /**
     * 
     * (Original XSL attribuut: <code>epub.html.toc.id</code>.)
     *
     * @parameter
     */  
    protected String epubHtmlTocId;

    /**
     * Name of default window.
     * (Original XSL attribuut: <code>htmlhelp.hhp.window</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpHhpWindow;

    /**
     * In order to resolve olinks efficiently, the stylesheets can generate an external data file containing information about all potential cross reference endpoints in a document.
     * (Original XSL attribuut: <code>collect.xref.targets</code>.)
     *
     * @parameter
     */  
    protected String collectXrefTargets;

    /**
     * If true, year ranges that span a single year will be printed in range notation (1998-1999) instead of discrete notation (1998, 1999).
     * (Original XSL attribuut: <code>make.single.year.ranges</code>.)
     *
     * @parameter
     */  
    protected String makeSingleYearRanges;

    /**
     * When true this parameter enables enhanced decompilation of CHM.
     * (Original XSL attribuut: <code>htmlhelp.enhanced.decompilation</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpEnhancedDecompilation;

    /**
     * URL address of page accessible by Jump2 button.
     * (Original XSL attribuut: <code>htmlhelp.button.jump2.url</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpButtonJump2Url;

    /**
     * Set to true for folder-like icons or zero for book-like icons in the ToC.
     * (Original XSL attribuut: <code>htmlhelp.hhc.folders.instead.books</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpHhcFoldersInsteadBooks;

    /**
     * If true, the HTML stylesheet will generate ID attributes on containers.
     * (Original XSL attribuut: <code>generate.id.attributes</code>.)
     *
     * @parameter
     */  
    protected String generateIdAttributes;

    /**
     * 
     * (Original XSL attribuut: <code>epub.cover.id</code>.)
     *
     * @parameter
     */  
    protected String epubCoverId;

    /**
     * 
     * (Original XSL attribuut: <code>stylesheet.result.type</code>.)
     *
     * @parameter
     */  
    protected String stylesheetResultType;

    /**
     * This parameter permits you to override the text to insert between page references in a formatted index entry.
     * (Original XSL attribuut: <code>index.number.separator</code>.)
     *
     * @parameter
     */  
    protected String indexNumberSeparator;

    /**
     * 
     * (Original XSL attribuut: <code>callout.unicode.start.character</code>.)
     *
     * @parameter
     */  
    protected String calloutUnicodeStartCharacter;

    /**
     * Sets the background color for EBNF tables (a pale brown).
     * (Original XSL attribuut: <code>ebnf.table.bgcolor</code>.)
     *
     * @parameter
     */  
    protected String ebnfTableBgcolor;

    /**
     * 
     * (Original XSL attribuut: <code>epub.container.filename</code>.)
     *
     * @parameter
     */  
    protected String epubContainerFilename;

    /**
     * 
     * (Original XSL attribuut: <code>l10n.lang.value.rfc.compliant</code>.)
     *
     * @parameter
     */  
    protected String l10nLangValueRfcCompliant;

    /**
     * This parameter allows you to control the punctuation of certain types of generated cross reference text.
     * (Original XSL attribuut: <code>xref.label-page.separator</code>.)
     *
     * @parameter
     */  
    protected String xrefLabelPageSeparator;

    /**
     * 
     * (Original XSL attribuut: <code>process.empty.source.toc</code>.)
     *
     * @parameter
     */  
    protected String processEmptySourceToc;

    /**
     * Set to true to remember help window position between starts.
     * (Original XSL attribuut: <code>htmlhelp.remember.window.position</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpRememberWindowPosition;

    /**
     * If true, the headers and footers of chunked HTML display the titles of the next and previous chunks, along with the words 'Next' and 'Previous' (or the equivalent graphical icons if navig.
     * (Original XSL attribuut: <code>navig.showtitles</code>.)
     *
     * @parameter
     */  
    protected String navigShowtitles;

    /**
     * This location has precedence over the corresponding Java property.
     * (Original XSL attribuut: <code>highlight.xslthl.config</code>.)
     *
     * @parameter
     */  
    protected String highlightXslthlConfig;

    /**
     * 
     * (Original XSL attribuut: <code>epub.ncx.filename</code>.)
     *
     * @parameter
     */  
    protected String epubNcxFilename;

    /**
     * 
     * (Original XSL attribuut: <code>highlight.source</code>.)
     *
     * @parameter
     */  
    protected String highlightSource;

    /**
     * If true, a rule will be drawn above the page footers.
     * (Original XSL attribuut: <code>footer.rule</code>.)
     *
     * @parameter
     */  
    protected String footerRule;

    /**
     * 
     * (Original XSL attribuut: <code>refentry.generate.title</code>.)
     *
     * @parameter
     */  
    protected String refentryGenerateTitle;

    /**
     * Sets the path, probably relative to the directory where the HTML files are created, to the navigational graphics used in the headers and footers of chunked HTML.
     * (Original XSL attribuut: <code>navig.graphics.path</code>.)
     *
     * @parameter
     */  
    protected String navigGraphicsPath;

    /**
     * Sets the path to the directory holding the callout graphics.
     * (Original XSL attribuut: <code>callout.graphics.path</code>.)
     *
     * @parameter
     */  
    protected String calloutGraphicsPath;

    /**
     * 
     * (Original XSL attribuut: <code>autotoc.label.in.hyperlink</code>.)
     *
     * @parameter
     */  
    protected String autotocLabelInHyperlink;

    /**
     * Set to true to include the Zoom button  on the toolbar.
     * (Original XSL attribuut: <code>htmlhelp.button.zoom</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpButtonZoom;

    /**
     * This parameter specifies the output method to be used in files generated by the chunking stylesheet.
     * (Original XSL attribuut: <code>chunker.output.method</code>.)
     *
     * @parameter
     */  
    protected String chunkerOutputMethod;

    /**
     * 
     * (Original XSL attribuut: <code>qanda.in.toc</code>.)
     *
     * @parameter
     */  
    protected String qandaInToc;

    /**
     * If true, then the glossentry elements within a glossary, glossdiv, or glosslist are sorted on the glossterm, using the current lang setting.
     * (Original XSL attribuut: <code>glossary.sort</code>.)
     *
     * @parameter
     */  
    protected String glossarySort;

    /**
     * Sets the filename extension to use on callout graphics.
     * (Original XSL attribuut: <code>callout.graphics.extension</code>.)
     *
     * @parameter
     */  
    protected String calloutGraphicsExtension;

    /**
     * 
     * (Original XSL attribuut: <code>footnote.number.symbols</code>.)
     *
     * @parameter
     */  
    protected String footnoteNumberSymbols;

    /**
     * URL address of page accessible by Home button.
     * (Original XSL attribuut: <code>htmlhelp.button.home.url</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpButtonHomeUrl;

    /**
     * If true, CSS will be used to draw table borders.
     * (Original XSL attribuut: <code>table.borders.with.css</code>.)
     *
     * @parameter
     */  
    protected String tableBordersWithCss;

    /**
     * 
     * (Original XSL attribuut: <code>html.extra.head.links</code>.)
     *
     * @parameter
     */  
    protected String htmlExtraHeadLinks;

    /**
     * 
     * (Original XSL attribuut: <code>bridgehead.in.toc</code>.)
     *
     * @parameter
     */  
    protected String bridgeheadInToc;

    /**
     * 
     * (Original XSL attribuut: <code>othercredit.like.author.enabled</code>.)
     *
     * @parameter
     */  
    protected String othercreditLikeAuthorEnabled;

    /**
     * If line numbering is enabled, everyNth line will be numbered.
     * (Original XSL attribuut: <code>linenumbering.everyNth</code>.)
     *
     * @parameter
     */  
    protected String linenumberingEveryNth;

    /**
     * This parameter has effect only when Saxon 6 is used (version 6.
     * (Original XSL attribuut: <code>saxon.character.representation</code>.)
     *
     * @parameter
     */  
    protected String saxonCharacterRepresentation;

    /**
     * 
     * (Original XSL attribuut: <code>funcsynopsis.style</code>.)
     *
     * @parameter
     */  
    protected String funcsynopsisStyle;

    /**
     * Specify if an index should be generated.
     * (Original XSL attribuut: <code>generate.index</code>.)
     *
     * @parameter
     */  
    protected String generateIndex;

    /**
     * 
     * (Original XSL attribuut: <code>empty.local.l10n.xml</code>.)
     *
     * @parameter
     */  
    protected String emptyLocalL10nXml;

    /**
     * Set to true to display texts under toolbar buttons, zero to switch off displays.
     * (Original XSL attribuut: <code>htmlhelp.show.toolbar.text</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpShowToolbarText;

    /**
     * 
     * (Original XSL attribuut: <code>epub.embedded.fonts</code>.)
     *
     * @parameter
     */  
    protected String epubEmbeddedFonts;

    /**
     * If true, the language of the target will be used when generating cross reference text.
     * (Original XSL attribuut: <code>l10n.gentext.use.xref.language</code>.)
     *
     * @parameter
     */  
    protected String l10nGentextUseXrefLanguage;

    /**
     * This parameter defines a list of lang values to search among to resolve olinks.
     * (Original XSL attribuut: <code>olink.lang.fallback.sequence</code>.)
     *
     * @parameter
     */  
    protected String olinkLangFallbackSequence;

    /**
     * 
     * (Original XSL attribuut: <code>epub.ncx.toc.id</code>.)
     *
     * @parameter
     */  
    protected String epubNcxTocId;

    /**
     * 
     * (Original XSL attribuut: <code>author.othername.in.middle</code>.)
     *
     * @parameter
     */  
    protected String authorOthernameInMiddle;

    /**
     * If true, a separator will be generated between consecutive reference pages.
     * (Original XSL attribuut: <code>refentry.separator</code>.)
     *
     * @parameter
     */  
    protected String refentrySeparator;

    /**
     * 
     * (Original XSL attribuut: <code>menuchoice.separator</code>.)
     *
     * @parameter
     */  
    protected String menuchoiceSeparator;

    /**
     * 
     * (Original XSL attribuut: <code>make.year.ranges</code>.)
     *
     * @parameter
     */  
    protected String makeYearRanges;

    /**
     * 
     * (Original XSL attribuut: <code>make.graphic.viewport</code>.)
     *
     * @parameter
     */  
    protected String makeGraphicViewport;

    /**
     * 
     * (Original XSL attribuut: <code>manifest</code>.)
     *
     * @parameter
     */  
    protected String manifest;

    /**
     * If you want Stop button shown on toolbar, turn this parameter to 1.
     * (Original XSL attribuut: <code>htmlhelp.button.stop</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpButtonStop;

    /**
     * 
     * (Original XSL attribuut: <code>nominal.image.depth</code>.)
     *
     * @parameter
     */  
    protected String nominalImageDepth;

    /**
     * If this parameter is set to any value other than the empty string, its value will be used as the value for the language when generating text.
     * (Original XSL attribuut: <code>l10n.gentext.language</code>.)
     *
     * @parameter
     */  
    protected String l10nGentextLanguage;

    /**
     * 
     * (Original XSL attribuut: <code>htmlhelp.chm</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpChm;

    /**
     * This parameter specifies the width of the navigation pane (containing TOC and other navigation tabs) in pixels.
     * (Original XSL attribuut: <code>htmlhelp.hhc.width</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpHhcWidth;

    /**
     * 
     * (Original XSL attribuut: <code>epub.ncx.depth</code>.)
     *
     * @parameter
     */  
    protected String epubNcxDepth;

    /**
     * If true, extensions may be used.
     * (Original XSL attribuut: <code>use.extensions</code>.)
     *
     * @parameter
     */  
    protected String useExtensions;

    /**
     * Specify which characters are to be counted as punctuation.
     * (Original XSL attribuut: <code>runinhead.title.end.punct</code>.)
     *
     * @parameter
     */  
    protected String runinheadTitleEndPunct;

    /**
     * If true, then each olink will generate several messages about how it is being resolved during processing.
     * (Original XSL attribuut: <code>olink.debug</code>.)
     *
     * @parameter
     */  
    protected String olinkDebug;

    /**
     * Title of Jump1 button.
     * (Original XSL attribuut: <code>htmlhelp.button.jump1.title</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpButtonJump1Title;

    /**
     * 
     * (Original XSL attribuut: <code>local.l10n.xml</code>.)
     *
     * @parameter
     */  
    protected String localL10nXml;

    /**
     * 
     * (Original XSL attribuut: <code>index.links.to.section</code>.)
     *
     * @parameter
     */  
    protected String indexLinksToSection;

    /**
     * 
     * (Original XSL attribuut: <code>xref.with.number.and.title</code>.)
     *
     * @parameter
     */  
    protected String xrefWithNumberAndTitle;

    /**
     * Sets the path to the directory containing the admonition graphics (caution.
     * (Original XSL attribuut: <code>admon.graphics.path</code>.)
     *
     * @parameter
     */  
    protected String admonGraphicsPath;

    /**
     * If you want to include chapter and section numbers into ToC in the left panel, set this parameter to 1.
     * (Original XSL attribuut: <code>eclipse.autolabel</code>.)
     *
     * @parameter
     */  
    protected String eclipseAutolabel;

    /**
     * 
     * (Original XSL attribuut: <code>annotation.js</code>.)
     *
     * @parameter
     */  
    protected String annotationJs;

    /**
     * Set this to true to include chapter and section numbers into ToC in the left panel.
     * (Original XSL attribuut: <code>htmlhelp.autolabel</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpAutolabel;

    /**
     * 
     * (Original XSL attribuut: <code>table.footnote.number.format</code>.)
     *
     * @parameter
     */  
    protected String tableFootnoteNumberFormat;

    /**
     * 
     * (Original XSL attribuut: <code>html.head.legalnotice.link.types</code>.)
     *
     * @parameter
     */  
    protected String htmlHeadLegalnoticeLinkTypes;

    /**
     * 
     * (Original XSL attribuut: <code>default.image.width</code>.)
     *
     * @parameter
     */  
    protected String defaultImageWidth;

    /**
     * Set to true to include the Home button  on the toolbar.
     * (Original XSL attribuut: <code>htmlhelp.button.home</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpButtonHome;

    /**
     * If true, a rule will be drawn below the page headers.
     * (Original XSL attribuut: <code>header.rule</code>.)
     *
     * @parameter
     */  
    protected String headerRule;

    /**
     * 
     * (Original XSL attribuut: <code>preface.autolabel</code>.)
     *
     * @parameter
     */  
    protected String prefaceAutolabel;

    /**
     * Set to true if you insert images into your documents as external binary entities or if you are using absolute image paths.
     * (Original XSL attribuut: <code>htmlhelp.enumerate.images</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpEnumerateImages;

    /**
     * When olinks between documents are resolved for HTML output, the stylesheet can compute the relative path between the current document and the target document.
     * (Original XSL attribuut: <code>current.docid</code>.)
     *
     * @parameter
     */  
    protected String currentDocid;

    /**
     * If true, a web link will be generated, presumably to an online man->HTML gateway.
     * (Original XSL attribuut: <code>citerefentry.link</code>.)
     *
     * @parameter
     */  
    protected String citerefentryLink;

    /**
     * If you are re-using XML content modules in multiple documents, you may want to redirect some of your olinks.
     * (Original XSL attribuut: <code>prefer.internal.olink</code>.)
     *
     * @parameter
     */  
    protected String preferInternalOlink;

    /**
     * If true, SVG will be considered an acceptable image format.
     * (Original XSL attribuut: <code>use.svg</code>.)
     *
     * @parameter
     */  
    protected String useSvg;

    /**
     * 
     * (Original XSL attribuut: <code>profile.attribute</code>.)
     *
     * @parameter
     */  
    protected String profileAttribute;

    /**
     * 
     * (Original XSL attribuut: <code>link.mailto.url</code>.)
     *
     * @parameter
     */  
    protected String linkMailtoUrl;

    /**
     * Content of this parameter is placed at the end of [WINDOWS] section of project file.
     * (Original XSL attribuut: <code>htmlhelp.hhp.windows</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpHhpWindows;

    /**
     * Specifies the maximal depth of TOC on all levels.
     * (Original XSL attribuut: <code>toc.max.depth</code>.)
     *
     * @parameter
     */  
    protected String tocMaxDepth;

    /**
     * To resolve olinks between documents, the stylesheets use a master database document that identifies the target datafiles for all the documents within the scope of the olinks.
     * (Original XSL attribuut: <code>target.database.document</code>.)
     *
     * @parameter
     */  
    protected String targetDatabaseDocument;

    /**
     * Sets the filename extension to use on admonition graphics.
     * (Original XSL attribuut: <code>admon.graphics.extension</code>.)
     *
     * @parameter
     */  
    protected String admonGraphicsExtension;

    /**
     * 
     * (Original XSL attribuut: <code>html.ext</code>.)
     *
     * @parameter
     */  
    protected String htmlExt;

    /**
     * 
     * (Original XSL attribuut: <code>bibliography.numbered</code>.)
     *
     * @parameter
     */  
    protected String bibliographyNumbered;

    /**
     * 
     * (Original XSL attribuut: <code>epub.cover.image.id</code>.)
     *
     * @parameter
     */  
    protected String epubCoverImageId;

    /**
     * The textinsert extension element inserts the contents of       a file into the result tree (as text).
     * (Original XSL attribuut: <code>textinsert.extension</code>.)
     *
     * @parameter
     */  
    protected String textinsertExtension;

    /**
     * 
     * (Original XSL attribuut: <code>epub.cover.html</code>.)
     *
     * @parameter
     */  
    protected String epubCoverHtml;

    /**
     * 
     * (Original XSL attribuut: <code>generate.manifest</code>.)
     *
     * @parameter
     */  
    protected String generateManifest;

    /**
     * 
     * (Original XSL attribuut: <code>index.prefer.titleabbrev</code>.)
     *
     * @parameter
     */  
    protected String indexPreferTitleabbrev;

    /**
     * If html.
     * (Original XSL attribuut: <code>html.base</code>.)
     *
     * @parameter
     */  
    protected String htmlBase;

    /**
     * 
     * (Original XSL attribuut: <code>html.cleanup</code>.)
     *
     * @parameter
     */  
    protected String htmlCleanup;

    /**
     * 
     * (Original XSL attribuut: <code>default.table.width</code>.)
     *
     * @parameter
     */  
    protected String defaultTableWidth;

    /**
     * This parameter specifies the system identifier that should be used by the chunking stylesheet in the document type declaration of chunked pages.
     * (Original XSL attribuut: <code>chunker.output.doctype-system</code>.)
     *
     * @parameter
     */  
    protected String chunkerOutputDoctypeSystem;

    /**
     * Specifies the depth to which recursive sections should appear in the TOC.
     * (Original XSL attribuut: <code>toc.section.depth</code>.)
     *
     * @parameter
     */  
    protected String tocSectionDepth;

    /**
     * Sets direction of text flow and text alignment based on locale.
     * (Original XSL attribuut: <code>writing.mode</code>.)
     *
     * @parameter
     */  
    protected String writingMode;

    /**
     * JavaHelp crashes on some characters when written as character references.
     * (Original XSL attribuut: <code>javahelp.encoding</code>.)
     *
     * @parameter
     */  
    protected String javahelpEncoding;

    /**
     * 
     * (Original XSL attribuut: <code>htmlhelp.display.progress</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpDisplayProgress;

    /**
     * The stylesheets can use either an image of the numbers one to ten, or the single Unicode character which represents the numeral, in white on a black background.
     * (Original XSL attribuut: <code>callout.unicode</code>.)
     *
     * @parameter
     */  
    protected String calloutUnicode;

    /**
     * 
     * (Original XSL attribuut: <code>textdata.default.encoding</code>.)
     *
     * @parameter
     */  
    protected String textdataDefaultEncoding;

    /**
     * If true, TOCs will be annotated.
     * (Original XSL attribuut: <code>annotate.toc</code>.)
     *
     * @parameter
     */  
    protected String annotateToc;

    /**
     * If true (true), admonitions are presented in an alternate style that uses a graphic.
     * (Original XSL attribuut: <code>admon.graphics</code>.)
     *
     * @parameter
     */  
    protected String admonGraphics;

    /**
     * 
     * (Original XSL attribuut: <code>htmlhelp.button.hideshow</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpButtonHideshow;

    /**
     * Set to true to include the Stop button  on the toolbar.
     * (Original XSL attribuut: <code>htmlhelp.button.refresh</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpButtonRefresh;

    /**
     * 
     * (Original XSL attribuut: <code>runinhead.default.title.end.punct</code>.)
     *
     * @parameter
     */  
    protected String runinheadDefaultTitleEndPunct;

    /**
     * 
     * (Original XSL attribuut: <code>glossentry.show.acronym</code>.)
     *
     * @parameter
     */  
    protected String glossentryShowAcronym;

    /**
     * 
     * (Original XSL attribuut: <code>css.decoration</code>.)
     *
     * @parameter
     */  
    protected String cssDecoration;

    /**
     * 
     * (Original XSL attribuut: <code>use.role.for.mediaobject</code>.)
     *
     * @parameter
     */  
    protected String useRoleForMediaobject;

    /**
     * If true, section labels are prefixed with the label of the component that contains them.
     * (Original XSL attribuut: <code>section.label.includes.component.label</code>.)
     *
     * @parameter
     */  
    protected String sectionLabelIncludesComponentLabel;

    /**
     * If true (true), admonitions are presented with a generated text label such as Note or Warning in the appropriate language.
     * (Original XSL attribuut: <code>admon.textlabel</code>.)
     *
     * @parameter
     */  
    protected String admonTextlabel;

    /**
     * The value of this parameter specifies profiles which should be included in the output.
     * (Original XSL attribuut: <code>profile.vendor</code>.)
     *
     * @parameter
     */  
    protected String profileVendor;

    /**
     * The value of this parameter specifies profiles which should be included in the output.
     * (Original XSL attribuut: <code>profile.status</code>.)
     *
     * @parameter
     */  
    protected String profileStatus;

    /**
     * 
     * (Original XSL attribuut: <code>index.on.role</code>.)
     *
     * @parameter
     */  
    protected String indexOnRole;

    /**
     * The image to be used for draft watermarks.
     * (Original XSL attribuut: <code>draft.watermark.image</code>.)
     *
     * @parameter
     */  
    protected String draftWatermarkImage;

    /**
     * The value of this parameter specifies profiles which should be included in the output.
     * (Original XSL attribuut: <code>profile.wordsize</code>.)
     *
     * @parameter
     */  
    protected String profileWordsize;

    /**
     * Name of auxiliary file for TeX equations.
     * (Original XSL attribuut: <code>tex.math.file</code>.)
     *
     * @parameter
     */  
    protected String texMathFile;

    /**
     * 
     * (Original XSL attribuut: <code>htmlhelp.output</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpOutput;

    /**
     * 
     * (Original XSL attribuut: <code>qanda.nested.in.toc</code>.)
     *
     * @parameter
     */  
    protected String qandaNestedInToc;

    /**
     * If you want Options button shown on toolbar, turn this parameter to 1.
     * (Original XSL attribuut: <code>htmlhelp.button.options</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpButtonOptions;

    /**
     * Set the color of table cell borders.
     * (Original XSL attribuut: <code>table.cell.border.color</code>.)
     *
     * @parameter
     */  
    protected String tableCellBorderColor;

    /**
     * 
     * (Original XSL attribuut: <code>olink.fragid</code>.)
     *
     * @parameter
     */  
    protected String olinkFragid;

    /**
     * The separator is inserted between line numbers and lines in the verbatim environment.
     * (Original XSL attribuut: <code>linenumbering.separator</code>.)
     *
     * @parameter
     */  
    protected String linenumberingSeparator;

    /**
     * 
     * (Original XSL attribuut: <code>docbook.css.source</code>.)
     *
     * @parameter
     */  
    protected String docbookCssSource;

    /**
     * If set to zero, there will be no entry for the root element in the  ToC.
     * (Original XSL attribuut: <code>htmlhelp.hhc.show.root</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpHhcShowRoot;

    /**
     * If you want to include chapter and section numbers into ToC in,  set this parameter to 1.
     * (Original XSL attribuut: <code>epub.autolabel</code>.)
     *
     * @parameter
     */  
    protected String epubAutolabel;

    /**
     * Set to true to include the Next button  on the toolbar.
     * (Original XSL attribuut: <code>htmlhelp.button.next</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpButtonNext;

    /**
     * Selects the direction in which a float should be placed.
     * (Original XSL attribuut: <code>default.float.class</code>.)
     *
     * @parameter
     */  
    protected String defaultFloatClass;

    /**
     * 
     * (Original XSL attribuut: <code>label.from.part</code>.)
     *
     * @parameter
     */  
    protected String labelFromPart;

    /**
     * 
     * (Original XSL attribuut: <code>abstract.notitle.enabled</code>.)
     *
     * @parameter
     */  
    protected String abstractNotitleEnabled;

    /**
     * 
     * (Original XSL attribuut: <code>bibliography.style</code>.)
     *
     * @parameter
     */  
    protected String bibliographyStyle;

    /**
     * Specifies the thickness of the border on the table's frame.
     * (Original XSL attribuut: <code>table.frame.border.thickness</code>.)
     *
     * @parameter
     */  
    protected String tableFrameBorderThickness;

    /**
     * If true, then the exsl:node-set() function is available to be used in the stylesheet.
     * (Original XSL attribuut: <code>exsl.node.set.available</code>.)
     *
     * @parameter
     */  
    protected String exslNodeSetAvailable;

    /**
     * 
     * (Original XSL attribuut: <code>callouts.extension</code>.)
     *
     * @parameter
     */  
    protected String calloutsExtension;

    /**
     * 
     * (Original XSL attribuut: <code>annotation.support</code>.)
     *
     * @parameter
     */  
    protected String annotationSupport;

    /**
     * This parameter specifies the value of the standalone   specification for generated pages.
     * (Original XSL attribuut: <code>chunker.output.standalone</code>.)
     *
     * @parameter
     */  
    protected String chunkerOutputStandalone;

    /**
     * Separator character used for compound profile values.
     * (Original XSL attribuut: <code>profile.separator</code>.)
     *
     * @parameter
     */  
    protected String profileSeparator;

    /**
     * 
     * (Original XSL attribuut: <code>linenumbering.extension</code>.)
     *
     * @parameter
     */  
    protected String linenumberingExtension;

    /**
     * Specifies the filename of the alias file (used for context-sensitive help).
     * (Original XSL attribuut: <code>htmlhelp.alias.file</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpAliasFile;

    /**
     * 
     * (Original XSL attribuut: <code>keep.relative.image.uris</code>.)
     *
     * @parameter
     */  
    protected String keepRelativeImageUris;

    /**
     * 
     * (Original XSL attribuut: <code>use.id.as.filename</code>.)
     *
     * @parameter
     */  
    protected String useIdAsFilename;

    /**
     * The value of this parameter specifies profiles which should be included in the output.
     * (Original XSL attribuut: <code>profile.userlevel</code>.)
     *
     * @parameter
     */  
    protected String profileUserlevel;

    /**
     * Eclipse Help plugin name.
     * (Original XSL attribuut: <code>eclipse.plugin.name</code>.)
     *
     * @parameter
     */  
    protected String eclipsePluginName;

    /**
     * If non-zero, specifies the thickness of borders on table cells.
     * (Original XSL attribuut: <code>table.cell.border.thickness</code>.)
     *
     * @parameter
     */  
    protected String tableCellBorderThickness;

    /**
     * Specifies the border style of table cells.
     * (Original XSL attribuut: <code>table.cell.border.style</code>.)
     *
     * @parameter
     */  
    protected String tableCellBorderStyle;

    /**
     * URL address of page accessible by Jump1 button.
     * (Original XSL attribuut: <code>htmlhelp.button.jump1.url</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpButtonJump1Url;

    /**
     * 
     * (Original XSL attribuut: <code>graphicsize.use.img.src.path</code>.)
     *
     * @parameter
     */  
    protected String graphicsizeUseImgSrcPath;

    /**
     * If true, each of the ToC and LoTs (List of Examples, List of Figures, etc.
     * (Original XSL attribuut: <code>chunk.separate.lots</code>.)
     *
     * @parameter
     */  
    protected String chunkSeparateLots;

    /**
     * 
     * (Original XSL attribuut: <code>use.embed.for.svg</code>.)
     *
     * @parameter
     */  
    protected String useEmbedForSvg;

    /**
     * If true, unlabeled qandadivs will be enumerated.
     * (Original XSL attribuut: <code>qandadiv.autolabel</code>.)
     *
     * @parameter
     */  
    protected String qandadivAutolabel;

    /**
     * 
     * (Original XSL attribuut: <code>ebnf.statement.terminator</code>.)
     *
     * @parameter
     */  
    protected String ebnfStatementTerminator;

    /**
     * In order to resolve olinks efficiently, the stylesheets can generate an external data file containing information about all potential cross reference endpoints in a document.
     * (Original XSL attribuut: <code>targets.filename</code>.)
     *
     * @parameter
     */  
    protected String targetsFilename;

    /**
     * 
     * (Original XSL attribuut: <code>generate.section.toc.level</code>.)
     *
     * @parameter
     */  
    protected String generateSectionTocLevel;

    /**
     * When true, additional, empty paragraphs are inserted in several contexts (for example, around informal figures), to create a more pleasing visual appearance in many browsers.
     * (Original XSL attribuut: <code>spacing.paras</code>.)
     *
     * @parameter
     */  
    protected String spacingParas;

    /**
     * 
     * (Original XSL attribuut: <code>function.parens</code>.)
     *
     * @parameter
     */  
    protected String functionParens;

    /**
     * Formal procedures are numbered and always have a title.
     * (Original XSL attribuut: <code>formal.procedures</code>.)
     *
     * @parameter
     */  
    protected String formalProcedures;

    /**
     * 
     * (Original XSL attribuut: <code>epub.cover.filename</code>.)
     *
     * @parameter
     */  
    protected String epubCoverFilename;

    /**
     * 
     * (Original XSL attribuut: <code>process.source.toc</code>.)
     *
     * @parameter
     */  
    protected String processSourceToc;

    /**
     * 
     * (Original XSL attribuut: <code>annotation.css</code>.)
     *
     * @parameter
     */  
    protected String annotationCss;

    /**
     * Set the section depth in the left pane of HTML Help viewer.
     * (Original XSL attribuut: <code>htmlhelp.hhc.section.depth</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpHhcSectionDepth;

    /**
     * When cross reference data is collected for use by olinks, the data for each potential target includes one field containing a completely assembled cross reference string, as if it were an xref generated in that document.
     * (Original XSL attribuut: <code>use.local.olink.style</code>.)
     *
     * @parameter
     */  
    protected String useLocalOlinkStyle;

    /**
     * 
     * (Original XSL attribuut: <code>phrase.propagates.style</code>.)
     *
     * @parameter
     */  
    protected String phrasePropagatesStyle;

    /**
     * If true, callouts are presented with graphics (e.
     * (Original XSL attribuut: <code>callout.graphics</code>.)
     *
     * @parameter
     */  
    protected String calloutGraphics;

    /**
     * 
     * (Original XSL attribuut: <code>insert.olink.page.number</code>.)
     *
     * @parameter
     */  
    protected String insertOlinkPageNumber;

    /**
     * If true title of document is shown before ToC/LoT in separate chunk.
     * (Original XSL attribuut: <code>chunk.tocs.and.lots.has.title</code>.)
     *
     * @parameter
     */  
    protected String chunkTocsAndLotsHasTitle;

    /**
     * 
     * (Original XSL attribuut: <code>component.label.includes.part.label</code>.)
     *
     * @parameter
     */  
    protected String componentLabelIncludesPartLabel;

    /**
     * 
     * (Original XSL attribuut: <code>profile.value</code>.)
     *
     * @parameter
     */  
    protected String profileValue;

    /**
     * 
     * (Original XSL attribuut: <code>img.src.path</code>.)
     *
     * @parameter
     */  
    protected String imgSrcPath;

    /**
     * 
     * (Original XSL attribuut: <code>firstterm.only.link</code>.)
     *
     * @parameter
     */  
    protected String firsttermOnlyLink;

    /**
     * Selects draft mode.
     * (Original XSL attribuut: <code>draft.mode</code>.)
     *
     * @parameter
     */  
    protected String draftMode;

    /**
     * 
     * (Original XSL attribuut: <code>funcsynopsis.decoration</code>.)
     *
     * @parameter
     */  
    protected String funcsynopsisDecoration;

    /**
     * 
     * (Original XSL attribuut: <code>callout.unicode.number.limit</code>.)
     *
     * @parameter
     */  
    protected String calloutUnicodeNumberLimit;

    /**
     * Set to true to include the Print button  on the toolbar.
     * (Original XSL attribuut: <code>htmlhelp.button.print</code>.)
     *
     * @parameter
     */  
    protected String htmlhelpButtonPrint;

    /**
     * Eclipse Help plugin provider name.
     * (Original XSL attribuut: <code>eclipse.plugin.provider</code>.)
     *
     * @parameter
     */  
    protected String eclipsePluginProvider;

    /**
     * The value of this parameter specifies profiles which should be included in the output.
     * (Original XSL attribuut: <code>profile.lang</code>.)
     *
     * @parameter
     */  
    protected String profileLang;

    /**
     * 
     * (Original XSL attribuut: <code>olink.pubid</code>.)
     *
     * @parameter
     */  
    protected String olinkPubid;

    /**
     * 
     * (Original XSL attribuut: <code>blurb.on.titlepage.enabled</code>.)
     *
     * @parameter
     */  
    protected String blurbOnTitlepageEnabled;

    public File getImageDirectory() {
        return imageDirectory;
    }

    public void setImageDirectory(File imageDirectory) {
        this.imageDirectory = imageDirectory;
    }

    protected void configure(Transformer transformer) {
        getLog().debug("Configure the transformer.");
        if (chunkQuietly != null) {
            transformer.setParameter("chunk.quietly", 
                convertBooleanToXsltParam(chunkQuietly));
        }                     
        if (profileCondition != null) {
            transformer.setParameter("profile.condition", 
                convertStringToXsltParam(profileCondition));
        }                     
        if (useRoleAsXrefstyle != null) {
            transformer.setParameter("use.role.as.xrefstyle", 
                convertBooleanToXsltParam(useRoleAsXrefstyle));
        }                     
        if (profileRole != null) {
            transformer.setParameter("profile.role", 
                convertStringToXsltParam(profileRole));
        }                     
        if (navigGraphicsExtension != null) {
            transformer.setParameter("navig.graphics.extension", 
                convertStringToXsltParam(navigGraphicsExtension));
        }                     
        if (tableFrameBorderColor != null) {
            transformer.setParameter("table.frame.border.color", 
                convertStringToXsltParam(tableFrameBorderColor));
        }                     
        if (chunkTocsAndLots != null) {
            transformer.setParameter("chunk.tocs.and.lots", 
                convertBooleanToXsltParam(chunkTocsAndLots));
        }                     
        if (texMathDelims != null) {
            transformer.setParameter("tex.math.delims", 
                convertBooleanToXsltParam(texMathDelims));
        }                     
        if (graphicDefaultExtension != null) {
            transformer.setParameter("graphic.default.extension", 
                convertStringToXsltParam(graphicDefaultExtension));
        }                     
        if (partAutolabel != null) {
            transformer.setParameter("part.autolabel", 
                convertStringToXsltParam(partAutolabel));
        }                     
        if (showRevisionflag != null) {
            transformer.setParameter("show.revisionflag", 
                convertBooleanToXsltParam(showRevisionflag));
        }                     
        if (variablelistAsTable != null) {
            transformer.setParameter("variablelist.as.table", 
                convertBooleanToXsltParam(variablelistAsTable));
        }                     
        if (htmlhelpHhcBinary != null) {
            transformer.setParameter("htmlhelp.hhc.binary", 
                convertBooleanToXsltParam(htmlhelpHhcBinary));
        }                     
        if (graphicsizeExtension != null) {
            transformer.setParameter("graphicsize.extension", 
                convertBooleanToXsltParam(graphicsizeExtension));
        }                     
        if (epubCoverLinear != null) {
            transformer.setParameter("epub.cover.linear", 
                convertStringToXsltParam(epubCoverLinear));
        }                     
        if (pointsPerEm != null) {
            transformer.setParameter("points.per.em", 
                convertStringToXsltParam(pointsPerEm));
        }                     
        if (htmlhelpWindowGeometry != null) {
            transformer.setParameter("htmlhelp.window.geometry", 
                convertStringToXsltParam(htmlhelpWindowGeometry));
        }                     
        if (olinkSysid != null) {
            transformer.setParameter("olink.sysid", 
                convertStringToXsltParam(olinkSysid));
        }                     
        if (inheritKeywords != null) {
            transformer.setParameter("inherit.keywords", 
                convertBooleanToXsltParam(inheritKeywords));
        }                     
        if (profileRevision != null) {
            transformer.setParameter("profile.revision", 
                convertStringToXsltParam(profileRevision));
        }                     
        if (ebnfAssignment != null) {
            transformer.setParameter("ebnf.assignment", 
                convertStringToXsltParam(ebnfAssignment));
        }                     
        if (qandaDefaultlabel != null) {
            transformer.setParameter("qanda.defaultlabel", 
                convertStringToXsltParam(qandaDefaultlabel));
        }                     
        if (htmlhelpButtonPrev != null) {
            transformer.setParameter("htmlhelp.button.prev", 
                convertBooleanToXsltParam(htmlhelpButtonPrev));
        }                     
        if (chunkFirstSections != null) {
            transformer.setParameter("chunk.first.sections", 
                convertBooleanToXsltParam(chunkFirstSections));
        }                     
        if (nominalImageWidth != null) {
            transformer.setParameter("nominal.image.width", 
                convertStringToXsltParam(nominalImageWidth));
        }                     
        if (footnoteNumberFormat != null) {
            transformer.setParameter("footnote.number.format", 
                convertStringToXsltParam(footnoteNumberFormat));
        }                     
        if (referenceAutolabel != null) {
            transformer.setParameter("reference.autolabel", 
                convertStringToXsltParam(referenceAutolabel));
        }                     
        if (highlightDefaultLanguage != null) {
            transformer.setParameter("highlight.default.language", 
                convertStringToXsltParam(highlightDefaultLanguage));
        }                     
        if (preferredMediaobjectRole != null) {
            transformer.setParameter("preferred.mediaobject.role", 
                convertStringToXsltParam(preferredMediaobjectRole));
        }                     
        if (manualToc != null) {
            transformer.setParameter("manual.toc", 
                convertStringToXsltParam(manualToc));
        }                     
        if (generateToc != null) {
            transformer.setParameter("generate.toc", 
                convertStringToXsltParam(generateToc));
        }                     
        if (indexMethod != null) {
            transformer.setParameter("index.method", 
                convertStringToXsltParam(indexMethod));
        }                     
        if (insertOlinkPdfFrag != null) {
            transformer.setParameter("insert.olink.pdf.frag", 
                convertBooleanToXsltParam(insertOlinkPdfFrag));
        }                     
        if (ebnfTableBorder != null) {
            transformer.setParameter("ebnf.table.border", 
                convertBooleanToXsltParam(ebnfTableBorder));
        }                     
        if (indexOnType != null) {
            transformer.setParameter("index.on.type", 
                convertBooleanToXsltParam(indexOnType));
        }                     
        if (autotocLabelSeparator != null) {
            transformer.setParameter("autotoc.label.separator", 
                convertStringToXsltParam(autotocLabelSeparator));
        }                     
        if (nominalTableWidth != null) {
            transformer.setParameter("nominal.table.width", 
                convertStringToXsltParam(nominalTableWidth));
        }                     
        if (olinkDoctitle != null) {
            transformer.setParameter("olink.doctitle", 
                convertStringToXsltParam(olinkDoctitle));
        }                     
        if (htmlhelpUseHhk != null) {
            transformer.setParameter("htmlhelp.use.hhk", 
                convertBooleanToXsltParam(htmlhelpUseHhk));
        }                     
        if (htmlhelpButtonJump2Title != null) {
            transformer.setParameter("htmlhelp.button.jump2.title", 
                convertStringToXsltParam(htmlhelpButtonJump2Title));
        }                     
        if (chunkFast != null) {
            transformer.setParameter("chunk.fast", 
                convertStringToXsltParam(chunkFast));
        }                     
        if (insertXrefPageNumber != null) {
            transformer.setParameter("insert.xref.page.number", 
                convertStringToXsltParam(insertXrefPageNumber));
        }                     
        if (biblioentryAltPrimarySeps != null) {
            transformer.setParameter("biblioentry.alt.primary.seps", 
                convertStringToXsltParam(biblioentryAltPrimarySeps));
        }                     
        if (htmlhelpDefaultTopic != null) {
            transformer.setParameter("htmlhelp.default.topic", 
                convertStringToXsltParam(htmlhelpDefaultTopic));
        }                     
        if (htmlStylesheet != null) {
            transformer.setParameter("html.stylesheet", 
                convertStringToXsltParam(htmlStylesheet));
        }                     
        if (emphasisPropagatesStyle != null) {
            transformer.setParameter("emphasis.propagates.style", 
                convertBooleanToXsltParam(emphasisPropagatesStyle));
        }                     
        if (htmlhelpShowMenu != null) {
            transformer.setParameter("htmlhelp.show.menu", 
                convertBooleanToXsltParam(htmlhelpShowMenu));
        }                     
        if (onechunk != null) {
            transformer.setParameter("onechunk", 
                convertStringToXsltParam(onechunk));
        }                     
        if (chunkAppend != null) {
            transformer.setParameter("chunk.append", 
                convertStringToXsltParam(chunkAppend));
        }                     
        if (htmlAppend != null) {
            transformer.setParameter("html.append", 
                convertStringToXsltParam(htmlAppend));
        }                     
        if (variablelistTermBreakAfter != null) {
            transformer.setParameter("variablelist.term.break.after", 
                convertBooleanToXsltParam(variablelistTermBreakAfter));
        }                     
        if (htmlhelpShowAdvancedSearch != null) {
            transformer.setParameter("htmlhelp.show.advanced.search", 
                convertBooleanToXsltParam(htmlhelpShowAdvancedSearch));
        }                     
        if (htmlCellspacing != null) {
            transformer.setParameter("html.cellspacing", 
                convertStringToXsltParam(htmlCellspacing));
        }                     
        if (showComments != null) {
            transformer.setParameter("show.comments", 
                convertBooleanToXsltParam(showComments));
        }                     
        if (profileOs != null) {
            transformer.setParameter("profile.os", 
                convertStringToXsltParam(profileOs));
        }                     
        if (tableFrameBorderStyle != null) {
            transformer.setParameter("table.frame.border.style", 
                convertStringToXsltParam(tableFrameBorderStyle));
        }                     
        if (htmlLongdescLink != null) {
            transformer.setParameter("html.longdesc.link", 
                convertBooleanToXsltParam(htmlLongdescLink));
        }                     
        if (calloutGraphicsNumberLimit != null) {
            transformer.setParameter("callout.graphics.number.limit", 
                convertStringToXsltParam(calloutGraphicsNumberLimit));
        }                     
        if (suppressNavigation != null) {
            transformer.setParameter("suppress.navigation", 
                convertBooleanToXsltParam(suppressNavigation));
        }                     
        if (biblioentryItemSeparator != null) {
            transformer.setParameter("biblioentry.item.separator", 
                convertStringToXsltParam(biblioentryItemSeparator));
        }                     
        if (xrefTitlePageSeparator != null) {
            transformer.setParameter("xref.title-page.separator", 
                convertStringToXsltParam(xrefTitlePageSeparator));
        }                     
        if (tablecolumnsExtension != null) {
            transformer.setParameter("tablecolumns.extension", 
                convertBooleanToXsltParam(tablecolumnsExtension));
        }                     
        if (olinkBaseUri != null) {
            transformer.setParameter("olink.base.uri", 
                convertStringToXsltParam(olinkBaseUri));
        }                     
        if (makeValidHtml != null) {
            transformer.setParameter("make.valid.html", 
                convertBooleanToXsltParam(makeValidHtml));
        }                     
        if (annotationGraphicOpen != null) {
            transformer.setParameter("annotation.graphic.open", 
                convertStringToXsltParam(annotationGraphicOpen));
        }                     
        if (profileAudience != null) {
            transformer.setParameter("profile.audience", 
                convertStringToXsltParam(profileAudience));
        }                     
        if (emailDelimitersEnabled != null) {
            transformer.setParameter("email.delimiters.enabled", 
                convertBooleanToXsltParam(emailDelimitersEnabled));
        }                     
        if (generateCssHeader != null) {
            transformer.setParameter("generate.css.header", 
                convertBooleanToXsltParam(generateCssHeader));
        }                     
        if (htmlhelpTitle != null) {
            transformer.setParameter("htmlhelp.title", 
                convertStringToXsltParam(htmlhelpTitle));
        }                     
        if (texMathInAlt != null) {
            transformer.setParameter("tex.math.in.alt", 
                convertStringToXsltParam(texMathInAlt));
        }                     
        if (htmlhelpForceMapAndAlias != null) {
            transformer.setParameter("htmlhelp.force.map.and.alias", 
                convertBooleanToXsltParam(htmlhelpForceMapAndAlias));
        }                     
        if (sectionAutolabelMaxDepth != null) {
            transformer.setParameter("section.autolabel.max.depth", 
                convertStringToXsltParam(sectionAutolabelMaxDepth));
        }                     
        if (idWarnings != null) {
            transformer.setParameter("id.warnings", 
                convertBooleanToXsltParam(idWarnings));
        }                     
        if (adeExtensions != null) {
            transformer.setParameter("ade.extensions", 
                convertBooleanToXsltParam(adeExtensions));
        }                     
        if (formalObjectBreakAfter != null) {
            transformer.setParameter("formal.object.break.after", 
                convertStringToXsltParam(formalObjectBreakAfter));
        }                     
        if (profileArch != null) {
            transformer.setParameter("profile.arch", 
                convertStringToXsltParam(profileArch));
        }                     
        if (htmlhelpMapFile != null) {
            transformer.setParameter("htmlhelp.map.file", 
                convertStringToXsltParam(htmlhelpMapFile));
        }                     
        if (chunkerOutputCdataSectionElements != null) {
            transformer.setParameter("chunker.output.cdata-section-elements", 
                convertStringToXsltParam(chunkerOutputCdataSectionElements));
        }                     
        if (profileConformance != null) {
            transformer.setParameter("profile.conformance", 
                convertStringToXsltParam(profileConformance));
        }                     
        if (htmlHeadLegalnoticeLinkMultiple != null) {
            transformer.setParameter("html.head.legalnotice.link.multiple", 
                convertBooleanToXsltParam(htmlHeadLegalnoticeLinkMultiple));
        }                     
        if (refclassSuppress != null) {
            transformer.setParameter("refclass.suppress", 
                convertBooleanToXsltParam(refclassSuppress));
        }                     
        if (htmlCellpadding != null) {
            transformer.setParameter("html.cellpadding", 
                convertStringToXsltParam(htmlCellpadding));
        }                     
        if (eclipsePluginId != null) {
            transformer.setParameter("eclipse.plugin.id", 
                convertStringToXsltParam(eclipsePluginId));
        }                     
        if (chunkerOutputDoctypePublic != null) {
            transformer.setParameter("chunker.output.doctype-public", 
                convertStringToXsltParam(chunkerOutputDoctypePublic));
        }                     
        if (paraPropagatesStyle != null) {
            transformer.setParameter("para.propagates.style", 
                convertBooleanToXsltParam(paraPropagatesStyle));
        }                     
        if (makeCleanHtml != null) {
            transformer.setParameter("make.clean.html", 
                convertBooleanToXsltParam(makeCleanHtml));
        }                     
        if (tocListType != null) {
            transformer.setParameter("toc.list.type", 
                convertStringToXsltParam(tocListType));
        }                     
        if (navigGraphics != null) {
            transformer.setParameter("navig.graphics", 
                convertBooleanToXsltParam(navigGraphics));
        }                     
        if (generateRevhistoryLink != null) {
            transformer.setParameter("generate.revhistory.link", 
                convertBooleanToXsltParam(generateRevhistoryLink));
        }                     
        if (docbookCssLink != null) {
            transformer.setParameter("docbook.css.link", 
                convertBooleanToXsltParam(docbookCssLink));
        }                     
        if (l10nXml != null) {
            transformer.setParameter("l10n.xml", 
                convertStringToXsltParam(l10nXml));
        }                     
        if (tableFootnoteNumberSymbols != null) {
            transformer.setParameter("table.footnote.number.symbols", 
                convertStringToXsltParam(tableFootnoteNumberSymbols));
        }                     
        if (ulinkTarget != null) {
            transformer.setParameter("ulink.target", 
                convertStringToXsltParam(ulinkTarget));
        }                     
        if (chunkerOutputEncoding != null) {
            transformer.setParameter("chunker.output.encoding", 
                convertStringToXsltParam(chunkerOutputEncoding));
        }                     
        if (sectionAutolabel != null) {
            transformer.setParameter("section.autolabel", 
                convertBooleanToXsltParam(sectionAutolabel));
        }                     
        if (generateMetaAbstract != null) {
            transformer.setParameter("generate.meta.abstract", 
                convertBooleanToXsltParam(generateMetaAbstract));
        }                     
        if (htmlhelpHhpTail != null) {
            transformer.setParameter("htmlhelp.hhp.tail", 
                convertStringToXsltParam(htmlhelpHhpTail));
        }                     
        if (chunkToc != null) {
            transformer.setParameter("chunk.toc", 
                convertStringToXsltParam(chunkToc));
        }                     
        if (htmlhelpShowFavorities != null) {
            transformer.setParameter("htmlhelp.show.favorities", 
                convertBooleanToXsltParam(htmlhelpShowFavorities));
        }                     
        if (glosstermAutoLink != null) {
            transformer.setParameter("glossterm.auto.link", 
                convertBooleanToXsltParam(glosstermAutoLink));
        }                     
        if (get != null) {
            transformer.setParameter("get", 
                convertStringToXsltParam(get));
        }                     
        if (simplesectInToc != null) {
            transformer.setParameter("simplesect.in.toc", 
                convertBooleanToXsltParam(simplesectInToc));
        }                     
        if (suppressHeaderNavigation != null) {
            transformer.setParameter("suppress.header.navigation", 
                convertBooleanToXsltParam(suppressHeaderNavigation));
        }                     
        if (htmlhelpButtonJump2 != null) {
            transformer.setParameter("htmlhelp.button.jump2", 
                convertBooleanToXsltParam(htmlhelpButtonJump2));
        }                     
        if (htmlhelpButtonJump1 != null) {
            transformer.setParameter("htmlhelp.button.jump1", 
                convertBooleanToXsltParam(htmlhelpButtonJump1));
        }                     
        if (chunkerOutputOmitXmlDeclaration != null) {
            transformer.setParameter("chunker.output.omit-xml-declaration", 
                convertStringToXsltParam(chunkerOutputOmitXmlDeclaration));
        }                     
        if (htmlhelpButtonForward != null) {
            transformer.setParameter("htmlhelp.button.forward", 
                convertBooleanToXsltParam(htmlhelpButtonForward));
        }                     
        if (punctHonorific != null) {
            transformer.setParameter("punct.honorific", 
                convertStringToXsltParam(punctHonorific));
        }                     
        if (ignoreImageScaling != null) {
            transformer.setParameter("ignore.image.scaling", 
                convertBooleanToXsltParam(ignoreImageScaling));
        }                     
        if (appendixAutolabel != null) {
            transformer.setParameter("appendix.autolabel", 
                convertStringToXsltParam(appendixAutolabel));
        }                     
        if (entryPropagatesStyle != null) {
            transformer.setParameter("entry.propagates.style", 
                convertBooleanToXsltParam(entryPropagatesStyle));
        }                     
        if (suppressFooterNavigation != null) {
            transformer.setParameter("suppress.footer.navigation", 
                convertBooleanToXsltParam(suppressFooterNavigation));
        }                     
        if (indexTermSeparator != null) {
            transformer.setParameter("index.term.separator", 
                convertStringToXsltParam(indexTermSeparator));
        }                     
        if (calloutListTable != null) {
            transformer.setParameter("callout.list.table", 
                convertBooleanToXsltParam(calloutListTable));
        }                     
        if (htmlhelpOnly != null) {
            transformer.setParameter("htmlhelp.only", 
                convertBooleanToXsltParam(htmlhelpOnly));
        }                     
        if (htmlLongdesc != null) {
            transformer.setParameter("html.longdesc", 
                convertBooleanToXsltParam(htmlLongdesc));
        }                     
        if (editedbyEnabled != null) {
            transformer.setParameter("editedby.enabled", 
                convertBooleanToXsltParam(editedbyEnabled));
        }                     
        if (chunkerOutputMediaType != null) {
            transformer.setParameter("chunker.output.media-type", 
                convertStringToXsltParam(chunkerOutputMediaType));
        }                     
        if (segmentedlistAsTable != null) {
            transformer.setParameter("segmentedlist.as.table", 
                convertBooleanToXsltParam(segmentedlistAsTable));
        }                     
        if (htmlhelpHhc != null) {
            transformer.setParameter("htmlhelp.hhc", 
                convertStringToXsltParam(htmlhelpHhc));
        }                     
        if (htmlhelpHhp != null) {
            transformer.setParameter("htmlhelp.hhp", 
                convertStringToXsltParam(htmlhelpHhp));
        }                     
        if (chunkerOutputIndent != null) {
            transformer.setParameter("chunker.output.indent", 
                convertStringToXsltParam(chunkerOutputIndent));
        }                     
        if (htmlhelpHhk != null) {
            transformer.setParameter("htmlhelp.hhk", 
                convertStringToXsltParam(htmlhelpHhk));
        }                     
        if (customCssSource != null) {
            transformer.setParameter("custom.css.source", 
                convertStringToXsltParam(customCssSource));
        }                     
        if (htmlhelpEncoding != null) {
            transformer.setParameter("htmlhelp.encoding", 
                convertStringToXsltParam(htmlhelpEncoding));
        }                     
        if (annotationGraphicClose != null) {
            transformer.setParameter("annotation.graphic.close", 
                convertStringToXsltParam(annotationGraphicClose));
        }                     
        if (defaultTableFrame != null) {
            transformer.setParameter("default.table.frame", 
                convertStringToXsltParam(defaultTableFrame));
        }                     
        if (glossaryCollection != null) {
            transformer.setParameter("glossary.collection", 
                convertStringToXsltParam(glossaryCollection));
        }                     
        if (olinkOutlineExt != null) {
            transformer.setParameter("olink.outline.ext", 
                convertStringToXsltParam(olinkOutlineExt));
        }                     
        if (menuchoiceMenuSeparator != null) {
            transformer.setParameter("menuchoice.menu.separator", 
                convertStringToXsltParam(menuchoiceMenuSeparator));
        }                     
        if (profileSecurity != null) {
            transformer.setParameter("profile.security", 
                convertStringToXsltParam(profileSecurity));
        }                     
        if (chapterAutolabel != null) {
            transformer.setParameter("chapter.autolabel", 
                convertStringToXsltParam(chapterAutolabel));
        }                     
        if (biblioentryPrimaryCount != null) {
            transformer.setParameter("biblioentry.primary.count", 
                convertStringToXsltParam(biblioentryPrimaryCount));
        }                     
        if (pixelsPerInch != null) {
            transformer.setParameter("pixels.per.inch", 
                convertStringToXsltParam(pixelsPerInch));
        }                     
        if (contribInlineEnabled != null) {
            transformer.setParameter("contrib.inline.enabled", 
                convertBooleanToXsltParam(contribInlineEnabled));
        }                     
        if (olinkResolver != null) {
            transformer.setParameter("olink.resolver", 
                convertStringToXsltParam(olinkResolver));
        }                     
        if (htmlhelpButtonBack != null) {
            transformer.setParameter("htmlhelp.button.back", 
                convertBooleanToXsltParam(htmlhelpButtonBack));
        }                     
        if (formalTitlePlacement != null) {
            transformer.setParameter("formal.title.placement", 
                convertStringToXsltParam(formalTitlePlacement));
        }                     
        if (chunkerOutputQuiet != null) {
            transformer.setParameter("chunker.output.quiet", 
                convertStringToXsltParam(chunkerOutputQuiet));
        }                     
        if (bibliographyCollection != null) {
            transformer.setParameter("bibliography.collection", 
                convertStringToXsltParam(bibliographyCollection));
        }                     
        if (indexRangeSeparator != null) {
            transformer.setParameter("index.range.separator", 
                convertStringToXsltParam(indexRangeSeparator));
        }                     
        if (htmlhelpButtonLocate != null) {
            transformer.setParameter("htmlhelp.button.locate", 
                convertBooleanToXsltParam(htmlhelpButtonLocate));
        }                     
        if (shadeVerbatim != null) {
            transformer.setParameter("shade.verbatim", 
                convertBooleanToXsltParam(shadeVerbatim));
        }                     
        if (linenumberingWidth != null) {
            transformer.setParameter("linenumbering.width", 
                convertStringToXsltParam(linenumberingWidth));
        }                     
        if (l10nGentextDefaultLanguage != null) {
            transformer.setParameter("l10n.gentext.default.language", 
                convertStringToXsltParam(l10nGentextDefaultLanguage));
        }                     
        if (generateLegalnoticeLink != null) {
            transformer.setParameter("generate.legalnotice.link", 
                convertBooleanToXsltParam(generateLegalnoticeLink));
        }                     
        if (refentryGenerateName != null) {
            transformer.setParameter("refentry.generate.name", 
                convertBooleanToXsltParam(refentryGenerateName));
        }                     
        if (admonStyle != null) {
            transformer.setParameter("admon.style", 
                convertStringToXsltParam(admonStyle));
        }                     
        if (xrefLabelTitleSeparator != null) {
            transformer.setParameter("xref.label-title.separator", 
                convertStringToXsltParam(xrefLabelTitleSeparator));
        }                     
        if (htmlStylesheetType != null) {
            transformer.setParameter("html.stylesheet.type", 
                convertStringToXsltParam(htmlStylesheetType));
        }                     
        if (variablelistTermSeparator != null) {
            transformer.setParameter("variablelist.term.separator", 
                convertStringToXsltParam(variablelistTermSeparator));
        }                     
        if (qandaInheritNumeration != null) {
            transformer.setParameter("qanda.inherit.numeration", 
                convertBooleanToXsltParam(qandaInheritNumeration));
        }                     
        if (calloutDefaultcolumn != null) {
            transformer.setParameter("callout.defaultcolumn", 
                convertStringToXsltParam(calloutDefaultcolumn));
        }                     
        if (profileRevisionflag != null) {
            transformer.setParameter("profile.revisionflag", 
                convertStringToXsltParam(profileRevisionflag));
        }                     
        if (procedureStepNumerationFormats != null) {
            transformer.setParameter("procedure.step.numeration.formats", 
                convertStringToXsltParam(procedureStepNumerationFormats));
        }                     
        if (rootid != null) {
            transformer.setParameter("rootid", 
                convertStringToXsltParam(rootid));
        }                     
        if (chunkSectionDepth != null) {
            transformer.setParameter("chunk.section.depth", 
                convertStringToXsltParam(chunkSectionDepth));
        }                     
        if (refentryXrefManvolnum != null) {
            transformer.setParameter("refentry.xref.manvolnum", 
                convertBooleanToXsltParam(refentryXrefManvolnum));
        }                     
        if (epubHtmlTocId != null) {
            transformer.setParameter("epub.html.toc.id", 
                convertStringToXsltParam(epubHtmlTocId));
        }                     
        if (htmlhelpHhpWindow != null) {
            transformer.setParameter("htmlhelp.hhp.window", 
                convertStringToXsltParam(htmlhelpHhpWindow));
        }                     
        if (collectXrefTargets != null) {
            transformer.setParameter("collect.xref.targets", 
                convertStringToXsltParam(collectXrefTargets));
        }                     
        if (makeSingleYearRanges != null) {
            transformer.setParameter("make.single.year.ranges", 
                convertBooleanToXsltParam(makeSingleYearRanges));
        }                     
        if (htmlhelpEnhancedDecompilation != null) {
            transformer.setParameter("htmlhelp.enhanced.decompilation", 
                convertBooleanToXsltParam(htmlhelpEnhancedDecompilation));
        }                     
        if (htmlhelpButtonJump2Url != null) {
            transformer.setParameter("htmlhelp.button.jump2.url", 
                convertStringToXsltParam(htmlhelpButtonJump2Url));
        }                     
        if (htmlhelpHhcFoldersInsteadBooks != null) {
            transformer.setParameter("htmlhelp.hhc.folders.instead.books", 
                convertBooleanToXsltParam(htmlhelpHhcFoldersInsteadBooks));
        }                     
        if (generateIdAttributes != null) {
            transformer.setParameter("generate.id.attributes", 
                convertBooleanToXsltParam(generateIdAttributes));
        }                     
        if (epubCoverId != null) {
            transformer.setParameter("epub.cover.id", 
                convertStringToXsltParam(epubCoverId));
        }                     
        if (stylesheetResultType != null) {
            transformer.setParameter("stylesheet.result.type", 
                convertStringToXsltParam(stylesheetResultType));
        }                     
        if (indexNumberSeparator != null) {
            transformer.setParameter("index.number.separator", 
                convertStringToXsltParam(indexNumberSeparator));
        }                     
        if (calloutUnicodeStartCharacter != null) {
            transformer.setParameter("callout.unicode.start.character", 
                convertStringToXsltParam(calloutUnicodeStartCharacter));
        }                     
        if (ebnfTableBgcolor != null) {
            transformer.setParameter("ebnf.table.bgcolor", 
                convertStringToXsltParam(ebnfTableBgcolor));
        }                     
        if (epubContainerFilename != null) {
            transformer.setParameter("epub.container.filename", 
                convertStringToXsltParam(epubContainerFilename));
        }                     
        if (l10nLangValueRfcCompliant != null) {
            transformer.setParameter("l10n.lang.value.rfc.compliant", 
                convertBooleanToXsltParam(l10nLangValueRfcCompliant));
        }                     
        if (xrefLabelPageSeparator != null) {
            transformer.setParameter("xref.label-page.separator", 
                convertStringToXsltParam(xrefLabelPageSeparator));
        }                     
        if (processEmptySourceToc != null) {
            transformer.setParameter("process.empty.source.toc", 
                convertBooleanToXsltParam(processEmptySourceToc));
        }                     
        if (htmlhelpRememberWindowPosition != null) {
            transformer.setParameter("htmlhelp.remember.window.position", 
                convertBooleanToXsltParam(htmlhelpRememberWindowPosition));
        }                     
        if (navigShowtitles != null) {
            transformer.setParameter("navig.showtitles", 
                convertBooleanToXsltParam(navigShowtitles));
        }                     
        if (highlightXslthlConfig != null) {
            transformer.setParameter("highlight.xslthl.config", 
                convertStringToXsltParam(highlightXslthlConfig));
        }                     
        if (epubNcxFilename != null) {
            transformer.setParameter("epub.ncx.filename", 
                convertStringToXsltParam(epubNcxFilename));
        }                     
        if (highlightSource != null) {
            transformer.setParameter("highlight.source", 
                convertBooleanToXsltParam(highlightSource));
        }                     
        if (footerRule != null) {
            transformer.setParameter("footer.rule", 
                convertBooleanToXsltParam(footerRule));
        }                     
        if (refentryGenerateTitle != null) {
            transformer.setParameter("refentry.generate.title", 
                convertBooleanToXsltParam(refentryGenerateTitle));
        }                     
        if (navigGraphicsPath != null) {
            transformer.setParameter("navig.graphics.path", 
                convertStringToXsltParam(navigGraphicsPath));
        }                     
        if (calloutGraphicsPath != null) {
            transformer.setParameter("callout.graphics.path", 
                convertStringToXsltParam(calloutGraphicsPath));
        }                     
        if (autotocLabelInHyperlink != null) {
            transformer.setParameter("autotoc.label.in.hyperlink", 
                convertBooleanToXsltParam(autotocLabelInHyperlink));
        }                     
        if (htmlhelpButtonZoom != null) {
            transformer.setParameter("htmlhelp.button.zoom", 
                convertBooleanToXsltParam(htmlhelpButtonZoom));
        }                     
        if (chunkerOutputMethod != null) {
            transformer.setParameter("chunker.output.method", 
                convertStringToXsltParam(chunkerOutputMethod));
        }                     
        if (qandaInToc != null) {
            transformer.setParameter("qanda.in.toc", 
                convertBooleanToXsltParam(qandaInToc));
        }                     
        if (glossarySort != null) {
            transformer.setParameter("glossary.sort", 
                convertBooleanToXsltParam(glossarySort));
        }                     
        if (calloutGraphicsExtension != null) {
            transformer.setParameter("callout.graphics.extension", 
                convertStringToXsltParam(calloutGraphicsExtension));
        }                     
        if (footnoteNumberSymbols != null) {
            transformer.setParameter("footnote.number.symbols", 
                convertStringToXsltParam(footnoteNumberSymbols));
        }                     
        if (htmlhelpButtonHomeUrl != null) {
            transformer.setParameter("htmlhelp.button.home.url", 
                convertStringToXsltParam(htmlhelpButtonHomeUrl));
        }                     
        if (tableBordersWithCss != null) {
            transformer.setParameter("table.borders.with.css", 
                convertBooleanToXsltParam(tableBordersWithCss));
        }                     
        if (htmlExtraHeadLinks != null) {
            transformer.setParameter("html.extra.head.links", 
                convertBooleanToXsltParam(htmlExtraHeadLinks));
        }                     
        if (bridgeheadInToc != null) {
            transformer.setParameter("bridgehead.in.toc", 
                convertBooleanToXsltParam(bridgeheadInToc));
        }                     
        if (othercreditLikeAuthorEnabled != null) {
            transformer.setParameter("othercredit.like.author.enabled", 
                convertBooleanToXsltParam(othercreditLikeAuthorEnabled));
        }                     
        if (linenumberingEveryNth != null) {
            transformer.setParameter("linenumbering.everyNth", 
                convertStringToXsltParam(linenumberingEveryNth));
        }                     
        if (saxonCharacterRepresentation != null) {
            transformer.setParameter("saxon.character.representation", 
                convertStringToXsltParam(saxonCharacterRepresentation));
        }                     
        if (funcsynopsisStyle != null) {
            transformer.setParameter("funcsynopsis.style", 
                convertStringToXsltParam(funcsynopsisStyle));
        }                     
        if (generateIndex != null) {
            transformer.setParameter("generate.index", 
                convertBooleanToXsltParam(generateIndex));
        }                     
        if (emptyLocalL10nXml != null) {
            transformer.setParameter("empty.local.l10n.xml", 
                convertStringToXsltParam(emptyLocalL10nXml));
        }                     
        if (htmlhelpShowToolbarText != null) {
            transformer.setParameter("htmlhelp.show.toolbar.text", 
                convertBooleanToXsltParam(htmlhelpShowToolbarText));
        }                     
        if (epubEmbeddedFonts != null) {
            transformer.setParameter("epub.embedded.fonts", 
                convertStringToXsltParam(epubEmbeddedFonts));
        }                     
        if (l10nGentextUseXrefLanguage != null) {
            transformer.setParameter("l10n.gentext.use.xref.language", 
                convertBooleanToXsltParam(l10nGentextUseXrefLanguage));
        }                     
        if (olinkLangFallbackSequence != null) {
            transformer.setParameter("olink.lang.fallback.sequence", 
                convertStringToXsltParam(olinkLangFallbackSequence));
        }                     
        if (epubNcxTocId != null) {
            transformer.setParameter("epub.ncx.toc.id", 
                convertStringToXsltParam(epubNcxTocId));
        }                     
        if (authorOthernameInMiddle != null) {
            transformer.setParameter("author.othername.in.middle", 
                convertBooleanToXsltParam(authorOthernameInMiddle));
        }                     
        if (refentrySeparator != null) {
            transformer.setParameter("refentry.separator", 
                convertBooleanToXsltParam(refentrySeparator));
        }                     
        if (menuchoiceSeparator != null) {
            transformer.setParameter("menuchoice.separator", 
                convertStringToXsltParam(menuchoiceSeparator));
        }                     
        if (makeYearRanges != null) {
            transformer.setParameter("make.year.ranges", 
                convertBooleanToXsltParam(makeYearRanges));
        }                     
        if (makeGraphicViewport != null) {
            transformer.setParameter("make.graphic.viewport", 
                convertBooleanToXsltParam(makeGraphicViewport));
        }                     
        if (manifest != null) {
            transformer.setParameter("manifest", 
                convertStringToXsltParam(manifest));
        }                     
        if (htmlhelpButtonStop != null) {
            transformer.setParameter("htmlhelp.button.stop", 
                convertBooleanToXsltParam(htmlhelpButtonStop));
        }                     
        if (nominalImageDepth != null) {
            transformer.setParameter("nominal.image.depth", 
                convertStringToXsltParam(nominalImageDepth));
        }                     
        if (l10nGentextLanguage != null) {
            transformer.setParameter("l10n.gentext.language", 
                convertStringToXsltParam(l10nGentextLanguage));
        }                     
        if (htmlhelpChm != null) {
            transformer.setParameter("htmlhelp.chm", 
                convertStringToXsltParam(htmlhelpChm));
        }                     
        if (htmlhelpHhcWidth != null) {
            transformer.setParameter("htmlhelp.hhc.width", 
                convertStringToXsltParam(htmlhelpHhcWidth));
        }                     
        if (epubNcxDepth != null) {
            transformer.setParameter("epub.ncx.depth", 
                convertStringToXsltParam(epubNcxDepth));
        }                     
        if (useExtensions != null) {
            transformer.setParameter("use.extensions", 
                convertBooleanToXsltParam(useExtensions));
        }                     
        if (runinheadTitleEndPunct != null) {
            transformer.setParameter("runinhead.title.end.punct", 
                convertStringToXsltParam(runinheadTitleEndPunct));
        }                     
        if (olinkDebug != null) {
            transformer.setParameter("olink.debug", 
                convertBooleanToXsltParam(olinkDebug));
        }                     
        if (htmlhelpButtonJump1Title != null) {
            transformer.setParameter("htmlhelp.button.jump1.title", 
                convertStringToXsltParam(htmlhelpButtonJump1Title));
        }                     
        if (localL10nXml != null) {
            transformer.setParameter("local.l10n.xml", 
                convertStringToXsltParam(localL10nXml));
        }                     
        if (indexLinksToSection != null) {
            transformer.setParameter("index.links.to.section", 
                convertBooleanToXsltParam(indexLinksToSection));
        }                     
        if (xrefWithNumberAndTitle != null) {
            transformer.setParameter("xref.with.number.and.title", 
                convertBooleanToXsltParam(xrefWithNumberAndTitle));
        }                     
        if (admonGraphicsPath != null) {
            transformer.setParameter("admon.graphics.path", 
                convertStringToXsltParam(admonGraphicsPath));
        }                     
        if (eclipseAutolabel != null) {
            transformer.setParameter("eclipse.autolabel", 
                convertBooleanToXsltParam(eclipseAutolabel));
        }                     
        if (annotationJs != null) {
            transformer.setParameter("annotation.js", 
                convertStringToXsltParam(annotationJs));
        }                     
        if (htmlhelpAutolabel != null) {
            transformer.setParameter("htmlhelp.autolabel", 
                convertBooleanToXsltParam(htmlhelpAutolabel));
        }                     
        if (tableFootnoteNumberFormat != null) {
            transformer.setParameter("table.footnote.number.format", 
                convertStringToXsltParam(tableFootnoteNumberFormat));
        }                     
        if (htmlHeadLegalnoticeLinkTypes != null) {
            transformer.setParameter("html.head.legalnotice.link.types", 
                convertStringToXsltParam(htmlHeadLegalnoticeLinkTypes));
        }                     
        if (defaultImageWidth != null) {
            transformer.setParameter("default.image.width", 
                convertStringToXsltParam(defaultImageWidth));
        }                     
        if (htmlhelpButtonHome != null) {
            transformer.setParameter("htmlhelp.button.home", 
                convertBooleanToXsltParam(htmlhelpButtonHome));
        }                     
        if (headerRule != null) {
            transformer.setParameter("header.rule", 
                convertBooleanToXsltParam(headerRule));
        }                     
        if (prefaceAutolabel != null) {
            transformer.setParameter("preface.autolabel", 
                convertStringToXsltParam(prefaceAutolabel));
        }                     
        if (htmlhelpEnumerateImages != null) {
            transformer.setParameter("htmlhelp.enumerate.images", 
                convertBooleanToXsltParam(htmlhelpEnumerateImages));
        }                     
        if (currentDocid != null) {
            transformer.setParameter("current.docid", 
                convertStringToXsltParam(currentDocid));
        }                     
        if (citerefentryLink != null) {
            transformer.setParameter("citerefentry.link", 
                convertBooleanToXsltParam(citerefentryLink));
        }                     
        if (preferInternalOlink != null) {
            transformer.setParameter("prefer.internal.olink", 
                convertBooleanToXsltParam(preferInternalOlink));
        }                     
        if (useSvg != null) {
            transformer.setParameter("use.svg", 
                convertBooleanToXsltParam(useSvg));
        }                     
        if (profileAttribute != null) {
            transformer.setParameter("profile.attribute", 
                convertStringToXsltParam(profileAttribute));
        }                     
        if (linkMailtoUrl != null) {
            transformer.setParameter("link.mailto.url", 
                convertStringToXsltParam(linkMailtoUrl));
        }                     
        if (htmlhelpHhpWindows != null) {
            transformer.setParameter("htmlhelp.hhp.windows", 
                convertStringToXsltParam(htmlhelpHhpWindows));
        }                     
        if (tocMaxDepth != null) {
            transformer.setParameter("toc.max.depth", 
                convertStringToXsltParam(tocMaxDepth));
        }                     
        if (targetDatabaseDocument != null) {
            transformer.setParameter("target.database.document", 
                convertStringToXsltParam(targetDatabaseDocument));
        }                     
        if (admonGraphicsExtension != null) {
            transformer.setParameter("admon.graphics.extension", 
                convertStringToXsltParam(admonGraphicsExtension));
        }                     
        if (htmlExt != null) {
            transformer.setParameter("html.ext", 
                convertStringToXsltParam(htmlExt));
        }                     
        if (bibliographyNumbered != null) {
            transformer.setParameter("bibliography.numbered", 
                convertBooleanToXsltParam(bibliographyNumbered));
        }                     
        if (epubCoverImageId != null) {
            transformer.setParameter("epub.cover.image.id", 
                convertStringToXsltParam(epubCoverImageId));
        }                     
        if (textinsertExtension != null) {
            transformer.setParameter("textinsert.extension", 
                convertBooleanToXsltParam(textinsertExtension));
        }                     
        if (epubCoverHtml != null) {
            transformer.setParameter("epub.cover.html", 
                convertStringToXsltParam(epubCoverHtml));
        }                     
        if (generateManifest != null) {
            transformer.setParameter("generate.manifest", 
                convertBooleanToXsltParam(generateManifest));
        }                     
        if (indexPreferTitleabbrev != null) {
            transformer.setParameter("index.prefer.titleabbrev", 
                convertBooleanToXsltParam(indexPreferTitleabbrev));
        }                     
        if (htmlBase != null) {
            transformer.setParameter("html.base", 
                convertStringToXsltParam(htmlBase));
        }                     
        if (htmlCleanup != null) {
            transformer.setParameter("html.cleanup", 
                convertBooleanToXsltParam(htmlCleanup));
        }                     
        if (defaultTableWidth != null) {
            transformer.setParameter("default.table.width", 
                convertStringToXsltParam(defaultTableWidth));
        }                     
        if (chunkerOutputDoctypeSystem != null) {
            transformer.setParameter("chunker.output.doctype-system", 
                convertStringToXsltParam(chunkerOutputDoctypeSystem));
        }                     
        if (tocSectionDepth != null) {
            transformer.setParameter("toc.section.depth", 
                convertStringToXsltParam(tocSectionDepth));
        }                     
        if (writingMode != null) {
            transformer.setParameter("writing.mode", 
                convertStringToXsltParam(writingMode));
        }                     
        if (javahelpEncoding != null) {
            transformer.setParameter("javahelp.encoding", 
                convertStringToXsltParam(javahelpEncoding));
        }                     
        if (htmlhelpDisplayProgress != null) {
            transformer.setParameter("htmlhelp.display.progress", 
                convertBooleanToXsltParam(htmlhelpDisplayProgress));
        }                     
        if (calloutUnicode != null) {
            transformer.setParameter("callout.unicode", 
                convertBooleanToXsltParam(calloutUnicode));
        }                     
        if (textdataDefaultEncoding != null) {
            transformer.setParameter("textdata.default.encoding", 
                convertStringToXsltParam(textdataDefaultEncoding));
        }                     
        if (annotateToc != null) {
            transformer.setParameter("annotate.toc", 
                convertBooleanToXsltParam(annotateToc));
        }                     
        if (admonGraphics != null) {
            transformer.setParameter("admon.graphics", 
                convertBooleanToXsltParam(admonGraphics));
        }                     
        if (htmlhelpButtonHideshow != null) {
            transformer.setParameter("htmlhelp.button.hideshow", 
                convertBooleanToXsltParam(htmlhelpButtonHideshow));
        }                     
        if (htmlhelpButtonRefresh != null) {
            transformer.setParameter("htmlhelp.button.refresh", 
                convertBooleanToXsltParam(htmlhelpButtonRefresh));
        }                     
        if (runinheadDefaultTitleEndPunct != null) {
            transformer.setParameter("runinhead.default.title.end.punct", 
                convertStringToXsltParam(runinheadDefaultTitleEndPunct));
        }                     
        if (glossentryShowAcronym != null) {
            transformer.setParameter("glossentry.show.acronym", 
                convertStringToXsltParam(glossentryShowAcronym));
        }                     
        if (cssDecoration != null) {
            transformer.setParameter("css.decoration", 
                convertBooleanToXsltParam(cssDecoration));
        }                     
        if (useRoleForMediaobject != null) {
            transformer.setParameter("use.role.for.mediaobject", 
                convertBooleanToXsltParam(useRoleForMediaobject));
        }                     
        if (sectionLabelIncludesComponentLabel != null) {
            transformer.setParameter("section.label.includes.component.label", 
                convertBooleanToXsltParam(sectionLabelIncludesComponentLabel));
        }                     
        if (admonTextlabel != null) {
            transformer.setParameter("admon.textlabel", 
                convertBooleanToXsltParam(admonTextlabel));
        }                     
        if (profileVendor != null) {
            transformer.setParameter("profile.vendor", 
                convertStringToXsltParam(profileVendor));
        }                     
        if (profileStatus != null) {
            transformer.setParameter("profile.status", 
                convertStringToXsltParam(profileStatus));
        }                     
        if (indexOnRole != null) {
            transformer.setParameter("index.on.role", 
                convertBooleanToXsltParam(indexOnRole));
        }                     
        if (draftWatermarkImage != null) {
            transformer.setParameter("draft.watermark.image", 
                convertStringToXsltParam(draftWatermarkImage));
        }                     
        if (profileWordsize != null) {
            transformer.setParameter("profile.wordsize", 
                convertStringToXsltParam(profileWordsize));
        }                     
        if (texMathFile != null) {
            transformer.setParameter("tex.math.file", 
                convertStringToXsltParam(texMathFile));
        }                     
        if (htmlhelpOutput != null) {
            transformer.setParameter("htmlhelp.output", 
                convertStringToXsltParam(htmlhelpOutput));
        }                     
        if (qandaNestedInToc != null) {
            transformer.setParameter("qanda.nested.in.toc", 
                convertBooleanToXsltParam(qandaNestedInToc));
        }                     
        if (htmlhelpButtonOptions != null) {
            transformer.setParameter("htmlhelp.button.options", 
                convertBooleanToXsltParam(htmlhelpButtonOptions));
        }                     
        if (tableCellBorderColor != null) {
            transformer.setParameter("table.cell.border.color", 
                convertStringToXsltParam(tableCellBorderColor));
        }                     
        if (olinkFragid != null) {
            transformer.setParameter("olink.fragid", 
                convertStringToXsltParam(olinkFragid));
        }                     
        if (linenumberingSeparator != null) {
            transformer.setParameter("linenumbering.separator", 
                convertStringToXsltParam(linenumberingSeparator));
        }                     
        if (docbookCssSource != null) {
            transformer.setParameter("docbook.css.source", 
                convertStringToXsltParam(docbookCssSource));
        }                     
        if (htmlhelpHhcShowRoot != null) {
            transformer.setParameter("htmlhelp.hhc.show.root", 
                convertBooleanToXsltParam(htmlhelpHhcShowRoot));
        }                     
        if (epubAutolabel != null) {
            transformer.setParameter("epub.autolabel", 
                convertBooleanToXsltParam(epubAutolabel));
        }                     
        if (htmlhelpButtonNext != null) {
            transformer.setParameter("htmlhelp.button.next", 
                convertBooleanToXsltParam(htmlhelpButtonNext));
        }                     
        if (defaultFloatClass != null) {
            transformer.setParameter("default.float.class", 
                convertStringToXsltParam(defaultFloatClass));
        }                     
        if (labelFromPart != null) {
            transformer.setParameter("label.from.part", 
                convertBooleanToXsltParam(labelFromPart));
        }                     
        if (abstractNotitleEnabled != null) {
            transformer.setParameter("abstract.notitle.enabled", 
                convertBooleanToXsltParam(abstractNotitleEnabled));
        }                     
        if (bibliographyStyle != null) {
            transformer.setParameter("bibliography.style", 
                convertStringToXsltParam(bibliographyStyle));
        }                     
        if (tableFrameBorderThickness != null) {
            transformer.setParameter("table.frame.border.thickness", 
                convertStringToXsltParam(tableFrameBorderThickness));
        }                     
        if (exslNodeSetAvailable != null) {
            transformer.setParameter("exsl.node.set.available", 
                convertBooleanToXsltParam(exslNodeSetAvailable));
        }                     
        if (calloutsExtension != null) {
            transformer.setParameter("callouts.extension", 
                convertBooleanToXsltParam(calloutsExtension));
        }                     
        if (annotationSupport != null) {
            transformer.setParameter("annotation.support", 
                convertBooleanToXsltParam(annotationSupport));
        }                     
        if (chunkerOutputStandalone != null) {
            transformer.setParameter("chunker.output.standalone", 
                convertStringToXsltParam(chunkerOutputStandalone));
        }                     
        if (profileSeparator != null) {
            transformer.setParameter("profile.separator", 
                convertStringToXsltParam(profileSeparator));
        }                     
        if (linenumberingExtension != null) {
            transformer.setParameter("linenumbering.extension", 
                convertBooleanToXsltParam(linenumberingExtension));
        }                     
        if (htmlhelpAliasFile != null) {
            transformer.setParameter("htmlhelp.alias.file", 
                convertStringToXsltParam(htmlhelpAliasFile));
        }                     
        if (keepRelativeImageUris != null) {
            transformer.setParameter("keep.relative.image.uris", 
                convertBooleanToXsltParam(keepRelativeImageUris));
        }                     
        if (useIdAsFilename != null) {
            transformer.setParameter("use.id.as.filename", 
                convertBooleanToXsltParam(useIdAsFilename));
        }                     
        if (profileUserlevel != null) {
            transformer.setParameter("profile.userlevel", 
                convertStringToXsltParam(profileUserlevel));
        }                     
        if (eclipsePluginName != null) {
            transformer.setParameter("eclipse.plugin.name", 
                convertStringToXsltParam(eclipsePluginName));
        }                     
        if (tableCellBorderThickness != null) {
            transformer.setParameter("table.cell.border.thickness", 
                convertStringToXsltParam(tableCellBorderThickness));
        }                     
        if (tableCellBorderStyle != null) {
            transformer.setParameter("table.cell.border.style", 
                convertStringToXsltParam(tableCellBorderStyle));
        }                     
        if (htmlhelpButtonJump1Url != null) {
            transformer.setParameter("htmlhelp.button.jump1.url", 
                convertStringToXsltParam(htmlhelpButtonJump1Url));
        }                     
        if (graphicsizeUseImgSrcPath != null) {
            transformer.setParameter("graphicsize.use.img.src.path", 
                convertBooleanToXsltParam(graphicsizeUseImgSrcPath));
        }                     
        if (chunkSeparateLots != null) {
            transformer.setParameter("chunk.separate.lots", 
                convertBooleanToXsltParam(chunkSeparateLots));
        }                     
        if (useEmbedForSvg != null) {
            transformer.setParameter("use.embed.for.svg", 
                convertBooleanToXsltParam(useEmbedForSvg));
        }                     
        if (qandadivAutolabel != null) {
            transformer.setParameter("qandadiv.autolabel", 
                convertBooleanToXsltParam(qandadivAutolabel));
        }                     
        if (ebnfStatementTerminator != null) {
            transformer.setParameter("ebnf.statement.terminator", 
                convertStringToXsltParam(ebnfStatementTerminator));
        }                     
        if (targetsFilename != null) {
            transformer.setParameter("targets.filename", 
                convertStringToXsltParam(targetsFilename));
        }                     
        if (generateSectionTocLevel != null) {
            transformer.setParameter("generate.section.toc.level", 
                convertStringToXsltParam(generateSectionTocLevel));
        }                     
        if (spacingParas != null) {
            transformer.setParameter("spacing.paras", 
                convertBooleanToXsltParam(spacingParas));
        }                     
        if (functionParens != null) {
            transformer.setParameter("function.parens", 
                convertBooleanToXsltParam(functionParens));
        }                     
        if (formalProcedures != null) {
            transformer.setParameter("formal.procedures", 
                convertBooleanToXsltParam(formalProcedures));
        }                     
        if (epubCoverFilename != null) {
            transformer.setParameter("epub.cover.filename", 
                convertStringToXsltParam(epubCoverFilename));
        }                     
        if (processSourceToc != null) {
            transformer.setParameter("process.source.toc", 
                convertBooleanToXsltParam(processSourceToc));
        }                     
        if (annotationCss != null) {
            transformer.setParameter("annotation.css", 
                convertStringToXsltParam(annotationCss));
        }                     
        if (htmlhelpHhcSectionDepth != null) {
            transformer.setParameter("htmlhelp.hhc.section.depth", 
                convertStringToXsltParam(htmlhelpHhcSectionDepth));
        }                     
        if (useLocalOlinkStyle != null) {
            transformer.setParameter("use.local.olink.style", 
                convertBooleanToXsltParam(useLocalOlinkStyle));
        }                     
        if (phrasePropagatesStyle != null) {
            transformer.setParameter("phrase.propagates.style", 
                convertBooleanToXsltParam(phrasePropagatesStyle));
        }                     
        if (calloutGraphics != null) {
            transformer.setParameter("callout.graphics", 
                convertBooleanToXsltParam(calloutGraphics));
        }                     
        if (insertOlinkPageNumber != null) {
            transformer.setParameter("insert.olink.page.number", 
                convertStringToXsltParam(insertOlinkPageNumber));
        }                     
        if (chunkTocsAndLotsHasTitle != null) {
            transformer.setParameter("chunk.tocs.and.lots.has.title", 
                convertBooleanToXsltParam(chunkTocsAndLotsHasTitle));
        }                     
        if (componentLabelIncludesPartLabel != null) {
            transformer.setParameter("component.label.includes.part.label", 
                convertBooleanToXsltParam(componentLabelIncludesPartLabel));
        }                     
        if (profileValue != null) {
            transformer.setParameter("profile.value", 
                convertStringToXsltParam(profileValue));
        }                     
        if (imgSrcPath != null) {
            transformer.setParameter("img.src.path", 
                convertStringToXsltParam(imgSrcPath));
        }                     
        if (firsttermOnlyLink != null) {
            transformer.setParameter("firstterm.only.link", 
                convertBooleanToXsltParam(firsttermOnlyLink));
        }                     
        if (draftMode != null) {
            transformer.setParameter("draft.mode", 
                convertStringToXsltParam(draftMode));
        }                     
        if (funcsynopsisDecoration != null) {
            transformer.setParameter("funcsynopsis.decoration", 
                convertBooleanToXsltParam(funcsynopsisDecoration));
        }                     
        if (calloutUnicodeNumberLimit != null) {
            transformer.setParameter("callout.unicode.number.limit", 
                convertStringToXsltParam(calloutUnicodeNumberLimit));
        }                     
        if (htmlhelpButtonPrint != null) {
            transformer.setParameter("htmlhelp.button.print", 
                convertBooleanToXsltParam(htmlhelpButtonPrint));
        }                     
        if (eclipsePluginProvider != null) {
            transformer.setParameter("eclipse.plugin.provider", 
                convertStringToXsltParam(eclipsePluginProvider));
        }                     
        if (profileLang != null) {
            transformer.setParameter("profile.lang", 
                convertStringToXsltParam(profileLang));
        }                     
        if (olinkPubid != null) {
            transformer.setParameter("olink.pubid", 
                convertStringToXsltParam(olinkPubid));
        }                     
        if (blurbOnTitlepageEnabled != null) {
            transformer.setParameter("blurb.on.titlepage.enabled", 
                convertBooleanToXsltParam(blurbOnTitlepageEnabled));
        }                     
    }

    public File getSourceDirectory() {
        return sourceDirectory;
    }

    public File getTargetDirectory() {
        return targetDirectory;
    }

    public File getGeneratedSourceDirectory() {
        return generatedSourceDirectory;
    }

	public String getDefaultStylesheetLocation() {
        return "docbook/epub/docbook.xsl";
	}

	public String getType() {
	    return "epub";
	}

    public String getStylesheetLocation() {
    	getLog().debug("Customization: " + epubCustomization);
        if (epubCustomization != null) {
            return epubCustomization;
        } else if (getNonDefaultStylesheetLocation() == null) {
            return getDefaultStylesheetLocation();
        } else {
            return getNonDefaultStylesheetLocation();
        }
    }

    public String getTargetFileExtension() {
        return targetFileExtension;
    }

    public void setTargetFileExtension(String extension) {
        targetFileExtension = extension;
    }

    public String[] getIncludes() {
        String[] results = includes.split(",");
        for (int i = 0; i < results.length; i++) {
            results[i] = results[i].trim();
        }
        return results;
    }

    public List<Entity> getEntities() {
        return entities;
    }

    public List<Parameter> getCustomizationParameters()
    {
    	return customizationParameters;
    }

    public Properties getSystemProperties()
    {
        return systemProperties;
    }

    public Target getPreProcess() {
        return preProcess;
    }

    public Target getPostProcess() {
        return postProcess;
    }

    public MavenProject getMavenProject() {
        return project;
    }

    public List<Artifact> getArtifacts() {
        return artifacts;
    }

    protected boolean getXIncludeSupported() {
        return xincludeSupported;
    }

    /**
     * Returns false if the stylesheet is responsible to create the output file(s) using its own naming scheme.
     *
     * @return If using the standard output.
     */
    protected boolean isUseStandardOutput() {
        return useStandardOutput;
    }

    protected void setUseStandardOutput(boolean useStandardOutput) {
        this.useStandardOutput = useStandardOutput;
    }


  public void postProcessResult(File result) throws MojoExecutionException {
 
    // First transform the cover page
        transformCover();
        //rasterize();

    final File targetDirectory = result.getParentFile();
    try {
      final URL containerURL = getClass().getResource("/epub/container.xml");
      FileUtils.copyURLToFile(containerURL, new File(targetDirectory, "META-INF" + File.separator + "container.xml"));
    } catch (IOException e) {
      throw new MojoExecutionException("Unable to copy hardcoded container.xml file", e);
    }

    // copy mimetype file
    try {
      final URL mimetypeURL = getClass().getResource("/epub/mimetype");
      FileUtils.copyURLToFile(mimetypeURL, new File(targetDirectory, "mimetype"));
    } catch (IOException e) {
      throw new MojoExecutionException("Unable to copy hardcoded mimetype file", e);
    }

    try {
      ZipArchiver zipArchiver = new ZipArchiver();
      zipArchiver.addDirectory(targetDirectory);
      zipArchiver.setCompress(true); // seems to not be a problem to have mimetype compressed
      zipArchiver.setDestFile(new File(targetDirectory.getParentFile(), result.getName())); // copy it to parent dir
      zipArchiver.createArchive();

      getLog().debug("epub file created at: " + zipArchiver.getDestFile().getAbsolutePath());
    } catch (Exception e) {
      throw new MojoExecutionException("Unable to zip epub file", e);
    }
  }


      /**
     * The greeting to display.
     *
     * @parameter expression="${generate-pdf.branding}" default-value="rackspace"
     */
    private String branding;

    /**
     * A parameter used to specify the security level (external, internal, reviewer, writeronly) of the document.
     *
     * @parameter expression="${generate-pdf.security}" default-value=""
     */
    private String security;


     /**
     * A parameter used to configure how many elements to trim from the URI in the documentation for a wadl method.
     *
     * @parameter expression="${generate-pdf.trim.wadl.uri.count}" default-value=""
     */
    private String trimWadlUriCount;

    /**
     * @parameter expression="${project.build.directory}"
     */
    private File projectBuildDirectory;

    /**
     * Controls how the path to the wadl is calculated. If 0 or not set, then
     * The xslts look for the normalized wadl in /generated-resources/xml/xslt/.
     * Otherwise, in /generated-resources/xml/xslt/path/to/docbook-src, e.g.
     * /generated-resources/xml/xslt/src/docbkx/foo.wadl
     *
     * @parameter expression="${generate-pdf.compute.wadl.path.from.docbook.path}" default-value="0"
     */
    private String computeWadlPathFromDocbookPath;

  public void adjustTransformer(Transformer transformer, String sourceFilename, File targetFile) {
        GitHelper.addCommitProperties(transformer, projectBuildDirectory, 7, getLog());

        super.adjustTransformer(transformer, sourceFilename, targetFile);

	transformer.setParameter("branding", branding);
	transformer.setParameter("project.build.directory", projectBuildDirectory.toURI().toString());

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

	transformer.setParameter("docbook.infile",sourceDocBook.toURI().toString());
	transformer.setParameter("source.directory",sourceDirectory.toURI().toString());
	transformer.setParameter("compute.wadl.path.from.docbook.path",computeWadlPathFromDocbookPath);

        transformer.setParameter ("admon.graphics.path", imageDirectory.toURI().toString());
        transformer.setParameter ("callout.graphics.path", calloutDirectory.toURI().toString());

        //
        //  Setup the background image file
        //
        File cloudSub = new File (imageDirectory, "cloud");
        File ccSub    = new File (imageDirectory, "cc");
        coverImage = new File (cloudSub, COVER_IMAGE_NAME);
        coverImageTemplate = new File (cloudSub, COVER_IMAGE_TEMPLATE_NAME);

	coverImageTemplate = new File (cloudSub, branding + "-cover.st");

        transformer.setParameter ("cloud.api.background.image", coverImage.toURI().toString());
        transformer.setParameter ("cloud.api.cc.image.dir", ccSub.toURI().toString());
    }
  protected void transformCover() throws MojoExecutionException {
        try {
            ClassLoader classLoader = Thread.currentThread()
                .getContextClassLoader();

            TransformerFactory factory = TransformerFactory.newInstance();
            Transformer transformer = factory.newTransformer(new StreamSource(classLoader.getResourceAsStream(COVER_XSL)));

            transformer.setParameter("docbook.infile",sourceDocBook.getAbsolutePath());
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

  public void preProcess() throws MojoExecutionException {
        super.preProcess();

        final File targetDirectory = getTargetDirectory();
        File imageParentDirectory  = targetDirectory.getParentFile();

        if (!targetDirectory.exists()) {
            com.rackspace.cloud.api.docs.FileUtils.mkdir(targetDirectory);
        }

        //
        // Extract all images into the image directory.
        //
        com.rackspace.cloud.api.docs.FileUtils.extractJaredDirectory("images", PDFMojo.class, imageParentDirectory);
        setImageDirectory (new File (imageParentDirectory, "images"));

        //
        // Extract all fonts into fonts directory
        //
        com.rackspace.cloud.api.docs.FileUtils.extractJaredDirectory("fonts", PDFMojo.class, imageParentDirectory);
    }


    public void rasterize() throws RuntimeException{
        try{
        // Create a JPEG transcoder
        PNGTranscoder t = new PNGTranscoder();

        // Set the transcoding hints.
       // t.addTranscodingHint(PNGTranscoder.KEY_QUALITY,
         //                    new Float(.8));

        // Create the transcoder input.
        String svgURI = new File("/Users/nare4013/epub/rackspace-template/rackspace-template/target/docbkx/images/cloud/cover.svg").toURI().toURL().toString();
        TranscoderInput input = new TranscoderInput(svgURI);

        // Create the transcoder output.
        OutputStream ostream = new FileOutputStream("/Users/nare4013/epub/rackspace-template/rackspace-template/target/docbkx/images/cloud/cover.png");
        TranscoderOutput output = new TranscoderOutput(ostream);

        // Save the image.
        t.transcode(input, output);

        // Flush and close the stream.
        ostream.flush();
        ostream.close();
        }
        catch(Exception e){
            throw new RuntimeException("Could not able to rasterize the svg", e);
        }
   
}

}