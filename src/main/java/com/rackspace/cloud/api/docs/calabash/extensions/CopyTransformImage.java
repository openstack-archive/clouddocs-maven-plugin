package com.rackspace.cloud.api.docs.calabash.extensions;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URI;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.atomic.AtomicInteger;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;

import org.apache.batik.transcoder.TranscoderException;
import org.apache.batik.transcoder.TranscoderInput;
import org.apache.batik.transcoder.TranscoderOutput;
import org.apache.batik.transcoder.image.PNGTranscoder;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.maven.plugin.logging.Log;
import org.apache.maven.plugin.logging.SystemStreamLog;

import com.rackspace.cloud.api.docs.calabash.extensions.util.RelativePath;
import com.xmlcalabash.core.XProcException;
import com.xmlcalabash.util.ProcessMatch;
import com.xmlcalabash.util.ProcessMatchingNodes;

/**
 * Created with IntelliJ IDEA.
 * User: ykamran
 * Date: 9/12/12
 * Time: 6:29 PM
 * To change this template use File | Settings | File Templates.
 */

public class CopyTransformImage implements ProcessMatchingNodes {
	private String xpath;
	private Map<String, String> baseUriToDirMap = new HashMap<String, String>();
	private AtomicInteger simpleUniqueNumberGenerator = new AtomicInteger();
	private Map<String, String> processedFilesMapForHtmlOutput = new HashMap<String, String>();
	private Set<String> processedFilesSetForPdfOutput = new HashSet<String>(); 
	private ProcessMatch matcher;

	private URI targetDirectoryUri;
	private URI targetHtmlContentDirectoryUri;
	private String outputType;
	
	private boolean errorsFound = false;


	private Log log = null;

	public Log getLog() {
		if (log == null) {
			log = new SystemStreamLog();
		}
		return log;
	}

	public CopyTransformImage(String _xpath, URI _targetDirectory, URI _targetHtmlContentDirectoryUri, String _outputType) {
		this.xpath = _xpath;
		this.targetDirectoryUri = _targetDirectory;
		this.targetHtmlContentDirectoryUri = _targetHtmlContentDirectoryUri;
		this.outputType = _outputType;
	}
	
	public boolean hasErrors() {
		return errorsFound;
	}

	public String getXPath() {
		return xpath;
	}

	public void setMatcher (ProcessMatch matcher) {
		this.matcher = matcher;
	}

	private String processSelectedImage(XdmNode imageDataFileRef) {
		final URI baseUri = imageDataFileRef.getBaseURI();
		final String fileRef = imageDataFileRef.getStringValue();
		final URI baseDirUri = baseUri.resolve(".");
		
		String srcImgFilePath = FilenameUtils.normalize(baseDirUri.getPath() + File.separator + fileRef);
		File srcImgFile = getFileHandle(srcImgFilePath.trim());
		
		if (fileRef.toLowerCase().startsWith("http://") ||
			fileRef.toLowerCase().startsWith("https://")) {
			getLog().warn("Found reference to an external image " + fileRef + " in " + baseUri.getPath());
			return fileRef;
		} 
		else if (outputType.equals("pdf")) {
			//Need to check only for the existence of the image file
			if (this.processedFilesSetForPdfOutput.contains(srcImgFilePath)) {
				//do nothing as any errors for missing files would already have been reported
			}
			else if (isImageForHtmlOnly(imageDataFileRef.getParent())) {
				//ignore this imagedata
			}
			else if (! fileExists(srcImgFile)) {
				reportImageNotFoundError(baseUri, fileRef, srcImgFile);
			}
			this.processedFilesSetForPdfOutput.add(srcImgFilePath);
			//For pdf output always return the input fileRef
			return fileRef;
		}
		else if (outputType.equals("html")) {
			//check if we have already copied this particular image to webhelp folder
			if (this.processedFilesMapForHtmlOutput.containsKey(srcImgFilePath)) {
				return this.processedFilesMapForHtmlOutput.get(srcImgFilePath);
			}

			String targetDirPath = calculateTargetDirPath(baseUri.getPath(), fileRef);
			File targetDir = makeDirs(targetDirPath);
			String relativePathToCopiedFile;
			
			//For HTML, we need a more elaborate check for missing images
			if (isImageForPdfOnly(imageDataFileRef.getParent())) {
				//ignore this imagedata
				relativePathToCopiedFile = fileRef;
			}
			else if (! fileExists(srcImgFile)) {
				reportImageNotFoundError(baseUri, fileRef, srcImgFile);
				relativePathToCopiedFile = fileRef;
			}
			else if ("svg".equalsIgnoreCase(FilenameUtils.getExtension(srcImgFilePath))) {
				//convert the svg to the relevant type and copy
				File svgFile = getFileHandle(srcImgFilePath);
				File copiedFile = new TransformSVGToPNG().transformAndCopy(svgFile, targetDir);
				relativePathToCopiedFile = RelativePath.getRelativePath(new File(targetHtmlContentDirectoryUri), copiedFile);
			}
			else {
				//simply copy the src file to the destination
				File copiedFile = copyFile(srcImgFile, targetDir);
				relativePathToCopiedFile = RelativePath.getRelativePath(new File(targetHtmlContentDirectoryUri), copiedFile);
			}
			this.processedFilesMapForHtmlOutput.put(srcImgFilePath, relativePathToCopiedFile);
			return relativePathToCopiedFile;
		}
		else {
			//we only know how to handle "pdf" and "html" outputTypes so just return the value
			return fileRef;
		}
	}
	
