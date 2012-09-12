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

		/*

        System.out.println("\n\n\n****************************************************************");
        System.out.println(doc.toString());
        System.out.println("****************************************************************\n\n\n");

        doc.toString().replaceAll(Pattern.quote("file:///Users/somethingthatistotallywrong.svg"), "file:///Users/salmanqureshi/Projects/Rackspace/Dev/compute-api-final/openstack-compute-api-2/target/docbkx/webhelp/api/openstack/2/figures/Arrow_east.svg");
		 */

		return doc;
	}
}