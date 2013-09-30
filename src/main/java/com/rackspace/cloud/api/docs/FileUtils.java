package com.rackspace.cloud.api.docs;

import java.io.InputStream;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.FileOutputStream;
import java.io.File;

import java.util.Enumeration;
import java.util.zip.ZipFile;
import java.util.zip.ZipEntry;

import org.apache.maven.plugin.MojoExecutionException;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.zip.ZipException;
import java.util.zip.ZipOutputStream;



public class FileUtils {


    public static void addDirectory(ZipOutputStream zout, File fileSource) {
	int fileSourceNameLength = fileSource.toString().length() + 1; 	
	addDirectory(zout, fileSource, fileSourceNameLength );
    }

    private static void addDirectory(ZipOutputStream zout, File fileSource, int fileSourceNameLength) {
	// Adapted from:
	// http://www.java-examples.com/create-zip-file-directory-recursively-using-zipoutputstream-example
	//get sub-folder/files list
	File[] files = fileSource.listFiles();
               
	//System.out.println("Adding directory " + fileSource.getName());
               
	for(int i=0; i < files.length; i++)
	    {
		//if the file is directory, call the function recursively
		if(files[i].isDirectory())
		    {
			addDirectory(zout, files[i], fileSourceNameLength);
			continue;
		    }
                       
		/*
		 * we are here means, its file and not directory, so
		 * add it to the zip file
		 */
                       
		try
		    {
			//System.out.println("Adding file " + files[i].getName());
                               
			//create byte buffer
			byte[] buffer = new byte[1024];
                               
			//create object of FileInputStream
			FileInputStream fin = new FileInputStream(files[i]);
                            
			String parentPath = "";
			if(fileSource.toString().length() > fileSourceNameLength){
			    parentPath = fileSource.toString().substring(fileSourceNameLength) + "/";
			}

			zout.putNextEntry(new ZipEntry(parentPath + files[i].getName()));
                         
			/*
			 * After creating entry in the zip file, actually
			 * write the file.
			 */
			int length;
                         
			while((length = fin.read(buffer)) > 0)
			    {
				zout.write(buffer, 0, length);
			    }
                         
			/*
			 * After writing the file to ZipOutputStream, use
			 *
			 * void closeEntry() method of ZipOutputStream class to
			 * close the current entry and position the stream to
			 * write the next entry.
			 */
                         
			zout.closeEntry();
                         
			//close the InputStream
			fin.close();
                       
		    }
		catch(IOException ioe)
		    {
			System.out.println("IOException :" + ioe);                             
		    }
	    }
               
    }
 


    public static void mkdir (File directory)
    throws MojoExecutionException {
        try {
            directory.mkdirs();
        }catch (Exception e) {
            e.printStackTrace();
            throw new MojoExecutionException ("Error Creating Directory "+e);
        }
    }

    public static void extractJaredDirectory (String directory, Class<?> jarSrc,
                                              File dest)
        throws MojoExecutionException {
        try {
            File jar = new File (jarSrc.getProtectionDomain().getCodeSource().getLocation().getFile());

            ZipFile zf = new ZipFile (jar);
            Enumeration<? extends ZipEntry> entries = zf.entries();
            while (entries.hasMoreElements()) {
                ZipEntry ze = entries.nextElement();
                if (ze.getName().startsWith(directory)) {
                    if (ze.isDirectory()) {
                        File newDir = new File (dest, ze.getName());
                        newDir.mkdirs();
                    } else {
                        File outFile = new File (dest, ze.getName());
                        BufferedInputStream   in = new BufferedInputStream (zf.getInputStream (ze));
                        BufferedOutputStream out = new BufferedOutputStream (new FileOutputStream (outFile));

                        int read;
                        while ((read = in.read()) != -1) {
                            out.write (read);
                        }

                        in.close();
                        out.close();
                    }
                }
            }
            zf.close();
        }catch (Exception e) {
            e.printStackTrace();
            throw new MojoExecutionException("Error while extracting jar files: "+e);
        }
    }
}


