package com.rackspace.cloud.api.docs.calabash.extensions;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.atomic.AtomicInteger;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;

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
	private String inputDocbookName;
	private String outputType;
	private XdmNode stepNode;
	private static final int bufferSize = 8192;
	
	private boolean errorsFound = false;


	private Log log = null;

	public Log getLog() {
		if (log == null) {
			log = new SystemStreamLog();
		}
		return log;
	}

	public CopyTransformImage(String _xpath, URI _targetDirectory, URI _targetHtmlContentDirectoryUri, String _inputDocbookName, String _outputType, XdmNode _step) {
		this.xpath = _xpath;
		this.targetDirectoryUri = _targetDirectory;
		this.targetHtmlContentDirectoryUri = _targetHtmlContentDirectoryUri;
		this.inputDocbookName = _inputDocbookName;
		this.outputType = _outputType;
		this.stepNode = _step;
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

	private File getHandleToImageFile(URI sourceImageUri) {
		File file = null;
		file = new File(sourceImageUri.getPath());
		if (!file.exists()) {
			getLog().error("DocBook File: '" + inputDocbookName + "' - File: '" + sourceImageUri.getPath() + "' - Problem: File does not exist!");
			//throw new XProcException(stepNode, "Cannot copy: file does not exist: " + file.getAbsolutePath());
			return null;
		}

		if (file.isDirectory()) {
			getLog().error("DocBook File: '" + inputDocbookName + "' - File: '" + sourceImageUri.getPath() + "' - Problem: File is a directory!");
			//throw new XProcException(stepNode, "Cannot copy: file is a directory: " + file.getAbsolutePath());
			return null;
		}

		return file;
	}

	private File performFileCopyAndTransformation(URI uri, String inputFileName, File file) {

		File target;

		target = new File(uri.getPath());
		if(!target.exists()) {
			if (target.mkdir() || target.mkdirs()) {
				//do nothing
			}
		}

		if (target.isDirectory()) {
			target = new File(target, file.getName());
			if (target.isDirectory()) {
				getLog().error("DocBook File: '" + inputFileName + "' - File: '" + target.getPath() + "' - Problem: File is a directory!");
				throw new XProcException("Cannot copy: target file is a directory: " + target.getAbsolutePath());
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

			if (ext.equalsIgnoreCase("svg")) {
				TransformSVGToPNG t = new TransformSVGToPNG();
				String convertedFileUri = t.transform(target.getParent() + File.separator, name);
				if (convertedFileUri==null || convertedFileUri.isEmpty()) {
					getLog().error("DocBook File: '" + inputFileName + "' - File: '" + uri.getPath() + "' - Problem: Could not transform SVG to PNG!");
					//getLog().error("Could not transform SVG file to PNG:" + name);
				} 	
			}
		} catch (FileNotFoundException fnfe) {
			throw new XProcException(fnfe);
		} catch (IOException ioe) {
			throw new XProcException(ioe);
		}

		return target;
	}

	private String processSelectedImage(XdmNode imageDataFileRef) {
		final URI baseUri = imageDataFileRef.getBaseURI();
		final String fileRef = imageDataFileRef.getStringValue();
		final URI baseDirUri = baseUri.resolve(".");
		
		String srcImgFilePath = FilenameUtils.normalize(baseDirUri.getPath() + File.separator + fileRef);
		File srcImgFile = getFileHandle(srcImgFilePath);
		
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
				//TODO: check if conversion was successful
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
			return null;
		}
		return new File(targetDir.getAbsolutePath() + File.separator + srcFile.getName());
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
			return false;
		}
	}

	private File makeDirs(String relativePath) {
		//TODO: handle cases where dirPath is path to a file
		File dir = new File(targetDirectoryUri.getPath(), relativePath);
		if (dir.mkdir() || dir.mkdirs()) {
			
		}
		return dir;
	}

	private File getFileHandle(String filePath) {
		// TODO: Handle cases where the filePath refers to a directory
		return new File(filePath);
	}

	private String processSelectedImageOLD(XdmNode node) {
		System.out.println("****** Processing node: " + node.toString() + " --- baseUri="+node.getBaseURI().toString());
		
		String value = node.getStringValue();
		
		if(processedFilesMapForHtmlOutput.containsKey(value)) {
			System.out.println("\n\n*********** already processed **************** "+processedFilesMapForHtmlOutput.get(value));
			return processedFilesMapForHtmlOutput.get(value);
		}

		boolean isSVG = false;
		if(value.contains(".svg") || value.contains(".SVG")) {
			isSVG = true;
		}

		//System.out.println("\n\n*********** processing **************** "+value);
		//if the file hasn't been processed before then ....
		URI sourceImageUri = null;
		try {
			if(isSVG) {
				String executionPath = System.getProperty("user.dir") + File.separator;
				sourceImageUri = new URI(executionPath+"src/"+value);
			} else {
				String filePath = FilenameUtils.normalize("file://"+targetHtmlContentDirectoryUri.getPath() + File.separator + value);
				sourceImageUri = new URI(filePath);
			}
		} catch (URISyntaxException e) {
			throw new XProcException(stepNode, "Unable to get handle to image file",e);
		}
		if(sourceImageUri != null) {
			try {
				//TODO: Need to handle Case Sensitive file name checking.
				//TODO: NTH: Do not print error message while getting handle. For non-SVG images we are checking first in the target and then in the source directory.
				//The error message should be printed after we have made sure that it is not present in both directories.
				File sourceImageFile = getHandleToImageFile(sourceImageUri);

				if(outputType.equals("pdf")) {
					//no further processing required. Already checked if the image exists or not in the above get Image call.
					//System.out.println("*********** found **************** "+sourceImageFile.getAbsolutePath());
					processedFilesMapForHtmlOutput.put(value, sourceImageFile.getAbsolutePath());
				} 
				else if(outputType.equals("html")) {
					System.out.println("****** Entering elseif outputType=='html'");
					//if the output type is html then we need to decide steps based on the image extension
					//if the image is an SVG then transform and save a png in the html target directory
					//if the image is a PNG then make a huge assumption that an SVG was specified in the Docbook before the png
					//and we need to check in the target directory that it is present.
					if(sourceImageFile == null && !isSVG) {

						//Send another call to the getHandleToImageFile but this time check relative to the html content folder.
						try {
							String executionPath = System.getProperty("user.dir") + File.separator;
							sourceImageUri = new URI(executionPath+"src/"+value);
						} catch (URISyntaxException e) {
							throw new XProcException(stepNode, "Unable to get handle to image file",e);
						}
						sourceImageFile = getHandleToImageFile(sourceImageUri);
						if(sourceImageFile != null) {
							System.out.println("****** Case 1");
							File copiedFile = performFileCopyAndTransformation(targetDirectoryUri, inputDocbookName, sourceImageFile);
							String correctRelativePathToImage = RelativePath.getRelativePath(new File(targetHtmlContentDirectoryUri), copiedFile);
							processedFilesMapForHtmlOutput.put(value, correctRelativePathToImage);
						} else {
							//File not found in source and target folders.
						}
					} else if(sourceImageFile != null && !isSVG) {
						System.out.println("****** Case 2: " + sourceImageFile);
						File copiedFile = performFileCopyAndTransformation(targetDirectoryUri, inputDocbookName, sourceImageFile);
						String correctRelativePathToImage = RelativePath.getRelativePath( new File(targetHtmlContentDirectoryUri), copiedFile);
						processedFilesMapForHtmlOutput.put(value, correctRelativePathToImage);
						
					} else if(sourceImageFile != null && isSVG) {
						System.out.println("****** Case 3");
						//There really isn't any need to copy the SVG for html output but it is being done right now. We only care about transforming it to a PNG.
						File copiedFile = performFileCopyAndTransformation(targetDirectoryUri, inputDocbookName, sourceImageFile);
						
						String correctRelativePathToImage = RelativePath.getRelativePath( new File(targetHtmlContentDirectoryUri), copiedFile);
						processedFilesMapForHtmlOutput.put(value, correctRelativePathToImage);
					}

					System.out.println("****** Exiting elseif outputType=='html'");
				}
			} catch (XProcException x) {
				//getLog().error(x.getMessage());
				//do nothing
			}
		}

		return processedFilesMapForHtmlOutput.get(value);
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


		String transform(String directory, String fileName) {
			PNGTranscoder t = new PNGTranscoder();

			// Set the transcoding hints.
			//t.addTranscodingHint(PNGTranscoder., value)
			try {
				String svgURI = new File(directory, fileName).toURI().toString();
				TranscoderInput input = new TranscoderInput(svgURI);

				// Create the transcoder output.
				String pngFileName = directory + substringBeforeLast(fileName, ".svg") + ".png";
				
				File pngFile = new File(pngFileName);
				pngFile.createNewFile();
				
				OutputStream ostream = new FileOutputStream(pngFile);
				TranscoderOutput output = new TranscoderOutput(ostream);

				// Save the image.
				t.transcode(input, output);
				// Flush and close the stream.
				ostream.flush();
				ostream.close();

				return pngFileName;
			} catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}
		
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
			} catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}
	}
}


