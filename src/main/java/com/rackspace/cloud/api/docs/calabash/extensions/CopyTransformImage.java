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
import java.util.Map;
import java.util.Set;

import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;

import org.apache.batik.transcoder.TranscoderInput;
import org.apache.batik.transcoder.TranscoderOutput;
import org.apache.batik.transcoder.image.PNGTranscoder;
import org.apache.commons.io.FilenameUtils;
import org.apache.maven.plugin.logging.Log;
import org.apache.maven.plugin.logging.SystemStreamLog;

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
	private Map<String, String> imageMap = new HashMap<String, String>();
	private ProcessMatch matcher;

	private URI targetDirectoryUri;
	private URI targetHtmlContentDirectoryUri;
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

	public CopyTransformImage(String _xpath, URI _targetDirectory, URI _targetHtmlContentDirectoryUri, String _inputDocbookName, String _outputType, XdmNode _step) {
		this.xpath = _xpath;
		this.targetDirectoryUri = _targetDirectory;
		this.targetHtmlContentDirectoryUri = _targetHtmlContentDirectoryUri;
		this.inputDocbookName = _inputDocbookName;
		this.outputType = _outputType;
		this.stepNode = _step;
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
		}

		if (file.isDirectory()) {
			getLog().error("DocBook File: '" + inputDocbookName + "' - File: '" + sourceImageUri.getPath() + "' - Problem: File is a directory!");
			//throw new XProcException(stepNode, "Cannot copy: file is a directory: " + file.getAbsolutePath());
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

	private String processSelectedImage(XdmNode node) {
		
		String value = node.getStringValue();
		
		if(imageMap.containsKey(value)) {
			//System.out.println("\n\n*********** already processed **************** "+imageMap.get(value));
			return imageMap.get(value);
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
					imageMap.put(value, sourceImageFile.getAbsolutePath());
				} 
				else if(outputType.equals("html")) {
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

							File copiedFile = performFileCopyAndTransformation(targetDirectoryUri, inputDocbookName, sourceImageFile);
							String correctRelativePathToImage = RelativePath.getRelativePath(new File(targetHtmlContentDirectoryUri), copiedFile);
							imageMap.put(value, correctRelativePathToImage);
						} else {
							//File not found in source and target folders.
						}
					} else if(sourceImageFile != null && !isSVG) {
						String correctRelativePathToImage = RelativePath.getRelativePath( new File(targetHtmlContentDirectoryUri), sourceImageFile);
						imageMap.put(value, correctRelativePathToImage);
						
					} else if(sourceImageFile != null && isSVG) {
						//There really isn't any need to copy the SVG for html output but it is being done right now. We only care about transforming it to a PNG.
						File copiedFile = performFileCopyAndTransformation(targetDirectoryUri, inputDocbookName, sourceImageFile);
						
						String correctRelativePathToImage = RelativePath.getRelativePath( new File(targetHtmlContentDirectoryUri), copiedFile);
						imageMap.put(value, correctRelativePathToImage);
					} 
				}
			} catch (XProcException x) {
				//getLog().error(x.getMessage());
				//do nothing
			}
		}

		return imageMap.get(value);
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

	}
}


