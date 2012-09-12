package com.rackspace.cloud.api.docs.calabash.extensions;

import com.xmlcalabash.core.XProcException;
import com.xmlcalabash.model.RuntimeValue;
import com.xmlcalabash.util.ProcessMatch;
import com.xmlcalabash.util.ProcessMatchingNodes;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;
import org.apache.batik.transcoder.TranscoderInput;
import org.apache.batik.transcoder.TranscoderOutput;
import org.apache.batik.transcoder.image.PNGTranscoder;
import org.apache.maven.plugin.logging.Log;
import org.apache.maven.plugin.logging.SystemStreamLog;

import java.io.*;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.HashSet;
import java.util.Set;

/**
 * Created with IntelliJ IDEA.
 * User: ykamran
 * Date: 9/12/12
 * Time: 6:29 PM
 * To change this template use File | Settings | File Templates.
 */

public class CopyTransformImage implements ProcessMatchingNodes {
    private String xpath;
    private Set<Replacement> imageSet = new HashSet<Replacement>();
    private ProcessMatch matcher;

    private URI targetDirectoryUri;
    private String inputDocbookName;
    private String outputType;
    private XdmNode stepNode;
    private static final int bufferSize = 8192;


    private Log log = null;

    public Log getLog() {
        if (log == null) {
            log = new SystemStreamLog();
        }
        return log;
    }

    public CopyTransformImage(String _xpath, URI _targetDirectory, String _inputDocbookName, String _outputType, XdmNode _step) {
        this.xpath = _xpath;
        this.targetDirectoryUri = _targetDirectory;
        this.inputDocbookName = _inputDocbookName;
        this.outputType = _outputType;
        this.stepNode = _step;
    }

    public String getXPath() {
        return xpath;
    }

    public Set<Replacement> getImageSet(){
        return imageSet;
    }

    public void setMatcher (ProcessMatch matcher) {
        this.matcher = matcher;
    }

    private File getSourceImageFile(URI sourceImageUri) {
        File file = null;

        if (!"file".equals(sourceImageUri.getScheme())) {
            getLog().error("DocBook File: '" + inputDocbookName + "' - File: '" + sourceImageUri.getPath() + "' - Problem: Only 'file' scheme URIs are supported by this step!");
            throw new XProcException(stepNode, "Only file: scheme URIs are supported by the copy step.");
        } else {
            String executionPath = System.getProperty("user.dir") + File.separator;
            file = new File(executionPath + sourceImageUri.getPath());
        }

        return file;
    }

    private void checkIfFileExists(URI uri, String inputFileName, File file) {
        if (!file.exists()) {
            getLog().error("DocBook File: '" + inputFileName + "' - File: '" + uri.getPath() + "' - Problem: File does not exist!");
            throw new XProcException(stepNode, "Cannot copy: file does not exist: " + file.getAbsolutePath());
        }

        if (file.isDirectory()) {
            getLog().error("DocBook File: '" + inputFileName + "' - File: '" + uri.getPath() + "' - Problem: File is a directory!");
            throw new XProcException(stepNode, "Cannot copy: file is a directory: " + file.getAbsolutePath());
        }
    }

    private void performFileCopy(URI uri, String inputFileName, File file) {

        getLog().info("#################################### Enter performFileCopy: " + inputFileName);

        File target;

        if (!"file".equals(uri.getScheme())) {
            getLog().error("DocBook File: '" + inputFileName + "' - File: '" + uri.getPath() + "' - Problem: Only 'file' scheme URIs are supported by this step!");
            throw new XProcException("Only file: scheme URIs are supported by the copy step.");
        } else {
            target = new File(uri.getPath());
            if (target.mkdir()) {
            }
            if (target.mkdirs()) {
            }
        }

        if (target.isDirectory()) {
            target = new File(target, file.getName());
            if (target.isDirectory()) {
                getLog().error("DocBook File: '" + inputFileName + "' - File: '" + uri.getPath() + "' - Problem: File is a directory!");
                throw new XProcException("Cannot copy: target is a directory: " + target.getAbsolutePath());
            }
        }

        try {
            FileInputStream src = new FileInputStream(file);
            FileOutputStream dst = new FileOutputStream(target);
            byte[] buffer = new byte[bufferSize];
            int read = src.read(buffer, 0, bufferSize);
            while (read >= 0) {
                dst.write(buffer, 0, read);
                read = src.read(buffer, 0, bufferSize);
            }
            src.close();
            dst.close();
            //transform SVG file
            String name = file.getName();
            int pos = name.lastIndexOf('.');
            String ext = name.substring(pos + 1);

            getLog().info("#################################### Enter svg transformation for image: " + inputFileName);

            if (ext.equalsIgnoreCase("svg")) {
                getLog().info("#################################### Start Enter svg transformation for image: " + inputFileName);

                TransformSVGToPNG t = new TransformSVGToPNG();
                boolean check = t.transform(target.getParent() + File.separator, name);
                if (!check) {
                    getLog().error("DocBook File: '" + inputFileName + "' - File: '" + uri.getPath() + "' - Problem: Could not transform SVG to PNG!");
                    //getLog().error("Could not transform SVG file to PNG:" + name);
                }
                getLog().info("#################################### End Enter svg transformation for image: " + inputFileName);
            }

        } catch (FileNotFoundException fnfe) {
            throw new XProcException(fnfe);
        } catch (IOException ioe) {
            throw new XProcException(ioe);
        }

    }

