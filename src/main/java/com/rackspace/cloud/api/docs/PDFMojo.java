package com.rackspace.cloud.api.docs;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.BufferedOutputStream;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;

import java.net.MalformedURLException;

import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.URIResolver;
import javax.xml.transform.sax.SAXResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.transform.stream.StreamResult;

import org.apache.maven.plugin.MojoExecutionException;
import org.apache.avalon.framework.configuration.Configuration;
import org.apache.avalon.framework.configuration.ConfigurationException;
import org.apache.avalon.framework.configuration.DefaultConfigurationBuilder;
import org.apache.commons.io.IOUtils;
import org.apache.fop.apps.FOPException;
import org.apache.fop.apps.FOUserAgent;
import org.apache.fop.apps.Fop;
import org.apache.fop.apps.FopFactory;
import org.apache.fop.apps.MimeConstants;

import com.agilejava.docbkx.maven.TransformerBuilder;
import com.agilejava.docbkx.maven.AbstractPdfMojo;

import org.antlr.stringtemplate.StringTemplate;
import org.antlr.stringtemplate.StringTemplateGroup;

import org.xml.sax.SAXException;

import com.rackspace.cloud.api.docs.FileUtils;
import com.rackspace.cloud.api.docs.DocBookResolver;

public abstract class PDFMojo extends AbstractPdfMojo {
    private File imageDirectory;
    private File sourceDirectory;
    private File sourceDocBook;

    private File coverImageTemplate;
    private File coverImage;

    private static final String COVER_IMAGE_TEMPLATE_NAME = "cover.st";
    private static final String COVER_IMAGE_NAME = "cover.svg";

    private static final String COVER_XSL = "cloud/cover.xsl";

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
        return super.createTransformerBuilder (new DocBookResolver (resolver, getType()));
    }

    public void adjustTransformer(Transformer transformer, String sourceFilename, File targetFile) {
        super.adjustTransformer(transformer, sourceFilename, targetFile);

        //
        //  Setup graphics paths
        //
        sourceDocBook = new File(sourceFilename);
        sourceDirectory = sourceDocBook.getParentFile();
        File imageDirectory = getImageDirectory();
        File calloutDirectory = new File (imageDirectory, "callouts");

        transformer.setParameter ("admon.graphics.path", imageDirectory.getAbsolutePath()+File.separator);
        transformer.setParameter ("callout.graphics.path", calloutDirectory.getAbsolutePath()+File.separator);

        //
        //  Setup the background image file
        //
        File cloudSub = new File (imageDirectory, "cloud");
        File ccSub    = new File (imageDirectory, "cc");
        coverImage = new File (cloudSub, COVER_IMAGE_NAME);
        coverImageTemplate = new File (cloudSub, COVER_IMAGE_TEMPLATE_NAME);

        transformer.setParameter ("cloud.api.background.image", coverImage.getAbsolutePath());
        transformer.setParameter ("cloud.api.cc.image.dir", ccSub.getAbsolutePath());
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
}
