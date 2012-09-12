package com.rackspace.cloud.api.docs.calabash.extensions;

import java.io.File;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.HashSet;
import java.util.Set;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;

import org.apache.maven.plugin.logging.Log;
import org.apache.maven.plugin.logging.SystemStreamLog;

import com.xmlcalabash.core.XProcException;
import com.xmlcalabash.core.XProcRuntime;
import com.xmlcalabash.io.ReadablePipe;
import com.xmlcalabash.io.WritablePipe;
import com.xmlcalabash.library.DefaultStep;
import com.xmlcalabash.model.RuntimeValue;
import com.xmlcalabash.runtime.XAtomicStep;
import com.xmlcalabash.util.ProcessMatch;
import com.xmlcalabash.util.ProcessMatchingNodes;

public class CopyAndTransformXProcStep extends DefaultStep {
	private static final QName _target = new QName("target");
	private static final QName _inputFileName = new QName("inputFileName");
	private static final QName _outputType = new QName("outputType");
	private static final QName _fail_on_error = new QName("fail-on-error");

	private ReadablePipe source = null;
	private WritablePipe result = null;
	private ProcessMatch matcher = null;


	private Log log = null;

	public Log getLog()
	{
		if ( log == null )
		{
			log = new SystemStreamLog();
		}

		return log;
	}


	public CopyAndTransformXProcStep(XProcRuntime runtime, XAtomicStep step) {
		super(runtime,step);
	}

	public void setInput(String port, ReadablePipe pipe) {
		source = pipe;
	}

	public void setOutput(String port, WritablePipe pipe) {
		result = pipe;
	}

	public void reset() {
		source.resetReader();
		result.resetWriter();
	}

	public void run() throws SaxonApiException {
		super.run();
		System.out.println("Entering CopyAndTransformXProcStep!!! ");

		XdmNode updatedDoc = makeReplacements (source.read());
		result.write(updatedDoc);

		System.out.println("Leaving CopyAndTransformXProcStep!!! ");
	}

	private URI getTargetDirectoryURI() {
		RuntimeValue target = getOption(_target);
		URI uri = target.getBaseURI().resolve(target.getString());

		return uri;
	}

	private String getInputDocbookName() {
		return getOption(_inputFileName, "Unknown");

	}

	private String getOutputType() {
		return getOption(_outputType, "Unknown");
	}


	private XdmNode makeReplacements(XdmNode doc) {

		CopyTransformImage xpathRepl = new CopyTransformImage("//*:imagedata/@fileref",getTargetDirectoryURI(), getInputDocbookName(), getOutputType(), step.getNode());
		//CopyTransformImage xpathRepl = new CopyTransformImage("//*:imagedata/@fileref[not(. = ../following-sibling::imagedata/@fileref)]");

		matcher = new ProcessMatch(runtime, xpathRepl);
		xpathRepl.setMatcher(matcher);

		matcher.match(doc, new RuntimeValue(xpathRepl.getXPath()));
		doc = matcher.getResult();

		System.out.println("\n\n\n****************************************************************" + step.getNode().getNodeName());
		/*

        System.out.println("\n\n\n****************************************************************");
        System.out.println(doc.toString());
        System.out.println("****************************************************************\n\n\n");

        doc.toString().replaceAll(Pattern.quote("file:///Users/somethingthatistotallywrong.svg"), "file:///Users/salmanqureshi/Projects/Rackspace/Dev/compute-api-final/openstack-compute-api-2/target/docbkx/webhelp/api/openstack/2/figures/Arrow_east.svg");
		 */

		return doc;
	}
}

class CopyTransformImage implements ProcessMatchingNodes  {
	String xpath;
	Set<Replacement> imageSet = new HashSet<Replacement>();
	ProcessMatch matcher;

	URI targetDirectory;
	String inputDocbookName;
	String outputType;
	XdmNode stepNode;

	private Log log = null;
	public Log getLog() {
		if (log == null) {
			log = new SystemStreamLog();
		}
		return log;
	}

	public CopyTransformImage(String _xpath, URI _targetDirectory, String _inputDocbookName, String _outputType, XdmNode _step) {
		this.xpath = _xpath;
		this.targetDirectory = _targetDirectory;
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
}

