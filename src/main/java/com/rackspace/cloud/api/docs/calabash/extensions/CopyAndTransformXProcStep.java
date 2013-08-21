package com.rackspace.cloud.api.docs.calabash.extensions;

import java.io.File;
import java.net.URI;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;

import org.apache.commons.io.FilenameUtils;
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

public class CopyAndTransformXProcStep extends DefaultStep {
	private static final QName _target = new QName("target");
	private static final QName _targetHtmlContentDir = new QName("targetHtmlContentDir");
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

		XdmNode updatedDoc = processInlineImages (source.read());
		result.write(updatedDoc);
	}

	private URI getTargetDirectoryURI() {
		RuntimeValue target = getOption(_target);
		URI uri = null;

		if (target != null) {
			uri = target.getBaseURI().resolve(FilenameUtils.normalizeNoEndSeparator(target.getString()).replace(File.separatorChar, '/'));	
		}
		
		return uri;
	}

	private URI getTargetHtmlContentDirectoryURI() {
		RuntimeValue target = getOption(_targetHtmlContentDir);
		URI uri = null;
		if (target != null) {
			uri = target.getBaseURI().resolve(target.getString().replace(File.separatorChar, '/'));
		}
		return uri;
	}

	private String getOutputType() {
		return getOption(_outputType, "Unknown");
	}
	
	private boolean isFailOnErrorFlagSet() {
		return getOption(_fail_on_error, true);
	}


	private XdmNode processInlineImages(XdmNode doc) {
		String fileRefsXpath = "//*:imagedata/@fileref";
		CopyTransformImage copyTransform = 
				new CopyTransformImage(	fileRefsXpath,
										getTargetDirectoryURI(),
										getTargetHtmlContentDirectoryURI(),
										getOutputType());

		matcher = new ProcessMatch(runtime, copyTransform);
		copyTransform.setMatcher(matcher);

		matcher.match(doc, new RuntimeValue(fileRefsXpath));
		doc = matcher.getResult();
		
		if (copyTransform.hasErrors() && isFailOnErrorFlagSet()) {
			throw new XProcException("One or more images refered in the docbook were not found. Please see log for details.");
		}
		
		return doc;
	}
}