    private String computeReplacement(XdmNode node) {
        String value = node.getStringValue();
        Replacement repl = new Replacement(value, "");
        if(imageSet.add(repl)) {
            URI sourceImageUri = null;
            try {
                sourceImageUri = new URI("file://./src/"+value);
            } catch (URISyntaxException e) {
                throw new XProcException(stepNode, "Unable to get handle to image file",e);
            }
            if(sourceImageUri != null) {
                File sourceImageFile = getSourceImageFile(sourceImageUri);
                if(outputType.equals("pdf")) {
                    //check if image exists.
                    try {
                        checkIfFileExists(sourceImageUri, inputDocbookName, sourceImageFile);
                    } catch (XProcException x) {
                        //getLog().error(x.getMessage());
                        //do nothing
                    }
                } else if(outputType.equals("html")) {
                    //check if image exists.
                    //transform image if it is an SVG
                    //update image path for PNG images only

                    try {
                        checkIfFileExists(sourceImageUri, inputDocbookName, sourceImageFile);
                        performFileCopy(targetDirectoryUri, inputDocbookName, sourceImageFile);
                    } catch (XProcException x) {
                        //getLog().error(x.getMessage());
                        //do nothing
                    }
                }
            }
            //value = "file:///Users/salmanqureshi/Projects/Rackspace/Dev/compute-api-final/openstack-compute-api-2/target/docbkx/webhelp/api/openstack/2/figures/Arrow_east.svg";
            value = "file:///Users/somethingthatistotallywrong.svg";
        }

        return value;
    }

    @Override
    public boolean processStartDocument(XdmNode node) throws SaxonApiException {
        return true;//process children
    }

    @Override
    public void processEndDocument(XdmNode node) throws SaxonApiException {
        //do nothing
    }

    @Override
    public boolean processStartElement(XdmNode node) throws SaxonApiException {
        return true;//process children
    }

    @Override
    public void processAttribute(XdmNode node) throws SaxonApiException {
        String newValue = computeReplacement(node);
        matcher.addAttribute(node, newValue);
    }

    @Override
    public void processEndElement(XdmNode node) throws SaxonApiException { }

    @Override
    public void processText(XdmNode node) throws SaxonApiException {
        String newValue = computeReplacement(node);
        matcher.addText(newValue);
    }

    @Override
    public void processComment(XdmNode node) throws SaxonApiException {
        String newValue = computeReplacement(node);
        matcher.addText(newValue);}

    @Override
    public void processPI(XdmNode node) throws SaxonApiException {
        String newValue = computeReplacement(node);
        matcher.addText(newValue);
    }

    private class TransformSVGToPNG {

        String substringBeforeLast(String str, String separator) {
            if (isEmpty(str) || isEmpty(separator)) {
                return str;
            }
            int pos = str.lastIndexOf(separator);
            if (pos == -1) {
                return str;
            }
            return str.substring(0, pos);
        }

        boolean isEmpty(String str) {
            return str == null || str.length() == 0;
        }


        boolean transform(String directory, String fileName) {
            //String fileName = "/Users/salmanqureshi/Projects/Rackspace/Dev/batik-1.7/examples/batikYin.svg";
            PNGTranscoder t = new PNGTranscoder();

            // Set the transcoding hints.
            //t.addTranscodingHint(PNGTranscoder., value)
            try {
                String svgURI = new File(directory, fileName).toURI().toString();
                TranscoderInput input = new TranscoderInput(svgURI);

                // Create the transcoder output.
                String pngFileName = directory + substringBeforeLast(fileName, ".svg") + ".png";

                OutputStream ostream = new FileOutputStream(pngFileName);
                TranscoderOutput output = new TranscoderOutput(ostream);

                // Save the image.
                t.transcode(input, output);

                // Flush and close the stream.
                ostream.flush();
                ostream.close();
                return true;
            } catch (Exception e) {
                e.printStackTrace();
            }
            return false;
        }

    }
}


