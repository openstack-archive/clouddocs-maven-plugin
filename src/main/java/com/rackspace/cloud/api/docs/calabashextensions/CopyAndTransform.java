package com.rackspace.cloud.api.docs.calabashextensions;

import com.xmlcalabash.core.XProcConstants;
import com.xmlcalabash.core.XProcException;
import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.model.RuntimeValue;
import com.xmlcalabash.runtime.XAtomicStep;
import com.xmlcalabash.util.TreeWriter;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import org.apache.batik.transcoder.TranscoderInput;
import org.apache.batik.transcoder.TranscoderOutput;
import org.apache.batik.transcoder.image.PNGTranscoder;
import org.apache.maven.plugin.logging.Log;
import org.apache.maven.plugin.logging.SystemStreamLog;

import java.io.*;
import java.net.URI;
import java.util.HashMap;
import java.util.HashSet;


/**
 * Created by IntelliJ IDEA.
 * User: ndw
 * Date: May 24, 2009
 * Time: 3:17:23 PM
 * To change this template use File | Settings | File Templates.
 */
public class CopyAndTransform extends DefaultStep {
    private static HashMap <String, HashSet<String>> processedImagesMap = new HashMap<String, HashSet<String>>();
    private static final QName _href = new QName("href");
    private static final QName _target = new QName("target");
    private static final QName _inputFileName = new QName("inputFileName");
    private static final QName _outputType = new QName("outputType");
    private static final QName _fail_on_error = new QName("fail-on-error");
    private static final int bufsize = 8192;

    private WritablePipe result = null;
    private Log log = null;

    public Log getLog() {
        if (log == null) {
            log = new SystemStreamLog();
        }
        return log;
    }


    /**
     * Creates a new instance of UriInfo
     */
    public CopyAndTransform(XProcRuntime runtime, XAtomicStep step) {
        super(runtime, step);
    }

    public void setOutput(String port, WritablePipe pipe) {
        result = pipe;
    }

    public void reset() {
        result.resetWriter();
    }

    public void run() throws SaxonApiException {

        super.run();

        if (runtime.getSafeMode()) {
            throw XProcException.dynamicError(21);
        }

        boolean failOnError = getOption(_fail_on_error, true);

        RuntimeValue href = getOption(_href);
        URI uri = href.getBaseURI().resolve(href.getString());
//        getLog().info("HREF IS = " + getOption(_href, "something"));
//        getLog().info("############################################################################################################");
        String executionPath = System.getProperty("user.dir") + File.separator;

        String inputFileName = getOption(_inputFileName, "Unknown");
        String outputType = getOption(_outputType, "Unknown");

        HashSet<String> imagesList = processedImagesMap.get(outputType + inputFileName);

        if(imagesList == null)
        {
            imagesList = new HashSet<String>();
            processedImagesMap.put(outputType + inputFileName, imagesList);
        }

//        getLog().info("############################################# MAKE PDF: " + makePdf + "####################################################");


        File file;
        if (!"file".equals(uri.getScheme())) {
            getLog().error("DocBook File: '" + inputFileName + "' - File: '" + uri.getPath() + "' - Problem: Only 'file' scheme URIs are supported by this step!");
            throw new XProcException(step.getNode(), "Only file: scheme URIs are supported by the copy step.");
        } else {
            file = new File(executionPath + uri.getPath());
        }

        if (imagesList.size() > 0 && imagesList.contains(file.getAbsolutePath().toLowerCase())) {
//            getLog().error("DocBook File: '" +inputFileName+ "' - File: '" +uri.getPath()+ "' - Problem: File already processed.");
//            throw new XProcException(step.getNode(), "File already processed: " + file.getAbsolutePath());
            return;
        }

        imagesList.add(file.getAbsolutePath().toLowerCase());

        if (outputType != null && outputType.equalsIgnoreCase("pdf")) {
//            getLog().info("################# PDF {" + imagesList.size() + "} #################");
            checkIfFileExists(uri, inputFileName, file);
        } else if (outputType != null && outputType.equalsIgnoreCase("html")){
//            getLog().info("################# WEB Help {" + imagesList.size() + "} #################");
            checkIfFileExists(uri, inputFileName, file);
            performFileCopy(inputFileName, file);
        }
    }

    private void checkIfFileExists(URI uri, String inputFileName, File file) {
        if (!file.exists()) {
            getLog().error("DocBook File: '" + inputFileName + "' - File: '" + uri.getPath() + "' - Problem: File does not exist!");
            throw new XProcException(step.getNode(), "Cannot copy: file does not exist: " + file.getAbsolutePath());
        }

        if (file.isDirectory()) {
            getLog().error("DocBook File: '" + inputFileName + "' - File: '" + uri.getPath() + "' - Problem: File is a directory!");
            throw new XProcException(step.getNode(), "Cannot copy: file is a directory: " + file.getAbsolutePath());
        }
    }

    private void performFileCopy(String inputFileName, File file) {
        RuntimeValue href;
        URI uri;
        href = getOption(_target);
        uri = href.getBaseURI().resolve(href.getString());
        File target;

        if (!"file".equals(uri.getScheme())) {
            getLog().error("DocBook File: '" + inputFileName + "' - File: '" + uri.getPath() + "' - Problem: Only 'file' scheme URIs are supported by this step!");
            throw new XProcException(step.getNode(), "Only file: scheme URIs are supported by the copy step.");
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
                throw new XProcException(step.getNode(), "Cannot copy: target is a directory: " + target.getAbsolutePath());
            }
        }

        TreeWriter tree = new TreeWriter(runtime);
        tree.startDocument(step.getNode().getBaseURI());
        tree.addStartElement(XProcConstants.c_result);
        tree.startContent();

        tree.addText(target.toURI().toASCIIString());

        try {
            FileInputStream src = new FileInputStream(file);
            FileOutputStream dst = new FileOutputStream(target);
            byte[] buffer = new byte[bufsize];
            int read = src.read(buffer, 0, bufsize);
            while (read >= 0) {
                dst.write(buffer, 0, read);
                read = src.read(buffer, 0, bufsize);
            }
            src.close();
            dst.close();
            //transform SVG file
            String name = file.getName();
            int pos = name.lastIndexOf('.');
            String ext = name.substring(pos + 1);
            if (ext.equalsIgnoreCase("svg")) {
                TransformSVGToPNG t = new TransformSVGToPNG();
                boolean check = t.transform(target.getParent() + File.separator, name);
                if (!check) {
                    getLog().error("DocBook File: '" + inputFileName + "' - File: '" + uri.getPath() + "' - Problem: Could not transform SVG to PNG!");
                    //getLog().error("Could not transform SVG file to PNG:" + name);
                }
            }

        } catch (FileNotFoundException fnfe) {
            throw new XProcException(fnfe);
        } catch (IOException ioe) {
            throw new XProcException(ioe);
        }

        tree.addEndElement();
        tree.endDocument();
        //getLog().info("############################################################################################################");

        result.write(tree.getResult());
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