	private boolean isImageForHtmlOnly(XdmNode imageDataNode) {
		return parentRoleEquals(imageDataNode, "html"); 
	}
	
	private boolean isImageForPdfOnly(XdmNode imageDataNode) {
		return parentRoleEquals(imageDataNode, "fo") || parentRoleEquals(imageDataNode, "pdf"); 
	}
	
	private boolean parentRoleEquals(XdmNode node, String role) {
		XdmNode parent = node.getParent();
		String parentRole = (parent==null ? null : parent.getAttributeValue(new QName("role")));
		if (parentRole != null &&
			parentRole.equalsIgnoreCase(role)) {
			return true;
		}
		return false;
	}

	private String calculateTargetDirPath(String baseUriPath, String fileRef) {
		String targetDirForBaseUri = null;
		if (this.baseUriToDirMap.containsKey(baseUriPath)) {
			targetDirForBaseUri = this.baseUriToDirMap.get(baseUriPath);
		} else {
			targetDirForBaseUri = "" + this.simpleUniqueNumberGenerator.incrementAndGet();
			this.baseUriToDirMap.put(baseUriPath, targetDirForBaseUri);
		}
		
		String targetDirForFileRef = FilenameUtils.getPathNoEndSeparator(fileRef.replaceAll("\\.\\.", "a"));
		return (targetDirForBaseUri + File.separator + targetDirForFileRef);
	}

	private File copyFile(File srcFile, File targetDir) {
		try {
			FileUtils.copyFileToDirectory(srcFile, targetDir);
		} catch (IOException e) {
			getLog().error("Unable to copy file: " + srcFile.getAbsolutePath() + " to " + targetDir.getAbsolutePath());
			throw new XProcException(e);
		}
		return new File(targetDir.getAbsolutePath(), srcFile.getName());
	}

	private void reportImageNotFoundError(URI baseUri, String fileRef, File srcImgFile) {
		getLog().error(	"File not found: '" + srcImgFile + "'. " +
						"File is referred in '" + baseUri.getPath() + "' fileRef='" + fileRef + "'.");
		this.errorsFound = true; 
	}

	private boolean fileExists(File file) {
		try {
			return file==null ? false : file.exists() &&  file.getCanonicalPath().endsWith(file.getName());
		} catch (IOException e) {
			getLog().error("Unable to access file: " + file.getAbsolutePath());
			return false;
		}
	}

	private File makeDirs(String relativePath) {
		File dir = new File(targetDirectoryUri.getPath(), relativePath);
		if (dir.exists() || dir.mkdir() || dir.mkdirs()) {
			return dir;
		} else {
			getLog().error("Unable to create directory: " + dir.getAbsolutePath());
			return null;
		}
	}

	private File getFileHandle(String filePath) {
		File handle = new File(filePath);
		return (handle.isDirectory() ? null : handle);
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
		String newValue = processSelectedImage(node);
		matcher.addAttribute(node, newValue);
	}

	@Override
	public void processEndElement(XdmNode node) throws SaxonApiException { }

	@Override
	public void processText(XdmNode node) throws SaxonApiException {
		String newValue = processSelectedImage(node);
		matcher.addText(newValue);
	}

	@Override
	public void processComment(XdmNode node) throws SaxonApiException {
		String newValue = processSelectedImage(node);
		matcher.addText(newValue);}

	@Override
	public void processPI(XdmNode node) throws SaxonApiException {
		String newValue = processSelectedImage(node);
		matcher.addText(newValue);
	}

	private class TransformSVGToPNG {

		File transformAndCopy(File svgFile, File targetDir) {
			String pngFileName = FilenameUtils.getBaseName(svgFile.getPath()) + ".png";
			File pngFile = new File(targetDir, pngFileName);
			PNGTranscoder t = new PNGTranscoder();
			
			try {
				TranscoderInput input = new TranscoderInput(svgFile.toURI().toString());
				pngFile.createNewFile();
				
				OutputStream ostream = new FileOutputStream(pngFile);
				TranscoderOutput output = new TranscoderOutput(ostream);
				
				t.transcode(input, output);
				ostream.flush();
				ostream.close();
				
				return pngFile;
			} catch (IOException e) {
				getLog().error("An error occured while transforming " + svgFile.getAbsolutePath() + " to " + pngFile.getAbsolutePath());
				throw new XProcException(e);
			} catch (TranscoderException e) {
				getLog().error("Unable to convert " + svgFile.getAbsolutePath() + " to png");
				throw new XProcException(e);
			}
		}
	}
}


